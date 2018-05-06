/* Function matrix_multiply
 * matrixA, matrixB, and matrix C are matrices represented as
 * one-dimensional arrays in row-major order. This function must
 * preform matrix multiplication so that C=A*B.
 * INPUT: matrixA, a one dimensional array of size m*k
 *        matrixB, a one dimensional double array of size k*n
 * OUTPUT: matrixC, a one dimensional double array of size m*n
 */
void matrix_multiply(double *matrixA, double *matrixB, double *matrixC, int m, int k, int n) {
  int i, j, q;
  for (i = 0; i < m; i++) {
    for (j = 0; j < n; j++) {
      double temp = 0;
      for (q = 0; q < k; q++) {
        temp += matrixA[q+ i * k] * matrixB[j + q * n];
      }
      matrixC[j+i * n] = temp;
    }
  }
}
