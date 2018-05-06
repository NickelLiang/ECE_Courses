#include "honors4.h"
// reads in the two preference files and populates the preference matrices.
// INPUT:
// menPrefs: men preference file name
// womenPrefs: women preference file name
// size: The number of men or women
// men: empty men preference array
// women: empty women preference array
// SIDE EFFECTS:
// men: populated men preference array where men[i][j] is the jth preference of the ith man
// women: populated women preference array where women[i][j] is the jth preference of the jth woman
void readPrefFiles(char *menPrefs, char *womenPrefs, int size, int **men, int **women) {
  FILE *menFile = fopen(menPrefs, "r");
  FILE *womenFile = fopen(womenPrefs, "r");
  int i, j;
  for (i = 0; i < size; i++) {
    for (j = 0; j < size; j++) {
      fscanf(menFile, "%d", &men[i][j]);
      fscanf(womenFile, "%d", &women[i][j]);
    }
  }
  fclose(menFile);
  fclose(womenFile);
}

//This function solves the stable marriage problem for with males as suitors
//INPUTS:
//men- populated preference array for men
//women- populated preference array for women
//solution- the 1-dimensional solution array where solution[i] is the wife of man i

void maleOptimalSolution(int **men, int **women, int *solution, int size) {
  int tempMen[size][size], i, j, k;
  int freeMen = size;
  int tempWomen[size];
  int solutionEmpty;
  int warning = 0;

  for (i = 0; i < size; i++) {
    tempWomen[i] = -1;
    solution[i] = -1;
    for (j = 0; j < size; j++) {
      tempMen[i][j] = 0;
    }
  }

  while (freeMen != 0) {
    solutionEmpty = 1; //Solution is not empty
    for (i = 0; i < size; i++) { //Loop over men
      int proposeCount = 0; //This man has proposed to # of women
      for (j = 0; j < size; j++) { //Loop over women / men's choice
        if (solution[i] != -1) {
          break;
        }
        if (tempMen[i][j] != 1) {//If he didn't propose to her before
          int propose = men[i][j];
          tempMen[i][j] = 1;
          //printf("Men %d Propose to %d\n", i, propose);
          if (tempWomen[propose] == -1) { //If she is free
            solution[i] = propose;
            tempWomen[propose] = i; //They become engaged
            //printf("%d is free, MW(%d, %d)\n\n", solution[i], tempWomen[propose], solution[i]);
            break;
          } else { //If she is already engaged
            int previous = tempWomen[propose];
            int current = i;
            //printf("%d is already engaged with %d.\n", propose, previous);
            for (k = 0; k < size; k++) {
              if (women[propose][k] == previous) { //Else they remain engaged
                break;
              } else if (women[propose][k] == current) {//If she prefer new
                solution[previous] = -1; //Previous is free
                solutionEmpty = 0; //solution has empty
                warning = 1; //warning! something just changed
                solution[i] = propose;
                tempWomen[propose] = i;
                //printf("But %d choose to engage with %d. MW(%d, %d). %d is free now.\n\n", propose, current, current, propose, previous);
                break;
              }
            }
          }
        } else {
          proposeCount ++;
        }
      }
      if (proposeCount == size) {
        freeMen --;
      }
    }
    if (solutionEmpty == 1 && warning != 1) {
      break;
    }
    warning = 0;
  }
}
