#include "algorithm.h"

// Return H(i-1,j-1) + s(ai,bj)
int substitution(char *a, char *b, int **matrix, int i, int j, int sub) {
    (a[i] == b[j]) ? (sub = sub) : (sub = -sub);
    return matrix[i-1][j-1] + sub;
}

// Print the given x*y matrix
void printMatrix(int **matrix, int x, int y) {
    int i, j;
    for (i = 0; i < x; i++) {
        for (j = 0; j < y; j++) {
            printf("%02d ", matrix[i][j]);
        }
        printf("\n");
    }
    printf("\n");
}

// This function take in two values and return the max
int max(int a, int b) {
    if (a >= b) return a;
    return b;
}

// This function take in four values and return the max
int maxInFour(int a, int b, int c, int d) {
    int maxN = max(max(max(a,b),c),d);
    if (a == maxN) {
        return -2; // Upper left
    } else if (b == maxN) {
        return -1; // Upper
    } else if (c == maxN) {
        return 1; // Left
    } else {
        return 0; // None
    }
}

// Find max value in matrix
void maxInMatrix(int **matrix, int x, int y, int *row, int *col) {
    int i, j, temp = 0;
    for (i = 1; i < x; i++) {
        for (j = 1; j < y; j++) {
            if (matrix[i][j] >= temp) {
                temp = matrix[i][j];
                *row = i;
                *col = j;
            }
        }
    }
}

// Trace back, recursively solve the problem
int trace(int **matrix, int *row, int *col, int SUB, int GAP, char *seq1, char *seq2, int *out1, int *out2, int *index) {
    int source = maxInFour(substitution(seq1, seq2, matrix, *row, *col, SUB),matrix[*row-1][*col]-GAP,matrix[*row][*col-1]-GAP,0);
    int nRow = 0;
    int nCol = 0;

    if (matrix[*row][*col] == 0){
        return 0; //End
    }

    out1[*index] = *row;
    out2[*index] = *col;

    *index = *index + 1;

    if (source == 0) { //End
        return 0;
    } else if (source == -2) { //Upper Left
        nRow = *row - 1;
        nCol = *col - 1;
    } else if (source == -1) { //Upper
        nRow = *row - 1;
        nCol = *col;
    } else if (source == 1) { //Left
        nRow = *row;
        nCol = *col - 1;
    }

    if (nRow == 0 || nCol == 0) {
        return 0; //End
    }

    //printf("source: %d a: %d b: %d val: %d\n", source, nRow, nCol, matrix[*row][*col]);
    return trace(matrix, &nRow, &nCol, SUB, GAP, seq1, seq2, out1, out2, index);
}
