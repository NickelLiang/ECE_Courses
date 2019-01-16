module armor_recog (
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
    // D5M CAMERA
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

    `include "vga_control/vga_control_param.h"

    // Reset Delay
    logic           DLY_RST_0;
    logic           DLY_RST_1;
    logic           DLY_RST_2;
    logic           DLY_RST_3;
    logic           DLY_RST_4;
    // SDRAM
    logic   [15:0]  READ_DATA1;
    logic   [15:0]  READ_DATA2;
    logic           SDRAM_CTRL_CLK;
    logic           READ_DS;
    logic           READ_VGA;
    logic           READ_REQ;
    logic           READ_SELECT;
    logic           READ_SELECT_m;
    // CCD
    logic   [11:0]  CCD_R;
    logic   [11:0]  CCD_G;
    logic   [11:0]  CCD_B;
    logic           CCD_DVAL;
    logic   [31:0]  FRAME_CONT;
    logic   [15:0]  EXPOSURE_VAL;
    logic           CCD_AUTO_START;
    // Four Image Buffer
    logic   [16:0]  IMG1_WRADDR;
    logic   [ 7:0]  IMG1_WRDATA;
    logic           IMG1_WREN;
    logic   [16:0]  IMG1_RDADDR;
    logic   [ 7:0]  IMG1_RDDATA;
    logic   [16:0]  IMG2_WRADDR;
    logic   [ 7:0]  IMG2_WRDATA;
    logic           IMG2_WREN;
    logic   [16:0]  IMG2_RDADDR;
    logic   [ 7:0]  IMG2_RDDATA;
    logic   [16:0]  IMG3_WRADDR;
    logic   [ 7:0]  IMG3_WRDATA;
    logic           IMG3_WREN;
    logic   [16:0]  IMG3_RDADDR;
    logic   [ 7:0]  IMG3_RDDATA;
    logic   [16:0]  IMG4_WRADDR;
    logic   [ 7:0]  IMG4_WRDATA;
    logic           IMG4_WREN;
    logic   [16:0]  IMG4_RDADDR;
    logic   [ 7:0]  IMG4_RDDATA;

    logic   [16:0]  IMG1_RD_VGA;
    logic   [16:0]  IMG1_RD_SXB;
    logic           IMG1_RD_SELECT;
    logic           IMG1_RD_SELECT_m;
    logic   [16:0]  IMG2_RD_VGA;
    logic   [16:0]  IMG2_RD_VCB;
    logic           IMG2_RD_SELECT;
    logic           IMG2_RD_SELECT_m;
    logic   [16:0]  IMG3_RD_VGA;
    logic   [16:0]  IMG3_RD_DTB;
    logic           IMG3_RD_SELECT;
    logic           IMG3_RD_SELECT_m;
    logic   [16:0]  IMG4_RD_VGA;
    // logic   [16:0]  ;
    logic           IMG4_RD_SELECT;
    logic           IMG4_RD_SELECT_m;

    always_ff @ (posedge CLOCK2_50) begin
        READ_SELECT     <= READ_SELECT_m;
        IMG1_RD_SELECT  <= IMG1_RD_SELECT_m;
        IMG2_RD_SELECT  <= IMG2_RD_SELECT_m;
        IMG3_RD_SELECT  <= IMG3_RD_SELECT_m;
        IMG4_RD_SELECT  <= IMG4_RD_SELECT_m;
    end

    always_comb begin
        // IO
        LEDR            = SW;
        LEDG[8]         = FRAME_CONT[0];
        LEDG[7]         = 1'b0;
        LEDG[6]         = 1'b0;
        LEDG[5]         = 1'b0;
        LEDG[4]         = 1'b0;
        LEDG[3]         = 1'b0;
        LEDG[2]         = IMG1_WREN;
        LEDG[1]         = READ_VGA;
        LEDG[0]         = READ_DS;
        // CCD
        CCD_AUTO_START  = ((KEY[0]) && (DLY_RST_3) && (!DLY_RST_4)) ? 1'b1 : 1'b0;
        // SDRAM
        READ_REQ        = (READ_SELECT ? READ_VGA : READ_DS);
        READ_SELECT_m   = READ_SELECT;
        if (!KEY[0] && SW[16]) begin
            READ_SELECT_m   = 1'b1;     // Direct VGA
        end else if (!KEY[0] && !SW[16]) begin
            READ_SELECT_m   = 1'b0;     // Four Split
        end

        IMG1_RDADDR         = (IMG1_RD_SELECT ? IMG1_RD_VGA : IMG1_RD_SXB);
        IMG1_RD_SELECT_m    = IMG1_RD_SELECT;
        if (!KEY[0] && SW[11]) begin
            IMG1_RD_SELECT_m    = 1'b1;     // Direct VGA
        end else if (!KEY[0] && !SW[11]) begin
            IMG1_RD_SELECT_m    = 1'b0;     // Recog
        end
        IMG2_RDADDR         = (IMG2_RD_SELECT ? IMG2_RD_VGA : IMG2_RD_VCB);
        IMG2_RD_SELECT_m    = IMG2_RD_SELECT;
        if (!KEY[0] && SW[12]) begin
            IMG2_RD_SELECT_m    = 1'b1;     // Direct VGA
        end else if (!KEY[0] && !SW[12]) begin
            IMG2_RD_SELECT_m    = 1'b0;     // Recog
        end
        IMG3_RDADDR         = (IMG3_RD_SELECT ? IMG3_RD_VGA : IMG3_RD_DTB);
        IMG3_RD_SELECT_m    = IMG3_RD_SELECT;
        if (!KEY[0] && SW[13]) begin
            IMG3_RD_SELECT_m    = 1'b1;     // Direct VGA
        end else if (!KEY[0] && !SW[13]) begin
            IMG3_RD_SELECT_m    = 1'b0;     // Recog
        end
        IMG4_RDADDR         = (IMG4_RD_SELECT ? IMG4_RD_VGA : 17'b0);
        IMG4_RD_SELECT_m    = IMG4_RD_SELECT;
        if (!KEY[0] && SW[14]) begin
            IMG4_RD_SELECT_m    = 1'b1;     // Direct VGA
        end else if (!KEY[0] && !SW[14]) begin
            IMG4_RD_SELECT_m    = 1'b0;     // Recog
        end

        // Image Buffer
        IMG4_WRADDR     = IMG1_WRADDR;
        IMG4_WREN       = IMG1_WREN;
        IMG4_WRDATA     = IMG1_WRDATA;
    end

    camera_control camera_control (
        .D5M_PIXLCLK    (D5M_PIXLCLK),
        .D5M_D          (D5M_D),
        .D5M_LVAL       (D5M_LVAL),
        .D5M_FVAL       (D5M_FVAL),
        .D5M_TRIGGER    (D5M_TRIGGER),
        .D5M_RESET_N    (D5M_RESET_N),
        .D5M_SCLK       (D5M_SCLK),
        .D5M_SDATA      (D5M_SDATA),
        .RESTART        (!KEY[3] | CCD_AUTO_START),
        .STOP           (!KEY[2]),
        .CLOCK2_50      (CLOCK2_50),
        .DLY_RST_1      (DLY_RST_1),
        .DLY_RST_2      (DLY_RST_2),
        .EXPOSURE_ADJ   (KEY[1]),
        .EXPOSURE_ACT   (SW[0]),
        .FRAME_CONT     (FRAME_CONT),
        .EXPOSURE_VAL   (EXPOSURE_VAL),
        .CCD_R          (CCD_R),
        .CCD_G          (CCD_G),
        .CCD_B          (CCD_B),
        .CCD_DVAL       (CCD_DVAL)
    );

    sdram_control sdram_control (
        // HOST Side
        .RESET_N        (KEY[0]),
        .CLK            (SDRAM_CTRL_CLK),
        // FIFO Write Side 1
        .WR1_DATA       ({1'b0, CCD_G[11:7], CCD_B[11:2]}),
        .WR1            (CCD_DVAL),
        .WR1_ADDR       (23'h0),
        .WR1_MAX_ADDR   (23'd153600),   // 640*480/2
        .WR1_LENGTH     (8'h50),
        .WR1_LOAD       (!DLY_RST_0),
        .WR1_CLK        (D5M_PIXLCLK),
        // FIFO Write Side 2
        .WR2_DATA       ({1'b0, CCD_G[6:2], CCD_R[11:2]}),
        .WR2            (CCD_DVAL),
        .WR2_ADDR       (23'h100000),
        .WR2_MAX_ADDR   (23'h100000 + 23'd153600),
        .WR2_LENGTH     (8'h50),
        .WR2_LOAD       (!DLY_RST_0),
        .WR2_CLK        (D5M_PIXLCLK),
        // FIFO Read Side 1
        .RD1_DATA       (READ_DATA1),
        .RD1            (READ_REQ),
        .RD1_ADDR       (23'h0),
        .RD1_MAX_ADDR   (23'd153600),
        .RD1_LENGTH     (8'h50),
        .RD1_LOAD       (!DLY_RST_0),
        .RD1_CLK        (VGA_CLK),
        // FIFO Read Side 2
        .RD2_DATA       (READ_DATA2),
        .RD2            (READ_REQ),
        .RD2_ADDR       (23'h100000),
        .RD2_MAX_ADDR   (23'h100000 + 23'd153600),
        .RD2_LENGTH     (8'h50),
        .RD2_LOAD       (!DLY_RST_0),
        .RD2_CLK        (VGA_CLK),
        // SDRAM Side
        .SA             (DRAM_ADDR),
        .BA             (DRAM_BA),
        .CS_N           (DRAM_CS_N),
        .CKE            (DRAM_CKE),
        .RAS_N          (DRAM_RAS_N),
        .CAS_N          (DRAM_CAS_N),
        .WE_N           (DRAM_WE_N),
        .DQ             (DRAM_DQ),
        .DQM            (DRAM_DQM)
    );

    img img_1 (
        .clock          (VGA_CLK),
        .data           (IMG1_WRDATA),
        .rdaddress      (IMG1_RDADDR),
        .wraddress      (IMG1_WRADDR),
        .wren           (IMG1_WREN),
        .q              (IMG1_RDDATA)
    );
    img img_2 (
        .clock          (VGA_CLK),
        .data           (IMG2_WRDATA),
        .rdaddress      (IMG2_RDADDR),
        .wraddress      (IMG2_WRADDR),
        .wren           (IMG2_WREN),
        .q              (IMG2_RDDATA)
    );
    img img_3 (
        .clock          (VGA_CLK),
        .data           (IMG3_WRDATA),
        .rdaddress      (IMG3_RDADDR),
        .wraddress      (IMG3_WRADDR),
        .wren           (IMG3_WREN),
        .q              (IMG3_RDDATA)
    );
    img img_4 (
        .clock          (VGA_CLK),
        .data           (IMG4_WRDATA),
        .rdaddress      (IMG4_RDADDR),
        .wraddress      (IMG4_WRADDR),
        .wren           (IMG4_WREN),
        .q              (IMG4_RDDATA)
    );

    downsample ds (
        .iCLK           (~VGA_CLK),
        .iRESET         (~DLY_RST_2),
        .iRED           (READ_DATA2[9:0]),
        .iGREEN         ({READ_DATA1[14:10], READ_DATA2[14:10]}),
        .iBLUE          ({READ_DATA1[9:0]}),
        .oADDR          (IMG1_WRADDR),
        .oWREN          (IMG1_WREN),
        .oDATA          (IMG1_WRDATA),
        .oDATA_R        (),
        .oDATA_G        (),
        .oDATA_B        (),
        .oREAD          (READ_DS)
    );

    sobel_x_bridge sxb (
        .iCLK           (~VGA_CLK),
        .iRESET         (~DLY_RST_2),
        .iDATA          (IMG1_RDDATA),
        .oRDADDR        (IMG1_RD_SXB),
        .oWREN          (IMG2_WREN),
        .oWRADDR        (IMG2_WRADDR),
        .oDATA          (IMG2_WRDATA)
    );

    vertical_cnt_bridge vcb (
        .iCLK           (~VGA_CLK),
        .iRESET         (~DLY_RST_2),
        .iDATA          (IMG2_RDDATA),
        .oRDADDR        (IMG2_RD_VCB),
        .oWRADDR        (IMG3_WRADDR),
        .oWREN          (IMG3_WREN),
        .oDATA          (IMG3_WRDATA)
    );

    logic [9:0] BLEFT, BRIGHT, BTOP, BBOTTOM;
    detector_bridge dtb (
        .iCLK           (~VGA_CLK),
        .iRESET         (~DLY_RST_2),
        .iDATA          (IMG3_RDDATA),
        .oRDADDR        (IMG3_RD_DTB),
        .oLEFT          (BLEFT),
        .oRIGHT         (BRIGHT),
        .oTOP           (BTOP),
        .oBOTTOM        (BBOTTOM)
    );

    vga_control vga_control (
        .VGA_CLK        (~VGA_CLK),
        .RESET          (~DLY_RST_2),
        .BOX_ENABLE     (SW[17]),
        .BOX_LEFT       (BLEFT),
        .BOX_RIGHT      (BRIGHT),
        .BOX_TOP        (BTOP),
        .BOX_BOTTOM     (BBOTTOM),
        .VGA_R_IN       (READ_DATA2[9:2]),
        .VGA_G_IN       ({READ_DATA1[14:10], READ_DATA2[14:12]}),
        .VGA_B_IN       (READ_DATA1[9:2]),
        .DIVIDE_ENABLE  (!READ_SELECT),
        .IMG1_DATA      (IMG1_RDDATA),
        .IMG1_RDADDR    (IMG1_RD_VGA),
        .IMG1_CHANNEL   (IMG_GRAY),
        .IMG1_ENLARGE   (IMG1_RD_SELECT),
        .IMG2_DATA      (IMG2_RDDATA),
        .IMG2_RDADDR    (IMG2_RD_VGA),
        .IMG2_CHANNEL   (IMG_GRAY),
        .IMG2_ENLARGE   (IMG2_RD_SELECT),
        .IMG3_DATA      (IMG3_RDDATA),
        .IMG3_RDADDR    (IMG3_RD_VGA),
        .IMG3_CHANNEL   (IMG_GRAY),
        .IMG3_ENLARGE   (IMG3_RD_SELECT),
        .IMG4_DATA      (IMG4_RDDATA),
        .IMG4_RDADDR    (IMG4_RD_VGA),
        .IMG4_CHANNEL   (IMG_GRAY),
        .IMG4_ENLARGE   (IMG4_RD_SELECT),
        .VGA_R          (VGA_R),
        .VGA_G          (VGA_G),
        .VGA_B          (VGA_B),
        .VGA_BLANK_N    (VGA_BLANK_N),
        .VGA_SYNC_N     (VGA_SYNC_N),
        .VGA_HS         (VGA_HS),
        .VGA_VS         (VGA_VS),
        .REQUEST_DATA   (READ_VGA)
    );

    io_reset_delay reset_delay (
        .CLK            (CLOCK2_50),
        .RST            (KEY[0]),
        .RST_0          (DLY_RST_0),
        .RST_1          (DLY_RST_1),
        .RST_2          (DLY_RST_2),
        .RST_3          (DLY_RST_3),
        .RST_4          (DLY_RST_4)
    );

    io_seg7_group seg7_group (
        .CLK            (CLOCK2_50),
        .SEG0           (HEX0),
        .SEG1           (HEX1),
        .SEG2           (HEX2),
        .SEG3           (HEX3),
        .SEG4           (HEX4),
        .SEG5           (HEX5),
        .SEG6           (HEX6),
        .SEG7           (HEX7),
        .DIG            ({ BLEFT[7:0], BTOP[7:0], EXPOSURE_VAL })
    );

    sdram_pll sdram_pll (
        .inclk0         (CLOCK2_50),
        .c0             (SDRAM_CTRL_CLK),
        .c1             (DRAM_CLK),         // With Delay
        .c2             (D5M_XCLKIN),       // 25M
        .c3             (VGA_CLK)           // 25M
    );

    // =============Grayscale Experiment===============
    // logic [7:0] gray;
    // logic VGA_Req;
    // Edge_X edge_x (    .iCLK(~VGA_CTRL_CLK),
    //             .iReset(~DLY_RST_2),
    //             .iDVAL(VGA_Req),
    //             .iRed(READ_DATA2[9:0]),
    //             .iGreen({READ_DATA1[14:10], READ_DATA2[14:10]}),
    //             .iBlue({READ_DATA1[9:0]}),
    //             .oDVAL(Read),
    //             .oData(gray));
    //
    // vga_control vga_control (
    //     .VGA_CLK(~VGA_CLK),
    //     .RESET(~DLY_RST_2),
    //     .BOX_ENABLE(SW[17]),
    //     .BOX_LEFT(10'd270),
    //     .BOX_RIGHT(10'd370),
    //     .BOX_TOP(10'd190),
    //     .BOX_BOTTOM(10'd290),
    //     .VGA_R_IN(gray[7:0]),
    //     .VGA_G_IN(gray[7:0]),
    //     .VGA_B_IN(gray[7:0]),
    //     .VGA_R(VGA_R),
    //     .VGA_G(VGA_G),
    //     .VGA_B(VGA_B),
    //     .VGA_BLANK_N(VGA_BLANK_N),
    //     .VGA_SYNC_N(VGA_SYNC_N),
    //     .VGA_HS(VGA_HS),
    //     .VGA_VS(VGA_VS),
    //     .REQUEST_DATA(VGA_Req)
    // );

endmodule // armor_recog
