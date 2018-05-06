#include "sliding.h"
/*  Slide all values of array up
*/
void slide_up(int* my_array, int rows, int cols){
    int i, j, k;

    for (i = 0; i < cols; i++) { //For each of the N columns in the MxN matrix:
        for (j = 0; j < rows; j++) { //For each of the M elements within this column
            if (my_array[j*cols+i] > 0) { //If the current row value is not empty
                for (k = 0; k < j; k++) { //Find the first available target row
                    if (my_array[k*cols+i] <= 0) {
                        my_array[k*cols+i] = my_array[j*cols+i]; //Copy current row value into target row
                        my_array[j*cols+i] = -1; //Clear current row contents
                    }
                }

            }
        }
    }
}
