#include <stdio.h>

int binarySearch(int arr[], int start, int end, int item);

int main(int argc, char const *argv[]) {
    int arr[9] = {3, 5, 8, 10, 13, 16, 18, 20, 50};
    int start = 0;
    int end = 8;
    int item = 50;
    printf("%d\n", binarySearch(arr, start, end, item));
    return 0;
}

int binarySearch(int arr[], int start, int end, int item) {
    if (end >= start) {
        int mid = (start+end)/2;
        if (arr[mid] == item) return mid;
        if (arr[mid] > item) return binarySearch(arr, start, mid-1, item);
        return binarySearch(arr, mid+1, end, item);
    }
    return -1;
}
