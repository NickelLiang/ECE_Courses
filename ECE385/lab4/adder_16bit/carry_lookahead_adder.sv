module carry_lookahead_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);

    /* TODO
     *
     * Insert code here to implement a CLA adder.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
    
    logic [3:0] P, G, C;
    
    cla_4 C4_0(.A(A[3:0]), .B(B[3:0]), .c_in(C[0]), .S(Sum[3:0]), .PG(P[0]), .GG(G[0]));
    cla_4 C4_1(.A(A[7:4]), .B(B[7:4]), .c_in(C[1]), .S(Sum[7:4]), .PG(P[1]), .GG(G[1]));
    cla_4 C4_2(.A(A[11:8]), .B(B[11:8]), .c_in(C[2]), .S(Sum[11:8]), .PG(P[2]), .GG(G[2]));
    cla_4 C4_3(.A(A[15:12]), .B(B[15:12]), .c_in(C[3]), .S(Sum[15:12]), .PG(P[3]), .GG(G[3]));
    
    carry_lookahead_unit_4 CLU(.P(P[2:0]), .G(G[2:0]), .c_in(1'b0), .C);
    
    assign CO = (G[0]&P[1]&P[2]&P[3]) | (G[1]&P[2]&P[3]) | (G[2]&P[3]) | G[3];
     
endmodule

module cla_4(input logic [3:0] A, B,
             input logic c_in,
            output logic [3:0] S,
            output logic PG, GG);

    logic [3:0] P, G, C;
    
    full_adder_pg FAPG0(.A(A[0]), .B(B[0]), .c_in(C[0]), .S(S[0]), .P(P[0]), .G(G[0]));
    full_adder_pg FAPG1(.A(A[1]), .B(B[1]), .c_in(C[1]), .S(S[1]), .P(P[1]), .G(G[1]));
    full_adder_pg FAPG2(.A(A[2]), .B(B[2]), .c_in(C[2]), .S(S[2]), .P(P[2]), .G(G[2]));
    full_adder_pg FAPG3(.A(A[3]), .B(B[3]), .c_in(C[3]), .S(S[3]), .P(P[3]), .G(G[3]));
    
    carry_lookahead_unit_4 CLU(.P(P[2:0]), .G(G[2:0]), .c_in, .C);
    
    always_comb begin
        PG = P[0] & P[1] & P[2] & P[3];
        GG = G[3] | (G[2] & P[3]) | (G[1] & P[2] & P[3]) | (G[0] & P[1] & P[2] & P[3]);
    end

endmodule

module full_adder_pg(input logic A, B, c_in,
                    output logic S, P, G);
    always_comb begin
        P = A ^ B;
        G = A & B;
        S = A ^ B ^ c_in;
    end
endmodule

module carry_lookahead_unit_4(input logic [2:0] P, G,
                              input logic c_in,
                              output logic [3:0] C);
    always_comb begin
        C[0] = c_in;
        C[1] = (c_in&P[0]) | G[0];
        C[2] = (c_in&P[0]&P[1]) | (G[0]&P[1]) | G[1];
        C[3] = (c_in&P[0]&P[1]&P[2]) | (G[0]&P[1]&P[2]) | (G[1]&P[2]) | G[2];
    end
endmodule
