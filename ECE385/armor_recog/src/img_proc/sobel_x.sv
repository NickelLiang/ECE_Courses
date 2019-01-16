module max_2 # (BITWIDTH=8) (
    input  logic [BITWIDTH-1:0] iA, iB,
    output logic [BITWIDTH-1:0] oMAX
);
    assign oMAX = (iA > iB) ? iA : iB;
endmodule

module max_4 # (BITWIDTH=8) (
    input  logic [BITWIDTH-1:0] iA, iB, iC, iD,
    output logic [BITWIDTH-1:0] oMAX
);
    logic [BITWIDTH-1:0] max1, max2;
    max_2 #(BITWIDTH) max_2_1(.iA(iA), .iB(iB), .oMAX(max1));
    max_2 #(BITWIDTH) max_2_2(.iA(iC), .iB(iD), .oMAX(max2));

    assign oMAX = (max1 > max2) ? max1 : max2;
endmodule

module dilate_4 (
    input  logic        iCLK,
    input  logic        iRESET,
    input  logic [7:0]  iDATA,
    output logic [7:0]  oDATA
);
    logic [2:0][7:0] buffer;
    
    max_4 m4(.iA(iDATA), .iB(buffer[2]), .iC(buffer[1]), .iD(buffer[0]), .oMAX(oDATA));

    always_ff @ (posedge iCLK or posedge iRESET) begin
        if (iRESET)
            buffer <= 24'd0;
        else
            buffer <= { iDATA, buffer[2:1] };
    end
endmodule

