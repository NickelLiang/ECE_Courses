/*
 * This program can solve a sudoku. The first four functions can check if a number is valid.
 * The fifth function use a recursive method to solve the sudoku.
 *
 * Nickel Liang, 10/20/2017
 * zuodong2@illinois.edu
 */


#include "sudoku.h"

//-------------------------------------------------------------------------------------------------
// Start here to work on your MP7
//-------------------------------------------------------------------------------------------------

// You are free to declare any private functions if needed.

// Function: is_val_in_row
// Return true if "val" already existed in ith row of array sudoku.
int is_val_in_row(const int val, const int i, const int sudoku[9][9]) {
  assert(i>=0 && i<9);

  int j;
  for (j = 0; j < 9; j++) {
    if (sudoku[i][j] == val) {
      return 1;
    }
  }
  return 0;
}

// Function: is_val_in_col
// Return true if "val" already existed in jth column of array sudoku.
int is_val_in_col(const int val, const int j, const int sudoku[9][9]) {
  assert(j>=0 && j<9);

  int i;
  for (i = 0; i < 9; i++) {
    if (sudoku[i][j] == val) {
      return 1;
    }
  }
  return 0;
}

// Function: is_val_in_3x3_zone
// Return true if val already existed in the 3x3 zone corresponding to (i, j)
int is_val_in_3x3_zone(const int val, const int i, const int j, const int sudoku[9][9]) {
  assert(i>=0 && i<9);

  int upper = i - (i % 3); // Get the upper left corner coordinate.
  int left = j - (j % 3);
  int x,y; // Check those nine places.
  for (x = upper; x < upper + 3; x++) {
    for (y = left; y < left + 3; y++) {
      if (sudoku[x][y] == val) {
        return 1;
      }
    }
  }
  return 0;
}

// Function: is_val_valid
// Return true if the val is can be filled in the given entry.
int is_val_valid(const int val, const int i, const int j, const int sudoku[9][9]) {
  assert(i>=0 && i<9 && j>=0 && j<9);

  if (is_val_in_row(val, i, sudoku)||is_val_in_col(val, j, sudoku)||is_val_in_3x3_zone(val, i, j, sudoku)) {
    return 0;
  }
  return 1;
}

// Procedure: solve_sudoku
// Solve the given sudoku instance.
int solve_sudoku(int sudoku[9][9]) {
  int i, j, empty = 0;
  int emp_i, emp_j, num;
  for (i = 0; i < 9; i++) {
    for (j = 0; j < 9; j++) {
      if (sudoku[i][j] == 0 && empty == 0) {
        emp_i = i; //If we found empty location, record the coordinate.
        emp_j = j;
        empty = 1;
      }
    }
  }

  if (empty == 0) {
    return 1; //If the puzzle is full, we solved it.
  }

  for (num = 1; num <= 9; num++) {
    if (is_val_valid(num, emp_i, emp_j, sudoku)) {
      sudoku[emp_i][emp_j] = num;
      if (solve_sudoku(sudoku)) { //Recursion.
        return 1;
      }
      sudoku[emp_i][emp_j] = 0; //Back track.
    }
  }
  return 0;
}

// Procedure: print_sudoku
void print_sudoku(int sudoku[9][9])
{
  int i, j;
  for(i=0; i<9; i++) {
    for(j=0; j<9; j++) {
      printf("%2d", sudoku[i][j]);
    }
    printf("\n");
  }
}

// Procedure: parse_sudoku
void parse_sudoku(const char fpath[], int sudoku[9][9]) {
  FILE *reader = fopen(fpath, "r");
  assert(reader != NULL);
  int i, j;
  for(i=0; i<9; i++) {
    for(j=0; j<9; j++) {
      fscanf(reader, "%d", &sudoku[i][j]);
    }
  }
  fclose(reader);
}
