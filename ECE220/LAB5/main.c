/* Code to simulate rolling three six-sided dice (D6)
 * User first types in seed value
 * Use seed value as argument to srand()
 * Call roll_three to generate three integers, 1-6
 * Print result "%d %d %d "
 * If triple, print "Triple!\n"
 * If it is not a triple but it is a dobule, print "Double!\n"
 * Otherwise print "\n"
 */
 #include <stdio.h>
 #include <stdlib.h>
 #include "dice.h"

 int main() {

   int seed, diceOne, diceTwo, diceThree = 0;

   printf("Enter Seed:\n");
   scanf("%d", &seed);
   srand(seed);
   roll_three(&diceOne, &diceTwo, &diceThree);

   printf("%d %d %d ", diceOne, diceTwo, diceThree);
   if ((diceOne == diceTwo) && (diceTwo == diceThree)) {
     printf("Triple!\n");
   } else if ((diceOne == diceTwo) || (diceTwo == diceThree) || (diceOne == diceThree)) {
     printf("Double!\n");
   } else {
     printf("\n");
   }

   return 0;
 }
