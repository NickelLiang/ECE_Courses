#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define PI	3.1415926

int n, omega1, omega2, i;
double xi, f;

int main() {
	printf("Enter the value of n, omega1, and omega2 in that order\n");
	scanf("%d %d %d", &n, &omega1, &omega2);
	for(i = 0; i < n; i++) {
		xi = i * PI / n;
		f = sin(omega1 * xi) + sin(omega2 * xi) / 2;
		printf("(%f, %f)\n", xi, f);
	}
	return 0;
}
