module armor_recog (
    input  logic        CLOCK_50,
    input  logic [1:0]  KEY,
    output logic [7:0]  LEDG,
    output logic [17:0] LEDR,
    output logic [6:0]  HEX0,
    output logic [6:0]  HEX1,
    output logic [6:0]  HEX2,
    output logic [6:0]  HEX3,
    output logic [6:0]  HEX4,
    output logic [6:0]  HEX5,
    output logic [6:0]  HEX6,
    output logic [6:0]  HEX7,
    // DRAM
    output logic [12:0] DRAM_ADDR,      // SDRAM Address 13 Bits
    inout  wire  [31:0] DRAM_DQ,        // SDRAM Data 32 Bits
    output logic [1:0]  DRAM_BA,        // SDRAM Bank Address 2 Bits
    output logic [3:0]  DRAM_DQM,       // SDRAM Data Mast 4 Bits
    output logic        DRAM_RAS_N,     // SDRAM Row Address Strobe
    output logic        DRAM_CAS_N,     // SDRAM Column Address Strobe
    output logic        DRAM_CKE,       // SDRAM Clock Enable
    output logic        DRAM_WE_N,      // SDRAM Write Enable
    output logic        DRAM_CS_N,      // SDRAM Chip Select
    output logic        DRAM_CLK,       // SDRAM Clock
    // VGA Interface
    output logic [7:0]  VGA_R,          // VGA Red
    output logic [7:0]  VGA_G,          // VGA Green
    output logic [7:0]  VGA_B,          // VGA Blue
    output logic        VGA_CLK,        // VGA Clock
    output logic        VGA_SYNC_N,     // VGA Sync Signal
    output logic        VGA_BLANK_N,    // VGA Blank Signal
    output logic        VGA_VS,         // VGA Virtical Sync Signal
    output logic        VGA_HS,         // VGA Horizontal Sync Signal
    // CAMERA
    input  logic [11:0] D5M_D,
    input  logic        D5M_FVAL,
    input  logic        D5M_LVAL,
    input  logic        D5M_PIXLCLK,
    output logic        D5M_RESET_N,
    output logic        D5M_SCLK,
    inout  logic        D5M_SDATA,
    input  logic        D5M_STROBE,
    output logic        D5M_TRIGGER,
    output logic        D5M_XCLKIN
    );

    `include "sdram_control/sdram_params.h"
    `include "armor_recog_params.h"

    wire    DRAM_CTL_CLK;
    // Not set yet
    wire    [11:0]  sCCD_R;
    wire    [11:0]  sCCD_G;
    wire    [11:0]  sCCD_B;
    wire            sCCD_DVAL;
    wire            DLY_RST_0;
    wire            VGA_CTRL_CLK;

    sdram_control sdram_control (
        // HOST Side
        .RESET_N(KEY[0]),
        .CLK(DRAM_CTL_CLK),

        // FIFO Write Side 1
        .WR1_DATA({1'b0, sCCD_G[11:7], sCCD_B[11:2]}),
        .WR1(sCCD_DVAL),
        .WR1_ADDR(0),
        .WR1_MAX_ADDR(`VGA_HORZ * `VGA_VERT / 2),
        .WR1_LENGTH(8'h`FIFO_LENG),
        .WR1_LOAD(!DLY_RST_0),
        .WR1_CLK(D5M_PIXLCLK),

        // FIFO Write Side 2
        .WR2_DATA({1'b0, sCCD_G[6:2], sCCD_R[11:2]}),
        .WR2(sCCD_DVAL),
        .WR2_ADDR(`ASIZE'h100000),
        .WR2_MAX_ADDR(`ASIZE'h100000 + `VGA_HORZ * `VGA_VERT / 2),
        .WR2_LENGTH(8'h`FIFO_LENG),
        .WR2_LOAD(!DLY_RST_0),
        .WR2_CLK(D5M_PIXLCLK),

        // FIFO Read Side 1
        .RD1_DATA(Read_DATA1),
        .RD1(Read),
        .RD1_ADDR(0),
        .RD1_MAX_ADDR(`VGA_HORZ * `VGA_VERT / 2),
        .RD1_LENGTH(8'h`FIFO_LENG),
        .RD1_LOAD(!DLY_RST_0),
        .RD1_CLK(~VGA_CTRL_CLK),

        // FIFO Read Side 2
        .RD2_DATA(Read_DATA2),
        .RD2(Read),
        .RD2_ADDR(`ASIZE'h100000),
        .RD2_MAX_ADDR(`ASIZE'h100000 + `VGA_HORZ * `VGA_VERT / 2),
        .RD2_LENGTH(8'h`FIFO_LENG),
        .RD2_LOAD(!DLY_RST_0),
        .RD2_CLK(~VGA_CTRL_CLK),

        // SDRAM Side
        .SA(DRAM_ADDR),
        .BA(DRAM_BA),
        .CS_N(DRAM_CS_N),
        .CKE(DRAM_CKE),
        .RAS_N(DRAM_RAS_N),
        .CAS_N(DRAM_CAS_N),
        .WE_N(DRAM_WE_N),
        .DQ(DRAM_DQ),
        .DQM(DRAM_DQM)
    );

    main_pll pll (
        .inclk0(CLOCK_50),
        .c0(DRAM_CTL_CLK),  // 100MHz SDRAM Controller CLK
        .c1(DRAM_CLK),      // 100MHz with 3ns delay SDRAM CLK
        .c2(D5M_XCLKIN),    // 25MHz Camera CLK
        .c3(VGA_CLK)        // 40MHz 800 * 600 VGA CLK
    );

endmodule // armor_recog top level module
