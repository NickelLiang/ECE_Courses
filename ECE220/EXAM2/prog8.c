#include <stdio.h>

int findpair(int array[], int start, int end);
void PrintArray(int array[], int arraySize);

int main(int argc, char const *argv[]) {
    int arr[] = {11,5,7,9,11,3,5};
    int size = sizeof(arr)/sizeof(int);
    PrintArray(arr, size);
    printf("%d\n", findpair(arr, 0, size-1));
    PrintArray(arr, size);
    return 0;
}

int findpair(int array[], int start, int end) {
    int i, j;
    int result = 0;
    for (i = start; i <= end; i++) {
        for (j = i+1; j <= end; j++) {
            if (array[i]>=0 && (array[i] == array[j])) {
                result++;
                array[i]=-1;
                array[j]=-1;
            }
        }
    }
    return result;
}

void PrintArray(int array[], int arraySize) {
    int i;
    for (i = 0; i < arraySize; i++) {
        printf("%d ", array[i]);
    }
    printf("\n");
}
