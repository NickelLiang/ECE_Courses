		.ORIG x3000

; Compromise the TRAP x22 PUTS routine

		LD R0, CHANGE_LINE1	; Change TRAP x22 PUTS
		STI R0, PUTS_LINE1	;
		LD R0, CHANGE_LINE2	; 
		STI R0, PUTS_LINE2	;
		
		AND R0, R0, #0		; R0 as target memory addr pointer
		LD R0, BAD_MESSAGE_ADDR	;
		AND R1, R1, #0		; R1 as bad message addr pointer
		LEA R1, BAD_MESSAGE	;
		AND R2, R2, #0		; R2 as temporary
FILL_LOOP	
		LDR R2, R1, #0		; Copy bad message to x04F1
		STR R2, R0, #0		; 
		
		ADD R2, R2, #0		; If we found a NUL, we successfully copied the bad message
		BRz COMPROMISED		;

		ADD R0, R0, #1		; Increment pointer
		ADD R1, R1, #1		;
		BRnzp FILL_LOOP		;
		
COMPROMISED
		AND R0, R0, #0		; Erase our trace
		AND R1, R1, #0		;
		AND R2, R2, #0		;
		BRnzp BEGIN		; Go to showcase program

PUTS_LINE1	.FILL x0456		; Original content is ST R0, OS_R0
CHANGE_LINE1	.FILL xE09A		; LEA R0, x04F1 (9A) 	-> 1110 000 0 1001 1010 	-> xE09A
PUTS_LINE2	.FILL x045F		; Original content is LD R0, OS R0
CHANGE_LINE2	.FILL x5020		; AND R0, R0, #0 	-> 0101 000 000 1 00000		-> x5020
BAD_MESSAGE_ADDR
		.FILL x04F1		; This memory location is empty. We can copy our bad message to this place.
BAD_MESSAGE	.STRINGZ "Hacked by Nickel"

; Showcase Program Starts Here

BEGIN
		LEA R0, TEST_STRING	; Check if our PUTS work properly
		PUTS			;
		LD R0, ASCII_NL		; Put a New Line
		OUT			;
		HALT			; HALT our program

ASCII_NL	.FILL x000A		;
TEST_STRING	.STRINGZ "TEST"		;

		.END
