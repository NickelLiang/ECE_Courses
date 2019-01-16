module vga_control (
    input  logic        VGA_CLK,
    input  logic        RESET,
    input  logic        BOX_ENABLE,
    input  logic [ 9:0] BOX_LEFT, BOX_TOP, BOX_RIGHT, BOX_BOTTOM,
    input  logic [ 7:0] VGA_R_IN, VGA_G_IN, VGA_B_IN,
    input  logic [ 7:0] IMG1_DATA, IMG2_DATA, IMG3_DATA, IMG4_DATA,
    input  logic        DIVIDE_ENABLE,
    input  logic [ 3:0] IMG1_CHANNEL, IMG2_CHANNEL, IMG3_CHANNEL, IMG4_CHANNEL,
    input  logic        IMG1_ENLARGE, IMG2_ENLARGE, IMG3_ENLARGE, IMG4_ENLARGE,
    output logic [16:0] IMG1_RDADDR, IMG2_RDADDR, IMG3_RDADDR, IMG4_RDADDR,
    output logic [ 7:0] VGA_R, VGA_G, VGA_B,
    output logic        VGA_BLANK_N,
    output logic        VGA_SYNC_N,
    output logic        VGA_HS,
    output logic        VGA_VS,
    output logic        REQUEST_DATA
    );

    logic [9:0] SCREEN_X, SCREEN_Y;

    vga_signal vga_signal(.*);
    vga_color vga_color(.*);

endmodule // vga_control
