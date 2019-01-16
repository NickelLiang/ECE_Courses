module control (
    input  logic Clk, Reset, Run,
    output logic Shift, F, ClrA
    );
    // States in FSM
    enum logic [3:0] {HOLD_START, CLEARA, ADD1, ADD2, ADD3, ADD4, ADD5, ADD6, ADD7, SUB8, HOLD_END} curr_state, next_state;

    // Updates flip flop, current state is the only one
    always_ff @ (posedge Clk) begin
        if (Reset)
            curr_state <= HOLD_START;
        else
            curr_state <= next_state;
    end

    always_comb begin
        next_state = curr_state;
        // Next state logic
        unique case (curr_state)
            HOLD_START:
                if (Run)
                    next_state = CLEARA;
            CLEARA: next_state = ADD1;
            ADD1:   next_state = ADD2;
            ADD2:   next_state = ADD3;
            ADD3:   next_state = ADD4;
            ADD4:   next_state = ADD5;
            ADD5:   next_state = ADD6;
            ADD6:   next_state = ADD7;
            ADD7:   next_state = SUB8;
            SUB8:   next_state = HOLD_END;
            HOLD_END:
                if (~Run)
                    next_state = HOLD_START;
        endcase

        // Output logic
        Shift   = 1'b1;
        F       = 1'b0;
        ClrA    = 1'b0;
        case (curr_state)
            HOLD_START: Shift = 1'b0;
            HOLD_END:   Shift = 1'b0;
            SUB8:       F = 1'b1;
            CLEARA: begin
                Shift   = 1'b0;
                ClrA    = 1'b1;
            end
            default: begin
                Shift   = 1'b1; // Shift and ADD/SUB always at same state
                F       = 1'b0;
            end
        endcase
    end
endmodule
