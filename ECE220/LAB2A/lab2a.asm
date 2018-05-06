.ORIG x3000
; Read in characters and echo them till a newline character is entered.
;
; R0: Input/Output/Input for IS_BALANCED
; R1: Temporary
; R2: Status, = -1 if unbalanced
; R3: New Line check template
; R5: Result from IS_BALANCED
	
	AND R2, R2, #0		; Initialize status register
ECHO
	GETC			; Get an input char
	OUT			; Print on screen				
	
	ADD R2, R2, #0		; If we found unbalanced, just echo
	BRn NEWLINE_CHECK	;

	JSR IS_BALANCED		;
	ADD R5, R5, #-1		; If not balanced, R5 == -1
	BRn SET_STATUS		;
	BRzp NEWLINE_CHECK	;
SET_STATUS
	ADD R2, R2, #-1		;
	
NEWLINE_CHECK
	LD R3, NEW_LINE		; Check if user typed a NL
	NOT R3, R3		;
	ADD R3, R3, #1		; R3 = -#000A
	ADD R1, R0, R3		; If NL typed, R1 == 0
	BRz FINAL_PRINT		; User finished equation entry	
	BRnzp ECHO		;
	
FINAL_PRINT
	ADD R2, R2, #0		;
	BRn NOT_B		;

	AND R5, R5, #0		;
	ADD R5, R5, #1		;
	LEA R0, STRING_B	; Print result on screen
	PUTS			;
	BRnzp DONE		;
NOT_B	
	AND R5, R5, #0		;
	ADD R5, R5, #-1		;
	LEA R0, STRING_NOT_B	;
	PUTS			;
DONE	
	HALT			;
	
STRING_B	.STRINGZ "BALANCED\n"
STRING_NOT_B	.STRINGZ "NOT BALANCED or ERROR\n"
SPACE   	.FILL x0020
NEW_LINE        .FILL x000A
CHAR_RETURN     .FILL x000D

;==============================
;if ( push onto stack, if ) pop from stack and check if popped value is (
;IN: R0 holds the input
;OUT:R5 set to -1 if unbalanced, set to 1 if balanced. Other registers unmodified.
;
IS_BALANCED
	ST R0, BALANCED_SaveR0  ; save R0
	ST R1, BALANCED_SaveR1  ; save R1
	ST R7, BALANCED_SaveR7  ; save R7
	LD R1, NEG_OPEN		;
	ADD R1, R1, R0		;
	BRnp CHECK_END		; Not (, check if )
	JSR PUSH		;
	ADD R5, R5, #0		; Overflow Check
	BRp NOT_BALANCED	;
	BRnzp BALANCED		;
CHECK_END
	LD R1, NEG_END		;
	ADD R1, R1, R0		;
	BRnp CHECK_NL		; Not ), check if NL
	JSR POP			;
	ADD R5, R5, #0		; Underflow Check
	BRp NOT_BALANCED	;
	LD R1, NEG_OPEN		; Check if poped (
	ADD R1, R1, R0		;
	BRz BALANCED		; poped is (
	JSR PUSH		; Oops we need to put it back
	BRnzp NOT_BALANCED	; poped is not (, not balanced
CHECK_NL
	LD R1, NEG_NL		;
	ADD R1, R1, R0		;
	BRnp BALANCED		; Not NL, get next
	JSR POP			; Check if any more ( left	Underflow check?
	ADD R5, R5, #0		; *Underflow Check
	BRp BALANCED		; *No more thing in stack, it is balanced
	LD R1, NEG_OPEN		;
	ADD R1, R1, R0		;
	BRz NOT_BALANCED	; More ( left, not balanced	Take out all leftover ( ?
	JSR PUSH		; Oops we need to put it back
	BRnzp BALANCED		;
NOT_BALANCED	
	AND R5, R5, #0		; If more ( left, set R5 to -1
	ADD R5, R5, #-1		;
	LD R0, BALANCED_SaveR0	;
	LD R1, BALANCED_SaveR1	;
	LD R7, BALANCED_SaveR7	;
	RET			;
BALANCED
	AND R5, R5, #0		;
	ADD R5, R5, #1		;
	LD R0, BALANCED_SaveR0	;
	LD R1, BALANCED_SaveR1	;
	LD R7, BALANCED_SaveR7	;
	RET			;
	
BALANCED_SaveR0 .BLKW #1        ;
BALANCED_SaveR1 .BLKW #1        ;
BALANCED_SaveR7 .BLKW #1	;
NEG_OPEN 	.FILL xFFD8	; -x0028
NEG_END		.FILL xFFD7	; -x0029
NEG_NL		.FILL xFFF6	;
;==============================

;==============================
;IN:R0, OUT:R5 (0-success, 1-fail/overflow)
;R3: STACK_END R4: STACK_TOP
;
PUSH
        ST R3, PUSH_SaveR3      ;save R3
        ST R4, PUSH_SaveR4      ;save R4
        AND R5, R5, #0          ;
        LD R3, STACK_END        ;
        LD R4, STACK_TOP        ;
        ADD R3, R3, #-1         ;
        NOT R3, R3              ;
        ADD R3, R3, #1          ;
        ADD R3, R3, R4          ;
        BRz OVERFLOW            ;stack is full
        STR R0, R4, #0          ;no overflow, store value in the stack
        ADD R4, R4, #-1         ;move top of the stack
        ST R4, STACK_TOP        ;store top of stack pointer
        BRnzp DONE_PUSH         ;
OVERFLOW
        ADD R5, R5, #1          ;
DONE_PUSH
        LD R3, PUSH_SaveR3      ;
        LD R4, PUSH_SaveR4      ;
        RET

PUSH_SaveR3     .BLKW #1        ;
PUSH_SaveR4     .BLKW #1        ;
;==============================

;==============================
;OUT: R0, OUT R5 (0-success, 1-fail/underflow)
;R3 STACK_START R4 STACK_TOP
;
POP
        ST R3, POP_SaveR3       ;save R3
        ST R4, POP_SaveR4       ;save R3
        AND R5, R5, #0          ;clear R5
        LD R3, STACK_START      ;
        LD R4, STACK_TOP        ;
        NOT R3, R3              ;
        ADD R3, R3, #1          ;
        ADD R3, R3, R4          ;
        BRz UNDERFLOW           ;
        ADD R4, R4, #1          ;
        LDR R0, R4, #0          ;
        ST R4, STACK_TOP        ;
        BRnzp DONE_POP          ;
UNDERFLOW
        ADD R5, R5, #1          ;
DONE_POP
        LD R3, POP_SaveR3       ;
        LD R4, POP_SaveR4       ;
        RET

POP_SaveR3      .BLKW #1        ;
POP_SaveR4      .BLKW #1        ;
STACK_END       .FILL x3FF0     ;
STACK_START     .FILL x4000     ;
STACK_TOP       .FILL x4000     ;
;==============================

.END
