/*
  This simple program calculate a pascal triangle.
  User can input the line index, and the program will print that line of
  pascal triangle. The index number begin with 0.
  Maximum input number is 40.
  Nickel Liang, 09/22/17
  ECE220 MP3
*/
#include <stdio.h>
#include <stdlib.h>

int main()
{
  int row, k, i;
  //Read row index from user
  printf("Enter a row index: ");
  scanf("%d", &row);
  for(k = 0; k <= row; k++) { //k in range 0 to n
    unsigned long temp = 1; //Use unsigned long to prevent overflow
    for(i = 1; i <= k; i++) { //Calculate kth binomial
      temp *= (row - i + 1); //When we calculate, we try to keep the number
      temp /= i; //as small as possible
    }
    printf("%lu ", temp); //unsigned long integer use %lu
  }
  printf("\n");
  return 0;
}
