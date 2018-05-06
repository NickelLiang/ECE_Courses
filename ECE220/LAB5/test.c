#include <stdio.h>

int main()
{
    int num_scan = 0;
    int i;

    printf("Input a number: ");
    num_scan = scanf("%d", &i);

    printf("Scanned in %d numbers.\n", num_scan);
    printf("Number = %d\n", i);
}
