module reg_file (
    input  logic        Clk, Reset,
    input  logic        LD_REG, DRMUX, SR1MUX,
    input  logic [15:0] DATA_BUS, IR,
    output logic [15:0] SR1_OUT, SR2_OUT
    );

    logic [15:0] reg_array[8];
    logic [2:0] SR1, SR2, DR;

    always_comb begin
        SR1 = SR1MUX ? IR[8:6] : IR[11:9];
        SR2 = IR[2:0];
        SR1_OUT = reg_array[SR1];
        SR2_OUT = reg_array[SR2];
        DR = DRMUX ? 3'b111 : IR[11:9];
    end

    always_ff @ (posedge Clk) begin
        if (Reset)
            for (int i = 0; i < 8; i++) begin
                reg_array[i] <= 16'b0;
            end
        else if (LD_REG)
            reg_array[DR] <= DATA_BUS;
    end

endmodule // reg_file
