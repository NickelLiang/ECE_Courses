#include <stdio.h>

int ReverseArray(int array[], int arraySize);
void PrintArray(int array[], int arraySize);

int main(int argc, char const *argv[]) {
    int arr[] = {1,2,3,4,5,6,7,8,9,10};
    int size = sizeof(arr)/sizeof(int);
    PrintArray(arr, size);
    ReverseArray(arr, size);
    PrintArray(arr, size);
    return 0;
}

int ReverseArray(int array[], int arraySize) {
    int i;
    for (i = 0; i < arraySize/2; i++) {
        int temp = array[i];
        array[i] = array[arraySize-1-i];
        array[arraySize-1-i] = temp;
    }
    return 0;
}

void PrintArray(int array[], int arraySize) {
    int i;
    for (i = 0; i < arraySize; i++) {
        printf("%d ", array[i]);
    }
    printf("\n");
}
