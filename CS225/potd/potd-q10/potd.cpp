#include "potd.h"
#include <cmath>

int * potd::raise(int *arr) {
    if (arr[0] == -1) {
        int * newArray = new int(1);
        newArray[0] = -1;
        return newArray;
    }
    int i = 0;
    while (arr[i] != -1) {
        i++;
    }
    int * newArray = new int(i+1);
    i = 0;
    while (arr[i+1] != -1) {
        newArray[i] = pow(arr[i], arr[i+1]);
        i++;
    }
    newArray[i] = arr[i];
    newArray[i+1] = -1;
    return newArray;
}
