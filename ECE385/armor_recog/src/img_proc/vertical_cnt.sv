/* custom shift register */
module shift_reg_8 # (BUFF_LENGTH=320) (
    input  logic        iCLK,
    input  logic        iRESET,
    input  logic [7:0]  iDATA,
    output logic [7:0]  oDATA
);

    logic [BUFF_LENGTH-1:0][7:0] buffer;
    
    assign oDATA = buffer[0];

    always_ff @ (posedge iCLK or posedge iRESET) begin
        if (iRESET)
            buffer <= {BUFF_LENGTH{8'b0}};
        else
            buffer = {iDATA, buffer[BUFF_LENGTH-1:1]};
    end

endmodule

module vertical_cnt (
    input  logic        iCLK,
    input  logic        iRESET,
    input  logic [7:0]  iDATA,
    output logic [16:0] oADDR,
    output logic [7:0]  oDATA
);
    /* shift register related */
    logic [7:0] prev;
    logic [7:0] buff_in;
    shift_reg_8 vbuff(.iCLK, .iRESET, .iDATA(buff_in), .oDATA(prev));

    /* state machine */
    enum logic { PREFILL, VALID } state, state_next;
    logic [16:0] mADDR;

    parameter THRESHOLD = 8'd50; // binarization threshold
    parameter MAX_ADDR  = 17'd76800; // = 320 * 240
    parameter BUFF_LEN  = 320;

    always_comb begin
        /* output signal */
        case (state)
            PREFILL: begin
                oDATA   = 8'b0;
                buff_in = 8'b0; 
            end
            VALID: begin
                if (iDATA > THRESHOLD)
                    oDATA = prev + 8'b1;    
                else
                    oDATA = 8'b0;
                buff_in = oDATA;
            end
        endcase

        /* state transition */
        mADDR       = oADDR;
        state_next  = state;
        case (state)
            PREFILL: begin
                mADDR = oADDR - 17'b1;
                if (oADDR == MAX_ADDR - BUFF_LEN) // = 320 * 240 - 320
                    state_next = VALID;
            end
            VALID: begin
                mADDR = oADDR - 17'b1;
                if (oADDR == 17'b0) begin
                    state_next  = PREFILL;
                    mADDR       = MAX_ADDR - 17'd1;
                end
            end
        endcase
    end

    always_ff @ (posedge iCLK or posedge iRESET) begin
        if (iRESET) begin
            state   <= PREFILL;
            oADDR   <= MAX_ADDR - 17'd1; // last address = 320 * 240 - 1
        end else begin
            state   <= state_next;
            oADDR   <= mADDR;
        end
    end
endmodule

module vertical_cnt_bridge (
    input  logic        iCLK,
    input  logic        iRESET,
    input  logic [7:0]  iDATA,
    output logic [16:0] oRDADDR,
    output logic [16:0] oWRADDR,
    output logic        oWREN,
    output logic [7:0]  oDATA
);
    logic [16:0] oADDR;
    vertical_cnt vc(.*);

    assign oWRADDR = oADDR;
    assign oRDADDR = oADDR;
    assign oWREN   = 1'b1;

endmodule
