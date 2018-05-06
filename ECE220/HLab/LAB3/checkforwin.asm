; checkforwin.asm
;
; This program contain 4 subroutine.
; Each subroutine can take in a starting address, and check if four
; counsecutive address has the same value.
; In the main program, I applied some filter condition to maximize program
; efficiency.
;
; Nickel Liang, zuodong2@illinois.edu
; ECE220 Honor Lab
; 10/03/17

    .ORIG x3A00         ;
; CHECKFORWIN
;   Inputs:
;     R0: Current player's token
;     R1: Column of last move
;     R2: Memory location modified in last move
;   Outputs:
;     R0: 1 if the player wins
;         0 if no win
;   Registers:
;     R0: Token
;     R1: Column
;     R2: Board pointer
;     R3: Return from SR
;     R4: Loop counter
;     R5: Temp Addr Pointer
;     R6: Loop counter
;     R7: Temp
CHECKFORWIN
    ST R0, CW_SaveR0    ;
    ST R1, CW_SaveR1    ;
    ST R2, CW_SaveR2    ;
    ST R3, CW_SaveR3    ;
    ST R4, CW_SaveR4    ;
    ST R5, CW_SaveR5    ;
    ST R6, CW_SaveR6    ;
    ST R7, CW_SaveR7    ;

CW_C_HOR
    NOT R5, R1          ;
    ADD R5, R5, #2      ; R5 = - R1 + 1
    ADD R5, R5, R2      ; R5 = R2 + 1 - R1
    AND R4, R4, #0      ;
    ADD R4, R4, #4      ; Check from col 1 to 4
CW_C_HOR_LOOP
    ADD R4, R4, #0      ;
    BRz CW_C_VER        ;
    ADD R3, R5, #0      ; R3 = R5
    JSR CW_HOR          ;
    ADD R3, R3, #0      ;
    BRp CW_WIN          ;
    ADD R4, R4, #-1     ; Update counter
    ADD R5, R5, #1      ; Update temp pointer
    BRnzp CW_C_HOR_LOOP ;
    
CW_C_VER
    LD R5, CW_BOARD     ;
    NOT R5, R5          ;
    ADD R5, R5, #1      ; R5 = - x6000
    ADD R5, R5, R2      ; R5 = R2 - x6000
    ADD R5, R5, #-10    ;
    ADD R5, R5, #-10    ; R5 = R2 - x6020
    BRp CW_C_LRD      	; If R2 is in range x6000 - x6020, nz
    ADD R3, R2, #0      ; R3 = R2
    JSR CW_VER          ;
    ADD R3, R3, #0      ;
    BRp CW_WIN          ;
    BRnzp CW_C_LRD      ;
    
CW_C_LRD
    LD R5, CW_BOARD     ; R5 at begin of the board
    AND R4, R4, #0      ;
    ADD R4, R4, #3      ; Check first 3 row
CW_C_LRD_ROW_LOOP
    ADD R4, R4, #0      ;
    BRz CW_C_RLD        ;
    AND R6, R6, #0      ;
    ADD R6, R6, #4      ; Check first 4 item in each row
CW_C_LRD_COL_LOOP
    ADD R6, R6, #0      ;
    BRz CW_C_LRD_COL_DONE   ;
    ADD R3, R5, #0      ; 
    JSR CW_LRD          ;
    ADD R3, R3, #0      ;
    BRp CW_WIN          ;
    ADD R5, R5, #1      ;
    ADD R6, R6, #-1     ;
    BRnzp CW_C_LRD_COL_LOOP ;
CW_C_LRD_COL_DONE
    ADD R5, R5, #3      ;
    ADD R4, R4, #-1     ;
    BRnzp CW_C_LRD_ROW_LOOP ;
    
CW_C_RLD
    LD R5, CW_BOARD     ; R5 at begin of the board
    ADD R5, R5, #3      ;
    AND R4, R4, #0      ;
    ADD R4, R4, #3      ; Check first 3 row
CW_C_RLD_ROW_LOOP
    ADD R4, R4, #0      ;
    BRz CW_NOT_WIN      ;
    AND R6, R6, #0      ;
    ADD R6, R6, #4      ; Check last 4 item in each row
