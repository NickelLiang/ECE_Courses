; getinput.asm
;
; Get player input, check if it's valid.
; If it's valid, return input.
; If it's invalid, ask player to give another try.
;
; Nickel Liang, zuodong2@illinois.edu
; ECE220 Honor Lab
; 10/03/17

    .ORIG x3400             ;

; GETINPUT
;   Inputs:
;     R0: Current player's token
;   Outputs:
;     R0: Column number chosen by player
;   Registers:
;     R1: Temporary store player input
GETINPUT
    ST R0, GI_SaveR0        ;
    ST R1, GI_SaveR1        ;
    ST R7, GI_SaveR7        ;

GI_CHECK_PLAYER
    LD R0, GI_SaveR0        ; When we get an invalid input and loop back,
    ADD R0, R0, #0          ; we need to set R0 to player token
    BRp GI_P1               ; Player token is 1, player 1's move
    BRn GI_P2               ; Player token is -1, player 2's move
    
GI_P1
    LD R0, GI_P1_PROMPT     ; Print 'Player 1's turn: [1-7] '
    PUTS                    ;
    BRnzp GI_ECHO           ;

GI_P2
    LD R0, GI_P2_PROMPT     ; Print 'Player 2's turn: [1-7] '
    PUTS                    ;
    BRnzp GI_ECHO           ;

GI_ECHO
    GETC                    ;
    OUT                     ;
    ADD R1, R0, #0          ; Store player input into R1
    LDI R0, GI_NEWLINE      ; Print NewLine
    OUT                     ;
    
    LDI R0, GI_ASCII_ZERO   ; Check if we got a valid number
    NOT R0, R0              ;
    ADD R0, R0, #1          ;
    ADD R1, R0, R1          ; R1 = INPUT - x0030
    BRnz GI_INVALID         ; Check Lower Bound, Input at least 1
    ADD R0, R1, #-7         ; R0 = INPUT - x0030 - 7, #7 should be #0
    BRp GI_INVALID          ; Check Upper Bound
    
    BRnzp GI_DONE           ;
	
GI_INVALID
    LD R0, GI_INVALID_INPUT ; Print 'Invalid Input!\n'
    PUTS                    ;
    BRnzp GI_CHECK_PLAYER   ;

GI_DONE
    ADD R0, R1, #0          ;
    LD R1, GI_SaveR1        ;
    LD R7, GI_SaveR7        ;
    RET                     ;

GI_SaveR0
	.BLKW #1                ;
GI_SaveR1
	.BLKW #1                ;
GI_SaveR7
	.BLKW #1                ;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Do not modify below this line ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Indirect references to far away locations
GI_ASCII_ZERO
    .FILL x602A
GI_NEWLINE
    .FILL x602B
GI_P1_PROMPT
    .FILL x605A
GI_P2_PROMPT
    .FILL x6072
GI_INVALID_INPUT
    .FILL x608A

; End of assembly file
    .END
