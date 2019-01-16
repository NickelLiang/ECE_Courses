// VGA Signal Format |ACT|_SYC_|BACK|FRONT|
// Note: Remember to change bit width if modify resolution
// Horizontal Pixel Parameter
parameter HS_ACT        = 10'd640;
parameter HS_SYC        = 10'd96;
parameter HS_BACK       = 10'd48;
parameter HS_FRONT      = 10'd16;
parameter HS_TOTAL      = 10'd800;

// Vertical Line Parameter
parameter VS_ACT        = 10'd480;
parameter VS_SYC        = 10'd2;
parameter VS_BACK       = 10'd33;
parameter VS_FRONT      = 10'd10;
parameter VS_TOTAL      = 10'd525;

// FIFO Related Magic Number
parameter FIFO_PRE      = 10'd2;

// Box Property
parameter BOX_R         = 8'h0;
parameter BOX_G         = 8'hFF;
parameter BOX_B         = 8'h0;
parameter BOX_LINE_W    = 4'd1; // Line Width of the Box

parameter IMG_ADDR_MAX  = 17'd76800;    // 320*240
parameter IMG_RED       = 4'b1000;
parameter IMG_GREEN     = 4'b0100;
parameter IMG_BLUE      = 4'b0010;
parameter IMG_GRAY      = 4'b0001;
// vga_control u1 (
//     .VGA_CLK(VGA_CLK),
//     .RESET(DLY_RST_2),
//     .BOX_ENABLE(SW[17]),
//     .BOX_LEFT(10'd270),
//     .BOX_RIGHT(10'd370),
//     .BOX_TOP(10'd190),
//     .BOX_BOTTOM(10'd290),
//     .VGA_R_IN(8'hFF),
//     .VGA_G_IN(8'hFF),
//     .VGA_B_IN(8'hFF),
//     .VGA_R(VGA_R),
//     .VGA_G(VGA_G),
//     .VGA_B(VGA_B),
//     .VGA_BLANK_N(VGA_BLANK_N),
//     .VGA_SYNC_N(VGA_SYNC_N),
//     .VGA_HS(VGA_HS),
//     .VGA_VS(VGA_VS),
//     .REQUEST_DATA()
// );
