//Two-always example for state machine

module control (input  logic Clk, Reset, LoadA, LoadB, Execute,
                output logic Shift_En, Ld_A, Ld_B );

    // Declare signals curr_state, next_state of type enum
    // with enum values of A, B, ..., F as the state values
	 // Note that the length implies a max of 16 states
    enum logic [3:0] {HOLD_START, S1, S2, S3, S4, S5, S6, S7, S8, HOLD_END}   curr_state, next_state; 

	//updates flip flop, current state is the only one
    always_ff @ (posedge Clk)  
    begin
        if (Reset)
            curr_state <= HOLD_START;
        else 
            curr_state <= next_state;
    end

    // Assign outputs based on state
	always_comb
    begin
        
		  next_state  = curr_state;	//required because I haven't enumerated all possibilities below
        unique case (curr_state) 

            HOLD_START	:	if (Execute)
										next_state = S1;
            S1				:	next_state = S2;
            S2				:	next_state = S3;
            S3				:	next_state = S4;
            S4				:	next_state = S5;
				S5				:	next_state = S6;
				S6				:	next_state = S7;
            S7				:	next_state = S8;
				S8				:	next_state = HOLD_END;
				HOLD_END		:	if (~Execute) 
										next_state = HOLD_START;
							  
        endcase
   
		  // Assign outputs based on ‘state’
        case (curr_state) 
	   	   HOLD_START: 
	         begin
                Ld_A = LoadA;
                Ld_B = LoadB;
                Shift_En = 1'b0;
		      end
	   	   HOLD_END: 
		      begin
                Ld_A = 1'b0;
                Ld_B = 1'b0;
                Shift_En = 1'b0;
		      end
	   	   default:  //default case, can also have default assignments for Ld_A and Ld_B before case
		      begin 
                Ld_A = 1'b0;
                Ld_B = 1'b0;
                Shift_En = 1'b1;
		      end
        endcase
    end

endmodule
