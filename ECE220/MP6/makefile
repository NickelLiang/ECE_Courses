all:
	gcc -Wall -std=c99 -lm -g -I include/ -L lib/ main.c updateBoard.c -o gameoflife -lncurses
	gcc -Wall -std=c99 -lm -g test.c updateBoard.c updateBoardGold.o -o test
clean:
	rm gameoflife
	rm test
