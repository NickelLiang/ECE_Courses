module RB2GRAY(
    input  logic [9:0]  iRED,
    input  logic [9:0]  iBLUE,
    output logic [7:0]  oGRAY
    );
    logic [10:0] sum;
    assign sum      = iRED + iBLUE;
    assign oGRAY    = sum[10:3];
endmodule

module downsample (
    input  logic        iCLK,
    input  logic        iRESET,
    input  logic [9:0]  iRED,
    input  logic [9:0]  iGREEN,
    input  logic [9:0]  iBLUE,
    output logic [16:0] oADDR,
    output logic        oWREN,
    output logic [7:0]  oDATA,
    output logic [7:0]  oDATA_R,
    output logic [7:0]  oDATA_G,
    output logic [7:0]  oDATA_B,
    output logic        oREAD
    );
    logic [16:0] addrcnt;
    logic [9:0] xcnt;
    logic [8:0] ycnt;

    /* GRAY = (R + B ) / 2*/
    RB2GRAY rb2g(.iRED, .iBLUE, .oGRAY(oDATA));

    parameter max_addr  = 76800;
    parameter width     = 640;
    parameter height    = 480;

    enum logic {PRE, ONGOING} state;

    assign oWREN = ~(xcnt[0] | ycnt[0]);
    assign oADDR = addrcnt;
    assign oDATA_R = iRED[9:2];
    assign oDATA_G = iGREEN[9:2];
    assign oDATA_B = iBLUE[9:2];

    always_ff @ (posedge iCLK or posedge iRESET) begin
        if (iRESET) begin
            addrcnt <= 17'b0;
            xcnt    <= 10'b0;
            ycnt    <= 9'b0;
            oREAD   <= 1'b0;
            state   <= PRE;
        end else begin
            case (state)
                PRE: begin // initialization after reset
                    oREAD <= 1'b1;
                    state <= ONGOING;
                end
                ONGOING: begin
                    oREAD   <= 1'b1;
                    if (oWREN) begin
                        if (addrcnt < max_addr - 1)
                            addrcnt <= addrcnt + 17'd1;
                        else
                            addrcnt <= 0;
                    end
                    if (xcnt < width - 1)
                        xcnt <= xcnt + 10'd1;
                    else begin
                        xcnt <= 10'd0;
                        if (ycnt < height - 1)
                            ycnt <= ycnt + 9'd1;
                        else
                            ycnt <= 0;
                    end
                end
            endcase
        end
    end
endmodule
