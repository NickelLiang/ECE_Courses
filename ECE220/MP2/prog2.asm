;This program takes a post-fix string and do + - * / and ^ base on give quation.
;Nickel Liang, Sep. 12, 2017.
;669195442, zuodong2@illinois.edu
;
;R0	IO Register
;R1 	Temporary
;R2	Output of EVALUATE, status register
;R3	
;R4	
;R5	Output, required
;R6	Output of EVALUATE, final value
;R7

		.ORIG x3000

	AND R2, R2, #0		; Clear status checker
	
DO_NEXT	
	GETC			;
	OUT			;
	ADD R0, R0, #0		; Check R0
	BRz DO_HALT		;
	JSR EVALUATE		;
	ADD R2, R2, #0		; Check status register
	BRn DO_STORE		; Got an answer
	BRp DO_INVALID		; Got an invalid
	BRnzp DO_NEXT		; 
	
DO_STORE
	AND R5, R5, #0		;
	ADD R5, R5, R6		; R5 for output
	AND R3, R3, #0		;
	ADD R3, R3, R5		; R3 for print
	JSR PRINT_HEX		;
	BRnzp DO_HALT		;		

DO_INVALID
	LEA R0, ERROR_STRING	;
	PUTS			;
	BRnzp DO_HALT		;

DO_HALT
	HALT			;

ERROR_STRING	.STRINGZ "Invalid Expression\n"

;==============================
;IN:	R0 Character input from keyboard
;OUT:	R2 Status: done (-1) more input (0) or invalid (1)
;	R6 Numerical output
;R1:	Temporary
;R3:	Second poped value
;R4:	First poped Value
;R5:	Under/Overflow check
;

EVALUATE
	ST R0, EVALUATE_SaveR0	; Save R0
	ST R1, EVALUATE_SaveR1	; Save R1
	ST R3, EVALUATE_SaveR3	; Save R3
	ST R4, EVALUATE_SaveR4	; Save R4	
	ST R5, EVALUATE_SaveR5	; Save R5
	ST R7, EVALUATE_SaveR7	; Save R7
 	BRnzp CHECK_EQUAL	;

CHECK_EQUAL
	LD R1, ASCII_EQUAL	;
	NOT R1, R1		;
	ADD R1, R1, #1		;
	ADD R1, R1, R0		;
	BRz CHECK_ONEVALUE	; Is '='
	BRnp CHECK_SPACE	; Not '='

CHECK_SPACE
	LD R1, ASCII_SPACE	;
	NOT R1, R1		;
	ADD R1, R1, #1		;
	ADD R1, R1, R0		;
	BRz EVALUATE_DONE	; Is ' '
	BRnp CHECK_OPERATOR	; Not ' '

CHECK_OPERATOR
	LD R1, ASCII_PLUS	;
	NOT R1, R1		;
	ADD R1, R1, #1		;
	ADD R1, R1, R0		;
	BRz DO_PLUS		; Is '+'
	LD R1, ASCII_MIN	;
	NOT R1, R1		;
	ADD R1, R1, #1		;
	ADD R1, R1, R0		;
	BRz DO_MIN		; Is '-'
	LD R1, ASCII_MUL	;
	NOT R1, R1		;
	ADD R1, R1, #1		;
	ADD R1, R1, R0		;
	BRz DO_MUL		; Is '*'
	LD R1, ASCII_DIV	;
	NOT R1, R1		;
	ADD R1, R1, #1		;
	ADD R1, R1, R0		;
	BRz DO_DIV		; Is '/'
	LD R1, ASCII_EXP	;
	NOT R1, R1		;
	ADD R1, R1, #1		;
	ADD R1, R1, R0		;
	BRz DO_EXP		; Is '^'
	BRnp CHECK_NUMBER	; Not operator

CHECK_NUMBER
	LD R1, ASCII_DIV	;
	NOT R1, R1		;
	ADD R1, R1, #1		;
	ADD R1, R1, R0		;
	BRnz EVALUATE_INVALID	; <x30
	LD R1, ASCII_SEMI	;
	NOT R1, R1		;
	ADD R1, R1, #1		;
	ADD R1, R1, R0		;
	BRzp EVALUATE_INVALID	; >x39
	AND R0, R0, #15		; Number Mask	
	BRnzp DO_PUSH		;

