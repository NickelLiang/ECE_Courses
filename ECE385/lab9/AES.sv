/************************************************************************
AES Decryption Core Logic

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department
************************************************************************/

module AddRoundKey(
    input  logic [127:0] in,
    output logic [127:0] out,
    input  logic [3:0] round,
    input  logic [1407:0] KeySchedule
);
    logic [127:0] key;

    always_comb begin
        key = 127'd0;
        unique case (round)
            4'd0 : key = KeySchedule[127:0];
            4'd1 : key = KeySchedule[255:128];
            4'd2 : key = KeySchedule[383:256];
            4'd3 : key = KeySchedule[511:384];
            4'd4 : key = KeySchedule[639:512];
            4'd5 : key = KeySchedule[767:640];
            4'd6 : key = KeySchedule[895:768];
            4'd7 : key = KeySchedule[1023:896];
            4'd8 : key = KeySchedule[1151:1024];
            4'd9 : key = KeySchedule[1279:1152];
            4'd10: key = KeySchedule[1407:1280];
        endcase
        out = in ^ key;
    end

endmodule

module AES (
    input  logic CLK,
    input  logic RESET,
    input  logic AES_START,
    output logic AES_DONE,
    input  logic [127:0] AES_KEY,
    input  logic [127:0] AES_MSG_ENC,
    output logic [127:0] AES_MSG_DEC
);

    logic [1407:0]  KeySchedule;

    enum logic [3:0] { START, ISR, ISB, ARK, IMC1, IMC2, IMC3, IMC4, END } state, state_next;
    logic [3:0] round, round_next;
    logic [31:0] imc_in, imc_out;
    logic [127:0] AES_MSG_DEC_next;
    logic [127:0] isr_out, isb_out, ark_out;

    KeyExpansion keyexp(.clk(CLK), .Cipherkey(AES_KEY), .KeySchedule);
    InvShiftRows invsr(.data_in(AES_MSG_DEC), .data_out(isr_out));
    InvSubBytes invsb[15:0](.clk(CLK), .in(AES_MSG_DEC), .out(isb_out));
    InvMixColumns invmc(.in(imc_in), .out(imc_out));
    AddRoundKey addrk(.in(AES_MSG_DEC), .out(ark_out), .round, .KeySchedule);

    always_ff @ (posedge CLK) begin
        if (RESET) begin
            state       <= START;
            round       <= 4'h0;
            AES_MSG_DEC <= AES_MSG_ENC;
        end
        else begin
            state       <= state_next;
            round       <= round_next;
            AES_MSG_DEC <= AES_MSG_DEC_next;
        end
    end

    always_comb begin
        AES_DONE    = 1'b0;
        state_next  = state;
        round_next  = round;
        AES_MSG_DEC_next = AES_MSG_DEC;

        imc_in  = 32'd0;

        unique case (state)
            START:
            begin
                round_next          = 4'h0;
                AES_MSG_DEC_next    = AES_MSG_ENC;
                if (AES_START)
                    state_next = ARK;
            end

            ISR:
            begin
                state_next  = ISB;
                round_next  = round + 1;
                AES_MSG_DEC_next = isr_out;
            end

            ISB:
            begin
                state_next = ARK;
                AES_MSG_DEC_next = isb_out;
            end

            ARK:
            begin
                if (round == 4'h0)
                    state_next = ISR;
                else if (round == 4'ha)
                    state_next = END;
                else
                    state_next = IMC1;
                AES_MSG_DEC_next = ark_out;
            end

            IMC1:
            begin
                state_next  = IMC2;
                imc_in = AES_MSG_DEC[127:96];
                AES_MSG_DEC_next[127:96] = imc_out;
            end

            IMC2:
            begin
                state_next  = IMC3;
                imc_in = AES_MSG_DEC[95:64];
                AES_MSG_DEC_next[95:64] = imc_out;
            end

            IMC3:
            begin
                state_next  = IMC4;
                imc_in = AES_MSG_DEC[63:32];
                AES_MSG_DEC_next[63:32] = imc_out;
            end

            IMC4:
            begin
                state_next  = ISR;
                imc_in = AES_MSG_DEC[31:0];
                AES_MSG_DEC_next[31:0] = imc_out;
            end

            END:
            begin
                AES_DONE = 1'b1;
                if (!AES_START)
                    state_next = START;
            end
        endcase
    end

endmodule
