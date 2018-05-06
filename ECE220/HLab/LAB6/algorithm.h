#include <stdio.h>
#include <stdlib.h>
#include <math.h>

void printMatrix(int **matrix, int x, int y);
int maxInFour(int a, int b, int c, int d);
int max(int a, int b);
int substitution(char *a, char *b, int **matrix, int i, int j, int sub);
void maxInMatrix(int **matrix, int x, int y, int *row, int *col);
int trace(int **matrix, int *row, int *col, int SUB, int GAP, char *seq1, char *seq2, int *out1, int *out2, int *index);
