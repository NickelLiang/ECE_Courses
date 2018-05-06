; ECE190 Fall 2012
; MP2 - Connect Four
; Chun Yang & Brad Thompson

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Do not modify this file ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

    .ORIG x3000

    LD R0, CF_START_PROMPT  ; Print start game string
    PUTS

    LD R7, CF_PRINTBOARD    ; Print the empty board
    JSRR R7

    AND R6, R6, 0           ; Use R6 to store token of current player
    ADD R6, R6, -1          ; Set current player to be player 2

CF_GAMELOOP
    NOT R6, R6              ; Change player (by changing player token)
    ADD R6, R6, 1

CF_VALIDATION_LOOP
    ; GETINPUT
    ADD R0, R6, 0           ; Put current player's token in R0
    LD R7, CF_GETINPUT      ; Call GETINPUT and get player's move, placing the
    JSRR R7                 ;   selected column in R0

    ; UPDATEBOARD
    ADD R1, R0, 0           ; Put player's move in R1
    ADD R0, R6, 0           ; Put player's token in R0
    LD R7, CF_UPDATEBOARD   ; Call UPDATEBOARD to update the game board based
    JSRR R7                 ;   on the player's move

    ADD R2, R0, 0           ; Check Return value from UPDATEBOARD
    BRnp CF_DONE_INPUT      ; If the value is not zero, the update was
                            ;   successful and the move was valid

    LD R0, CF_INVALID_MOVE  ; If the update was not successful,
    PUTS                    ;   show error message and try again
    BR CF_VALIDATION_LOOP

CF_DONE_INPUT
    ; PRINTBOARD
    LD R7, CF_PRINTBOARD    ; Call PRINTBOARD to print the game board
    JSRR R7

    ; CHECKFORWIN
    ADD R0, R6, 0           ; Put player's token in R0
                            ; Player's move is already in R1
                            ; Memory location of last updated position is
                            ;   in R2
    LD R7, CF_CHECKFORWIN   ; Call CHECKFORWIN to check for a win
    JSRR R7

    ADD R0, R0, 0           ; Check Return value from CHECKFORWIN
    BRp CF_WIN              ; If the value is positive, the game is over

    ; CHECKSTALEMATE
    LD R7, CF_CHECKSTALEMATE    ; Call CHECKSTALEMATE to check stalemate condition
    JSRR R7

    ADD R0, R0, 0           ; Check Return value from CHECKSTALEMATE
    BRp CF_TIE              ; If the value is positive, the game is over

    BR CF_GAMELOOP          ; Repeat

CF_WIN
    ADD R6, R6, 0           ; Check which player wins
    BRn #3                  ; Skip down if player 2 wins
    LD R0, CF_P1_WIN_PROMPT ; Print player 1's winning message
    PUTS
    BR CF_END               ; Halt
    LD R0, CF_P2_WIN_PROMPT ; Print player 2's winning message
    PUTS
    BR CF_END               ; Halt

CF_TIE
    LD R0, CF_STALEMATE_PROMPT  ; Print stalemate message
    PUTS

CF_END
    HALT                    ; Game over, win or stalemate occured

; Store addresses of strings in near memory, so they can be
;   accessed via indirection

CF_START_PROMPT
    .FILL x602F
CF_INVALID_MOVE
    .FILL x609A
CF_GETINPUT
    .FILL x3400
CF_PRINTBOARD
    .FILL x3600
CF_UPDATEBOARD
    .FILL x3800
CF_CHECKFORWIN
    .FILL x3A00
CF_CHECKSTALEMATE
    .FILL x3C00
CF_STALEMATE_PROMPT
    .FILL x60A9
CF_P1_WIN_PROMPT
    .FILL x60B5
CF_P2_WIN_PROMPT
    .FILL x60C5

; End of assembly file
    .END
