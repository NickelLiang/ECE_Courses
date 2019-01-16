module ripple_adder
(
    input   logic [15:0]    A,
    input   logic [15:0]    B,
    output  logic [15:0]    Sum,
    output  logic           CO
);

    /* TODO
     *
     * Insert code here to implement a ripple adder.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
    
    logic c1, c2, c3;
    ripple_adder_4 RP4_0(.a(A[3:0]), .b(B[3:0]), .c_in(1'b0), .s(Sum[3:0]), .c_out(c1));
    ripple_adder_4 RP4_1(.a(A[7:4]), .b(B[7:4]), .c_in(c1), .s(Sum[7:4]), .c_out(c2));
    ripple_adder_4 RP4_2(.a(A[11:8]), .b(B[11:8]), .c_in(c2), .s(Sum[11:8]), .c_out(c3));
    ripple_adder_4 RP4_3(.a(A[15:12]), .b(B[15:12]), .c_in(c3), .s(Sum[15:12]), .c_out(CO));
     
endmodule

module ripple_adder_4
(
    input   logic [3:0]  a,
    input   logic [3:0] b,
    input   logic       c_in,
    output  logic [3:0] s,
    output  logic       c_out
);

    logic c1, c2, c3;
    full_adder FA0(.a(a[0]), .b(b[0]), .c_in(c_in), .s(s[0]), .c_out(c1));
    full_adder FA1(.a(a[1]), .b(b[1]), .c_in(c1), .s(s[1]), .c_out(c2));
    full_adder FA2(.a(a[2]), .b(b[2]), .c_in(c2), .s(s[2]), .c_out(c3));
    full_adder FA3(.a(a[3]), .b(b[3]), .c_in(c3), .s(s[3]), .c_out(c_out));

endmodule

module full_adder(input logic a, b, c_in,
                output logic s, c_out);

    always_comb begin
        s = a ^ b ^ c_in;
        c_out = (a&b) | (b&c_in) | (a&c_in);
    end

endmodule

