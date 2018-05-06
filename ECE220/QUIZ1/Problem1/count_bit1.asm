
		.ORIG x3000	;

INIT_REGS
	AND R0, R0, #0		; Output
  	AND R1, R1, #0		;
  	AND R2, R2, #0		;
  	AND R3, R3, #0		;
  	AND R4, R4, #0		;
 	AND R5, R5, #0		;
  	AND R6, R6, #0		; Input
	LD R6, INPUT_ADDRESS	;
  	LDR R6, R6, #0		;
	BRnzp LOOP2		; Select a method

; TODO
LOOP
	ADD R2, R2, R6		; First method, bitwise &
	ADD R2, R2, #-1		;
	AND R6, R6, R2		;	
	BRz DONE		;
	ADD R0, R0, #1		;
	BRnzp LOOP		;
; END TODO

LOOP2
	ADD R6, R6, #0		; Second method, left shift
	BRzp ADD_ZERO		;
	ADD R0, R0, #1		;
ADD_ZERO
	ADD R6, R6, R6		;
	BRz DONE		;
	BRnzp LOOP2		;

DONE
	STI R0, OUTPUT_VALUE	;
	HALT			;

; Memory definition.
INPUT_ADDRESS 	.FILL x5000	;
OUTPUT_VALUE 	.FILL x5000	;

		.END		;
