module vga_control (
    input  logic        VGA_CLK,
    input  logic        RESET,
    input  logic        BOX_ENABLE,
    input  logic [9:0]  BOX_LEFT, BOX_TOP, BOX_RIGHT, BOX_BOTTOM,
    input  logic [7:0]  VGA_R_IN, VGA_G_IN, VGA_B_IN,
    output logic [7:0]  VGA_R, VGA_G, VGA_B,
    output logic        VGA_BLANK_N,
    output logic        VGA_SYNC_N,
    output logic        VGA_HS,
    output logic        VGA_VS,
    output logic        REQUEST_DATA
    );

    logic [9:0] SCREEN_X, SCREEN_Y;

    vga_signal vga_signal (.*);
    vga_color vga_color (.*);

endmodule // vga_control
