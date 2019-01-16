module testbench_alu();

timeunit 10ns;  // Half clock cycle at 50 MHz
            // This is the amount of time represented by #1
timeprecision 1ns;

logic       Clk = 0;
logic       Shift, F, ClrA_LdB, ClrA;
logic [7:0] S;
logic [7:0] A, B;
logic       X;

// To store expected results
logic [7:0] ans_a, ans_b, ans_x;

// A counter to count the instances where simulation results
// do no match with expected results
integer ErrorCnt = 0;

// Instantiating the DUT
// Make sure the module and signal names match with those in your design
arithmetic_unit ALU(.*);

// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
    #1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end

// Testing begins here
// The initial block is not synthesizable
// Everything happens sequentially inside an initial block
// as in a software program
initial begin: TEST_VECTORS
    S       = 8'b11000101;
    ClrA_LdB= 1;
    Shift   = 0;
    F       = 0;

    #2 ClrA_LdB = 0;

    // test for ClrA_LdB
    #2  ans_a = 8'h00;
        ans_b = 8'b11000101;
        ans_x = 1'b0;

    if (ans_a != A)
        ErrorCnt++;
    if (ans_b != B)
        ErrorCnt++;
    if (ans_x != X)
        ErrorCnt++;

    // toggle Shift
        S = 8'b00000111;
        Shift = 1;
    #2  Shift = 0;

    #2  ans_a = 8'b00000011;
        ans_b = 8'b11100010;
        ans_x = 1'b0;

    if (ans_a != A)
        ErrorCnt++;
    if (ans_b != B)
        ErrorCnt++;
    if (ans_x != X)
        ErrorCnt++;

    // toggle Shift
        Shift = 1;
    #2  Shift = 0;
    #2 ;
    // toggle Shift
        Shift = 1;
    #2  Shift = 0;
    #2 ;
    // toggle Shift
        Shift = 1;
    #2  Shift = 0;
    #2 ;
    // toggle Shift
        Shift = 1;
    #2  Shift = 0;
    #2 ;
    // toggle Shift
        Shift = 1;
    #2  Shift = 0;
    #2 ;
    // toggle Shift
        Shift = 1;
    #2  Shift = 0;
    #2 ;
    // toggle Shift
        Shift = 1;
        F = 1;
    #2  Shift = 0;
        F = 0;
    #2 ;



end
endmodule
