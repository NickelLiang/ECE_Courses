#include <stdio.h>

int largestSubarray(int *A, int start, int end);
void PrintArray(int array[], int arraySize);

int main(int argc, char const *argv[]) {
    int arr[] = {1,1,0,0,1,1,0,0,1,1,1,1};
    int size = sizeof(arr)/sizeof(int);
    PrintArray(arr, size);

    printf("%d\n", largestSubarray(arr, 0, size-1));
    return 0;
}

int largestSubarray(int *A, int start, int end) {
    if (start == end) {
        return 0;
    }
    int i, result;
    int one = 0;
    int zero = 0;
    for (i = start; i <= end; i++) {
        if (A[i] == 1) {
            one ++;
        } else {
            zero ++;
        }
    }
    if (zero >= one) {
        result = one*2;
    } else {
        result = zero*2;
    }
    int next = largestSubarray(A, start+1, end);
    if (result >= next) {
        return result;
    } else {
        return next;
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
