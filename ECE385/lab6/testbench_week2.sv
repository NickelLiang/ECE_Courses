import SLC3_2::opPSE;

module testbench_week2();

timeunit        10ns;
timeprecision   1ns;

logic Clk = 0;
logic Reset, Run, Continue;
logic [15:0] S;
logic [11:0] LED;
logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7;
logic CE, UB, LB, OE, WE;
logic [19:0] ADDR;
logic [15:0] hex_4;
wire [15:0] Data;

logic [15:0] MAR, MDR, IR, PC;
logic [15:0] R0, R1, R2, R3, R4, R5, R6, R7;
logic BEN;
logic LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_CC, LD_REG, LD_PC, LD_LED;
logic GatePC, GateMDR, GateALU, GateMARMUX;
logic [1:0] PCMUX, ADDR2MUX, ALUK;
logic DRMUX, SR1MUX, SR2MUX, ADDR1MUX;

integer ErrorCnt = 0;

slc3 processor(.*);

test_memory mem_test(.Reset(~Reset), .I_O(Data), .A(ADDR), .*);

always_comb begin: INTERNAL_MONITOR
    hex_4 = { processor.hex_4[3][3:0],
              processor.hex_4[2][3:0],
              processor.hex_4[1][3:0], 
              processor.hex_4[0][3:0] };
    PC      = processor.PC;
    MAR     = processor.MAR;
    IR      = processor.IR;
    MDR     = processor.MDR;
    BEN     = processor.BEN;
    LD_MAR  = processor.LD_MAR;
    LD_MDR  = processor.LD_MDR;
    LD_IR   = processor.LD_IR;
    LD_BEN  = processor.LD_BEN;
    LD_CC   = processor.LD_CC;
    LD_REG  = processor.LD_REG;
    LD_PC   = processor.LD_PC;
    LD_LED  = processor.LD_LED;
    GatePC  = processor.GatePC;
    GateMDR = processor.GateMDR;
    GateALU = processor.GateALU;
    GateMARMUX = processor.GateMARMUX;
    PCMUX   = processor.PCMUX;
    ADDR2MUX= processor.ADDR2MUX;
    ADDR1MUX= processor.ADDR1MUX;
    ALUK    = processor.ALUK;
    DRMUX   = processor.DRMUX;
    SR1MUX  = processor.SR1MUX;
    SR2MUX  = processor.SR2MUX;
    R0 = processor.d0.rf.reg_array[0];
    R1 = processor.d0.rf.reg_array[1];
    R2 = processor.d0.rf.reg_array[2];
    R3 = processor.d0.rf.reg_array[3];
    R4 = processor.d0.rf.reg_array[4];
    R5 = processor.d0.rf.reg_array[5];
    R6 = processor.d0.rf.reg_array[6];
    R7 = processor.d0.rf.reg_array[7];
end

always begin: CLOCK_GENERATION
    #1 Clk = ~Clk;
end

initial begin: CLOCK_INITIALIZATION
    Clk = 0;
end

initial begin: TEST_VECTORS
    // basic I/O test 1
    Reset       = 0;
    Run         = 1;
    Continue    = 1;
    S           = 16'd3;

#2  Reset       = 1;
    Run         = 0;

#2  Run         = 1;

#80 if (R1 != S)
        ErrorCnt++;
    if (hex_4 != S)
        ErrorCnt++;
        
    // basic I/O test 2
    Reset       = 0;
    S           = 16'd6;
    
#2  Reset       = 1;
    Run         = 0;
#2  Run         = 1;

#60 S           = 16'd30;
    Continue    = 0;
#10 Continue    = 1;

#50 if (R1 != S)
        ErrorCnt++;
    if (hex_4 != S)
        ErrorCnt++;

    S           = -16'd20;
    Continue    = 0;
#10 Continue    = 1;
#10 Continue    = 0;
#10 Continue    = 1;

#50 if (R1 != S)
        ErrorCnt++;
    if (hex_4 != S)
        ErrorCnt++;
        
    //basic I/O test 3
    Reset       = 0;
    S           = 16'd11;
    
#2  Reset       = 1;
    Run         = 0;
#2  Run         = 1;

#60 S           = 16'd2222;

#10 Continue    = 0;
#10 Continue    = 1;

#80 if (R1 != S)
        ErrorCnt++;
    if (hex_4 != S)
        ErrorCnt++;
#10 if (LED != 12'hc02)
        ErrorCnt++;
        
#20 Continue    = 0;
#10 Continue    = 1;

#50 ;
#50 if (LED != 12'hc03)
        ErrorCnt++;

    
end
        
endmodule
