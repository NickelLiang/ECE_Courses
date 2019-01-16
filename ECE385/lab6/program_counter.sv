module program_counter (
    input   logic           Clk, Reset,
    input   logic           LD_PC,
    input   logic   [1:0]   PCMUX,
    input   logic   [15:0]  DATA_BUS,
    input   logic   [15:0]  DATA_ADDER,
    output  logic   [15:0]  PC_OUT
    );

    logic [15:0] data_input;

    register_nbit pc_reg(.Clk, .Reset, .Load(LD_PC), .D_In(data_input), .D_Out(PC_OUT));

    always_comb begin
        unique case (PCMUX)
            2'b00: data_input = PC_OUT + 16'd1;
            2'b01: data_input = DATA_BUS;
            2'b10: data_input = DATA_ADDER;
            2'b11: data_input = PC_OUT; // this should not happen
        endcase
    end

endmodule
