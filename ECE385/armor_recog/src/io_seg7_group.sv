module io_seg7_group (
    input  logic        CLK,
    input  logic [31:0] DIG,
    output logic [6 :0] SEG0,
                        SEG1,
                        SEG2,
                        SEG3,
                        SEG4,
                        SEG5,
                        SEG6,
                        SEG7
    );

    io_seg7 io_seg7_0 (.CLK, .SEG(SEG0), .DIG(DIG[ 3: 0]));
    io_seg7 io_seg7_1 (.CLK, .SEG(SEG1), .DIG(DIG[ 7: 4]));
    io_seg7 io_seg7_2 (.CLK, .SEG(SEG2), .DIG(DIG[11: 8]));
    io_seg7 io_seg7_3 (.CLK, .SEG(SEG3), .DIG(DIG[15:12]));
    io_seg7 io_seg7_4 (.CLK, .SEG(SEG4), .DIG(DIG[19:16]));
    io_seg7 io_seg7_5 (.CLK, .SEG(SEG5), .DIG(DIG[23:20]));
    io_seg7 io_seg7_6 (.CLK, .SEG(SEG6), .DIG(DIG[27:24]));
    io_seg7 io_seg7_7 (.CLK, .SEG(SEG7), .DIG(DIG[31:28]));

endmodule
