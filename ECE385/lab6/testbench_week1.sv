import SLC3_2::*;

module testbench_week1();

timeunit 10ns;  // Half clock cycle at 50 MHz
            // This is the amount of time represented by #1
timeprecision 1ns;

logic Clk = 0;
logic Reset, Run, Continue;
logic [15:0] S, MAR, MDR, IR, PC;
logic [11:0] LED;
logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
logic CE, UB, LB, OE, WE;
logic [19:0] ADDR;
wire [15:0] Data;

integer ErrorCnt = 0;

slc3 my_slc(.*);

test_memory my_test_memory(.Reset(~Reset), .I_O(Data), .A(ADDR), .*);

always_comb begin: INTERNAL_MONITOR
    MAR = my_slc.MAR;
    MDR = my_slc.MDR;
    IR  = my_slc.IR;
    PC  = my_slc.PC;
end

always begin: CLOCK_GENERATION
    #1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end

initial begin: TEST_VECTORS
    Reset       = 0;
    Run         = 1;
    Continue    = 1;

#2  Reset       = 1;
    Run         = 0;

#2  Run         = 1;

#20 if (IR != opCLR(R0))
        ErrorCnt++;
    Continue    = 0;

#2  Continue    = 1;

#20 if (IR != opLDR(R1, R0, inSW))
        ErrorCnt++;
    Continue    = 0;

#2  Continue    = 1;

#20 if (IR != opJMP(R1))
        ErrorCnt++;

end

endmodule
