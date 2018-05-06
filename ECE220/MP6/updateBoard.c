/*
 * This program is part of MP6.
 * countLiveNeighbor can count how many nearby neighbors have value 1
 * updateBoard put updated board to a temporary array, after finished updateBoard
 * the whole board, it copy the value back to original board.
 * aliveStable can check if we reach to the end of the game.
 * Nickel Liang, 10/13/17
 * ECE 220 MP6, zuodong2@illinois.edu
 */

/*
 * countLiveNeighbor
 * Inputs:
 * board: 1-D array of the current game board. 1 represents a live cell.
 * 0 represents a dead cell
 * boardRowSize: the number of rows on the game board.
 * boardColSize: the number of cols on the game board.
 * row: the row of the cell that needs to count alive neighbors.
 * col: the col of the cell that needs to count alive neighbors.
 * Output:
 * return the number of alive neighbors. There are at most eight neighbors.
 * Pay attention for the edge and corner cells, they have less neighbors.
 */
int countLiveNeighbor(int* board, int boardRowSize, int boardColSize, int row, int col) {
	int i,j;
	int count = 0;
	for (i = row - 1; i <= row + 1; i++) { //We only need to go over a 3 * 3 area
		for (j = col - 1; j <= col + 1; j++) {
			if (i >= 0 && i < boardRowSize && j >= 0 && j < boardColSize && !(i == row && j == col)) {
				if (board[i * boardColSize + j] == 1) { //If that location is one, we count it.
					count++;
				}
			}
		}
	}
	return count;
}

/*
 * Update the game board to the next step.
 * Input:
 * board: 1-D array of the current game board. 1 represents a live cell.
 * 0 represents a dead cell
 * boardRowSize: the number of rows on the game board.
 * boardColSize: the number of cols on the game board.
 * Output: board is updated with new values for next step.
 */
void updateBoard(int* board, int boardRowSize, int boardColSize) {
	int i, j;
	int temp_board[boardRowSize*boardColSize];
	for (i = 0; i < boardRowSize; i++) {
		for (j = 0; j < boardColSize; j++) {
			int current = board[i * boardColSize + j];
			int neighbors = countLiveNeighbor(board, boardRowSize, boardColSize, i, j);
			if ((neighbors < 2) && (current == 1)) {
				temp_board[i * boardColSize + j] = 0; //Any live cell with fewer than two live neighbours dies, as if caused by under-population.
			} else if ((neighbors > 3) && (current == 1)) {
				temp_board[i * boardColSize + j] = 0; //Any live cell with more than three live neighbours dies, as if by over-population.
			} else if ((neighbors == 3) && (current == 0)) {
				temp_board[i * boardColSize + j] = 1; //Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
			} else if (((neighbors == 2)||(neighbors == 3)) && (current == 1)) {
				temp_board[i * boardColSize + j] = 1; //Any live cell with two or three live neighbours lives on to the next generation.
			} else {
				temp_board[i * boardColSize + j] = board[i * boardColSize + j]; //Nothing changed, just copy # to the temp array.
			}
		}
	}
	for (i = 0; i < boardRowSize; i++) {
		for (j = 0; j < boardColSize; j++) {
			board[i * boardColSize + j] = temp_board[i * boardColSize + j]; //Copy temp array back to original board
		}
	}
}

/*
 * aliveStable
 * Checks if the alive cells stay the same for next step
 * board: 1-D array of the current game board. 1 represents a live cell.
 * 0 represents a dead cell
 * boardRowSize: the number of rows on the game board.
 * boardColSize: the number of cols on the game board.
 * Output: return 1 if the alive cells for next step is exactly the same with
 * current step or there is no alive cells at all.
 * return 0 if the alive cells change for the next step.
 */
int aliveStable(int* board, int boardRowSize, int boardColSize){
	int i, j, noChange = 1;
	for (i = 0; i < boardRowSize; i++) {
		for (j = 0; j < boardColSize; j++) {
			int current = board[i * boardColSize + j];
			int neighbors = countLiveNeighbor(board, boardRowSize, boardColSize, i, j);
			if ((neighbors < 2) && (current == 1)) { //if anything changed, we can notify.
				noChange = 0;
			} else if ((neighbors > 3) && (current == 1)) {
				noChange = 0;
			} else if ((neighbors == 3) && (current == 0)) {
				noChange = 0;
			}
		}
	}
	return noChange;
}