CW_C_RLD_COL_LOOP
    ADD R6, R6, #0      ;
    BRz CW_C_RLD_COL_DONE   ;
    ADD R3, R5, #0      ;
    JSR CW_RLD          ;
    ADD R3, R3, #0      ;
    BRp CW_WIN          ;
    ADD R5, R5, #1      ;
    ADD R6, R6, #-1     ;
    BRnzp CW_C_RLD_COL_LOOP ;
CW_C_RLD_COL_DONE
    ADD R5, R5, #3      ;
    ADD R4, R4, #-1     ;
    BRnzp CW_C_RLD_ROW_LOOP ;
    BRnzp CW_NOT_WIN    ;

CW_WIN
    AND R0, R0, #0      ;
    ADD R0, R0, #1      ;
    BRnzp CW_DONE       ;
CW_NOT_WIN
    AND R0, R0, #0      ;
    BRnzp CW_DONE       ;
CW_DONE
    LD R1, CW_SaveR1    ;
    LD R2, CW_SaveR2    ;
    LD R3, CW_SaveR3    ;
    LD R4, CW_SaveR4    ;
    LD R5, CW_SaveR5    ;
    LD R6, CW_SaveR6    ;
    LD R7, CW_SaveR7    ;
    RET                 ;

CW_SaveR0
    .BLKW #1            ;
CW_SaveR1
    .BLKW #1            ;
CW_SaveR2
    .BLKW #1            ;
CW_SaveR3
    .BLKW #1            ;
CW_SaveR4
    .BLKW #1            ;
CW_SaveR5
    .BLKW #1            ;
CW_SaveR6
    .BLKW #1            ;
CW_SaveR7
    .BLKW #1            ;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CW_HOR
;   Check 4 horizontal consecutive addr
;   Input:
;     R0: Token
;     R3: Starting memory addr
;   Output:
;     R3: If 4 consecutive are same as token, 1
;         If 4 consecutive are not same as token, 0
;   Registers:
;     R1: Loop counter
;     R4: Value @ M[R2]
CW_HOR
    ST R0, CW_HOR_R0    ;
    ST R1, CW_HOR_R1    ;
    ST R4, CW_HOR_R4    ;
    ST R7, CW_HOR_R7    ;
    AND R1, R1, #0      ;
    ADD R1, R1, #4      ;
CW_HOR_LOOP
    ADD R1, R1, #0      ;
    BRz CW_HOR_SAME     ;
    LDR R4, R3, #0      ;
    ADD R1, R1, #-1     ; Update counter
    ADD R3, R3, #1      ; Update pointer
    NOT R4, R4          ;
    ADD R4, R4, #1      ;
    ADD R4, R4, R0      ; R4 = R0 - M[R2]
    BRz CW_HOR_LOOP     ;
    AND R3, R3, #0      ;
    BRnzp CW_HOR_DONE   ;
CW_HOR_SAME
    AND R3, R3, #0      ;
    ADD R3, R3, #1      ;
    BRnzp CW_HOR_DONE   ;
CW_HOR_DONE
    LD R0, CW_HOR_R0    ;
    LD R1, CW_HOR_R1    ;
    LD R4, CW_HOR_R4    ;
    LD R7, CW_HOR_R7    ;
    RET                 ;

CW_HOR_R0   .BLKW #1    ;
CW_HOR_R1   .BLKW #1    ;
CW_HOR_R4   .BLKW #1    ;
CW_HOR_R7   .BLKW #1    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CW_VER
;   Check 4 vertical consecutive addr
;   Input:
;     R0: Token
;     R3: Starting memory addr
;   Output:
;     R3: If 4 consecutive are same as token, 1
;         If 4 consecutive are not same as token, 0
;   Registers:
;     R1: Loop counter
;     R4: Value @ M[R2]
CW_VER
    ST R0, CW_VER_R0    ;
    ST R1, CW_VER_R1    ;
    ST R4, CW_VER_R4    ;
    ST R7, CW_VER_R7    ;
    AND R1, R1, #0      ;
    ADD R1, R1, #4      ;
CW_VER_LOOP
    ADD R1, R1, #0      ;
    BRz CW_VER_SAME     ;
    LDR R4, R3, #0      ;
    ADD R1, R1, #-1     ; Update counter
    ADD R3, R3, #7      ; Update pointer
    NOT R4, R4          ;
    ADD R4, R4, #1      ;
    ADD R4, R4, R0      ; R4 = R0 - M[R2]
    BRz CW_VER_LOOP     ;
    AND R3, R3, #0      ;
    BRnzp CW_VER_DONE   ;
