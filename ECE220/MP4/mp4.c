/*
 * This program print all semiprimes between a user entered range.
 * Nickel Liang, Sep. 29, 2017
 * ECE220 MP4
 */

#include <stdlib.h>
#include <stdio.h>

int is_prime(int number);
int print_semiprimes(int a, int b);

int main() {
   int a, b;
   printf("Input two numbers: ");
   scanf("%d %d", &a, &b);
   if ( a <= 0 || b <= 0 ) {
     printf("Inputs should be positive integers\n");
     return 1;
   }

   if ( a > b ) {
     printf("The first number should be smaller than or equal to the second number\n");
     return 1;
   }

   print_semiprimes(a, b); //Print all semiprimes
   return 0;
}

/*
 * Function : is_prime
 * Purpose  : Check the number is prime or not.
 * Input    : a number
 * Return   : 0 if the number is not prime, else 1
 */
int is_prime(int number)
{
  int i;
  if (number < 2) { //Prime begin at 2
    return 0;
  }
  for (i = 2; i < number; i++) {
    if (number % i == 0) {
      return 0;
    }
  }
  return 1;
}

/*
 * Function : print_semiprimes
 * Purpose  : print all semiprimes in [a,b] (including a, b).
 * Input    : a, b (a should be smaller than or equal to b)
 * Return   : 0 if there is no semiprime in [a,b], else 1
 */
int print_semiprimes(int a, int b) {
  int i, j, flag;
  for (i = a; i <= b; i++) {
    for (j = 2; j < i; j++) {
      if (i % j == 0) {
        if ((is_prime(j) == 1) && (is_prime(i / j) == 1)) {
          printf("%d ", i);
          flag = 1;
          break; // if we found it's semiprime, we can jump to check the next number.
        }
      }
    }
  }
  printf("\n");
  if (flag == 1) {
    return 1;
  } else {
    return 0;
  }
}
