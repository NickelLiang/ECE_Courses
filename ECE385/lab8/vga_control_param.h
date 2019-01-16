// VGA Signal Format |ACT|_SYC_|BACK|FRONT|

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