CW_VER_SAME
    AND R3, R3, #0      ;
    ADD R3, R3, #1      ;
    BRnzp CW_VER_DONE   ;
CW_VER_DONE
    LD R0, CW_VER_R0    ;
    LD R1, CW_VER_R1    ;
    LD R4, CW_VER_R4    ;
    LD R7, CW_VER_R7    ;
    RET                 ;

CW_VER_R0   .BLKW #1    ;
CW_VER_R1   .BLKW #1    ;
CW_VER_R4   .BLKW #1    ;
CW_VER_R7   .BLKW #1    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CW_LRD
;   Check left to right diagonal address
;   Input:
;     R0: Token
;     R2: Starting memory addr
;   Output:
;     R3: If 4 consecutive are same as token, 1
;         If 4 consecutive are not same as token, 0
;   Registers:
;     R1: Loop counter
;     R4: Value @ M[R2]
CW_LRD
    ST R0, CW_LRD_R0    ;
    ST R1, CW_LRD_R1    ;
    ST R4, CW_LRD_R4    ;
    ST R7, CW_LRD_R7    ;
    AND R1, R1, #0      ;
    ADD R1, R1, #4      ;
CW_LRD_LOOP
    ADD R1, R1, #0      ;
    BRz CW_LRD_SAME     ;
    LDR R4, R3, #0      ;
    ADD R1, R1, #-1     ; Update counter
    ADD R3, R3, #8      ; Update pointer
    NOT R4, R4          ;
    ADD R4, R4, #1      ;
    ADD R4, R4, R0      ; R4 = R0 - M[R2]
    BRz CW_LRD_LOOP     ;
    AND R3, R3, #0      ;
    BRnzp CW_LRD_DONE   ;
CW_LRD_SAME
    AND R3, R3, #0      ;
    ADD R3, R3, #1      ;
    BRnzp CW_LRD_DONE   ;
CW_LRD_DONE
    LD R0, CW_LRD_R0    ;
    LD R1, CW_LRD_R1    ;
    LD R4, CW_LRD_R4    ;
    LD R7, CW_LRD_R7    ;
    RET                 ;

CW_LRD_R0   .BLKW #1    ;
CW_LRD_R1   .BLKW #1    ;
CW_LRD_R4   .BLKW #1    ;
CW_LRD_R7   .BLKW #1    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; CW_RLD
;   Check right to left diagonal address
;   Input:
;     R0: Token
;     R2: Starting memory addr
;   Output:
;     R3: If 4 consecutive are same as token, 1
;         If 4 consecutive are not same as token, 0
;   Registers:
;     R1: Loop counter
;     R4: Value @ M[R2]
CW_RLD
    ST R0, CW_RLD_R0    ;
    ST R1, CW_RLD_R1    ;
    ST R4, CW_RLD_R4    ;
    ST R7, CW_RLD_R7    ;
    AND R1, R1, #0      ;
    ADD R1, R1, #4      ;
CW_RLD_LOOP
    ADD R1, R1, #0      ;
    BRz CW_RLD_SAME     ;
    LDR R4, R3, #0      ;
    ADD R1, R1, #-1     ; Update counter
    ADD R3, R3, #6      ; Update pointer
    NOT R4, R4          ;
    ADD R4, R4, #1      ;
    ADD R4, R4, R0      ; R4 = R0 - M[R2]
    BRz CW_RLD_LOOP     ;
    AND R3, R3, #0      ;
    BRnzp CW_RLD_DONE   ;
CW_RLD_SAME
    AND R3, R3, #0      ;
    ADD R3, R3, #1      ;
    BRnzp CW_RLD_DONE   ;
CW_RLD_DONE
    LD R0, CW_RLD_R0    ;
    LD R1, CW_RLD_R1    ;
    LD R4, CW_RLD_R4    ;
    LD R7, CW_RLD_R7    ;
    RET                 ;

CW_RLD_R0   .BLKW #1    ;
CW_RLD_R1   .BLKW #1    ;
CW_RLD_R4   .BLKW #1    ;
CW_RLD_R7   .BLKW #1    ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Do not modify below this line ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Indirect references to far away locations
CW_BOARD
    .FILL x6000

; End of assembly file
    .END
