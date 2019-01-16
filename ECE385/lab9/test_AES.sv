module testbench_AES();

timeunit 10ns;

timeprecision 1ns;

integer ErrorCnt = 0;

logic CLK = 0;
logic RESET, AES_START, AES_DONE;
logic [127:0] AES_KEY, AES_MSG_ENC, AES_MSG_DEC;
logic [3:0] round, state;
logic [1407:0] keys;

AES aesmod(.*);

always begin: CLOCK_GENERATION
    #1 CLK = ~CLK;
end

initial begin: CLOCK_INITIALIZATION
    CLK = 0;
end

always_comb begin: INTERNAL_MONITORING
    round = aesmod.round;
    state = aesmod.state;
    keys = aesmod.KeySchedule;
end

initial begin: TEST_VECTORS
    RESET = 0;
    AES_START = 0;
    AES_KEY     = 128'h000102030405060708090a0b0c0d0e0f;
    AES_MSG_ENC = 128'hdaec3055df058e1c39e814ea76f6747e;

    RESET = 1;
#2  RESET = 0;

#20; // wait for key expension

    AES_START = 1;
#2  AES_START = 0;
end

endmodule
