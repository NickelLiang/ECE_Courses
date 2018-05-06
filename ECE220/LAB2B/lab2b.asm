;number to print in decimal is in R3.
;it will be positive.
;
; R0	Output of DIV / IO
; R1	Output of DIV / ASCII_0
; R3	Input of DIV
; R4	Input of DIV
; R5	Underflow check
;

		.ORIG x3000

	LD R3, TEST		; Load test string into R3
	AND R4, R4, #0		;
	ADD R4, R4, #10		; Set R4 to #10

LOOP
	JSR DIV			;
	AND R3, R3, #0		;
	ADD R3, R3, R0		; New divident
	AND R0, R0, #0		;	
	ADD R0, R0, R1		; Remainder
	JSR PUSH		;	
	ADD R3, R3, #0		; Check if R3 is #0
	BRz PRINT		;
	BRnzp LOOP		;

PRINT
	JSR POP			;
	ADD R5, R5, #0		; Underflow check
	BRp DONE		; If underflow, done
	LD R1, ASCII_0		; R1 as a mask
	ADD R0, R1, R0		;
	OUT			;
	BRnzp PRINT		;	 
	
DONE
	HALT			;

TEST		.FILL x0078	; Number to be print
ASCII_0 	.FILL x0030	;

;==============================
;     	R0 = R3 / R4
;Algorithm:
;     	Save R3 & R4
;    	R0 = 0
;     	R3 = R3 - R4
;     	If R3 > 0, R0 = R0 + 1
;     	El RET
;IN:  	R3, R4
;OUT: 	R0 Quotient
	R1 Remainder
;R0:  	Act as counter
;
DIV	
	ST R3, DIV_SaveR3	; Save R3
	ST R4, DIV_SaveR4	; Save R4
	AND R0, R0, #0		; R0 = 0
	NOT R4, R4		;
	ADD R4, R4, #1		; R4 = -R4
DIV_LOOP
	ADD R3, R3, R4		; R3 = R3 - R4
	BRn DIV_DONE		; R3 < 0 when done
	ADD R0, R0, #1		; R0 = R0 + 1 if R3 >= 0 
	BRnzp DIV_LOOP		;
DIV_DONE
	AND R1, R1, #0		;
	LD R4, DIV_SaveR4	; Restore R4
	ADD R1, R3, R4		; R1 is remainder
	LD R3, DIV_SaveR3	; Restore R3
	RET			;

DIV_SaveR3	.BLKW #1	;
DIV_SaveR4	.BLKW #1	;
;==============================

;==============================
;IN:R0, OUT:R5 (0-success, 1-fail/overflow)
;R3: STACK_END R4: STACK_TOP
;
PUSH	
	ST R3, PUSH_SaveR3	;save R3
	ST R4, PUSH_SaveR4	;save R4
	AND R5, R5, #0		;
	LD R3, STACK_END	;
	LD R4, STACk_TOP	;
	ADD R3, R3, #-1		;
	NOT R3, R3		;
	ADD R3, R3, #1		;
	ADD R3, R3, R4		;
	BRz OVERFLOW		;stack is full
	STR R0, R4, #0		;no overflow, store value in the stack
	ADD R4, R4, #-1		;move top of the stack
	ST R4, STACK_TOP	;store top of stack pointer
	BRnzp DONE_PUSH		;
OVERFLOW
	ADD R5, R5, #1		;
DONE_PUSH
	LD R3, PUSH_SaveR3	;
	LD R4, PUSH_SaveR4	;
	RET

PUSH_SaveR3	.BLKW #1	;
PUSH_SaveR4	.BLKW #1	;
;==============================

;==============================
;IN: R0, OUT R5 (0-success, 1-fail/underflow)
;R3 STACK_START R4 STACK_TOP
;
POP	
	ST R3, POP_SaveR3	;save R3
	ST R4, POP_SaveR4	;save R3
	AND R5, R5, #0		;clear R5
	LD R3, STACK_START	;
	LD R4, STACK_TOP	;
	NOT R3, R3		;
	ADD R3, R3, #1		;
	ADD R3, R3, R4		;
	BRz UNDERFLOW		;
	ADD R4, R4, #1		;
	LDR R0, R4, #0		;
	ST R4, STACK_TOP	;
	BRnzp DONE_POP		;
UNDERFLOW
	ADD R5, R5, #1		;
DONE_POP
	LD R3, POP_SaveR3	;
	LD R4, POP_SaveR4	;
	RET


POP_SaveR3	.BLKW #1	;
POP_SaveR4	.BLKW #1	;
STACK_END	.FILL x3FF0	;
STACK_START	.FILL x4000	;
STACK_TOP	.FILL x4000	;
;==============================
		.END
