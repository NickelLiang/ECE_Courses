// Address Space Parameters

`define ROWSTART        8
`define ROWSIZE         12
`define COLSTART        0
`define COLSIZE         8
`define BANKSTART       20
`define BANKSIZE        2

// Address and Data Bus Sizes

`define  ASIZE          23      // total address width of the SDRAM
`define  DSIZE          32      // Width of data bus to SDRAMS
`define  DIOSIZE        16      // Width of data bus in/out SDRAM Controller

// Controller Parameter
////////////    133 MHz    ///////////////
// parameter   INIT_PER    = 16'd32000;
// parameter   REF_PER     = 16'd1536;
// parameter   SC_CL       = 3;
// parameter   SC_RCD      = 3;
// parameter   SC_RRD      = 7;
// parameter   SC_PM       = 1;
// parameter   SC_BL       = 1;
////////////    125 MHz    ///////////////
parameter   INIT_PER       = 16'd30000;
parameter   REF_PER        = 16'd1280;
parameter   SC_CL          = 3;
parameter   SC_RCD         = 3;
parameter   SC_RRD         = 7;
parameter   SC_PM          = 1;
parameter   SC_BL          = 1;
////////////    100 MHz    ///////////////
// parameter   INIT_PER       = 16'd24000;
// parameter   REF_PER        = 16'd1024;
// parameter   SC_CL          = 3;
// parameter   SC_RCD         = 3;
// parameter   SC_RRD         = 7;
// parameter   SC_PM          = 1;
// parameter   SC_BL          = 1;
////////////    50 MHz    ///////////////
// parameter   INIT_PER       = 16'd12000;
// parameter   REF_PER        = 16'd512;
// parameter   SC_CL          = 3;
// parameter   SC_RCD         = 3;
// parameter   SC_RRD         = 7;
// parameter   SC_PM          = 1;
// parameter   SC_BL          = 1;
///////////////////////////////////////

//    SDRAM Parameter
parameter   SDR_BL          = (SC_PM == 1) ? 3'b111 :
                              (SC_BL == 1) ? 3'b000 :
                              (SC_BL == 2) ? 3'b001 :
                              (SC_BL == 4) ? 3'b010 : 3'b011;
parameter   SDR_BT          = 1'b0;    //    1'b0 : Sequential  1'b1 :    Interteave
parameter   SDR_CL          = (SC_CL == 2) ? 3'b10 : 3'b11;