DO_PLUS
	JSR POP			;
	ADD R5, R5, #0		; Underflow Check
	BRp EVALUATE_INVALID	;
	AND R4, R4, #0		;
	ADD R4, R4, R0		;
	JSR POP			;
	ADD R5, R5, #0		; Underflow Check
	BRp EVALUATE_INVALID	;
	AND R3, R3, #0		;
	ADD R3, R3, R0		;
	JSR PLUS		;
	BRnzp DO_PUSH		;

DO_MIN
	JSR POP			;
	ADD R5, R5, #0		; Underflow Check
	BRp EVALUATE_INVALID	;
	AND R4, R4, #0		;
	ADD R4, R4, R0		;
	JSR POP			;
	ADD R5, R5, #0		; Underflow Check
	BRp EVALUATE_INVALID	;
	AND R3, R3, #0		;
	ADD R3, R3, R0		;
	JSR MIN			;
	BRnzp DO_PUSH		;

DO_MUL
	JSR POP			;
	ADD R5, R5, #0		; Underflow Check
	BRp EVALUATE_INVALID	;
	AND R4, R4, #0		;
	ADD R4, R4, R0		;
	JSR POP			;
	ADD R5, R5, #0		; Underflow Check
	BRp EVALUATE_INVALID	;
	AND R3, R3, #0		;
	ADD R3, R3, R0		;
	JSR MUL			;
	BRnzp DO_PUSH		;

DO_DIV
	JSR POP			;
	ADD R5, R5, #0		; Underflow Check
	BRp EVALUATE_INVALID	;
	AND R4, R4, #0		;
	ADD R4, R4, R0		;
	JSR POP			;
	ADD R5, R5, #0		; Underflow Check
	BRp EVALUATE_INVALID	;
	AND R3, R3, #0		;
	ADD R3, R3, R0		;
	JSR DIV			;
	BRnzp DO_PUSH		;

DO_EXP
	JSR POP			;
	ADD R5, R5, #0		; Underflow Check
	BRp EVALUATE_INVALID	; ***
	AND R4, R4, #0		;
	ADD R4, R4, R0		;
	JSR POP			;
	ADD R5, R5, #0		; Underflow Check
	BRp EVALUATE_INVALID	; ***
	AND R3, R3, #0		;
	ADD R3, R3, R0		;
	JSR EXP			;
	BRnzp DO_PUSH		;

DO_PUSH
	JSR PUSH		;
	AND R2, R2, #0		; Set R2 to 0, continue
	BRnzp EVALUATE_DONE	;

CHECK_ONEVALUE
	JSR POP			;
	ADD R5, R5, #0		; Underflow Check
	BRp EVALUATE_INVALID	; ***
	AND R6, R6, #0		;
	ADD R6, R6, R0		;
	JSR POP			;
	ADD R5, R5, #0		; Underflow Check
	BRz EVALUATE_INVALID	; ***
	AND R2, R2, #0		; 
	ADD R2, R2, #-1		; Set R2 to -1, done
	BRnzp EVALUATE_DONE	;

EVALUATE_INVALID
	AND R2, R2, #0		;
	ADD R2, R2, #1		; Set R2 to 1, invalid
	BRnzp EVALUATE_DONE	;

EVALUATE_DONE
	LD R0, EVALUATE_SaveR0	; Restore R0
	LD R1, EVALUATE_SaveR1	; Restore R1		
	LD R3, EVALUATE_SaveR3	; Restore R3
	LD R4, EVALUATE_SaveR4	; Restore R4
	LD R5, EVALUATE_SaveR5	; Restore R5
	LD R7, EVALUATE_SaveR7	; Restore R7
	RET			;

EVALUATE_SaveR0	.BLKW #1	;
EVALUATE_SaveR1	.BLKW #1	;	
EVALUATE_SaveR3	.BLKW #1	;
EVALUATE_SaveR4	.BLKW #1	;	
EVALUATE_SaveR5	.BLKW #1	;
EVALUATE_SaveR7	.BLKW #1	;

ASCII_SPACE	.FILL	x0020	;' '
ASCII_EQUAL	.FILL	x003d	;'='
ASCII_DIV	.FILL	x002f	;'/', before '0'
ASCII_SEMI	.FILL	x003a	;':', after '9'
ASCII_PLUS	.FILL	x002b	;'+'
ASCII_MIN	.FILL	x002d	;'-'
ASCII_MUL	.FILL	x002a	;'*'
ASCII_EXP	.FILL	x005e	;'^'

