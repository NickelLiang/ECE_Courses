module io_reset_delay (
    input  logic        CLK,    // 50MHz
    input  logic        RST,
    output logic        RST_0,
    output logic        RST_1,
    output logic        RST_2,
    output logic        RST_3,
    output logic        RST_4
    );

    logic   [31:0]  CONT_m;

    always_ff @ (posedge CLK or negedge RST) begin
        if (!RST) begin
            CONT_m      <= 0;
            RST_0       <= 0;
            RST_1       <= 0;
            RST_2       <= 0;
            RST_3       <= 0;
            RST_4       <= 0;
        end else begin
            if (CONT_m != 32'h01FFFFFF) // ~0.7s
                CONT_m  <= CONT_m + 1;
            if (CONT_m >= 32'h001FFFFF) // ~0.04s
                RST_0   <= 1;
            if (CONT_m >= 32'h002FFFFF) // ~0.06s
                RST_1   <= 1;
            if (CONT_m >= 32'h011FFFFF) // ~0.38s
                RST_2   <= 1;
            if (CONT_m >= 32'h016FFFFF) // ~0.48s
                RST_3   <= 1;
            if (CONT_m >= 32'h01FFFFFF) // ~0.7s
                RST_4   <= 1;
        end
    end
endmodule // io_reset_delay
