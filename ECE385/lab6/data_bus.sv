module data_bus (
    input   logic        GateMARMUX, GatePC, GateALU, GateMDR,
    input   logic [15:0] MARMUX, PC, ALU, MDR,
    output  logic [15:0] DATA_BUS
    );

    always_comb begin
        unique case ({GateMARMUX, GatePC, GateALU, GateMDR})
            4'b0001: DATA_BUS = MDR;
            4'b0010: DATA_BUS = ALU;
            4'b0100: DATA_BUS = PC;
            4'b1000: DATA_BUS = MARMUX;
            default: DATA_BUS = {16{1'bZ}};
        endcase
    end

endmodule
