;Reverse Characters
;n characters are provided to you
;in which n is a positive number stored at x4FFF
;characters stored in sequential memory location
;starting at x5000
;Use the subroutine REVERSE to flip the order

		.ORIG x3000	;

;your program starts here
	JSR REVERSE		;
	HALT			;

;REVERSE subroutine:
;reverse the order of n characters starting at x5000
;SWAPMEM subroutine must be called here, not in the main user program
REVERSE
	ST R0, REVERSE_R0	; SWAPMEM input
	ST R1, REVERSE_R1	; SWAPMEM input
	ST R2, REVERSE_R2	; n
	ST R3, REVERSE_R3	; First pointer
	ST R4, REVERSE_R4	; Second pointer
	ST R5, REVERSE_R5	; Temp
	LDI R2, NUM_ADDR	; 
	LD R3, CHAR_ADDR	; 
	ADD R4, R2, R3		; 
	ADD R4, R4, #-1		;
	
REVERSE_LOOP
	NOT R5, R4		;
	ADD R5, R5, #1		; R5 = - R4
	ADD R5, R5, R3		; R5 = R3 - R4
	BRzp REVERSE_DONE	;
	AND R0, R0, #0		;
	AND R1, R1, #0		;
	ADD R0, R3, #0		;
	ADD R1, R4, #0		;
	JSR SWAPMEM		;
	ADD R3, R3, #1		;
	ADD R4, R4, #-1		;
	BRnzp REVERSE_LOOP	;

REVERSE_DONE
	LD R0, REVERSE_R0	;
	LD R1, REVERSE_R1	;
	LD R2, REVERSE_R2	;
	LD R3, REVERSE_R3	;
	LD R4, REVERSE_R4	;
	LD R5, REVERSE_R5	;
	RET			;

REVERSE_R0	.BLKW #1	;
REVERSE_R1	.BLKW #1	;
REVERSE_R2	.BLKW #1	;
REVERSE_R3	.BLKW #1	;
REVERSE_R4	.BLKW #1	;
REVERSE_R5	.BLKW #1	;

;SWAPMEM subroutine:
;address one is in R0, address two in R1
;if mem[R0]=A and mem[R1]=B, then after subroutine call
;   mem[R0]=B and mem[R1]=A
SWAPMEM
	ST R2, SWAPMEM_R2	;
	ST R3, SWAPMEM_R3	;
	LDR R2, R0, #0		;
	LDR R3, R1, #0		;
	STR R2, R1, #0		;
	STR R3, R0, #0		;
	LD R2, SWAPMEM_R2	;
	LD R3, SWAPMEM_R3	;
	RET			;

SWAPMEM_R2	.BLKW #1	;
SWAPMEM_R3	.BLKW #1	;

NUM_ADDR    	.FILL x4FFF	;
CHAR_ADDR   	.FILL x5000	;

		.END		;
