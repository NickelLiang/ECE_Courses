; ECE 220 FA17 LAB1
; Function description:
; 	Print R3 on monitor in hexidecimal format
; Nickel Liang, 09/01/2017	

	.ORIG x3000
	
; R0 Register for test
; R4 Outer loop counter : 4 letters
; R5 Inner loop counter : 4 bits
; R6 Digit

	AND R4,R4,#0		; Initialize register

; Check if we got 4 letters
OUTERLOOP	
	ADD R0,R4,#-4
	BRz DONE

	AND R5,R5,#0		; Initialize registers
	AND R6,R6,#0

; Check if we got 4 bits 
INNERLOOP	
	ADD R0,R5,#-4
	BRz OUTPUT
			
	ADD R6,R6,R6 		; Digit left shift
	ADD R3,R3,#0
	BRzp ADD_ZERO
	ADD R6,R6,#1
ADD_ZERO		
	ADD R3,R3,R3 		; R3 left shift
		
	ADD R5,R5,#1
	BRnzp INNERLOOP
		
; Print the number on to the display
OUTPUT		
	ADD R0,R6,#-9
	BRnz ASCII_ADD_ZERO
	LD R0,ASCII_A
	ADD R0,R0,R6		; Add A to our digit to get the real ASCII value to print
	ADD R0,R0,#-10
	BRnzp DISPLAY
ASCII_ADD_ZERO  
	LD R0,ASCII_ZERO	; Add 0 to our digit to get the real ASCII value to print
	ADD R0,R0,R6
DISPLAY		
	OUT			; Print on our display!

	ADD R4,R4,#1
	BRnzp OUTERLOOP

DONE	HALT			; We are done!

ASCII_ZERO 	.FILL 	x0030	; ASCII value of '0'
ASCII_A 	.FILL   x0041	; ASCII value of 'A'

		.END
