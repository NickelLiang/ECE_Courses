module sdram_experiment (
    input  logic            CLOCK2_50,
    output logic [8 :0]     LEDG,
    output logic [17:0]     LEDR,
    input  logic [3 :0]     KEY,
    input  logic [17:0]     SW,
    // HEX
    output logic [6 :0]     HEX0,
    output logic [6 :0]     HEX1,
    output logic [6 :0]     HEX2,
    output logic [6 :0]     HEX3,
    output logic [6 :0]     HEX4,
    output logic [6 :0]     HEX5,
    output logic [6 :0]     HEX6,
    output logic [6 :0]     HEX7,
    // VGA
    output logic [7 :0]     VGA_B,
    output logic            VGA_BLANK_N,
    output logic            VGA_CLK,
    output logic [7 :0]     VGA_G,
    output logic            VGA_HS,
    output logic [7 :0]     VGA_R,
    output logic            VGA_SYNC_N,
    output logic            VGA_VS,
    // SDRAM
    output logic [12:0]     DRAM_ADDR,
    output logic [1 :0]     DRAM_BA,
    output logic            DRAM_CAS_N,
    output logic            DRAM_CKE,
    output logic            DRAM_CLK,
    output logic            DRAM_CS_N,
    inout  wire  [31:0]     DRAM_DQ,
    output logic [3 :0]     DRAM_DQM,
    output logic            DRAM_RAS_N,
    output logic            DRAM_WE_N,
    // CCD
    input  logic [11:0]     D5M_D,
    input  logic            D5M_FVAL,
    input  logic            D5M_LVAL,
    input  logic            D5M_PIXLCLK,
    output logic            D5M_RESET_N,
    output logic            D5M_SCLK,
    inout  wire             D5M_SDATA,
    input  logic            D5M_STROBE,
    output logic            D5M_TRIGGER,
    output logic            D5M_XCLKIN
    );

    // NOTE To Change Memory Frequency, Change Both QSYS and PLL value.

    // Clocks
    logic           SDRAM_CONTROL_CLK;
    logic           CCD_CONTROL_CLK;
    // CCD Ouput
    logic [11:0]    CCD_R_m, CCD_G_m, CCD_B_m;
    logic           CCD_DVAL_m;
    logic           CCD_PIX_CLK;
    // VGA Input
    logic [31:0]    VGA_FIFO_OUTPUT_m;          // Connected
    logic [7 :0]    VGA_R_m, VGA_G_m, VGA_B_m;  // Connected
    logic           VGA_READ_REQ_m;             // Connected

    assign VGA_R_m = VGA_FIFO_OUTPUT_m[29:22];
    assign VGA_G_m = VGA_FIFO_OUTPUT_m[19:12];
    assign VGA_B_m = VGA_FIFO_OUTPUT_m[9 :2];

    // Temporary Test Utility
    // assign CCD_DVAL_m       = 1'b1;
    // assign CCD_R_m          = 12'hFFF;
    // assign CCD_G_m          = 12'hFFF;
    // assign CCD_B_m          = 12'hFFF;

    sdram_control sdram_control (
        // HOST Side
        .RESET_N    (KEY[0]),
        .CLK        (SDRAM_CONTROL_CLK),
        // FIFO Write Side
        .WR_DATA    ({2'b0, CCD_R_m[11:2], CCD_G_m[11:2], CCD_B_m[11:2]}),
        .WR         (CCD_DVAL_m),
        .WR_ADDR    (25'h0),
        .WR_MAX_ADDR(25'd307200),
        .WR_LENGTH  (8'h50),
        .WR_LOAD    (~KEY[0]),                 // Reset Delay?
        .WR_CLK     (CCD_PIX_CLK),
        // FIFO Read Side
        .RD_DATA    (VGA_FIFO_OUTPUT_m),
        .RD         (VGA_READ_REQ_m),
        .RD_ADDR    (25'h0),
        .RD_MAX_ADDR(25'd307200),
        .RD_LENGTH  (8'h50),
        .RD_LOAD    (~KEY[0]),                 // Reset Delay?
        .RD_CLK     (VGA_CLK),
        // SDRAM Side
        .SA         (DRAM_ADDR),
        .BA         (DRAM_BA),
        .CS_N       (DRAM_CS_N),
        .CKE        (DRAM_CKE),
        .RAS_N      (DRAM_RAS_N),
        .CAS_N      (DRAM_CAS_N),
        .WE_N       (DRAM_WE_N),
        .DQ         (DRAM_DQ),
        .DQM        (DRAM_DQM),
        // DEBUG
        .WR_EMPTY   (LEDG[7]),
        .WR_FULL    (LEDG[6]),
        .RD_EMPTY   (LEDG[1]),
        .RD_FULL    (LEDG[0])
    );

    // NEED to change sdc file period when modify clock
    main_pll main_pll (
        .inclk0 (CLOCK2_50),         // 50MHz Input
        .c0     (SDRAM_CONTROL_CLK), // 50MHz SDRAM Control Output
        .c1     (DRAM_CLK),          // 50MHz SDRAM with -3ns Delay Output
        .c2     (VGA_CLK),           // 25MHz VGA Output
        .c3     (CCD_CONTROL_CLK),   // 25MHz CCD Control Output
        .c4     (CCD_PIX_CLK)        // 30MHz Output - temporary mimic the output pix clk
    );

    vga_control vga_control (
        .VGA_CLK        (VGA_CLK),
        .RESET          (~KEY[0]),
        .BOX_ENABLE     (SW[17]),
        .BOX_LEFT       (10'd270),
        .BOX_RIGHT      (10'd370),
        .BOX_TOP        (10'd190),
        .BOX_BOTTOM     (10'd290),
        .VGA_R_IN       (VGA_R_m),
        .VGA_G_IN       (VGA_G_m),
        .VGA_B_IN       (VGA_B_m),
        .VGA_R          (VGA_R),
        .VGA_G          (VGA_G),
        .VGA_B          (VGA_B),
        .VGA_BLANK_N    (VGA_BLANK_N),
        .VGA_SYNC_N     (VGA_SYNC_N),
        .VGA_HS         (VGA_HS),
        .VGA_VS         (VGA_VS),
        .REQUEST_DATA   (VGA_READ_REQ_m)
    );

    simulate_camera simulate_camera (
        .PIXCLK     (CCD_PIX_CLK),
        .RESET      (~KEY[0]),
        .CCD_R      (CCD_R_m),
        .CCD_G      (CCD_G_m),
        .CCD_B      (CCD_B_m),
        .CCD_DVAL   (CCD_DVAL_m)
    );

endmodule // sdram_experiment
