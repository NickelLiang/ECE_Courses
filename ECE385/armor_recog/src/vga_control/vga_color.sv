module vga_color (
    input  logic        VGA_CLK,
    input  logic        RESET,
    input  logic        BOX_ENABLE,
    input  logic [9:0]  SCREEN_X, SCREEN_Y,
    input  logic [9:0]  BOX_LEFT, BOX_TOP, BOX_RIGHT, BOX_BOTTOM,
    input  logic [7:0]  VGA_R_IN, VGA_G_IN, VGA_B_IN,
    input  logic        DIVIDE_ENABLE,
    input  logic        IMG1_ENLARGE, IMG2_ENLARGE, IMG3_ENLARGE, IMG4_ENLARGE,
    input  logic [7:0]  IMG1_DATA, IMG2_DATA, IMG3_DATA, IMG4_DATA,
    input  logic [3:0]  IMG1_CHANNEL, IMG2_CHANNEL, IMG3_CHANNEL, IMG4_CHANNEL,
    output logic [7:0]  VGA_R, VGA_G, VGA_B
    );

    `include "vga_control_param.h"

    logic [7:0] VGA_R_m, VGA_G_m, VGA_B_m;

    always_ff @ (posedge VGA_CLK or posedge RESET) begin
        if (RESET) begin
            VGA_R <= 8'd0;
            VGA_G <= 8'd0;
            VGA_B <= 8'd0;
        end else begin
            VGA_R <= VGA_R_m;
            VGA_G <= VGA_G_m;
            VGA_B <= VGA_B_m;
        end
    end

    always_comb begin
        VGA_R_m = 8'h00;
        VGA_G_m = 8'h00;
        VGA_B_m = 8'h00;
        if (SCREEN_X < HS_ACT && SCREEN_Y < VS_ACT) begin
            if (!DIVIDE_ENABLE) begin // Original RGB Output
                VGA_R_m = VGA_R_IN;
                VGA_G_m = VGA_G_IN;
                VGA_B_m = VGA_B_IN;
            end else begin
                if (IMG1_ENLARGE) begin // IMG1 Full Screen
                    if (IMG1_CHANNEL & (IMG_RED | IMG_GRAY))
                        VGA_R_m = IMG1_DATA;
                    if (IMG1_CHANNEL & (IMG_GREEN | IMG_GRAY))
                        VGA_G_m = IMG1_DATA;
                    if (IMG1_CHANNEL & (IMG_BLUE | IMG_GRAY))
                        VGA_B_m = IMG1_DATA;
                end else if (IMG2_ENLARGE) begin // IMG2 Full Screen
                    if (IMG2_CHANNEL & (IMG_RED | IMG_GRAY))
                        VGA_R_m = IMG2_DATA;
                    if (IMG2_CHANNEL & (IMG_GREEN | IMG_GRAY))
                        VGA_G_m = IMG2_DATA;
                    if (IMG2_CHANNEL & (IMG_BLUE | IMG_GRAY))
                        VGA_B_m = IMG2_DATA;
                end else if (IMG3_ENLARGE) begin // IMG3 Full Screen
                    if (IMG3_CHANNEL & (IMG_RED | IMG_GRAY))
                        VGA_R_m = IMG3_DATA;
                    if (IMG3_CHANNEL & (IMG_GREEN | IMG_GRAY))
                        VGA_G_m = IMG3_DATA;
                    if (IMG3_CHANNEL & (IMG_BLUE | IMG_GRAY))
                        VGA_B_m = IMG3_DATA;
                end else if (IMG4_ENLARGE) begin // IMG4 Full Screen
                    if (IMG4_CHANNEL & (IMG_RED | IMG_GRAY))
                        VGA_R_m = IMG4_DATA;
                    if (IMG4_CHANNEL & (IMG_GREEN | IMG_GRAY))
                        VGA_G_m = IMG4_DATA;
                    if (IMG4_CHANNEL & (IMG_BLUE | IMG_GRAY))
                        VGA_B_m = IMG4_DATA;
                end else begin // Four Split Screen
                    if (SCREEN_X < HS_ACT / 2 && SCREEN_Y < VS_ACT / 2) begin
                        if (IMG1_CHANNEL & (IMG_RED | IMG_GRAY))
                            VGA_R_m = IMG1_DATA;
                        if (IMG1_CHANNEL & (IMG_GREEN | IMG_GRAY))
                            VGA_G_m = IMG1_DATA;
                        if (IMG1_CHANNEL & (IMG_BLUE | IMG_GRAY))
                            VGA_B_m = IMG1_DATA;
                    end else if (SCREEN_X >= HS_ACT / 2 && SCREEN_Y < VS_ACT / 2) begin
                        if (IMG2_CHANNEL & (IMG_RED | IMG_GRAY))
                            VGA_R_m = IMG2_DATA;
                        if (IMG2_CHANNEL & (IMG_GREEN | IMG_GRAY))
                            VGA_G_m = IMG2_DATA;
                        if (IMG2_CHANNEL & (IMG_BLUE | IMG_GRAY))
                            VGA_B_m = IMG2_DATA;
                    end else if (SCREEN_X < HS_ACT / 2 && SCREEN_Y >= VS_ACT / 2) begin
                        if (IMG3_CHANNEL & (IMG_RED | IMG_GRAY))
                            VGA_R_m = IMG3_DATA;
                        if (IMG3_CHANNEL & (IMG_GREEN | IMG_GRAY))
                            VGA_G_m = IMG3_DATA;
                        if (IMG3_CHANNEL & (IMG_BLUE | IMG_GRAY))
                            VGA_B_m = IMG3_DATA;
                    end else begin
                        if (IMG4_CHANNEL & (IMG_RED | IMG_GRAY))
                            VGA_R_m = IMG4_DATA;
                        if (IMG4_CHANNEL & (IMG_GREEN | IMG_GRAY))
                            VGA_G_m = IMG4_DATA;
                        if (IMG4_CHANNEL & (IMG_BLUE | IMG_GRAY))
                            VGA_B_m = IMG4_DATA;
                    end
                end
            end
            if (BOX_ENABLE && (
                ((SCREEN_X == BOX_LEFT || SCREEN_X == BOX_RIGHT) && SCREEN_Y >= BOX_TOP && SCREEN_Y <= BOX_BOTTOM) ||
                ((SCREEN_Y == BOX_TOP || SCREEN_Y == BOX_BOTTOM) && SCREEN_X >= BOX_LEFT && SCREEN_X <= BOX_RIGHT)
                )) begin // Draw Box
                VGA_R_m = BOX_R;
                VGA_G_m = BOX_G;
                VGA_B_m = BOX_B;
            end
        end
    end

endmodule // vga_color
