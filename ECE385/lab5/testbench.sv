module testbench();

timeunit 10ns;  // Half clock cycle at 50 MHz
            // This is the amount of time represented by #1
timeprecision 1ns;

logic Clk = 0;
logic Reset, Run, ClearA_LoadB;
logic [7:0] S;
logic [7:0] Aval, Bval;
logic [6:0] AhexU, AhexL, BhexU, BhexL;
logic       X;

// To store expected results
logic [15:0] result;

// A counter to count the instances where simulation results
// do no match with expected results
integer ErrorCnt = 0;

// intantiate a multiplier
multiplier MPL(.*);

// Toggle the clock
// #1 means wait for a delay of 1 timeunit
always begin : CLOCK_GENERATION
    #1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end

assign result = {Aval, Bval};

// Testing begins here
// The initial block is not synthesizable
// Everything happens sequentially inside an initial block
// as in a software program
initial begin: TEST_VECTORS
    S               = 21;
    ClearA_LoadB    = 1;
    Reset           = 0;
    Run             = 1;

    // toggle reset
    #2  Reset = 1;

    // toggle ClearA_LoadB
        ClearA_LoadB = 0;
    #2  ClearA_LoadB = 1;

    // test case 1: check if ClearA_LoadB work as expected
    #2 if (Aval != 0 || Bval != 8'd21)
        ErrorCnt++;

    // test case 2: check if + * + work as expected (17 * 21 = 357)
        S = 17;
    #2  Run = 0;
    #2  Run = 1;
    #20 if (result != 16'd357)
        ErrorCnt++;

    // test case 3: check if - * + work as expected ((-3) * 21 = -63)
        S = 21;
        ClearA_LoadB = 0;
    #2  ClearA_LoadB = 1;
        S = -3;
    #2  Run = 0;
    #2  Run = 1;
    #20 if (result != -16'd63)
        ErrorCnt++;

    // test case 4: check if + * - work as expected (89 * (-53) = -4717)
        S = -53;
        ClearA_LoadB = 0;
    #2  ClearA_LoadB = 1;
        S = 89;
    #2  Run = 0;
    #2  Run = 1;
    #20 if (result != -16'd4717)
        ErrorCnt++;

    // test case 5: check if - * - work as expected ((-37) * (-53) = 1961)
        S = -53;
        ClearA_LoadB = 0;
    #2  ClearA_LoadB = 1;
        S = -37;
    #2  Run = 0;
    #2  Run = 1;
    #20 if (result != 16'd1961)
        ErrorCnt++;

    // test case 6: check if consecutive multiplication work as expected ((-2)*(-2)*(-2)*(-2)*(-2) = 32)
        S = -2;
        ClearA_LoadB = 0;
    #2  ClearA_LoadB = 1;

    #2  Run = 0;
    #2  Run = 1;

    #20 Run = 0;
    #2  Run = 1;

    #20 Run = 0;
    #2  Run = 1;

    #20 Run = 0;
    #2  Run = 1;

    #20 if (result != -16'd32)
        ErrorCnt++;
end

endmodule
