		.ORIG x3000	;

	;GETC			; Test with input
	;AND R0, R0, #15	;
	;ADD R1, R0, #0		;

	LD R1, INPUT    	; Test with memory
	JSR FIBON		;
	ST R6, RESULT		;
	HALT			;

;your code goes here
;==========
;IN	R1
;OUT 	R6
;R0	
;R2	LOW
;R3	HIGH
;R4	
;R5
;R6	SUM
;
FIBON
	ST R0, FIBON_SaveR0	;
	ST R1, FIBON_SaveR1	;	
	ST R2, FIBON_SaveR2	;	
	ST R3, FIBON_SaveR3	;		

	ADD R1, R1, #-2		; Check if R1 <= 2
	BRnz FIBON_ONE		;
	AND R2, R2, #0		;
	ADD R2, R2, #1		; Low = 1
	AND R3, R3, #0		;
	ADD R3, R3, #1		; High = 1
	
FIBON_LOOP
	ADD R1, R1, #0		; Check if counter = 0
	BRz FIBON_DONE		;
	ADD R6, R3, R2		; Sum = Low + High
	BRn FIBON_MONE		; Check if overflow
	AND R2, R2, #0		;
	ADD R2, R2, R3		; Low = High
	AND R3, R3, #0		;
	ADD R3, R3, R6		; High = Sum
	ADD R1, R1, #-1		; Update counter
	BRnzp FIBON_LOOP	;

FIBON_MONE
	AND R6, R6, #0		;
	ADD R6, R6, #-1		;
	BRnzp FIBON_DONE	;

FIBON_ONE
	AND R6, R6, #0		;
	ADD R6, R6, #1		;
	BRnzp FIBON_DONE	;

FIBON_DONE
	LD R0, FIBON_SaveR0	;
	LD R1, FIBON_SaveR1	;	
	LD R2, FIBON_SaveR2	;	
	LD R3, FIBON_SaveR3	;
	RET			;

FIBON_SaveR0	.BLKW #1	;
FIBON_SaveR1	.BLKW #1	;
FIBON_SaveR2	.BLKW #1	;
FIBON_SaveR3	.BLKW #1	;

INPUT 		.FILL #24	;
RESULT		.BLKW #1	;
		.END		;
