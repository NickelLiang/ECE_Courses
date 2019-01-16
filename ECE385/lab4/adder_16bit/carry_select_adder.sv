module carry_select_adder
(
    input   logic [15:0]    A,
    input   logic [15:0]    B,
    output  logic [15:0]    Sum,
    output  logic           CO
);

    /* TODO
     *
     * Insert code here to implement a carry select.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */

    logic c1, c2, c3;

    carry_group_4 CP4_0(.a(A[3:0]), .b(B[3:0]), .c_in(1'b0), .s(Sum[3:0]), .c_out(c1));
    carry_group_4 CP4_1(.a(A[7:4]), .b(B[7:4]), .c_in(c1), .s(Sum[7:4]), .c_out(c2));
    carry_group_4 CP4_2(.a(A[11:8]), .b(B[11:8]), .c_in(c2), .s(Sum[11:8]), .c_out(c3));
    carry_group_4 CP4_3(.a(A[15:12]), .b(B[15:12]), .c_in(c3), .s(Sum[15:12]), .c_out(CO));
     
endmodule

module carry_group_4
(
    input   logic [3:0] a,
    input   logic [3:0] b,
    input   logic       c_in,
    output  logic [3:0] s,
    output  logic       c_out
);

    logic c_out0, c_out1;
    logic [3:0] s0, s1;

    ripple_adder_4 RA0(.a, .b, .c_in(1'b0), .s(s0), .c_out(c_out0));
    ripple_adder_4 RA1(.a, .b, .c_in(1'b1), .s(s1), .c_out(c_out1));

    always_comb begin
        c_out = c_out0;
        s = s0;
        if (c_in) begin
            c_out = c_out1;
            s = s1;
        end
    end

endmodule
