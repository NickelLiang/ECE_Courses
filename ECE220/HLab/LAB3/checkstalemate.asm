; checkstalemate.asm
;
;
; Nickel Liang, zuodong2@illinois.edu
; ECE220 Honor Lab
; 10/03/17

    .ORIG x3C00         ;
; CHECKSTALEMATE
;   Outputs:
;     R0: 1 if the board is filled
;         0 if it isn't
;   Registers:
;     R1: Loop Counter
;     R3: Board pointer
;     R4: Value @ M[R3]
CHECKSTALEMATE
    ST R1, CS_SaveR1    ;
    ST R3, CS_SaveR3    ;
    ST R4, CS_SaveR4    ;
    LD R3, CS_BOARD     ;
    AND R1, R1, #0      ;
    ADD R1, R1, #7      ; We have 7 columns in each row
CS_LOOP    
    ADD R1, R1, #0      ;
    BRz CS_FULL         ;
    LDR R4, R3, #0      ; R4 now contain actual value
    ADD R3, R3, #1      ; Update Pointer
    ADD R1, R1, #-1     ; Update Column Counter
    ADD R4, R4, #0      ;
    BRnp CS_LOOP        ;
    BRz CS_NOT_FULL     ;

CS_NOT_FULL
    AND R0, R0, #0      ;
    BRnzp CS_DONE       ;

CS_FULL
    AND R0, R0, #0      ;
    ADD R0, R0, #1      ;
    BRnzp CS_DONE       ;

CS_DONE
    LD R1, CS_SaveR1    ;
    LD R3, CS_SaveR3    ;
    LD R4, CS_SaveR4    ;
    RET                 ;

CS_SaveR1
    .BLKW #1            ;
CS_SaveR3
    .BLKW #1            ;
CS_SaveR4
    .BLKW #1            ;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Do not modify below this line ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Indirect references to far away locations
CS_BOARD
    .FILL x6000

; End of assembly file
    .END
