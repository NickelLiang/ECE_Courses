module arithmetic_unit (
    input   logic [7:0] S,
    input   logic       Shift, F, ClrA_LdB, ClrA, // Perform addition when F = 0, otherwise perform subtraction
    input   logic       Clk,
    output  logic [7:0] A, B,
    output  logic       X
    );
    logic [8:0] add_result;
    logic       B_in;
    logic       opr, adder_co, LoadXA, M;

    register_9bit RXA(.Clk, .Reset(ClrA_LdB | ClrA), .Load(LoadXA), .Shift_En(Shift),
                        .D(add_result), .Shift_Out(B_in), .Data_Out({X, A}));
    register_8bit RB(.Clk, .Reset(1'b0), .Shift_In(B_in), .Load(ClrA_LdB), .Shift_En(Shift),
                        .D(S), .Shift_Out(M), .Data_Out(B));
    adder_9bit ADDR(.A({A[7], A}), .B({S[7], S}), .F, .Sum(add_result), .CO(adder_co));

    always_comb begin
        LoadXA = 1'b0;
        if (M & Shift) // Indicate multiplication of the last bit
            LoadXA = 1'b1;
    end
endmodule
