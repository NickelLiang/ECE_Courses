		.ORIG x3000	;

;your program starts here

	LD R1, STORE		; R1 is pointer
ECHO
	LD R2, ASCII_NL		; R2 is temp
	NOT R2, R2		;
	ADD R2, R2, #1		;
	ADD R2, R2, R0		; R0 is IO
	BRz CHECK_VALID		;
CHECK_KBSR
	LDI R0, KBSR		;
	BRzp CHECK_KBSR		;
	LDI R0, KBDR		;
	STR R0, R1, #0		; Store into x5000
	ADD R1, R1, #1		; Update pointer
CHECK_DSR
	LDI R2, DSR		;
	BRzp CHECK_DSR		;
	STI R0, DDR		;
	BRnzp ECHO		;
	
CHECK_VALID
	LD R1, STORE		;
	LD R2, MASK		;
	NOT R2, R2		;
	ADD R2, R2, #1		;
	AND R3, R3, #0		;
	ADD R3, R3, #10		;
VALID_LOOP
	ADD R3, R3, #0		;
	BRz PRINT_VALID		;
	LDR R0, R1, #0		;
	ADD R0, R0, R2		;
	BRn PRINT_INVALID	;
	ADD R0, R0, #-10	;
	BRzp PRINT_INVALID	;

	ADD R3, R3, #-1		;
	ADD R1, R1, #1		; Update pointer
	BRnzp VALID_LOOP	;

PRINT_VALID
	ADD R1, R1, #1		; Check if anything left
	LDR R0, R1, #0		;
	BRnp PRINT_INVALID	;
	LEA R0, VAL_MSG		;
	PUTS			;
	BRnzp DONE		;

PRINT_INVALID
	LEA R0, INV_MSG		;
	PUTS			;
	BRnzp DONE		;

DONE
	HALT			;

KBSR    	.FILL xFE00	;
KBDR    	.FILL xFE02	;
DSR     	.FILL xFE04	;
DDR     	.FILL xFE06	;
STORE		.FILL x5000	;
ASCII_NL	.FILL x000A	;
MASK		.FILL x0030	;
INV_MSG 	.STRINGZ "Invalid Phone Number."
VAL_MSG 	.STRINGZ "Valid Phone Number."

		.END		;
