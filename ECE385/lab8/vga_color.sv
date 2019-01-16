module vga_color (
    input  logic        VGA_CLK,
    input  logic        RESET,
    input  logic        BOX_ENABLE,
    input  logic [9:0]  SCREEN_X, SCREEN_Y,
    input  logic [9:0]  BOX_LEFT, BOX_TOP, BOX_RIGHT, BOX_BOTTOM,
    input  logic [7:0]  VGA_R_IN, VGA_G_IN, VGA_B_IN,
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
        VGA_R_m = 8'd0;
        VGA_G_m = 8'd0;
        VGA_B_m = 8'd0;
        if (SCREEN_X < HS_ACT && SCREEN_Y < VS_ACT) begin
            VGA_R_m = VGA_R_IN;
            VGA_G_m = VGA_G_IN;
            VGA_B_m = VGA_B_IN;
            if (BOX_ENABLE &&
                SCREEN_X > BOX_LEFT - BOX_LINE_W &&
                SCREEN_X < BOX_RIGHT + BOX_LINE_W &&
                SCREEN_Y > BOX_TOP - BOX_LINE_W &&
                SCREEN_Y < BOX_BOTTOM + BOX_LINE_W
                ) begin
                VGA_R_m = BOX_R;
                VGA_G_m = BOX_G;
                VGA_B_m = BOX_B;
                if (SCREEN_X > BOX_LEFT &&
                    SCREEN_X < BOX_RIGHT &&
                    SCREEN_Y > BOX_TOP &&
                    SCREEN_Y < BOX_BOTTOM
                    ) begin
                    VGA_R_m = VGA_R_IN;
                    VGA_G_m = VGA_G_IN;
                    VGA_B_m = VGA_B_IN;
                end
            end
        end
    end

endmodule // vga_color
