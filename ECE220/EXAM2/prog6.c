#include <stdio.h>

int DotProduct(int vectorA[], int vectorB[], int vectorLength);
void PrintArray(int array[], int arraySize);

int main(int argc, char const *argv[]) {
    int arr1[] = {1,2,3};
    int arr2[] = {9,8,7};
    int size = sizeof(arr1)/sizeof(int);
    PrintArray(arr1, size);
    PrintArray(arr2, size);
    printf("%d\n", DotProduct(arr1, arr2, size));
    return 0;
}

int DotProduct(int vectorA[], int vectorB[], int vectorLength) {
    int sum = 0;
    int i;
    for (i = 0; i < vectorLength; i++) {
        sum += vectorA[i]*vectorB[i];
    }
    return sum;
}

void PrintArray(int array[], int arraySize) {
    int i;
    for (i = 0; i < arraySize; i++) {
        printf("%d ", array[i]);
    }
    printf("\n");
}
