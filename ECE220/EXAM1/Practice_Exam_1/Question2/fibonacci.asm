		.ORIG x3000	;

	LD R1, INPUT   		; 
	JSR FIBON		;
	ST R6, RESULT		;
	HALT			;

;your code goes here
;Input 	R1
;Low	R4
;High	R5
;Output R6 sum
FIBON
	ST R1, FIBON_R1		;
	ADD R1, R1, #-2		;
	BRnz FIBOn_ONE		;
	AND R6, R6, #0		;
	AND R4, R4, #0		;
	ADD R4, R4, #1		;
	AND R5, R5, #0		;
	ADD R5, R5, #1		;
FIBON_LOOP
	ADD R1, R1, #0		;
	BRz FIBON_DONE		;
	ADD R6, R4, R5		;
	ADD R6, R6, #0		;
	BRn FIBON_ERROR		;
	ADD R4, R5, #0		;
	ADD R5, R6, #0		;
	ADD R1, R1, #-1		;
	BRnzp FIBON_LOOP	;
FIBON_ERROR
	AND R6, R6, #0		;
	ADD R6, R6, #-1		;
	BRnzp FIBON_DONE	;
FIBON_ONE
	AND R6, R6, #0		;
	ADD R6, R6, #1		;
	BRnzp FIBON_DONE	;
FIBON_DONE
	LD R1, FIBON_R1		;
	RET			;
FIBON_R1 	.BLKW #1	;

INPUT		.FILL #5	;
RESULT		.BLKW #1	;
		.END		;