;*** We should actually pop value back at these position
;==============================

;==============================
;TODO:	What if output is negative?
;IN:  	R3- value to print in hexadecimal
;R0: 	Temporary Register
;R3: 	Number we want to print
;R4:	Outer loop counter : 4 letters
;R5:	Inner loop counter : 4 bits
;R6: 	Digit we actually print
;
PRINT_HEX
	ST R0, PRINT_SaveR0	; Save R0	
	ST R3, PRINT_SaveR3	; Save R3
	ST R4, PRINT_SaveR4	; Save R4
	ST R5, PRINT_SaveR5	; Save R5
	ST R6, PRINT_SaveR6	; Save R6
	ST R7, PRINT_SaveR7	; Save R7
	AND R4, R4, #0		; R4 = 0

; Check if we got 4 letters
PRINT_OUTERLOOP	
	ADD R0, R4, #-4		; R0 = R4 - 4, Condition Check
	BRz PRINT_DONE		;		
	AND R5, R5, #0		; R5 = 0
	AND R6, R6, #0		; R6 = 0

; Check if we got 4 bits 
PRINT_INNERLOOP	
	ADD R0, R5, #-4		; R0 = R5 - 4, Condition Check
	BRz PRINT_OUTPUT	;	
	ADD R6, R6, R6 		; R6 = R6 + R6, Digit left shift
	ADD R3, R3, #0		;
	BRzp PRINT_ADD_ZERO	;
	ADD R6, R6, #1		;
PRINT_ADD_ZERO		
	ADD R3, R3, R3 		; R3 = R3 + R3, R3 left shift
	ADD R5, R5, #1		;
	BRnzp PRINT_INNERLOOP	;
		
; Print the number on to the display
PRINT_OUTPUT		
	ADD R0, R6, #-9		;
	BRnz PRINT_ASCII_ADD_ZERO	;
	LD R0, PRINT_A		; Add A in order to get the real ASCII value
	ADD R0, R0, R6		;
	ADD R0, R0, #-10	;
	BRnzp PRINT_DISPLAY	;
PRINT_ASCII_ADD_ZERO  		
	LD R0, PRINT_ZERO	; Add zero in order to get the real ASCII value
	ADD R0, R0, R6		;
PRINT_DISPLAY		
	OUT			;

	ADD R4, R4, #1		;
	BRnzp PRINT_OUTERLOOP	;

PRINT_DONE
	LD R0, PRINT_SaveR0	; Restore R0	
	LD R3, PRINT_SaveR3	; Restore R3
	LD R4, PRINT_SaveR4	; Restore R4
	LD R5, PRINT_SaveR5	; Restore R5
	LD R6, PRINT_SaveR6	; Restore R6
	LD R7, PRINT_SaveR7	; Restore R7
	RET			;

PRINT_SaveR0	.BLKW #1	;
PRINT_SaveR3	.BLKW #1	;	
PRINT_SaveR4	.BLKW #1	;
PRINT_SaveR5	.BLKW #1	;
PRINT_SaveR6	.BLKW #1	;
PRINT_SaveR7	.BLKW #1	;
PRINT_ZERO 	.FILL 	x0030	; ASCII value of '0'
PRINT_A 	.FILL   x0041	; ASCII value of 'A'
;==============================

;==============================
;     	R0 = R3 + R4
;IN:  	R3, R4
;OUT: 	R0
;
PLUS	
	AND R0, R0, #0		; R0 = 0	
	ADD R0, R3, R4		; R0 = R3 + R4
	RET			;
;==============================
	
;==============================
;     	R0 = R3 - R4
;IN:  	R3, R4
;OUT: 	R0
;
MIN	
	AND R0, R0, #0		; R0 = 0	
	NOT R0, R4		;
	ADD R0, R0, #1		; R0 = -R4
	ADD R0, R0, R3		; R0 = R3 - R4
	RET			;
;==============================
	
;==============================
;     	R0 = R3 * R4
;IN:  	R3, R4
;OUT: 	R0
;R4:  	Also act as a loop counter
;
MUL	
	ST R2, MUL_SaveR2	; Save R2
	ST R4, MUL_SaveR4	; Save R4
	AND R0, R0, #0		; R0 = 0
	AND R2, R2, #0		;
MUL_CHECK
	ADD R4, R4, #0		;
	BRzp MUL_LOOP		;
	NOT R4, R4		;
	ADD R4, R4, #1		;
	ADD R2, R2, #1		; Set R2 to 1 when negative occured
	BRnzp MUL_LOOP		;
