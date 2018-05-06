;
;R0	IO Register
;R1 	n
;R2	k
;R3	Input for Operation and Print
;R4	Input for Operation
;R5	Temporary
;R6	
;R7	N/A
;
		.ORIG x3000	;
	
;------------------------------
;This Piece of Code Can Print a Single Row. Row # is in line 37
;------------------------------
	LD R1, ROW_NUMBER	;
	JSR PASCAL		;
	HALT			;

;------------------------------
;This Piece of Code Can Print Pascal Row 0 - 7
;Comment Code Above to Use This
;------------------------------
	AND R1, R1, #0		;
LOOP
	ADD R0, R1, #-8		;
	BRz DONE		;
	JSR PASCAL		;
	LD R0, ASCII_NL		;
	OUT			;
	ADD R1, R1, #1		;
	BRnzp LOOP		;
DONE	
	HALT			;
;------------------------------
	
ROW_NUMBER	.FILL #7	; Row to be print, Max # is 7
ASCII_NL	.FILL x000A	;

;==============================
;Function
;	PASCAL
;Input	
;	R1 Row #
;Output	
;	N/A
;------------------------------
PASCAL
	ST R0, PASCAL_SaveR0	;
	ST R1, PASCAL_SaveR1	;
	ST R2, PASCAL_SaveR2	;
	ST R3, PASCAL_SaveR3	;
	ST R4, PASCAL_SaveR4	;
	ST R5, PASCAL_SaveR5	;
	ST R6, PASCAL_SaveR6	;
	ST R7, PASCAL_SaveR7	;
	LD R2, PASCAL_SaveR1	; k
PASCAL_LOOP
	LD R1, PASCAL_SaveR1	; n
	ADD R2, R2, #0		; Check k < 0
	BRn PASCAL_DONE		;
	AND R4, R4, #0		; Calculate n!, PUSH
	ADD R4, R4, R1		;
	JSR FAC			; 
	JSR PUSH		;
	AND R4, R4, #0		; Calculate k!, PUSH
	ADD R4, R4, R2		;
	JSR FAC			; 
	JSR PUSH		;
	NOT R5, R2		; Calculate (n-k)!
	ADD R5, R5, #1		; R5 = -k
	ADD R4, R5, R1		; R4 = n - k
	JSR FAC			; 
	AND R3, R3, #0		; 
	ADD R3, R3, R0		; 
	JSR POP			;
	AND R4, R4, #0		;
	ADD R4, R4, R0		;
	JSR MUL			; R0 = k! * (n-k)!
	AND R4, R4, #0		;
	ADD R4, R4, R0		;
	JSR POP			;
	AND R3, R3, #0		; 
	ADD R3, R3, R0		;
	JSR DIV			; R0 = n! / (k! * (n-k)!)
	LD R1, PASCAL_BASE	;
	AND R3, R3, #0		; 
	ADD R3, R3, R0		;
	JSR PRINT		; PRINT NUMBER
	LD R0, PASCAL_SPACE	; PRINT SPACE
	OUT			;
	ADD R2, R2, #-1		; Update k
	BRnzp PASCAL_LOOP	;
PASCAL_DONE
	LD R0, PASCAL_SaveR0	;
	LD R1, PASCAL_SaveR1	;
	LD R2, PASCAL_SaveR2	;
	LD R3, PASCAL_SaveR3	;
	LD R4, PASCAL_SaveR4	;
	LD R5, PASCAL_SaveR5	;
	LD R6, PASCAL_SaveR6	;
	LD R7, PASCAL_SaveR7	;
	RET			;

PASCAL_BASE	.FILL #10	; Base
PASCAL_SPACE	.FILL x0020	; Space
PASCAL_SaveR0	.BLKW #1	;
PASCAL_SaveR1	.BLKW #1	;
PASCAL_SaveR2	.BLKW #1	;
PASCAL_SaveR3	.BLKW #1	;
PASCAL_SaveR4	.BLKW #1	;
PASCAL_SaveR5	.BLKW #1	;
PASCAL_SaveR6	.BLKW #1	;
PASCAL_SaveR7	.BLKW #1	;
;==============================

;==============================
;Function
;	PRINT_decimal
;Input	
;	R1 Base
;	R3 # to be print
;Output	
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

PRINT_ASCII_0 	.FILL x0030	;
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
;	MULtiplication
;Input	
;	R3
;	R4
;Output	
;	R0
;Algorithm
;	R0 = R3 * R4
;Register
;	R4, Loop Counter
;------------------------------
MUL	
	ST R4, MUL_SaveR4	; Save R4
	AND R0, R0, #0		; R0 = 0	
MUL_LOOP
	ADD R4, R4, #0		; Condition check
	BRz MUL_DONE		; R4 = 0 when done
	ADD R0, R0, R3		; R0 = R0 + R3
	ADD R4, R4, #-1		; R4 = R4 - 1
	BRnzp MUL_LOOP		;
MUL_DONE
	LD R4, MUL_SaveR4	; Restore R4
	RET			;

MUL_SaveR4	.BLKW #1	;
;==============================

;==============================
;Function
;	DIVision
;Input	
;	R3
;	R4
;Output	
;	R0, Quotient
;	R1, Remainder
;Algorithm
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
;	FACtorial
;Input	
;	R4
;Output	
;	R0
;Algorithm
;	R0 = R4!
;	
;	Check if R4 = 0, 0! = 1
;	R3 = R4 - 1
;	LOOP
;	Check if R3 = 0, done
;	R0 = R3 * R4
;	R4 = R0
;	R3 = R3 - 1	
;------------------------------
FAC
	ST R3, FAC_SaveR3	; Save R3
	ST R4, FAC_SaveR4	; Save R4
	ST R7, FAC_SaveR7	; Save R7
	ADD R0, R4, #-1		;
	BRnz FAC_ZERO		; Check if R4 = 0 or 1
	ADD R3, R4, #-1		; R3 = R4 - 1
	AND R0, R0, #0		;
FAC_LOOP
	ADD R3, R3, #0		; Condition Check
	BRz FAC_DONE		; R2 = 0 when done
	JSR MUL			; R0 = R3 * R4
	ADD R0, R0, #0		;
	BRnz FAC_ERROR		;
	AND R4, R4, #0		;
	ADD R4, R4, R0		; R4 = R0
	ADD R3, R3, #-1		; R3 = R3 - 1
	BRnzp FAC_LOOP		;
FAC_ZERO
	AND R0, R0, #0		;
	ADD R0, R0, #1		;
	BRnzp FAC_DONE		;
FAC_ERROR
	AND R0, R0, #0		;
	ADD R0, R0, #-1		; R0 = -1 if error
	BRnzp FAC_DONE		;
FAC_DONE
	LD R3, FAC_SaveR3	; Restore R3
	LD R4, FAC_SaveR4	; Restore R4
	LD R7, FAC_SaveR7	; Restore R7
	RET			;

FAC_SaveR3	.BLKW #1	;
FAC_SaveR4	.BLKW #1	;
FAC_SaveR7	.BLKW #1	;
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
