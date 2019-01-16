module io_seg7 (
    input  logic        CLK,
    input  logic [3:0]  DIG,
    output logic [6:0]  SEG
    );

    always_ff @ (posedge CLK) begin
        case (DIG)
            4'h1: SEG <= 7'b1111001;    // ---t----
            4'h2: SEG <= 7'b0100100;     // |      |
            4'h3: SEG <= 7'b0110000;     // lt     rt
            4'h4: SEG <= 7'b0011001;     // |      |
            4'h5: SEG <= 7'b0010010;     // ---m----
            4'h6: SEG <= 7'b0000010;     // |      |
            4'h7: SEG <= 7'b1111000;     // lb     rb
            4'h8: SEG <= 7'b0000000;     // |      |
            4'h9: SEG <= 7'b0011000;     // ---b----
            4'ha: SEG <= 7'b0001000;
            4'hb: SEG <= 7'b0000011;
            4'hc: SEG <= 7'b1000110;
            4'hd: SEG <= 7'b0100001;
            4'he: SEG <= 7'b0000110;
            4'hf: SEG <= 7'b0001110;
            4'h0: SEG <= 7'b1000000;
        endcase
    end
endmodule
