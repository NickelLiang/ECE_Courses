// This is an implementation of Smith-Waterman Algorithm.
// Version 1.0
// It's a very fun problem, but since it's my first draft,
// the code is a little bit messy. I can do better with more time.
//
// ECE 220 HLab 6, 10/28/17
// Nickel Liang, zuodong2@illinois.edu
//
// Compile this file and algorithm.c
// Run with ./<program> <inputfile>

#include "algorithm.h"

// Global Parameter
int SUB = 1; // Substitution Penalty
int GAP = 1; // Gap Penalty
int MAX = 8; // Start with allocate this memory size to sequences

// Run the code in ./h6 <SequenceFile>
int main(int argc, char *argv[]) {
    // Read two lines from file
    // This is a little bit tricky when I put into another function
    // So I just leave it here..
    FILE *file = fopen(argv[1], "r");

    int tempMax = MAX;
    char ch = ' ';
    int len1 = 0;
    int len2 = 0;
    char *seq1 = malloc(MAX*sizeof(char));
    char *seq2 = malloc(MAX*sizeof(char));
    seq1[len1] = ch;
    seq2[len2] = ch;

    // printf("Before allocation\n");
    // printf("Seq1 ADDR: %p\n", seq1);
    // printf("Seq2 ADDR: %p\n\n", seq2);

    do {
        if(len1 == tempMax) { // time to expand ?
            tempMax = tempMax * 2;
            seq1 = realloc(seq1, tempMax*sizeof(char)); // reallocate memory, give it more!
        }
        fscanf(file, "%c", &ch);
        len1++;
        if (ch != '\n') seq1[len1] = ch;
    } while ((ch != '\n') && (ch != EOF));

    // printf("Seq1 allocated\n");
    // printf("Seq1 ADDR: %p\n", seq1);
    // printf("Seq2 ADDR: %p\n\n", seq2);

    ch = ' ';
    tempMax = MAX;

    do {
        if(len2 == tempMax) { // time to expand ?
            tempMax = tempMax * 2;
            seq2 = realloc(seq2, tempMax*sizeof(char)); // re allocate memory.
        }
        fscanf(file, "%c", &ch);
        len2++;
        if (ch != '\n') seq2[len2] = ch;
    } while ((ch != '\n') && (ch != EOF));

    fclose(file);

    // printf("Seq2 allocated\n");
    // printf("Seq1 ADDR: %p\n", seq1);
    // printf("Seq2 ADDR: %p\n\n", seq2);

    seq1 = realloc(seq1, len1*sizeof(char)); //Optimize memory space
    seq2 = realloc(seq2, len2*sizeof(char));

    // printf("Seqs reallocated\n");
    // printf("Seq1 ADDR: %p\n", seq1);
    // printf("Seq2 ADDR: %p\n", seq2);

    printf("\nSubs. Penalty : %d\n", SUB);
    printf("Gap Penalty   : %d\n\n", GAP);
    printf("Seq1:%s\n", seq1);
    printf("Seq2:%s\n\n", seq2);
    printf("Len1: %d\n", len1);
    printf("Len2: %d\n\n", len2);

    // Initialize the matrix
    int i, j;
    int **matrix;
    matrix = malloc((len1) * sizeof(matrix));
    for (i = 0; i < len1; i++) {
        matrix[i] = malloc((len2) * sizeof(matrix[0]));
        for (j = 0; j < len2; j++) {
            matrix[i][j] = 0;
        }
    }

    //printMatrix(matrix, len1, len2);

    // Fill score matrix
    for (i = 1; i < len1; i++) {
        for (j = 1; j < len2; j++) {
            matrix[i][j] = max(max(max(substitution(seq1, seq2, matrix, i, j, SUB),matrix[i-1][j]-GAP),matrix[i][j-1]-GAP),0);
        }
    }

    printMatrix(matrix, len1, len2);

    // Find where to start trace back
    int maxRow = 0;
    int maxCol = 0;

    maxInMatrix(matrix, len1, len2, &maxRow, &maxCol);

    // Get output array
    int *outSeq1 = malloc(((len1-1)+(len2-1)) * sizeof(outSeq1));
    int *outSeq2 = malloc(((len1-1)+(len2-1)) * sizeof(outSeq2));
    int index = 0;

    //Trace back
    trace(matrix, &maxRow, &maxCol, SUB, GAP, seq1, seq2, outSeq1, outSeq2, &index);

    //Print the result
    for(i = 1; i < index; i++) {
        if (outSeq1[i-1]==outSeq1[i]) {
            outSeq1[i-1] = -1;
        }
        if (outSeq2[i-1]==outSeq2[i]) {
            outSeq2[i-1] = -1;
        }
	}

    for(i = index-1; i >= 0; i--) {
        if (outSeq2[i] == -1) {
            printf("- ");
        } else {
		printf("%c ", seq2[outSeq2[i]]);
        }
	}
    printf("\n");

    for(i = index-1; i >= 0; i--) {
        if (outSeq1[i] == -1 || outSeq2[i] == -1) {
            printf("  ");
        } else {
		printf("| ");
        }
	}
    printf("\n");

    for(i = index-1; i >= 0; i--) {
        if (outSeq1[i] == -1) {
            printf("- ");
        } else {
		printf("%c ", seq1[outSeq1[i]]);
        }
	}
    printf("\n");

    free(seq1);
    free(seq2);

    return 0;
}
