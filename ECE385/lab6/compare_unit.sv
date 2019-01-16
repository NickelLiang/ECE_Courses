module cc (
    input  logic        Reset, Clk, LD_CC,
    input  logic [15:0] DATA_BUS,
    output logic        N, Z, P
    );

    logic N_IN, Z_IN, P_IN;

    always_comb begin
        N_IN = 1'b0;
        Z_IN = 1'b0;
        P_IN = 1'b0;
        if (DATA_BUS[15] == 1'b1) // Data Bus Content Smaller Than 0
            N_IN = 1'b1;
        else if (DATA_BUS[15:0] == 16'b0) // Data Bus Content Equal To 0
            Z_IN = 1'b1;
        else
            P_IN = 1'b1;
    end

    always_ff @ (posedge Clk) begin
        if (Reset) begin
            N <= 1'b0;
            Z <= 1'b0;
            P <= 1'b0;
        end
        else if (LD_CC) begin
            N <= N_IN;
            Z <= Z_IN;
            P <= P_IN;
        end
    end
endmodule // nzp

module ben (
    input  logic        Reset, Clk, LD_BEN, N, Z, P,
    input  logic [15:0] IR,
    output logic        BEN
    );

    logic BEN_IN;

    assign BEN_IN = (N & IR[11]) | (Z & IR[10]) | (P & IR[9]);

    always_ff @ (posedge Clk) begin
        if (Reset)
            BEN <= 1'b0;
        else if (LD_BEN)
            BEN <= BEN_IN;
    end
endmodule
