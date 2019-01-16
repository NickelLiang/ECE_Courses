module adder (
    input  logic        ADDR1MUX,
    input  logic [1:0]  ADDR2MUX,
    input  logic [15:0] PC, BaseR, IR,
    output logic [15:0] DATA_ADDER
    );

    logic [15:0] ADDR1, ADDR2;

    always_comb begin
        ADDR1 = ADDR1MUX ? BaseR : PC;
        unique case (ADDR2MUX)
            2'b00: ADDR2 = 16'b0;
            2'b01: ADDR2 = {{10{IR[5]}}, IR[5:0]};
            2'b10: ADDR2 = {{7{IR[8]}}, IR[8:0]};
            2'b11: ADDR2 = {{5{IR[10]}}, IR[10:0]};
        endcase
        DATA_ADDER = ADDR1 + ADDR2;
    end

endmodule // adder
