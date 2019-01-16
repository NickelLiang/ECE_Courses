// generic n bit regsiters
module register_nbit
    #(parameter n = 16)
    (
    input  logic            Clk, Reset, Load,
    input  logic [n-1:0]    D_In,
    output logic [n-1:0]    D_Out
    );
    logic [n-1:0] D_Next;

    always_ff @ (posedge Clk) begin
        D_Out <= D_Next;
    end

    always_comb begin
        D_Next = D_Out;
        if (Reset)
            D_Next = {n{1'b0}};
        else if (Load)
            D_Next = D_In;
    end
endmodule
