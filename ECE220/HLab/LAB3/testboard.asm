; testboard.asm
;
; This file contains an example board to test PRINTBOARD

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Do not modify this file ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

    .ORIG x6000

; Example Board
BOARD           ; x6000
    .FILL 1     ; row 1 (top)
    .FILL 0
    .FILL 0
    .FILL 0
    .FILL 0
    .FILL 0
    .FILL 1

    .FILL 0     ; row 2
    .FILL 0
    .FILL -1
    .FILL 0
    .FILL -1
    .FILL 0
    .FILL 0

    .FILL 0     ; row 3
    .FILL 0
    .FILL 0
    .FILL 0
    .FILL 0
    .FILL 0
    .FILL 0

    .FILL 0     ; row 4
    .FILL 1
    .FILL 0
    .FILL 0
    .FILL 0
    .FILL 1
    .FILL 0

    .FILL 0     ; row 5
    .FILL 0
    .FILL 1
    .FILL 1
    .FILL 1
    .FILL 0
    .FILL 0

    .FILL -1    ; row 6 (bottom)
    .FILL 0
    .FILL 0
    .FILL 0
    .FILL 0
    .FILL 0
    .FILL -1

; ASCII codes
ASCII_ZERO      ; x602A
    .FILL x30   ; 0
NEWLINE         ; x602B
    .FILL x0A   ; \n

; Player pieces
EMPTY_PIECE     ; x602C
    .FILL x2D   ; -
P1_PIECE        ; x602D
    .FILL x58   ; X
P2_PIECE        ; x602E
    .FILL x4F   ; O

; Strings
START_PROMPT    ; x602F
    .STRINGZ "=============\nConnect Four!\n=============\n"
P1_PROMPT       ; x605A
    .STRINGZ "Player 1's turn: [1-7] "
P2_PROMPT       ; x6072
    .STRINGZ "Player 2's turn: [1-7] "
INVALID_INPUT   ; x608A
    .STRINGZ "Invalid Input!\n"
INVALID_MOVE    ; x609A
    .STRINGZ "Invalid Move!\n"
STALEMATE       ; x60A9
    .STRINGZ "Stalemate!\n"
P1_WIN          ; x60B5
    .STRINGZ "Player 1 Wins!\n"
P2_WIN          ; x60C5
    .STRINGZ "Player 2 Wins!\n"

    .END
