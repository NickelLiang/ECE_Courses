#include <stdio.h>
#include "prime.h"

int input, i;

int main(){
  // Write the code to take a number n from user and print all the prime numbers between 1 and n
  printf("Enter the value of n: ");
  scanf("%d", &input);
  printf("Printing primes less than or equal to %d:\n", input);
  for (i = 0; i <= input; i++) {
    if (is_prime(i) == 1) {
      printf("%d ", i);
    }
  }
  printf("\n");
  return 0;
}
