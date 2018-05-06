#include <stdio.h>
#include <stdlib.h>
#include <limits.h>

void Min_Heapify(int size, int *arr, int i);
void Build_Min_Heap(int size, int *arr);
int Heap_Extract_Min(int *size, int *arr);
void Min_Heap_Insert(int *size, int *arr, int key);
void Print_Heap(int size, int *arr);

int main(int argc, char *argv[]) {
    // Open the file
    FILE *heapFile;
    if (!(heapFile = fopen(argv[1], "r"))) {
        fprintf(stderr, "Unable to open input file\n");
        return 1;
    }
    int *arr = (int *)malloc(1*sizeof(int));
    arr[0] = INT_MIN;
    int temp, size = 0;
    while(fscanf(heapFile, "%d", &temp) == 1) {
        printf("temp %d\n", temp);
        size++;
        arr = realloc(arr, (size+1)*sizeof(int));
        arr[size] = temp;
        // Min_Heap_Insert(&size, arr, temp);
        Print_Heap(size, arr);
    }
    Build_Min_Heap(size, arr);
    Print_Heap(size, arr);
    // // Build heap from file
    // int first;
    // fscanf(heapFile, "%d", &first);
    // int *arr = (int *)malloc(2*sizeof(int));
    // arr[0] = INT_MAX;
    // arr[1] = first;
    // int size = 1;
    // Print_Heap(size, arr);
    // int temp;
    // while(fscanf(heapFile, "%d", &temp) == 1) {
    //     printf("temp %d\n", temp);
    //     Min_Heap_Insert(&size, arr, temp);
    //     Print_Heap(size, arr);
    // }
    // fclose(heapFile);
    // printf("---\n");
    // Build_Min_Heap(size, arr);
    // Print_Heap(size, arr);
    // printf("---\n");
    // printf("Extract: %d\n", Heap_Extract_Min(&size, arr));
    // Print_Heap(size, arr);
    // printf("Extract: %d\n", Heap_Extract_Min(&size, arr));
    // Print_Heap(size, arr);
    // printf("Extract: %d\n", Heap_Extract_Min(&size, arr));
    // Print_Heap(size, arr);
    return 0;
}

void Min_Heapify(int size, int *arr, int i) {
    int smallest;
    int l = 2i;
    int r = 2i + 1;
    if (l <= size && arr[l] < arr[i]) {
        smallest = l;
    } else {
        smallest = i;
    }
    if (r <= size && arr[r] < arr[smallest]) {
        smallest = r;
    }
    if (smallest != i) {
        int tmp = arr[i];
        arr[i] = arr[smallest];
        arr[smallest] = tmp;
        Print_Heap(size, arr);
        Min_Heapify(size, arr, smallest);
    }
}

void Build_Min_Heap(int size, int *arr) {
    for (int i = size / 2; i > 0; i--) {
        Min_Heapify(size, arr, i);
    }
}

int Heap_Extract_Min(int *size, int *arr) {
    int min = arr[1];
    arr[1] = arr[*size]; // NOTE
    (*size)--;
    Min_Heapify(*size, arr, 1);
    return min;
}

void Min_Heap_Insert(int *size, int *arr, int key) {
    (*size)++;
    arr = realloc(arr, (*size+1)*sizeof(int));
    arr[*size] = key;
    int i = *size;
    while (i > 1 && arr[i/2] > arr[i]) {
        int tmp = arr[i];
        arr[i] = arr[i/2];
        arr[i/2] = tmp;
        i = i / 2;
    }
}

void Print_Heap(int size, int *arr) {
    for (int i = 1; i <= size; i++) {
        printf("%d ", arr[i]);
    }
    printf("\n");
}
