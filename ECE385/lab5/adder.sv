module adder_9bit (
    input   logic [8:0] A,
    input   logic [8:0] B,
    input   logic       F,  // Perform A + B when F = 0, otherwise perform A - B
    output  logic [8:0] Sum,
    output  logic       CO
    );
    logic c_in, c1, c2;
    logic [8:0] B_new;

    // Calculate -B if F = 1
    always_comb begin
        B_new = B ^ {9{F}}; // In case of F = 1, B XOR 0x1FF, flip every bits
        c_in = F;           // And then add 1
    end

    carry_group_3 CP3_0(.a(A[2:0]), .b(B_new[2:0]), .c_in, .s(Sum[2:0]), .c_out(c1));
    carry_group_3 CP3_1(.a(A[5:3]), .b(B_new[5:3]), .c_in(c1), .s(Sum[5:3]), .c_out(c2));
    carry_group_3 CP3_2(.a(A[8:6]), .b(B_new[8:6]), .c_in(c2), .s(Sum[8:6]), .c_out(CO));

endmodule

// Carry Select Adder to Blance Performance and Speed
module carry_group_3 (
    input   logic [2:0] a, b,
    input   logic       c_in,
    output  logic [2:0] s,
    output  logic       c_out
    );
    logic       c_out0, c_out1;
    logic [2:0] s0, s1;

    ripple_adder_3 RA0(.a, .b, .c_in(1'b0), .s(s0), .c_out(c_out0));
    ripple_adder_3 RA1(.a, .b, .c_in(1'b1), .s(s1), .c_out(c_out1));

    always_comb begin
        c_out = c_out0;
        s = s0;
        if (c_in) begin
            c_out = c_out1;
            s = s1;
        end
    end
endmodule

module ripple_adder_3 (
    input   logic [2:0] a, b,
    input   logic       c_in,
    output  logic [2:0] s,
    output  logic       c_out
    );
    logic c1, c2;

    full_adder FA0(.a(a[0]), .b(b[0]), .c_in, .s(s[0]), .c_out(c1));
    full_adder FA1(.a(a[1]), .b(b[1]), .c_in(c1), .s(s[1]), .c_out(c2));
    full_adder FA2(.a(a[2]), .b(b[2]), .c_in(c2), .s(s[2]), .c_out);
endmodule

module full_adder (
    input   logic a, b, c_in,
    output  logic s, c_out
    );
    always_comb begin
        s = a ^ b ^ c_in;
        c_out = (a&b) | (b&c_in) | (a&c_in);
    end
endmodule
