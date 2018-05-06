; printboard.asm
;
; Print Content from x6000 to x6029.
; 7 values in a row, 6 rows total.
; If the memory addr contain  1, print P1 piece.
; If the memory addr contain  0, print empty piece.
; If the memory addr contain -1, print P2 piece.
;
; Nickel Liang, zuodong2@illinois.edu
; ECE220 Honor Lab
; 10/03/17

    .ORIG x3600         ;
; PRINTBOARD
;   Inputs:
;     NONE
;   Outputs:
;     NONE
;   Registers:
;     R0: IO
;     R1: Column Loop Counter
;     R2: Row Loop counter
;     R3: Board Pointer
;     R4: Value @ M[Board Pointer]
PRINTBOARD
    ST R0, PB_SaveR0    ;
    ST R1, PB_SaveR1    ;
    ST R2, PB_SaveR2    ;
    ST R3, PB_SaveR3    ;
    ST R4, PB_SaveR4    ;
    ST R7, PB_SaveR7    ;
    
    LD R3, PB_BOARD     ;
    AND R2, R2, #0      ;
    ADD R2, R2, #6      ; We have 6 rows to print
PB_ROW_LOOP
    ADD R2, R2, #0      ;
    BRz PB_ROW_DONE     ;
    AND R1, R1, #0      ;
    ADD R1, R1, #7      ; We have 7 columns in each row
PB_COL_LOOP    
    ADD R1, R1, #0      ;
    BRz PB_COL_DONE     ;
    
    LDR R4, R3, #0      ; R4 now contain actual value
    ADD R3, R3, #1      ; Update Pointer
    ADD R1, R1, #-1     ; Update Column Counter
    ADD R4, R4, #0      ;
    BRp PB_PRINT_P1     ; If value is positive, P1 occupied
    BRn PB_PRINT_P2     ; If value is negative, P2 occupied
    
    LDI R0, PB_EMPTY_PIECE  ;
    OUT                 ; If value is zero, no one occupied
    BRnzp PB_COL_LOOP   ;
    
PB_PRINT_P1
    LDI R0, PB_P1_PIECE ;
    OUT                 ;
    BRnzp PB_COL_LOOP   ;
    
PB_PRINT_P2
    LDI R0, PB_P2_PIECE ;
    OUT                 ;
    BRnzp PB_COL_LOOP   ;
     
PB_COL_DONE
    LDI R0, PB_NEWLINE  ; Finish print 7 columns
    OUT                 ;
    ADD R2, R2, #-1     ; Update Row Counter
    BRnzp PB_ROW_LOOP   ;

PB_ROW_DONE
    LD R0, PB_SaveR0    ; Finish print 6 rows
    LD R1, PB_SaveR1    ;
    LD R2, PB_SaveR2    ;
    LD R3, PB_SaveR3    ;
    LD R4, PB_SaveR4    ;
    LD R7, PB_SaveR7    ;
    RET

PB_SaveR0
    .BLKW #1            ;
PB_SaveR1
    .BLKW #1            ;
PB_SaveR2
    .BLKW #1            ;
PB_SaveR3
    .BLKW #1            ;
PB_SaveR4
    .BLKW #1            ;
PB_SaveR7
    .BLKW #1            ;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Do not modify below this line ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Indirect references to far away locations
PB_BOARD
    .FILL x6000
PB_ASCII_ZERO
    .FILL x602A
PB_NEWLINE
    .FILL x602B
PB_EMPTY_PIECE
    .FILL x602C
PB_P1_PIECE
    .FILL x602D
PB_P2_PIECE
    .FILL x602E

; End of assembly file
    .END
