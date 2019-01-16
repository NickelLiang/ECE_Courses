module camera_config (
    input  logic        iCLK,
    input  logic        iRST_N,
    input  logic        iEXPOSURE_ADJ,
    input  logic        iEXPOSURE_DEC_p,
    output logic [15:0] EXPOSURE,
    output logic        I2C_SCLK,
    inout  wire         I2C_SDAT
    );

    // Internal Registers/Wires
    logic   [15:0]  mI2C_CLK_DIV;
    logic   [31:0]  mI2C_DATA;
    logic           mI2C_CTRL_CLK;
    logic           mI2C_GO;
    logic           mI2C_END;
    logic           mI2C_ACK;
    logic   [23:0]  LUT_DATA;
    logic   [5:0]   LUT_INDEX;
    logic   [3:0]   mSetup_ST;
    logic   [24:0]  combo_cnt;
    logic           combo_pulse;
    logic   [3:0]   iexposure_adj_delay;
    logic           exposure_adj_set;
    logic           exposure_adj_reset;
    logic   [15:0]  senosr_exposure;
    logic   [17:0]  senosr_exposure_temp;
    logic           i2c_reset;

    parameter   default_exposure        = 16'h0210;
    parameter   exposure_change_value   = 16'h10;
    // Clock Setting
    parameter   CLK_Freq                = 50000000;   // 50MHz
    parameter   I2C_Freq                = 20000;      // 20KHz
    // I2C Data Number
    parameter   LUT_SIZE                = 24;

    assign      EXPOSURE                = senosr_exposure;
    assign      exposure_adj_set        = ({iexposure_adj_delay[0], iEXPOSURE_ADJ} == 2'b10) ? 1'b1 : 1'b0 ;
    assign      exposure_adj_reset      = ({iexposure_adj_delay[3:2]} == 2'b10) ? 1'b1 : 1'b0 ;
    assign      senosr_exposure_temp    = iEXPOSURE_DEC_p ? (senosr_exposure - exposure_change_value) : (senosr_exposure + exposure_change_value);
    assign      combo_pulse             = (combo_cnt == 25'h1fffff) ? 1'b1 : 1'b0;
    assign      i2c_reset               = iRST_N & ~exposure_adj_reset & ~combo_pulse;

    always @ (posedge iCLK or negedge iRST_N) begin
        if (!iRST_N) begin
            iexposure_adj_delay     <= 4'b0;
        end else begin
            iexposure_adj_delay     <= {iexposure_adj_delay[2:0], iEXPOSURE_ADJ};
        end
    end

    always @ (posedge iCLK or negedge iRST_N) begin
        if (!iRST_N)
            senosr_exposure         <= default_exposure;
        else if (exposure_adj_set | combo_pulse)
            if (senosr_exposure_temp[17])
                senosr_exposure     <= 16'b0;
            else if (senosr_exposure_temp[16])
                senosr_exposure     <= 16'hffff;
            else
                senosr_exposure     <= senosr_exposure_temp[15:0];
    end

    always @ (posedge iCLK or negedge iRST_N) begin
        if (!iRST_N)
            combo_cnt   <= 25'b0;
        else if (!iexposure_adj_delay[3])
            combo_cnt   <= combo_cnt + 25'b1;
        else
            combo_cnt   <= 25'b0;
    end

    // I2C Clock Generation
    always @ (posedge iCLK or negedge i2c_reset) begin
        if (!i2c_reset) begin
            mI2C_CTRL_CLK       <= 1'b0;
            mI2C_CLK_DIV        <= 16'b0;
        end
        else begin
            if (mI2C_CLK_DIV < (CLK_Freq / I2C_Freq))
                mI2C_CLK_DIV    <= mI2C_CLK_DIV + 16'b1;
            else begin
                mI2C_CLK_DIV    <= 16'b0;
                mI2C_CTRL_CLK   <= ~mI2C_CTRL_CLK;
            end
        end
    end

    i2c_control i2c_control (
        .CLOCK(mI2C_CTRL_CLK),  // Controller Work Clock
        .I2C_SCLK(I2C_SCLK),    // I2C CLOCK
        .I2C_SDAT(I2C_SDAT),    // I2C DATA
        .I2C_DATA(mI2C_DATA),   // DATA:[SLAVE_ADDR,SUB_ADDR,DATA]
        .GO(mI2C_GO),           // GO transfor
        .END(mI2C_END),         // END transfor
        .ACK(mI2C_ACK),         // ACK
        .RESET(i2c_reset)
    );

    // I2C Configuration Control
    // always @ (posedge mI2C_CTRL_CLK or negedge iRST_N)
    always @ (posedge mI2C_CTRL_CLK or negedge i2c_reset) begin
        if (!i2c_reset) begin
            LUT_INDEX   <= 6'b0;
            mSetup_ST   <= 4'b0;
            mI2C_GO     <= 1'b0;
        end
        else if (LUT_INDEX < LUT_SIZE) begin
            case (mSetup_ST)
                0: begin
                    mI2C_DATA   <= {8'hBA, LUT_DATA};   // Write to 0xBA(Camera) with LUT_DATA content
                    mI2C_GO     <= 1'b1;                   // I2C GO need to remain high until end of transmission
                    mSetup_ST   <= 4'b1;
                end
                1:  begin
                    if (mI2C_END) begin
                        if (!mI2C_ACK)                  // ACK is LOW, slave received the msg, proceed to next msg
                            mSetup_ST   <= 4'd2;
                        else
                            mSetup_ST   <= 4'b0;           // ACK is HIGH, slave didnot receive the msg, redo tx
                        mI2C_GO     <= 1'b0;
                    end
                end
                14:  begin
                    LUT_INDEX   <= LUT_INDEX + 6'b1;
                    mSetup_ST   <= 4'b0;
                end
                default: mSetup_ST <= mSetup_ST + 4'b1;    // Delay for 13 cycles between writing different registers
            endcase
        end
    end

    // I2C Configuration Data
    always begin
        case (LUT_INDEX)
                // sync & pause restart not quite working correctly
            //0 : LUT_DATA    <=  24'h071F83;             // Sync Change Hold
            //1 : LUT_DATA    <=  24'h0B0011;             // Pause Restart

            2 : LUT_DATA    <=  24'h010036;                 // 0x01: Row Start              | Set start row
            3 : LUT_DATA    <=  24'h020010;                 // 0x02: Column Start           | Set start column
            4 : LUT_DATA    <=  24'h03077F;                 // 0x03: Row Size               | Set row size
            5 : LUT_DATA    <=  24'h0409FF;                 // 0x04: Column Size            | Set column size
            6 : LUT_DATA    <=  24'h220011;                 // 0x22: Row Address Mode       | Set row mode in bin mode
            7 : LUT_DATA    <=  24'h230011;                 // 0x23: Column Address Mode    | Set column mode in bin mode
            8 : LUT_DATA    <=  24'h20C000;                 // 0x20: Read Mode 2            | 0xC000 = 1100 Row and Columns are mirrored.
            9 : LUT_DATA    <=  {8'h09, senosr_exposure};   // 0x09: Shutter Width Lower    | Exposure control.
            10: LUT_DATA    <=  24'h050000;                 // 0x05: Horizontal Blank       | Affect exposure and frame rate. Default 0x0000. 3C / F0 / 1E0 /
            11: LUT_DATA    <=  24'h060019;                 // 0x06: Vertical Blank         | Affect exposure but not frame rate. Default 0x0019.
            12: LUT_DATA    <=  24'h0A8000;                 // 0x0A: Pixel Clock Control    | Invert Pixel Clock is set. When set, LVAL, FVAL, and D[11:0] should be captured on the rising edge of PIXCLK.
            13: LUT_DATA    <=  24'h2B0013;                 // 0x2B: Green 1 Gain           | 0x0013 = 0 0 0 010011. [5:0] = 19, effective gain is 1*1*19/8 = 1.625. Refer datashhet p23.
            14: LUT_DATA    <=  24'h2C009A;                 // 0x2C: Blue Gain              | 0x009A = 0 1 0 011010. [5:0] = 26, effective gain is 1*1*26/8 = 3.25. *****Why bit 7 is set?*****
            15: LUT_DATA    <=  24'h2D019C;                 // 0x2D: Red Gain               | 0x019C = 1 1 0 011100. [14:8] = 1, [5:0] = 28, effective gain is (1/8+1)*1*28/8 = 3.9375.
            16: LUT_DATA    <=  24'h2E0013;                 // 0x2E: Green 2 Gain           | 0x0013 = 0 0 0 010011. [5:0] = 19, effective gain is 1*1*19/8 = 1.625.
            17: LUT_DATA    <=  24'h100051;                 // 0x10: PLL Control            | Default 0x0050. [1] Use PLL, [0] Power PLL. Power up PLL.
            // ===== XCLKIN=25MHz, PIXCLK=75MHz ===== At MEM=100MHz, perfect. At MEM=125MHz, little noisy
            18: LUT_DATA    <=  24'h111E04;                 // 0x11: PLL Config 1           | 0x1E04 = 00011110 00 000100. PLL_m_Factor = 30, PLL_n_Divider = 4. PIXCLK = (XCLKIN * M) / (N * P1).
            19: LUT_DATA    <=  24'h120001;                 // 0x12: PLL Config 2           | 0x0001 = 1. PLL_p1_Divider = 1. PIXCLK = (XCLKIN * PLL_m_Factor)/((PLL_n_Divider+1)*(PLL_p1_Divider+1)) = 75MHz when XCLKIN is 25MHz.
            // ===== XCLKIN=25MHz, PIXCLK=80MHz ===== At MEM=125MHz, redish with green line
            // 18: LUT_DATA    <=  24'h112004;                 // 0x11: PLL Config 1           | 0x1E04 = 00100000 00 000100. PLL_m_Factor = 32, PLL_n_Divider = 4. PIXCLK = (XCLKIN * M) / (N * P1).
            // 19: LUT_DATA    <=  24'h120001;                 // 0x12: PLL Config 2           | 0x0001 = 1. PLL_p1_Divider = 1. PIXCLK = (XCLKIN * PLL_m_Factor)/((PLL_n_Divider+1)*(PLL_p1_Divider+1)) = 80MHz when XCLKIN is 25MHz.
            // ===== XCLKIN=25MHz, PIXCLK=85MHz ===== At MEM=125MHz,
            // 18: LUT_DATA    <=  24'h112404;                 // 0x11: PLL Config 1           | 0x1E04 = 00100100 00 000100. PLL_m_Factor = 36, PLL_n_Divider = 4. PIXCLK = (XCLKIN * M) / (N * P1).
            // 19: LUT_DATA    <=  24'h120001;                 // 0x12: PLL Config 2           | 0x0001 = 1. PLL_p1_Divider = 1. PIXCLK = (XCLKIN * PLL_m_Factor)/((PLL_n_Divider+1)*(PLL_p1_Divider+1)) = 90MHz when XCLKIN is 25MHz.
            // ======================================
            20: LUT_DATA    <=  24'h100053;                 // 0x10: PLL Control            | PLL remain power up, set Use PLL.
            21: LUT_DATA    <=  24'h620000;                 // 0x62: Black_Level_Cali       | Disble calibration

            //22: LUT_DATA    <=  24'h071F82;             // Sync Change Release
            //23: LUT_DATA    <=  24'h0B0001;             // Restart
            default :
                LUT_DATA    <=  24'h000000;
        endcase
    end

endmodule // camera_config
