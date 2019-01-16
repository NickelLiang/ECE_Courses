module simulate_camera (
    input  logic        PIXCLK,
    input  logic        RESET,
    output logic [11:0] CCD_R, CCD_G, CCD_B,
    output logic        CCD_DVAL
    );

    parameter L_TOTAL   = 12'd2592;
    parameter F_TOTAL   = 12'd1944;

    parameter S_DELAY   = 12'd609;

    parameter L_ACTIVE  = 12'd640;
    parameter F_ACTIVE  = 12'd480;

    logic [11:0]    COUNT_X, COUNT_Y;
    logic [11:0]    COUNT_X_m, COUNT_Y_m;
    logic [11:0]    CCD_R_m, CCD_G_m, CCD_B_m;
    logic           FRAME_START_m;
    logic           CCD_DVAL_m;

    // assign CCD_R_m = 12'hFFF;
    // assign CCD_G_m = 12'hFFF;
    // assign CCD_B_m = 12'hFFF;

    always_ff @ (posedge PIXCLK or posedge RESET) begin
        if (RESET) begin
            COUNT_X     <= 12'b0;
            COUNT_Y     <= 12'b0;
            CCD_R       <= 12'b0;
            CCD_G       <= 12'b0;
            CCD_B       <= 12'b0;
            CCD_DVAL    <= 0;
        end else begin
            COUNT_X     <= COUNT_X_m;
            COUNT_Y     <= COUNT_Y_m;
            CCD_R       <= CCD_R_m;
            CCD_G       <= CCD_G_m;
            CCD_B       <= CCD_B_m;
            CCD_DVAL    <= CCD_DVAL_m;
        end
    end

    always_comb begin
        COUNT_X_m = COUNT_X + 12'b1;
        COUNT_Y_m = COUNT_Y;
        if (COUNT_X_m == L_TOTAL + S_DELAY) begin
            COUNT_X_m = S_DELAY;
            COUNT_Y_m = COUNT_Y_m + 12'b1;
            if (COUNT_Y_m == F_TOTAL) begin
                COUNT_Y_m = 12'b0;
                COUNT_X_m = 12'b0; // Do a start delay
            end
        end
        if ((COUNT_Y_m < F_ACTIVE) && (COUNT_X_m >= S_DELAY) && (COUNT_X_m < S_DELAY + L_ACTIVE)) begin
            CCD_DVAL_m = 1;
        end else begin
            CCD_DVAL_m = 0;
        end

        // Color
        if ((COUNT_X_m < S_DELAY + L_ACTIVE / 2) && (COUNT_Y_m < F_ACTIVE / 2)) begin
            CCD_R_m = 12'hFFF;
            CCD_G_m = 12'h0;
            CCD_B_m = 12'h0;
        end else if ((COUNT_X_m >= S_DELAY + L_ACTIVE / 2) && (COUNT_Y_m < F_ACTIVE / 2)) begin
            CCD_R_m = 12'h0;
            CCD_G_m = 12'hFFF;
            CCD_B_m = 12'h0;
        end else if ((COUNT_X_m < S_DELAY + L_ACTIVE / 2) && (COUNT_Y_m >= F_ACTIVE / 2)) begin
            CCD_R_m = 12'h0;
            CCD_G_m = 12'h0;
            CCD_B_m = 12'hFFF;
        end else begin
            CCD_R_m = 12'hFFF;
            CCD_G_m = 12'hFFF;
            CCD_B_m = 12'hFFF;
        end
    end
endmodule // simulate_camera
