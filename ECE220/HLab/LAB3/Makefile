# Makefile
#
# Usage:
#   To assemble your probgram,
#     make
#
#   To run your program using lc3sim,
#     make sim
#
#   To remove .obj and .sym files,
#     make clean

###########################
# Do not modify this file #
###########################

all:
	lc3as data.asm
	lc3as getinput.asm
	lc3as printboard.asm
	lc3as updateboard.asm
	lc3as checkforwin.asm
	lc3as checkstalemate.asm
	lc3as mp2.asm

sim:
	lc3sim -s mp2.lcs

clean:
	rm -vf *.obj *.sym
