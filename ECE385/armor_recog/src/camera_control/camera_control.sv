module camera_control (
    input  logic        D5M_PIXLCLK,
    input  logic        CLOCK2_50,
    input  logic        DLY_RST_1,
    input  logic        DLY_RST_2,
    input  logic        RESTART,
    input  logic        STOP,
    input  logic [11:0] D5M_D,
    input  logic        D5M_LVAL,
    input  logic        D5M_FVAL,
    input  logic        EXPOSURE_ADJ,
    input  logic        EXPOSURE_ACT,
    output logic [31:0] FRAME_CONT,
    output logic [15:0] EXPOSURE_VAL,
    output logic [11:0] CCD_R,
    output logic [11:0] CCD_G,
    output logic [11:0] CCD_B,
    output logic        CCD_DVAL,
    output logic        D5M_TRIGGER,
    output logic        D5M_RESET_N,
    output logic        D5M_SCLK,
    inout  wire         D5M_SDATA
    );

    logic [11:0]    CAPTURE_DATA_m;
    logic           CAPTURE_DVAL_m;
    logic [11:0]    CCD_DATA_m;
    logic           CCD_FVAL_m;
    logic           CCD_LVAL_m;
    logic [15:0]    X_CNT_m;
    logic [15:0]    Y_CNT_m;

    assign D5M_RESET_N  = DLY_RST_1;
    assign D5M_TRIGGER  = 1'b1;

    always_ff @ (posedge D5M_PIXLCLK) begin
        CCD_DATA_m  <= D5M_D;
        CCD_FVAL_m  <= D5M_FVAL;
        CCD_LVAL_m  <= D5M_LVAL;
    end

    camera_config cam_config (
        .iCLK           (CLOCK2_50),
        .iRST_N         (DLY_RST_2),
        .iEXPOSURE_ADJ  (EXPOSURE_ADJ),
        .iEXPOSURE_DEC_p(EXPOSURE_ACT),
        .EXPOSURE       (EXPOSURE_VAL),
        .I2C_SCLK       (D5M_SCLK),
        .I2C_SDAT       (D5M_SDATA)
    );

    camera_capture capture (
        .oDATA      (CAPTURE_DATA_m),
        .oDVAL      (CAPTURE_DVAL_m),
        .oX_Cont    (X_CNT_m),
        .oY_Cont    (Y_CNT_m),
        .oFrame_Cont(FRAME_CONT),
        .iDATA      (CCD_DATA_m),
        .iFVAL      (CCD_FVAL_m),
        .iLVAL      (CCD_LVAL_m),
        .iSTART     (RESTART),
        .iEND       (STOP),
        .iCLK       (~D5M_PIXLCLK),
        .iRST       (DLY_RST_2)
    );

    camera_bayer2rgb bayer2rgb (
        .iCLK       (D5M_PIXLCLK),
        .iRST       (DLY_RST_1),
        .iDATA      (CAPTURE_DATA_m),
        .iDVAL      (CAPTURE_DVAL_m),
        .oRed       (CCD_R),
        .oGreen     (CCD_G),
        .oBlue      (CCD_B),
        .oDVAL      (CCD_DVAL),
        .iX_Cont    (X_CNT_m),
        .iY_Cont    (Y_CNT_m)
    );

endmodule // camera_control
