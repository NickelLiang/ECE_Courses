module sdram_control_sim ();

    timeunit 10ns;  // 50MHz
    timeprecision 1ns;

    integer ErrorCnt = 0;

    // HOST Side
    logic        RESET_N;        // System Reset
    logic        CLK;            // Memory Controller Clock
    // FIFO Write Side
    logic [31:0] WR_DATA;        // Data Input
    logic        WR;             // Write Request
    logic [24:0] WR_ADDR;        // Write Start Address
    logic [24:0] WR_MAX_ADDR;    // Write Max Address
    logic [7 :0] WR_LENGTH;      // Write Length
    logic        WR_LOAD;        // Write FIFO Clear
    logic        WR_CLK;         // Write FIFO Clock
    // FIFO Read Side
    logic [31:0] RD_DATA;        // Data Output
    logic        RD;             // Read Request
    logic [24:0] RD_ADDR;        // Read Start Address
    logic [24:0] RD_MAX_ADDR;    // Read Max Address
    logic [7 :0] RD_LENGTH;      // Read Length
    logic        RD_LOAD;        // Read FIFO Clear
    logic        RD_CLK;         // Read FIFO Clock
    // SDRAM Side
    logic [12:0] SA;             // SDRAM address output
    logic [1 :0] BA;             // SDRAM bank address
    logic        CS_N;           // SDRAM Chip Selects
    logic        CKE;            // SDRAM clock enable
    logic        RAS_N;          // SDRAM Row address Strobe
    logic        CAS_N;          // SDRAM Column address Strobe
    logic        WE_N;           // SDRAM write enable
    wire  [31:0] DQ;             // SDRAM data bus
    logic [3 :0] DQM;            // SDRAM data mask lines
    // Debug Signal
    logic        WR_EMPTY;
    logic        WR_FULL;
    logic        RD_EMPTY;
    logic        RD_FULL;

    // Additional monitor signal
    logic [24:0]    RAM_ADDR_m;
    logic           RAM_RD_N_m;         // Set to 0 When Read
    logic           RAM_WR_N_m;         // Set to 0 When Write
    logic           RAM_BUSY_m;         // Is 1 when RAM unable to respond
    // WR FIFO
    logic           WR_FIFO_REQ_m;      // Set to 1 to write WRFIFO content into memory
    logic [31:0]    WR_DRAM_DIN_m;      // FIFO Data Output, Memory Data Input
    logic [ 8:0]    WR_FIFO_USEDW_m;    // WRFIFO used words
    // RD FIFO
    logic           RD_FIFO_REQ_m;      // Set to 1 to read RDFIFO content from memory / Control by MEM logic
    logic [31:0]    RD_DRAM_DOUT_m;     // FIFO Data Input, Memory Data Output
    logic [ 8:0]    RD_FIFO_USEDW_m;    // RDFIFO used words
    // RAM Signal
    logic [24:0]    RAM_COUNT_m;        // How many RAM operations since WR/RD start
    // WR Signal
    logic [24:0]    WR_ADDR_m;          // Start to write to this address when control condition satisfy
    // logic [24:0]    WR_MAX_ADDR_m;      // Maximum address WRFIFO can write to
    // logic [7 :0]    WR_LENGTH_m;        // Write this many data when control condition satisfy
    logic           WR_ING_m;           // Is 1 when writing
    logic           WR_DONE_m;          // Is 1 when WR finished
    logic           WR_CONTROL_m;       // Set to 1 to start a WR process
    // RD Signal
    logic [24:0]    RD_ADDR_m;          // Start to read from this address when control condition satisfy
    // logic [24:0]    RD_MAX_ADDR_m;      // Maximum address RDFIFO can read from
    // logic [7 :0]    RD_LENGTH_m;        // Read this many data when control condition satisfy
    logic           RD_ING_m;           // Is 1 when reading
    logic           RD_DONE_m;          // Is 1 when RD finished
    logic           RD_CONTROL_m;       // Set to 1 to start a RD process

    // Temp value
    logic [11:0] CCD_R_m, CCD_G_m, CCD_B_m;

    assign      CCD_R_m = 12'hFFF;
    assign      CCD_G_m = 12'hFFF;
    assign      CCD_B_m = 12'hFFF;
    // assign      RD_CLK  = CLK;
    // assign      WR_CLK  = CLK;

    // Instantiate module
    sdram_control sdram_control0(.*);

    // Clocks
    always begin: CLOCK_GENERATION
    #1  CLK = ~CLK;
    end

    always begin: FIFO_CLOCK
    #2  WR_CLK = ~WR_CLK;
        RD_CLK = ~WR_CLK;
    end

    initial begin: CLOCK_INITIALIZATION
        CLK = 0;
        WR_CLK = 0;
        RD_CLK = 0;
    end

    // Internal monitor signals
    always_comb begin: INTERNAL_MONITOR
        WR_CONTROL_m = sdram_control0.WR_CONTROL_m;
        RD_CONTROL_m = sdram_control0.RD_CONTROL_m;
        WR_FIFO_REQ_m = sdram_control0.WR_FIFO_REQ_m;
        WR_DRAM_DIN_m = sdram_control0.WR_DRAM_DIN_m;
        WR_FIFO_USEDW_m = sdram_control0.WR_FIFO_USEDW_m;
        RD_FIFO_REQ_m = sdram_control0.RD_FIFO_REQ_m;
        RD_DRAM_DOUT_m = sdram_control0.RD_DRAM_DOUT_m;
        RD_FIFO_USEDW_m = sdram_control0.RD_FIFO_USEDW_m;
        RAM_COUNT_m = sdram_control0.RAM_COUNT_m;
        WR_ADDR_m = sdram_control0.WR_ADDR_m;
        WR_ING_m = sdram_control0.WR_ING_m;
        WR_DONE_m = sdram_control0.WR_DONE_m;
        RD_ADDR_m = sdram_control0.RD_ADDR_m;
        RD_ING_m = sdram_control0.RD_ING_m;
        RD_DONE_m = sdram_control0.RD_DONE_m;
    end

    initial begin: TEST_VECTORS
        RESET_N = 0;
        WR_DATA = {2'b0, CCD_R_m[11:2], CCD_G_m[11:2], CCD_B_m[11:2]};
        WR = 0;
        WR_ADDR = 25'h0;
        WR_MAX_ADDR = 25'd307200;
        WR_LENGTH = 8'h50;
        WR_LOAD = 0;
        RD = 0;
        RD_ADDR = 25'h0;
        RD_MAX_ADDR = 25'd307200;
        RD_LENGTH = 8'h50;
        RD_LOAD = 0;

    #2  RESET_N = 1;
    #4  WR = 1;
        RD = 1;

    #1280
        WR = 0;
        RD = 0;

    #20 RD = 0;
    end

endmodule // sdram_experiment_sim
