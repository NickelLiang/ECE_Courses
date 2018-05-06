/*
 * This program consists of three functions.
 * The first function set_seed can check if user input is valid,
 * and set srand seed if input is valid.
 * The second function start_game can generate 4 solutions.
 * The third function make_guess can check user's guess.
 *
 * ECE220 MP5, 10/06/17
 * Nickel Liang, zuodong2@illinois.edu
 */

/*
 * The functions that you must write are defined in the header file.
 * Blank function prototypes with explanatory headers are provided
 * in this file to help you get started.
 */

#include <stdio.h>
#include <stdlib.h>
#include "prog5.h"

/*
 * You will need to keep track of the solution code using file scope
 * variables as well as the guess number.
 */

static int guess_number;
static int solution1;
static int solution2;
static int solution3;
static int solution4;

/*
 * set_seed -- This function sets the seed value for pseudorandom
 * number generation based on the number the user types.
 * The input entered by the user is already stored in the string seed_str by the code in main.c.
 * This function should use the function sscanf to find the integer seed value from the
 * string seed_str, then initialize the random number generator by calling srand with the integer
 * seed value. To be valid, exactly one integer must be entered by the user, anything else is invalid.
 * INPUTS: seed_str -- a string (array of characters) entered by the user, containing the random seed
 * OUTPUTS: none
 * RETURN VALUE: 0 if the given string is invalid (string contains anything
 *               other than a single integer), or 1 if string is valid (contains one integer)
 * SIDE EFFECTS: initializes pseudo-random number generation using the function srand. Prints "set_seed: invalid seed\n"
 *               if string is invalid. Prints nothing if it is valid.
 */
int set_seed (const char seed_str[]) {
  int seed;
  char post[2];
  if (sscanf (seed_str, "%d%1s", &seed, post) == 1) { //Check if we got a valid seed input
    srand(seed);
    return 1;
  } else {
    printf("set_seed: invalid seed\n");
    return 0;
  }
}

/*
 * start_game -- This function is called by main.c after set_seed but before the user makes guesses.
 *               This function creates the four solution numbers using the approach
 *               described in the wiki specification (using rand())
 *               The four solution numbers should be stored in the static variables defined above.
 *               The values at the pointers should also be set to the solution numbers.
 *               The guess_number should be initialized to 1 (to indicate the first guess)
 * INPUTS: none
 * OUTPUTS: *one -- the first solution value (between 1 and 6)
 *          *two -- the second solution value (between 1 and 6)
 *          *three -- the third solution value (between 1 and 6)
 *          *four -- the fourth solution value (between 1 and 6)
 * RETURN VALUE: none
 * SIDE EFFECTS: records the solution in the static solution variables for use by make_guess, set guess_number
 */
void start_game (int* one, int* two, int* three, int* four) {
  *one = rand() % 6 + 1; //These numbers are between 1 and 6
  *two = rand() % 6 + 1;
  *three = rand() % 6 + 1;
  *four = rand() % 6 + 1;
  guess_number = 1;
  solution1 = *one;
  solution2 = *two;
  solution3 = *three;
  solution4 = *four;
}

/*
 * make_guess -- This function is called by main.c after the user types in a guess.
 *               The guess is stored in the string guess_str.
 *               The function must calculate the number of perfect and misplaced matches
 *               for a guess, given the solution recorded earlier by start_game
 *               The guess must be valid (contain only 4 integers, within the range 1-6). If it is valid
 *               the number of correct and incorrect matches should be printed, using the following format
 *               "With guess %d, you got %d perfect matches and %d misplaced matches.\n"
 *               If valid, the guess_number should be incremented.
 *               If invalid, the error message "make_guess: invalid guess\n" should be printed and 0 returned.
 *               For an invalid guess, the guess_number is not incremented.
 * INPUTS: guess_str -- a string consisting of the guess typed by the user
 * OUTPUTS: the following are only valid if the function returns 1 (A valid guess)
 *          *one -- the first guess value (between 1 and 6)
 *          *two -- the second guess value (between 1 and 6)
 *          *three -- the third guess value (between 1 and 6)
 *          *four -- the fourth color value (between 1 and 6)
 * RETURN VALUE: 1 if the guess string is valid (the guess contains exactly four
 *               numbers between 1 and 6), or 0 if it is invalid
 * SIDE EFFECTS: prints (using printf) the number of matches found and increments guess_number(valid guess)
 *               or an error message (invalid guess)
 *               (NOTE: the output format MUST MATCH EXACTLY, check the wiki writeup)
 */
int make_guess (const char guess_str[], int* one, int* two, int* three, int* four) {
  int w, x, y, z, i, j;
  int perfect = 0;
  int mismatch = 0;
  char post[2];
  int gue[4], sol[4];

  //Check if we got a valid input
  if (sscanf(guess_str, "%d%d%d%d%1s", &w, &x, &y, &z, post) != 4) {
    printf("make_guess: invalid guess\n");
    return 0;
  }
  if (w > 6 || w < 1 || x > 6 || x < 1 || y > 6 || y < 1 || z > 6 || z < 1) {
    printf("make_guess: invalid guess\n");
    return 0;
  }

  //Set guessed values
  *one = w;
  *two = x;
  *three = y;
  *four = z;

  //Initialize test array
  gue[0] = w;
  gue[1] = x;
  gue[2] = y;
  gue[3] = z;
  sol[0] = solution1;
  sol[1] = solution2;
  sol[2] = solution3;
  sol[3] = solution4;

  //Find perfect answers by check if sol[i] and gue[i] are equal
  for (i = 0; i < 4; i++) {
    if (gue[i] == sol[i]) {
      perfect ++;
      gue[i] = 0; //Set corresponding number to 0
      sol[i] = 0; //Easier for us to check mismatch
    }
  }

  //Find mismatch by go over sol and gue array 4 times
  for (i = 0; i < 4; i++) {
    for (j = 0; j < 4; j++) {
      if (gue[i] != 0 && sol[j] != 0) { //If 0 is in that position, skip
        if (gue[i] == sol[j]) {
          mismatch ++;
          gue[i] = 0; //If we found a mismatch, set original array to 0
          sol[j] = 0;
        }
      }
    }
  }

  printf("With guess %d, you got %d perfect matches and %d misplaced matches.\n", guess_number, perfect, mismatch);
  guess_number++;

  return 1;
}
