module sdram_control (
    // HOST Side
    input  logic        RESET_N,        // System Reset
    input  logic        CLK,            // Memory Controller Clock
    // FIFO Write Side
    input  logic [31:0] WR_DATA,        // Data Input
    input  logic        WR,             // Write Request
    input  logic [24:0] WR_ADDR,        // Write Start Address
    input  logic [24:0] WR_MAX_ADDR,    // Write Max Address
    input  logic [7 :0] WR_LENGTH,      // Write Length
    input  logic        WR_LOAD,        // Write FIFO Clear
    input  logic        WR_CLK,         // Write FIFO Clock
    // FIFO Read Side
    output logic [31:0] RD_DATA,        // Data Output
    input  logic        RD,             // Read Request
    input  logic [24:0] RD_ADDR,        // Read Start Address
    input  logic [24:0] RD_MAX_ADDR,    // Read Max Address
    input  logic [7 :0] RD_LENGTH,      // Read Length
    input  logic        RD_LOAD,        // Read FIFO Clear
    input  logic        RD_CLK,         // Read FIFO Clock
    // SDRAM Side
    output logic [12:0] SA,             // SDRAM address output
    output logic [1 :0] BA,             // SDRAM bank address
    output logic        CS_N,           // SDRAM Chip Selects
    output logic        CKE,            // SDRAM clock enable
    output logic        RAS_N,          // SDRAM Row address Strobe
    output logic        CAS_N,          // SDRAM Column address Strobe
    output logic        WE_N,           // SDRAM write enable
    inout  wire  [31:0] DQ,             // SDRAM data bus
    output logic [3 :0] DQM,            // SDRAM data mask lines
    // Debug Signal
    output logic        WR_EMPTY,
    output logic        WR_FULL,
    output logic        RD_EMPTY,
    output logic        RD_FULL
    );

    // RAM
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

    sdram_model sdram_model (
        .clk_clk                               (CLK),            // 50MHz Memory Controller Clock
        .reset_reset_n                         (RESET_N),        // Active Low Reset
        .sdram_controller_master_address       (RAM_ADDR_m),     // 25 bit Address To W/R
        .sdram_controller_master_byteenable_n  (4'h0),           // Always Enable All Bytes
        .sdram_controller_master_chipselect    (1'b1),           // Always Select SDRAM
        .sdram_controller_master_writedata     (WR_DRAM_DIN_m),  // WR FIFO Output
        .sdram_controller_master_read_n        (RAM_RD_N_m),     // Assert to Read from RAM
        .sdram_controller_master_write_n       (RAM_WR_N_m),     // Assert to Write to RAM
        .sdram_controller_master_readdata      (RD_DRAM_DOUT_m), // RD FIFO Input
        .sdram_controller_master_readdatavalid (RD_FIFO_REQ_m),  // Request to Write to RD FIFO
        .sdram_controller_master_waitrequest   (RAM_BUSY_m),     // Assert when unable to respond.
        .sdram_wire_addr                       (SA),             // SDRAM Address
        .sdram_wire_ba                         (BA),             // SDRAM Bank Address
        .sdram_wire_cas_n                      (CAS_N),          // SDRAM Column Sddress Strobe
        .sdram_wire_cke                        (CKE),            // SDRAM Clock Enable
        .sdram_wire_cs_n                       (CS_N),           // SDRAM Chip Selects
        .sdram_wire_dq                         (DQ),             // SDRAM Data Bus
        .sdram_wire_dqm                        (DQM),            // SDRAM Data Mask Lines
        .sdram_wire_ras_n                      (RAS_N),          // SDRAM Row Address Strobe
        .sdram_wire_we_n                       (WE_N)            // SDRAM Write Enable
    );

    sdram_fifo wr_fifo (
        .aclr       (WR_LOAD),          // IO Request to Clear FIFO Status
        .data       (WR_DATA),          // FIFO Data Input, IO Input Data
        .rdclk      (CLK),              // Memory Clcok
        .rdreq      (WR_FIFO_REQ_m),    // Logic, IN_REQ, Request to Write to Memory
        .wrclk      (WR_CLK),           // IO Input Clock
        .wrreq      (WR),               // IO Input Request
        .q          (WR_DRAM_DIN_m),    // FIFO Data Output, Memory Data Input
        .rdusedw    (WR_FIFO_USEDW_m),  // FIFO Currently Used Words
        .rdempty    (WR_EMPTY),
        .rdfull     (WR_FULL)
    );

    sdram_fifo rd_fifo (
        .aclr       (RD_LOAD),          // IO Request to Clear FIFO Status
        .data       (RD_DRAM_DOUT_m),   // FIFO Data Input, Memory Data Output
        .rdclk      (RD_CLK),           // IO Output Clock
        .rdreq      (RD),               // IO Output Request
        .wrclk      (CLK),              // Memory Clock
        .wrreq      (RD_FIFO_REQ_m),    // Logic, OUT_VALID, Request to Write to FIFO
        .q          (RD_DATA),          // FIFO Data Output, IO Output Data
        .wrusedw    (RD_FIFO_USEDW_m),  // FIFO Currently Used Words
        .wrempty    (RD_EMPTY),
        .wrfull     (RD_FULL)
    );

    always_ff @ (posedge CLK or negedge RESET_N) begin
        if (!RESET_N) begin
            WR_ADDR_m       <= WR_ADDR;
            RD_ADDR_m       <= RD_ADDR;
            // WR_MAX_ADDR_m   <= WR_MAX_ADDR;
            // RD_MAX_ADDR_m   <= RD_MAX_ADDR;
            // WR_LENGTH_m     <= WR_LENGTH;
            // RD_LENGTH_m     <= RD_LENGTH;
            RAM_COUNT_m     <= 25'b0;
            RAM_ADDR_m      <= 0;
            RAM_RD_N_m      <= 1;
            RAM_WR_N_m      <= 1;
            WR_DONE_m       <= 0;
            RD_DONE_m       <= 0;
            WR_FIFO_REQ_m   <= 0;
            // RD_FIFO_REQ_m   <= 0;    // Connected to MEM data valid pin
            WR_CONTROL_m    <= 0;
            RD_CONTROL_m    <= 0;
            WR_ING_m        <= 0;
            RD_ING_m        <= 0;
        end else begin
            // Auto Read / Write Control
            if ((WR_ING_m == 0) && (RD_ING_m == 0) && (RAM_COUNT_m == 0) &&
                (WR_LOAD == 0) && (RD_LOAD == 0) && !WR_CONTROL_m && !RD_CONTROL_m) begin // If nothing is doing anything to ram
                if (WR_FIFO_USEDW_m >= WR_LENGTH) begin
                    WR_CONTROL_m <= 1;
                end else if (RD_FIFO_USEDW_m < RD_LENGTH) begin
                    RD_CONTROL_m <= 1;
                end
            end

            // WR Signal Setting
            if (WR_CONTROL_m) begin     // If
                if (!WR_ING_m) begin    // Start a WR process
                    WR_FIFO_REQ_m   <= 1;
                    RAM_WR_N_m      <= 0;
                    WR_ING_m        <= 1;
                    RAM_ADDR_m      <= WR_ADDR_m;
                    RAM_COUNT_m     <= 0;
                end else begin          // WRing
                    RAM_ADDR_m      <= RAM_ADDR_m + 25'b1;
                    RAM_COUNT_m     <= RAM_COUNT_m + 25'b1;
                end

                if (RAM_COUNT_m == WR_LENGTH - 2) begin // If finish wr
                    WR_CONTROL_m    <= 0;
                    WR_ING_m        <= 0;
                    WR_DONE_m       <= 1;   // Must deassert WR_CONTROL_m signal
                    RAM_COUNT_m     <= 0;
                end
            end else begin
                WR_FIFO_REQ_m   <= 0;
                RAM_WR_N_m      <= 1;
            end
            // RD Signal Setting
            if (RD_CONTROL_m) begin
                if (!RD_ING_m) begin
                    RAM_RD_N_m      <= 0;
                    RD_ING_m        <= 1;
                    RAM_ADDR_m      <= RD_ADDR_m;
                    RAM_COUNT_m     <= 0;
                end else begin
                    RAM_ADDR_m      <= RAM_ADDR_m + 25'b1;
                    RAM_COUNT_m     <= RAM_COUNT_m + 25'b1;
                end

                if (RAM_COUNT_m == RD_LENGTH - 2) begin
                    RD_CONTROL_m    <= 0;
                    RD_ING_m        <= 0;
                    RD_DONE_m       <= 1;
                    RAM_COUNT_m     <= 0;
                end
            end else begin
                RAM_RD_N_m      <= 1;
            end

            // Write Side Address and Length Control
            if (WR_DONE_m) begin
                WR_DONE_m <= 0;
                if (WR_ADDR_m < WR_MAX_ADDR - WR_LENGTH)
                    WR_ADDR_m   <= WR_ADDR_m + WR_LENGTH;
                else
                    WR_ADDR_m   <= WR_ADDR;
            end
            // Read Side Address and Length Control
            if (RD_DONE_m) begin
                RD_DONE_m <= 0;
                if (RD_ADDR_m < RD_MAX_ADDR - RD_LENGTH)
                    RD_ADDR_m   <= RD_ADDR_m + RD_LENGTH;
                else
                    RD_ADDR_m   <= RD_ADDR;
            end
        end
    end

endmodule // sdram_control