module sobel_x (
    input  logic        iCLK,
    input  logic        iRESET,
    input  logic [7:0]  iDATA,
    output logic [16:0] oRDADDR,
    output logic        oDVAL,
    output logic [9:0]  oX,
    output logic [9:0]  oY,
    output logic [7:0]  oDATA
    );
    /* tap3x line buffer */
    logic [7:0] sbb_shiftin;
    logic [7:0] sbb [7];
    sobel_buffer sbbuff(
        .clken(1'b1),
        .clock(iCLK),
        .shiftin(sbb_shiftin),
        .shiftout(),
        .taps0x(sbb[0]),
        .taps1x(sbb[1]),
        .taps2x(sbb[2]),
        .taps3x(sbb[3]),
        .taps4x(sbb[4]),
        .taps5x(sbb[5]),
        .taps6x(sbb[6])
    );

    /* Sobel MAC operators */
    logic [11:0]        mac_result [7];
    logic [13:0]        mac_sum;
    parameter col1 = { 4'd2, 4'd4, 4'd6, 4'd7, 4'd6, 4'd4, 4'd2 };
    parameter col2 = 28'd0;
    parameter col3 = { -4'd2, -4'd4, -4'd6, -4'd7, -4'd6, -4'd4, -4'd2 };
    MAC_3 mac[7] (
        .aclr3(iRESET),
        .clock0(iCLK),
        .dataa_0(sbb),
        .datab_0(col1),
        .datab_1(col2),
        .datab_2(col3),
        .ena0(1'b1),
        .result(mac_result)
    );
    sobel_add sba (
        .data0x(mac_result[0]),
        .data1x(mac_result[1]),
        .data2x(mac_result[2]),
        .data3x(mac_result[3]),
        .data4x(mac_result[4]),
        .data5x(mac_result[5]),
        .data6x(mac_result[6]),
        .result(mac_sum)
    );
    /* length-7 low pass filter */
    logic [7:0] ftDATA;
    Lowpass_Filter lpf(
        .clk(iCLK),
        .reset_n(~iRESET),
        .ast_sink_data({1'b0, iDATA}),
        .ast_sink_valid(1'b1),
        .ast_sink_error(),
        .ast_source_data(ftDATA),
        .ast_source_valid(),
        .ast_source_error()
    );
    /* dilation oprators */
    logic [7:0] dtDATA;
    dilate_4 dt4(
        .iCLK,
        .iRESET,
        .iDATA(dtDATA),
        .oDATA
    );

    enum logic [1:0] {FILTER, PREFILL, VALID, POSTCLEAR} curr, next;

    parameter MARGIN_SIZE   = 1282; // == 320 * 4 + 2;
    parameter MAX_ADDR      = 76800; // == 320 * 240
    parameter WIDTH         = 320;
    parameter HEIGHT        = 240;
    parameter FT_DELAY      = 11; // some magic delay

    logic [16:0] mRDADDR;
    logic [9:0] xcnt, ycnt;
    logic       mDVAL;

    always_comb begin
        /* output signal */
        sbb_shiftin = 8'b0;
        dtDATA       = 8'b0;
        mDVAL       = 1'b0;
        case (curr)
            FILTER: ; // does not need to provide output signal for filter module
            PREFILL:
                sbb_shiftin = ftDATA;
            VALID: begin
                sbb_shiftin = ftDATA;
                mDVAL       = 1'b1;
                /* ReLU & Saturate the MSB */
                if (xcnt != 10'd0 && xcnt != WIDTH - 10'd1 && ycnt > 10'd2 && ycnt < HEIGHT - 10'd3) begin
                    if (mac_sum[13])
                        dtDATA = 8'd0;
                    else if (mac_sum[12])
                        dtDATA = 8'd255;
                    else
                        dtDATA = mac_sum[11:4];
                end
            end
            POSTCLEAR: begin
                mDVAL       = 1'b1;
                if (xcnt != 10'd0 && xcnt != WIDTH - 10'd1 && ycnt > 10'd2 && ycnt < HEIGHT - 10'd3) begin
                    if (mac_sum[13])
                        dtDATA = 8'd0;
                    else if (mac_sum[12])
                        dtDATA = 8'd255;
                    else
                        dtDATA = mac_sum[11:4];
                end
            end
        endcase

        /* state transition */
        next        = curr;
        mRDADDR     = oRDADDR;
        xcnt        = oX;
        ycnt        = oY;
        case (curr)
            FILTER: begin
                mRDADDR     = oRDADDR + 17'b1;
                if (mRDADDR == FT_DELAY)
                    next = PREFILL;
            end
            PREFILL: begin
                mRDADDR = oRDADDR + 17'b1;
                if (mRDADDR == MARGIN_SIZE + FT_DELAY) begin
                    xcnt = 10'b0;
                    ycnt = 10'b0;
                    next = VALID;
                end
            end
            VALID: begin
                mRDADDR = oRDADDR + 17'b1;
                if (mRDADDR == MAX_ADDR) begin
                    mRDADDR = 17'b0;
                    next = POSTCLEAR;
                end
                xcnt = oX + 10'b1;
                if (xcnt == WIDTH) begin
                    xcnt = 10'b0;
                    ycnt = oY + 10'b1;
                end
            end
            POSTCLEAR: begin
                xcnt = oX + 10'b1;
                if (xcnt == WIDTH) begin
                    xcnt = 10'b0;
                    ycnt = oY + 10'b1;
                    if (ycnt == HEIGHT) begin
                        ycnt = 10'b0;
                        next = FILTER;
                    end
                end
            end
        endcase
    end

    always_ff @ (posedge iCLK or posedge iRESET) begin: STATE_TRANSITION
        if (iRESET) begin
            oX      <= 1'b0;
            oY      <= 1'b0;
            curr    <= FILTER;
            oRDADDR <= 17'b0;
            oDVAL   <= 1'b0;
        end else begin
            curr    <= next;
            oX      <= xcnt;
            oY      <= ycnt;
            oRDADDR <= mRDADDR;
            oDVAL   <= mDVAL;
        end
    end

endmodule

module sobel_x_bridge (
    input  logic        iCLK,
    input  logic        iRESET,
    input  logic [7:0]  iDATA,
    output logic [16:0] oRDADDR,
    output logic        oWREN,
    output logic [16:0] oWRADDR,
    output logic [7:0]  oDATA
    );
    logic [9:0] oX, oY;
    sobel_x sobel_x(.oDVAL(oWREN), .*);

    parameter WIDTH = 17'd320;

    assign oWRADDR = oY * WIDTH + oX;
endmodule
