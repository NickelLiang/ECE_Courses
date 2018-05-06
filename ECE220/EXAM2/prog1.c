#include <stdio.h>

int maxProfit(int *prices, int n);

int main(int argc, char const *argv[]) {
    int n = 10;
    int data[] = {4, 3, 2, 3, 6, 4, 2, 1, 3, 4};
    printf("max is %d\n", maxProfit(data, n));
    return 0;
}

int maxProfit(int *prices, int n) {
    int i, j;
    int buy = 0;
    int sell = 0;
    int max = 0;
    for (i = 0; i < n; i++) {
        for (j = i; j < n; j++) {
            if (prices[j]-prices[i] >= max) {
                buy = i;
                sell = j;
                max = prices[j]-prices[i];
            }
        }
    }
    printf("buy %d sell %d max %d\n", buy+1, sell+1, max);
    return max;
}
