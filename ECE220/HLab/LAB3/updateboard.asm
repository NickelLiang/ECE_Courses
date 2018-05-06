; updateboard.asm
;
; Update board base on player token and player input.
; Return 1 if update is successful.
; Return 0 if update is failed.
;
; Nickel Liang, zuodong2@illinois.edu
; ECE220 Honor Lab
; 10/03/17

    .ORIG x3800         ;
    
; UPDATEBOARD
;   Inputs:
;     R0: Current player's token. 1 for player 1 and -1 for player 2.
;     R1: Column to make move in [1-7]
;   Outputs:
;     R0: Memory location that is updated if successful
;         0 if move was unsuccessful (column is full)
;   Registers:
;     R0: Output / Token
;     R1: Column / Temp
;     R2: Row pointer
;     R3: Board pointer
;     R4: Value @ M[Board Pointer]
UPDATEBOARD
    ST R1, UB_SaveR1    ;
    ST R2, UB_SaveR2    ;
    ST R3, UB_SaveR3    ;
    ST R4, UB_SaveR4    ;
    ST R7, UB_SaveR7    ;
    
    LD R3, UB_BOARD     ;
    ADD R3, R3, R1      ; 
    ADD R3, R3, #-1     ; R3 = x6000 + Col - 1
    AND R2, R2, #0      ; R2 = 0. R2 in range 0 to 5
    LDR R4, R3, #0      ;
    BRnp UB_FAILED      ; First row is occupied. Invalid.
    ADD R3, R3, #7      ; R3 is 2nd row addr
    
UB_LOOP
    ADD R1, R2, #-5     ; Check if R2 is #5
    BRz UB_FILL         ;
    
    LDR R4, R3, #0      ; Check if M[R3] is empty
    BRnp UB_FILL        ; If M[R3] is not empty, fill player token
    ADD R2, R2, #1      ; If M[R3] is empty, check next row
    ADD R3, R3, #7      ;
    BRnzp UB_LOOP       ;
    
UB_FILL
    ADD R3, R3, #-7     ;
    STR R0, R3, #0      ;
    ADD R0, R3, #0      ;
    BRnzp UB_DONE       ;

UB_FAILED               ;
    AND R0, R0, #0      ;
    BRnzp UB_DONE       ;
    
UB_DONE
    LD R1, UB_SaveR1    ;
    LD R2, UB_SaveR2    ;
    LD R3, UB_SaveR3    ;
    LD R4, UB_SaveR4    ;
    LD R7, UB_SaveR7    ;
    RET                 ;

UB_SaveR1
    .BLKW #1            ;
UB_SaveR2
    .BLKW #1            ;
UB_SaveR3
    .BLKW #1            ;
UB_SaveR4
    .BLKW #1            ;
UB_SaveR7
    .BLKW #1            ;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Do not modify below this line ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Indirect references to far away locations
UB_BOARD
    .FILL x6000

; End of assembly file
    .END