MUL_LOOP
	ADD R4, R4, #0		; Condition check
	BRz MUL_SET		; R4 = 0 when done
	ADD R0, R0, R3		; R0 = R0 + R3
	ADD R4, R4, #-1		; R4 = R4 - 1
	BRnzp MUL_LOOP		;
MUL_SET
	ADD R2, R2, #0		;
	BRnz MUL_DONE		;
	NOT R0, R0		;
	ADD R0, R0, #1		;
	BRnzp MUL_DONE		;
MUL_DONE
	LD R2, MUL_SaveR2	; Restore R2
	LD R4, MUL_SaveR4	; Restore R4
	RET			;

MUL_SaveR2	.BLKW #1	;
MUL_SaveR4	.BLKW #1	;
;==============================
	
;==============================
;     	R0 = R3 / R4
;Algorithm:
;     	Save R3 & R4
;    	R0 = 0
;     	R3 = R3 - R4
;     	If R3 > 0, R0 = R0 + 1
;     	El RET
;IN:  	R3, R4
;OUT: 	R0
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
	LD R3, DIV_SaveR3	; Restore R3
	LD R4, DIV_SaveR4	; Restore R4
	RET			;

DIV_SaveR3	.BLKW #1	;
DIV_SaveR4	.BLKW #1	;
;==============================
	
;==============================
;     	R0 = R3 ^ R4
;	R0 = 1
;	(R0 = R0 * R3 for R4 times)
;Algorithm:
;	Save R2, R3, R4
;	R0 = 1, R2 = R4, R4 = R3
;	LOOP - check if R2 = 0
;	R3 = R0
;	MUL
;	R2 = R2 - 1, go back to loop if R2 != 0
;		     done if R2 = 0
;IN:  	R3, R4
;OUT: 	R0
;R2: 	As a counter
;
EXP
	ST R2, EXP_SaveR2	; Save R2
	ST R3, EXP_SaveR3	; Save R3
	ST R4, EXP_SaveR4	; Save R4
	ST R7, EXP_SaveR7	; Save R7
	AND R0, R0, #0		;
	ADD R0, R0, #1		; R0 = 1
	AND R2, R2, #0		;
	ADD R2, R2, R4		; R2 = R4
	AND R4, R4, #0		;
	ADD R4, R4, R3		; R4 = R3
EXP_LOOP
	ADD R2, R2, #0		; Condition Check
	BRz EXP_DONE		; R2 = 0 when done
	AND R3, R3, #0		;
	ADD R3, R3, R0		; R3 = R0
	JSR MUL			; R0 = R3 * R4
	ADD R2, R2, #-1		; R2 = R2 - 1
	BRnzp EXP_LOOP
EXP_DONE
	LD R2, EXP_SaveR2	; Restore R2
	LD R3, EXP_SaveR3	; Restore R3
	LD R4, EXP_SaveR4	; Restore R4
	LD R7, EXP_SaveR7	; Restore R7
	RET			;

EXP_SaveR2	.BLKW #1	;
EXP_SaveR3	.BLKW #1	;
EXP_SaveR4	.BLKW #1	;
EXP_SaveR7	.BLKW #1	;
;==============================

;==============================
;IN:  	R0
;OUT: 	R5 (0-success, 1-fail/overflow)
;R3:  	STACK_END 
;R4:  	STACK_TOP
;
PUSH	
	ST R3, PUSH_SaveR3	; save R3
	ST R4, PUSH_SaveR4	; save R4
	AND R5, R5, #0		;
	LD R3, STACK_END	;
	LD R4, STACk_TOP	;
	ADD R3, R3, #-1		;
	NOT R3, R3		;
	ADD R3, R3, #1		;
	ADD R3, R3, R4		;
	BRz OVERFLOW		; stack is full
	STR R0, R4, #0		; no overflow, store value in the stack
	ADD R4, R4, #-1		; move top of the stack
	ST R4, STACK_TOP	; store top of stack pointer
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
;OUT: 	R0 
;     	R5 (0-success, 1-fail/underflow)
;R3:  	STACK_START 
;R4:  	STACK_TOP
;
POP	
	ST R3, POP_SaveR3	; save R3
	ST R4, POP_SaveR4	; save R4
	AND R5, R5, #0		; clear R5
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
