// This program is a maze solver.
// It can solve arbitrary maze with specific format.
// createMaze can create a maze instance base on the input file
// destroyMaze can free memory space
// printMaze can print onto the terminal
// solveMazeManhattanDFS use DFS method to recursively solve the maze
//
// ECE220 MP9, 11/03/2017
// Nickel Liang, zuoodong2@illinois.edu

#include <stdio.h>
#include <stdlib.h>
#include "maze.h"

/*
 * createMaze -- Creates and fills a maze structure from the given file
 * INPUTS:       fileName - character array containing the name of the maze file
 * OUTPUTS:      None
 * RETURN:       A filled maze structure that represents the contents of the input file
 * SIDE EFFECTS: None
 */
maze_t * createMaze(char * fileName) {
    int i, j;
    char junk;

    // Open file
    FILE *file = fopen(fileName, "r");
    if (file == NULL) {
        printf("Failed to open file.\n");
        return NULL;
    }

    // Memory allocation
    maze_t *newMaze = (maze_t *)malloc(sizeof(maze_t)); // Allocate memory for maze
    fscanf(file, "%d %d%c", &(newMaze->width), &(newMaze->height), &junk); // Read width and height
    newMaze->cells = (char **)malloc((newMaze->height)*sizeof(newMaze->cells)); // Allocate memory for cells
    for (i = 0; i < newMaze->height; i++) {
        newMaze->cells[i] = (char *)malloc((newMaze->width)*sizeof(newMaze->cells[i]));
    }

    for (i = 0; i < newMaze->height; i++) { // Initialize the maze
        for (j = 0; j < newMaze->width; j++) {
            fscanf(file, "%c", &(newMaze->cells[i][j]));
            if (newMaze->cells[i][j] == START) { // Mark start and end location
                newMaze->startRow = i;
                newMaze->startColumn = j;
            } else if (newMaze->cells[i][j] == END) {
                newMaze->endRow = i;
                newMaze->endColumn = j;
            }
        }
        fscanf(file, "%c", &junk);
    }

    fclose(file); //Close file

    return newMaze;
}

/*
 * destroyMaze -- Frees all memory associated with the maze structure, including the structure itself
 * INPUTS:        maze -- pointer to maze structure that contains all necessary information
 * OUTPUTS:       None
 * RETURN:        None
 * SIDE EFFECTS:  All memory that has been allocated for the maze is freed
 */
void destroyMaze(maze_t * maze) {
    int i;
    for (i = 0; i < maze->height; i++) {
        free(maze->cells[i]); // Free each single cell
    }
    free(maze->cells);
    free(maze);
}

/*
 * printMaze --  Prints out the maze in a human readable format (should look like examples)
 * INPUTS:       maze -- pointer to maze structure that contains all necessary information
 *               width -- width of the maze
 *               height -- height of the maze
 * OUTPUTS:      None
 * RETURN:       None
 * SIDE EFFECTS: Prints the maze to the console
 */
void printMaze(maze_t * maze) {
    int i, j;
    for (i = 0; i < maze->height; i++) {
        for (j = 0; j < maze->width; j++) {
            printf("%c", maze->cells[i][j]); // Print every term
        }
        printf("\n");
    }
}

/*
 * solveMazeManhattanDFS -- recursively solves the maze using depth first search,
 * INPUTS:               maze -- pointer to maze structure with all necessary maze information
 *                       col -- the column of the cell currently beinging visited within the maze
 *                       row -- the row of the cell currently being visited within the maze
 * OUTPUTS:              None
 * RETURNS:              0 if the maze is unsolvable, 1 if it is solved
 * SIDE EFFECTS:         Marks maze cells as visited or part of the solution path
 */
int solveMazeManhattanDFS(maze_t * maze, int col, int row) {
    if (maze->cells[row][col] == END) {
        return 1; // We reach the end!
    }
    if (col >= 0 && col < maze->width && row >= 0 && row < maze->height &&
        (maze->cells[row][col] == START || maze->cells[row][col] == EMPTY)) { // If the location is valid
        maze->cells[row][col] = PATH; // We assume we can go there
        if (solveMazeManhattanDFS(maze, col-1, row) || // Left
            solveMazeManhattanDFS(maze, col, row-1) || // Up
            solveMazeManhattanDFS(maze, col+1, row) || // Right
            solveMazeManhattanDFS(maze, col, row+1)) { // Down
            maze->cells[maze->startRow][maze->startColumn] = START; // Reset start cell
            return 1; // Can go there
        } else {
            maze->cells[row][col] = VISITED; // We can't go there. Visited.
            return 0;
        }
    }
    return 0; // Invalid Cell
}
