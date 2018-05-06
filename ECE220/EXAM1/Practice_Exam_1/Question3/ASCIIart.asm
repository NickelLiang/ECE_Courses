;Load ASCII art character, stored at memory address x5000 (IMAGEADDR)
;The first two numbers are the width (number of columns) and the height (number of rows) in the ASCII art image
;The memory addresses starting at x5002 are ASCII characters. The first N characters are the first row of the image, the second N characters are the second row of the image, etc.
;each row should end with a newline character

		.ORIG x3000
;YOUR CODE GOES HERE

	LD R1, IMAGEADDR	; R1 act as a pointer
	LDR R2, R1, #0		; R2 is N, column
	ADD R5, R2, #0		; R5 is a copy of N
	ADD R1, R1, #1		;
	LDR R3, R1, #0		; R3 is M, row
	ADD R1, R1, #1		;
	LD R4, ASCII_NL		; R4 is NL

LOOP_ROW
	ADD R2, R5, #0		;
	ADD R3, R3, #0		;
	BRz DONE		;

LOOP_COLUMN
	ADD R2, R2, #0		;
	BRz COLUMN_DONE		;
	LDR R0, R1, #0		;
	OUT			;
	ADD R1, R1, #1		;
	ADD R2, R2, #-1		;
	BRnzp LOOP_COLUMN	;
COLUMN_DONE
	ADD R0, R4, #0		;
	OUT			;
	ADD R3, R3, #-1		;
	BRnzp LOOP_ROW		;

DONE
	HALT			;

ASCII_NL	.FILL x000A	;
IMAGEADDR 	.FILL x5000 	; address of image
		.END
