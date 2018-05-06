; This program print # in TEST with base in BASE

		.ORIG x3000	;

	LD R1, BASE		; Load base into R1
	LD R3, TEST		; Load test string into R3
	JSR PRINT		;
	HALT			;

BASE		.FILL #16	; Base
TEST		.FILL x7ABC	; Number to be print

;==============================
;Function
;	PRINT
;Input	
;	R1 Base
;	R3 # to be print
;Output	
;	N/A
;Algorithum
;	N/A
;------------------------------
PRINT
	ST R0, PRINT_SaveR0	;
	ST R1, PRINT_SaveR1	;
	ST R3, PRINT_SaveR3	;
	ST R4, PRINT_SaveR4	;
	ST R5, PRINT_SaveR5	;
	ST R6, PRINT_SaveR6	;
	ST R7, PRINT_SaveR7	;
	AND R0, R0, #0		;
	AND R4, R4, #0		;
	ADD R4, R4, R1		;
PRINT_LOOP
	JSR DIV			;
	AND R3, R3, #0		; 
	ADD R3, R3, R0		; Put quotient into R3
	AND R0, R0, #0		;
	ADD R0, R0, R1		; Put remainder into R0
	JSR PUSH		;
	ADD R3, R3, #0		; Check if quotient is 0
	BRz PRINT_OUT		;
	BRnzp PRINT_LOOP	;
PRINT_OUT
	JSR POP			;
	ADD R5, R5, #0		;
	BRp PRINT_DONE		;
	AND R6, R6, #0		;
	ADD R6, R6, R0		;
	ADD R0, R6, #-9		; Check if we need to use A-Z to represent a number
	BRnz PRINT_ADD_ZERO	;
	LD R0, PRINT_ASCII_A	;
	ADD R0, R0, R6		; Add A to our digit to get the real ASCII value to print
	ADD R0, R0, #-10	;
	BRnzp PRINT_DISPLAY	;
PRINT_ADD_ZERO  
	LD R0, PRINT_ASCII_0	; Add 0 to our digit to get the real ASCII value to print
	ADD R0, R0, R6		;
PRINT_DISPLAY		
	OUT			; Print on our display!
	BRnzp PRINT_OUT		;
PRINT_DONE
	LD R0, PRINT_SaveR0	;
	LD R1, PRINT_SaveR1	;
	LD R3, PRINT_SaveR3	;
	LD R4, PRINT_SaveR4	;
	LD R5, PRINT_SaveR5	;
	LD R6, PRINT_SaveR6	;
	LD R7, PRINT_SaveR7	;
	RET			;

PRINT_ASCII_0 	.FILL x30	;
PRINT_ASCII_A 	.FILL x0041	;
PRINT_SaveR0	.BLKW #1	;
PRINT_SaveR1	.BLKW #1	;
PRINT_SaveR3	.BLKW #1	;
PRINT_SaveR4	.BLKW #1	;
PRINT_SaveR5	.BLKW #1	;
PRINT_SaveR6	.BLKW #1	;
PRINT_SaveR7	.BLKW #1	;
;==============================

;==============================
;Function
;	DIV
;Input	
;	R3
;	R4
;Output	
;	R0, Quotient
;	R1, Remainder
;Algorithum
;	R3 / R4 = R0 ... R1
;------------------------------
DIV
	ST R2, DIV_SaveR2	;
	ST R3, DIV_SaveR3	;
	NOT R2, R4		;
	ADD R2, R2, #1		;
	AND R0, R0, #0		;
	ADD R0, R0, #-1		;
DIV_LOOP	
	ADD R0, R0, #1		;
	ADD R3, R3, R2		;
	BRzp DIV_LOOP		;
	ADD R1, R3, R4		;
	LD R2, DIV_SaveR2	;
	LD R3, DIV_SaveR3	;
	RET			;

DIV_SaveR2	.BLKW #1	;
DIV_SaveR3 	.BLKW #1	;
;==============================

;==============================
;Function
;	PUSH & POP
;Input	
;	R0
;Output	
;	R5, 0 = Success, 1 = Fail
;Register
;	R3, STACK_END
;	R4, STACK_TOP
;------------------------------
PUSH	
	ST R3, PUSH_SaveR3	; Save R3
	ST R4, PUSH_SaveR4	; Save R4
	AND R5, R5, #0		;
	LD R3, STACK_END	;
	LD R4, STACK_TOP	;
	ADD R3, R3, #-1		;
	NOT R3, R3		;
	ADD R3, R3, #1		;
	ADD R3, R3, R4		;
	BRz PUSH_OVERFLOW	; Stack is full
	STR R0, R4, #0		; No overflow, store value in the stack
	ADD R4, R4, #-1		; Move top of the stack
	ST R4, STACK_TOP	; Store top of stack pointer
	BRnzp PUSH_DONE		;
PUSH_OVERFLOW
	ADD R5, R5, #1		;
PUSH_DONE
	LD R3, PUSH_SaveR3	;
	LD R4, PUSH_SaveR4	;
	RET

PUSH_SaveR3	.BLKW #1	;
PUSH_SaveR4	.BLKW #1	;
;------------------------------
POP	
	ST R3, POP_SaveR3	; Save R3
	ST R4, POP_SaveR4	; Save R3
	AND R5, R5, #0		; Clear R5
	LD R3, STACK_START	;
	LD R4, STACK_TOP	;
	NOT R3, R3		;
	ADD R3, R3, #1		;
	ADD R3, R3, R4		;
	BRz POP_UNDERFLOW	;
	ADD R4, R4, #1		;
	LDR R0, R4, #0		;
	ST R4, STACK_TOP	;
	BRnzp POP_DONE		;
POP_UNDERFLOW
	ADD R5, R5, #1		;
POP_DONE
	LD R3, POP_SaveR3	;
	LD R4, POP_SaveR4	;
	RET

POP_SaveR3	.BLKW #1	;
POP_SaveR4	.BLKW #1	;
STACK_END	.FILL x3FF0	;
STACK_START	.FILL x4000	;
STACK_TOP	.FILL x4000	;
;==============================
		.END		;
