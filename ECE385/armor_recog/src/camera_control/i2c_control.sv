module i2c_control (
    input  logic        CLOCK,
    input  logic        RESET,
    input  logic [31:0] I2C_DATA,
    input  logic        W_R,
    input  logic        GO,
    inout  wire         I2C_SDAT,
    output logic        I2C_SCLK,
    output logic        END,
    output logic        ACK
    );

    reg             SDO;        // Internal Serial Data Output
    reg             SCLK;       // Internal Serial Clock
    reg     [31:0]  SD;         // Serial Data
    reg     [6:0]   SD_COUNTER; // Counter for message transmit
    reg             ACK1, ACK2, ACK3, ACK4;

    assign  I2C_SCLK = SCLK | (((SD_COUNTER >= 7'd4) & (SD_COUNTER <= 7'd39)) ? ~CLOCK : 1'b0);
    assign  I2C_SDAT = SDO ? 1'bz : 1'b0;     // High Z will be 1 since bus is pulled up, so slave can write some msg onto bus
    assign  ACK = ACK1 | ACK2 | ACK3 | ACK4;   // ACK is made by slave pulling data line LOW

    // I2C Counter
    always @ (negedge RESET or posedge CLOCK) begin
        if (!RESET)
            SD_COUNTER = 6'b111111; // So next cycle it is 0
        else begin
            if (GO == 1'b0)
                SD_COUNTER = 7'd0;
            else if (SD_COUNTER < 7'd41)
                SD_COUNTER = SD_COUNTER + 7'd1;
            end
    end

    // I2C Write Routine
    always @ (negedge RESET or  posedge CLOCK ) begin
        if (!RESET) begin
            SCLK = 1'b1;
            SDO  = 1'b1;
            ACK1 = 1'b0;
            ACK2 = 1'b0;
            ACK3 = 1'b0;
            ACK4 = 1'b0;
            END  = 1'b1;
        end
        else begin
            case (SD_COUNTER)
                6'd0  : begin
                        ACK1    = 1'b0;
                        ACK2    = 1'b0;
                        ACK3    = 1'b0;
                        ACK4    = 1'b0;
                        END     = 1'b0;
                        SDO     = 1'b1;
                        SCLK    = 1'b1;
                        end

                // Start.
                // The start bit is defined as a HIGH-to-LOW transition of the data line while the clock line is HIGH.
                6'd1  : begin
                        SD      = I2C_DATA;
                        SDO     = 1'b0;
                        end
                6'd2  : SCLK    = 1'b0;

                // Slave Device ADDR
                // The 8-bit address of a two-wire serial interface device consists of seven bits of address and 1 bit of direction.
                // 0xBA write mode / 0xBB read mode
                6'd3  : SDO     = SD[31];
                6'd4  : SDO     = SD[30];
                6'd5  : SDO     = SD[29];
                6'd6  : SDO     = SD[28];
                6'd7  : SDO     = SD[27];
                6'd8  : SDO     = SD[26];
                6'd9  : SDO     = SD[25];
                6'd10 : SDO     = SD[24];   // 0 indicates a write and a 1 indicates a read.
                6'd11 : SDO     = 1'b1;     // ACK, high Z to prevent bus conflict

                // Register ADDR
                6'd12 : begin
                        SDO     = SD[23];
                        ACK1    = I2C_SDAT; // Slave send back acknowledgement
                        end
                6'd13 : SDO     = SD[22];
                6'd14 : SDO     = SD[21];
                6'd15 : SDO     = SD[20];
                6'd16 : SDO     = SD[19];
                6'd17 : SDO     = SD[18];
                6'd18 : SDO     = SD[17];
                6'd19 : SDO     = SD[16];
                6'd20 : SDO     = 1'b1;     // ACK

                // Data Higher Byte
                6'd21 : begin
                        SDO     = SD[15];
                        ACK2    = I2C_SDAT;
                        end
                6'd22 : SDO     = SD[14];
                6'd23 : SDO     = SD[13];
                6'd24 : SDO     = SD[12];
                6'd25 : SDO     = SD[11];
                6'd26 : SDO     = SD[10];
                6'd27 : SDO     = SD[9];
                6'd28 : SDO     = SD[8];
                6'd29 : SDO     = 1'b1;     // ACK

                // Data Lower Byte
                6'd30 : begin
                        SDO     = SD[7];
                        ACK3    = I2C_SDAT;
                        end
                6'd31 : SDO     = SD[6];
                6'd32 : SDO     = SD[5];
                6'd33 : SDO     = SD[4];
                6'd34 : SDO     = SD[3];
                6'd35 : SDO     = SD[2];
                6'd36 : SDO     = SD[1];
                6'd37 : SDO     = SD[0];
                6'd38 : SDO     = 1'b1;     // ACK

                // Stop. We are not using auto-address increment.
                // The stop bit is defined as a LOW-to-HIGH transition of the data line while the clock line is HIGH.
                6'd39 : begin
                        SDO     = 1'b0;
                        SCLK    = 1'b0;
                        ACK4    = I2C_SDAT;
                        end
                6'd40 : SCLK    = 1'b1;  // The bus is idle when both the data and clock lines are HIGH.
                6'd41 : begin
                        SDO     = 1'b1;
                        END     = 1'b1;
                        end
            endcase
        end
    end

endmodule // i2c_control
