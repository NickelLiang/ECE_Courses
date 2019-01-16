module vga_signal (
    input  logic        VGA_CLK,
    input  logic        RESET,
    output logic [9:0]  SCREEN_X, SCREEN_Y,
    output logic        VGA_BLANK_N,
    output logic        VGA_SYNC_N,
    output logic        VGA_HS,
    output logic        VGA_VS,
    output logic        REQUEST_DATA
    );

    `include "vga_control_param.h"

    logic [9:0] SCREEN_X_m, SCREEN_Y_m;
    logic       VGA_HS_m, VGA_VS_m, VGA_BLANK_N_m, VGA_SYNC_N_m;
    logic       REQUEST_DATA_m;

    always_ff @ (posedge VGA_CLK or posedge RESET) begin
        if (RESET) begin
            SCREEN_X        <= 10'd0;
            SCREEN_Y        <= 10'd0;
            VGA_HS          <= 1'b0;
            VGA_VS          <= 1'b0;
            VGA_BLANK_N     <= 1'b0;
            VGA_SYNC_N      <= 1'b0;
            REQUEST_DATA    <= 1'b0;
        end else begin
            SCREEN_X        <= SCREEN_X_m;
            SCREEN_Y        <= SCREEN_Y_m;
            VGA_HS          <= VGA_HS_m;
            VGA_VS          <= VGA_VS_m;
            VGA_BLANK_N     <= VGA_BLANK_N_m;
            VGA_SYNC_N      <= VGA_SYNC_N_m;
            REQUEST_DATA    <= REQUEST_DATA_m;
        end
    end

    always_comb begin
        // Screen Position Logic
        SCREEN_X_m = SCREEN_X + 10'd1;
        SCREEN_Y_m = SCREEN_Y;
        if (SCREEN_X_m == HS_TOTAL) begin
            SCREEN_X_m = 10'd0;
            SCREEN_Y_m = SCREEN_Y + 10'd1;
            if (SCREEN_Y_m == VS_TOTAL)
                SCREEN_Y_m = 10'd0;
        end

        // Horizontal Sync Logic
        VGA_HS_m = 1'b1;
        // Extra 4 is used to compensate clock. We can only generate 25MHz while VGA require 25.175MHz.
        if (SCREEN_X_m >= HS_ACT + HS_FRONT + 4 && SCREEN_X_m < HS_ACT + HS_FRONT + HS_SYC)
            VGA_HS_m = 1'b0;

        // Vertical Sync Logic
        VGA_VS_m = 1'b1;
        if (SCREEN_Y_m >= VS_ACT + VS_FRONT && SCREEN_Y_m < VS_ACT + VS_FRONT + VS_SYC)
            VGA_VS_m = 1'b0;

        // Blanking Logic
        VGA_BLANK_N_m = 1'b0;
        if (SCREEN_X_m < HS_ACT && SCREEN_Y_m < VS_ACT)
            VGA_BLANK_N_m = 1'b1;

        // Sync Logic
        VGA_SYNC_N_m = 1'b0;

        // Request Data Logic
        REQUEST_DATA_m = 1'b0;
        if ((SCREEN_X_m >= HS_TOTAL - FIFO_PRE || SCREEN_X_m < HS_ACT - FIFO_PRE) &&
            SCREEN_Y_m < VS_ACT)
            REQUEST_DATA_m = 1'b1;
    end
endmodule // vga_signal
