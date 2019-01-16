module alu (
    input  logic [15:0] IR, SR1_OUT, SR2_OUT,
    input  logic [1:0]  ALUK,
    input  logic        SR2MUX,
    output logic [15:0] ALU
    );

    logic [15:0] A, B;

    always_comb begin
        A = SR1_OUT;
        B = SR2MUX ? {{11{IR[4]}}, IR[4:0]} : SR2_OUT;
        unique case (ALUK)
            2'b00: ALU = A + B;
            2'b01: ALU = A & B;
            2'b10: ALU = ~A;
            2'b11: ALU = A;
        endcase
    end

endmodule // alu
