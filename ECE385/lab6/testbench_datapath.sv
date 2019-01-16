import SLC3_2::*;

module testbench_datapath();

timeunit 10ns;  // Half clock cycle at 50 MHz, This is the amount of time represented by #1
timeprecision 1ns;

integer ErrorCnt = 0;

logic Clk = 0;
logic Reset, GatePC, GateMDR, GateALU, GateMARMUX, MIO_EN;
logic LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_CC, LD_REG, LD_PC, LD_LED;
logic DRMUX, SR1MUX, SR2MUX, ADDR1MUX;
logic [1:0] PCMUX, ADDR2MUX, ALUK;
logic [15:0] MDR_In;
logic BEN;
logic [15:0] PC, IR, MAR, MDR;
logic [11:0] LED;

datapath datapath(.*);
always begin: CLOCK_GENERATION
    #1 Clk = ~Clk;
end
initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end

logic [15:0] DATA_BUS;
logic [15:0] R0, R1, R2, R3, R4, R5, R6, R7;
logic [2:0] DR;
always_comb begin: INTERNAL_MONITORING
    DATA_BUS = datapath.DATA_BUS;

    R0 = datapath.rf.reg_array[0];
    R1 = datapath.rf.reg_array[1];
    R2 = datapath.rf.reg_array[2];
    R3 = datapath.rf.reg_array[3];
    R4 = datapath.rf.reg_array[4];
    R5 = datapath.rf.reg_array[5];
    R6 = datapath.rf.reg_array[6];
    R7 = datapath.rf.reg_array[7];

    DR = datapath.reg_file.DR;
end

initial begin: TEST_VECTORS
    Reset   = 0;
    GatePC  = 0;
    GateMDR = 0;
    GateALU = 0;
    GateMARMUX = 0;
    LD_MAR  = 0;
    LD_MDR  = 0;
    LD_IR   = 0;
    LD_BEN  = 0;
    LD_CC   = 0;
    LD_REG  = 0;
    LD_PC   = 0;
    LD_LED  = 0;

#2  Reset   = 1;
#2  Reset   = 0;

#5  force datapath.DATA_BUS = 16'b0111;
    // force datapath.reg_file.DR = 3'b010;
    DRMUX = 1;

#5  LD_REG  = 1;

end

endmodule
