#ifndef MXNET_OPERATOR_NEW_FORWARD_CUH_
#define MXNET_OPERATOR_NEW_FORWARD_CUH_

#include <mxnet/base.h>

#define TILE_WIDTH              25
#define SHARE_MEM_SIZE          ((TILE_WIDTH + _K - 1) * (TILE_WIDTH + _K - 1))
#define MAX_THREADS             1024

#define _K                      5

#define TILE_WIDTH_1            22
#define _M1                     6
#define _C1                     1
#define _H1                     48
#define _H1_OUT                 (_H1 - _K + 1)  // 44
#define _W1                     48
#define _W1_OUT                 (_W1 - _K + 1)  // 44
#define _W1_GRID                ceil(_W1_OUT / (float)(TILE_WIDTH_1))   // 4
#define CONST_KERNEL_SIZE_1     (_M1 * _C1 * _K * _K) // 150
#define SHARE_MEM_WIDTH_1       (TILE_WIDTH_1 + _K - 1)  // 15
#define SHARE_MEM_SIZE_1        (_C1 * SHARE_MEM_WIDTH_1 * SHARE_MEM_WIDTH_1)   // 225

#define TILE_WIDTH_2            9
#define _M2                     16
#define _C2                     6
#define _H2                     22
#define _H2_OUT                 (_H2 - _K + 1)  // 18
#define _W2                     22
#define _W2_OUT                 (_W2 - _K + 1)  // 18
#define _W2_GRID                ceil(_W2_OUT / (float)(TILE_WIDTH_2))   // 1
#define CONST_KERNEL_SIZE_2     (_M2 * _C2 * _K * _K) // 2400
#define SHARE_MEM_WIDTH_2       (TILE_WIDTH_2 + _K - 1) // 22
#define SHARE_MEM_SIZE_2        (_C2 * SHARE_MEM_WIDTH_2 * SHARE_MEM_WIDTH_2)   // 484

__constant__ float KERNEL_1[CONST_KERNEL_SIZE_1];
__constant__ float KERNEL_2[CONST_KERNEL_SIZE_2]; // Second kernel is 2400 in size

namespace mxnet
{
namespace op
{

// 0: Original GPU implementation with no optimization: TILE = 32; 33.42ms
__global__ void forward_kernel_no_op(float *y, const float *x, const float *k,
    const int B, const int M, const int C, const int H, const int W, const int K) {
    const int H_out = H - K + 1;
    const int W_out = W - K + 1;
    const int W_grid = ceil(W_out / (float)(TILE_WIDTH));

    int b = blockIdx.x;
    int m = blockIdx.y;
    int h = (blockIdx.z / W_grid) * TILE_WIDTH + threadIdx.y;
    int w = (blockIdx.z % W_grid) * TILE_WIDTH + threadIdx.x;

    float acc = 0.;

    #define y4d(i3, i2, i1, i0) y[(i3) * (M * H_out * W_out) + (i2) * (H_out * W_out) + (i1) * (W_out) + i0]
    #define x4d(i3, i2, i1, i0) x[(i3) * (C * H * W) + (i2) * (H * W) + (i1) * (W) + i0]
    #define k4d(i3, i2, i1, i0) k[(i3) * (C * K * K) + (i2) * (K * K) + (i1) * (K) + i0]

    if (h < H_out && w < W_out) {
        for (int c = 0; c < C; c++) {
            for (int p = 0; p < K; p++) {
                for (int q = 0; q < K; q++) {
                    acc += x4d(b, c, h + p, w + q) * k4d(m, c, p, q);
                }
            }
        }
        y4d(b, m, h, w) = acc;
    }

    #undef y4d
    #undef x4d
    #undef k4d
}

// 1: Shared memory convolution: TILE = 32; 54.4ms
__global__ void forward_kernel_share_mem_conv(float *y, const float *x, const float *k,
    const int B, const int M, const int C, const int H, const int W, const int K) {
    const int H_out = H - K + 1;
    const int W_out = W - K + 1;
    const int W_grid = ceil(W_out / (float)(TILE_WIDTH));

    extern __shared__ float X_share_mem[];

    int share_mem_tile_width = TILE_WIDTH + K - 1;
    int b = blockIdx.x;
    int m = blockIdx.y;
    int h_base = (blockIdx.z / W_grid) * TILE_WIDTH;
    int h_index = threadIdx.y;
    int h = h_base + h_index;
    int w_base = (blockIdx.z % W_grid) * TILE_WIDTH;
    int w_index = threadIdx.x;
    int w = w_base + w_index;
    float acc = 0.0;

    #define y4d(i3, i2, i1, i0) y[(i3) * (M * H_out * W_out) + (i2) * (H_out * W_out) + (i1) * (W_out) + i0]
    #define x4d(i3, i2, i1, i0) x[(i3) * (C * H * W) + (i2) * (H * W) + (i1) * (W) + i0]
    #define k4d(i3, i2, i1, i0) k[(i3) * (C * K * K) + (i2) * (K * K) + (i1) * (K) + i0]

    for (int c = 0; c < C; c++) { // Go over channels
        // A: Load X_share_mem with input value
        for (int i = h; i < h_base + share_mem_tile_width; i += TILE_WIDTH) {
            for (int j = w; j < w_base + share_mem_tile_width; j += TILE_WIDTH) {
                if (i < H && j < W)
                    X_share_mem[(i - h_base) * share_mem_tile_width + (j - w_base)] = x4d(b, c, i, j);
                // else // add a lot of time
                //     X_share_mem[(i - h_base) * share_mem_tile_width + (j - w_base)] = 0.0;
            }
        }
        __syncthreads();
        // B: Do the convolution
        for (int p = 0; p < K; p++) {
            for (int q = 0; q < K; q++) {
                // if ((h_index + p < share_mem_tile_width) && (w_index + q < share_mem_tile_width)) // Add a lot of time
                acc += X_share_mem[(h_index + p) * share_mem_tile_width + (w_index + q)] * k4d(m, c, p, q);
            }
        }
        __syncthreads();
    }
    if (h < H_out && w < W_out) {
        y4d(b, m, h, w) = acc;
    }

    #undef y4d
    #undef x4d
    #undef k4d
}

// 2: Shared memory with kernel in constant memory: TILE = 32; 49.152ms
__global__ void forward_kernel_share_mem_const_kernel(float *y, const float *x, const float *k,
    const int B, const int M, const int C, const int H, const int W, const int K) {
    const int H_out = H - K + 1;
    const int W_out = W - K + 1;
    const int W_grid = ceil(W_out / (float)(TILE_WIDTH));

    extern __shared__ float X_share_mem_1[];

    int share_mem_tile_width = TILE_WIDTH + K - 1;
    int b = blockIdx.x;
    int m = blockIdx.y;
    int h_base = (blockIdx.z / W_grid) * TILE_WIDTH;
    int h_index = threadIdx.y;
    int h = h_base + h_index;
    int w_base = (blockIdx.z % W_grid) * TILE_WIDTH;
    int w_index = threadIdx.x;
    int w = w_base + w_index;
    float acc = 0.0;

    #define y4d(i3, i2, i1, i0) y[(i3) * (M * H_out * W_out) + (i2) * (H_out * W_out) + (i1) * (W_out) + i0]
    #define x4d(i3, i2, i1, i0) x[(i3) * (C * H * W) + (i2) * (H * W) + (i1) * (W) + i0]
    #define k4d(i3, i2, i1, i0) KERNEL_2[(i3) * (C * K * K) + (i2) * (K * K) + (i1) * (K) + i0]

    for (int c = 0; c < C; c++) { // Go over channels
        // A: Load X_share_mem_1 with input value
        for (int i = h; i < h_base + share_mem_tile_width; i += TILE_WIDTH) {
            for (int j = w; j < w_base + share_mem_tile_width; j += TILE_WIDTH) {
                if (i < H && j < W)
                    X_share_mem_1[(i - h_base) * share_mem_tile_width + (j - w_base)] = x4d(b, c, i, j);
            }
        }
        __syncthreads();
        // B: Do the convolution
        for (int p = 0; p < K; p++) {
            for (int q = 0; q < K; q++) {
                // if ((h_index + p < share_mem_tile_width) && (w_index + q < share_mem_tile_width)) // Add a lot of time
                acc += X_share_mem_1[(h_index + p) * share_mem_tile_width + (w_index + q)] * k4d(m, c, p, q);
            }
        }
        __syncthreads();
    }
    if (h < H_out && w < W_out) {
        y4d(b, m, h, w) = acc;
    }

    #undef y4d
    #undef x4d
    #undef k4d
}

__global__ void forward_kernel_layer_1(float *y, const float *x, const int B) {
    const int W_grid = ceil(_W1_OUT / (float)(TILE_WIDTH_1));
    extern __shared__ float X_share_mem_2[SHARE_MEM_SIZE_1];

    int b = blockIdx.x;
    int m = blockIdx.y;
    int h_base = (blockIdx.z / W_grid) * TILE_WIDTH_1;
    int h_index = threadIdx.y;
    int h = h_base + h_index;
    int w_base = (blockIdx.z % W_grid) * TILE_WIDTH_1;
    int w_index = threadIdx.x;
    int w = w_base + w_index;

    #define y4d(i3, i2, i1, i0) y[(i3) * (_M1 * _H1_OUT * _W1_OUT) + (i2) * (_H1_OUT * _W1_OUT) + (i1) * (_W1_OUT) + i0]
    #define x4d(i3, i2, i1, i0) x[(i3) * (_C1 * _H1 * _W1) + (i2) * (_H1 * _W1) + (i1) * (_W1) + i0]
    #define k4d(i3, i2, i1, i0) KERNEL_1[(i3) * (_C1 * _K * _K) + (i2) * (_K * _K) + (i1) * (_K) + i0]

    // Load X_share_mem_2
    // #pragma unroll
    for (int i = h_index; i < SHARE_MEM_WIDTH_1; i += TILE_WIDTH_1) {
        // #pragma unroll
        for (int j = w_index; j < SHARE_MEM_WIDTH_1; j += TILE_WIDTH_1) {
            if ((i + h_base < _H1) && (j + w_base < _W1))
                X_share_mem_2[i * SHARE_MEM_WIDTH_1 + j] = x4d(b, 0, i + h_base, j + w_base);
        }
    }
    __syncthreads();

    // Do conv
    float acc = 0.0;
    if ((h < _H1_OUT) && (w < _W1_OUT)) {
        // #pragma unroll
        for (int p = 0; p < _K; p++) {
            // #pragma unroll
            for (int q = 0; q < _K; q++) {
                acc += X_share_mem_2[(h_index + p) * SHARE_MEM_WIDTH_1 + (w_index + q)] * k4d(m, 0, p, q);
            }
        }
        y4d(b, m, h, w) = acc;
    }
    #undef y4d
    #undef x4d
    #undef k4d
}

__global__ void forward_kernel_layer_2(float *y, const float *x, const int B) {
    const int W_grid = ceil(_W2_OUT / (float)(TILE_WIDTH_2));
    extern __shared__ float X_share_mem_3[SHARE_MEM_SIZE_2];

    int b = blockIdx.x;
    int m = blockIdx.y;
    int h_base = (blockIdx.z / W_grid) * TILE_WIDTH_2;
    int h_index = threadIdx.y;
    int h = h_base + h_index;
    int w_base = (blockIdx.z % W_grid) * TILE_WIDTH_2;
    int w_index = threadIdx.x;
    int w = w_base + w_index;

    #define y4d(i3, i2, i1, i0) y[(i3) * (_M2 * _H2_OUT * _W2_OUT) + (i2) * (_H2_OUT * _W2_OUT) + (i1) * (_W2_OUT) + i0]
    #define x4d(i3, i2, i1, i0) x[(i3) * (_C2 * _H2 * _W2) + (i2) * (_H2 * _W2) + (i1) * (_W2) + i0]
    #define k4d(i3, i2, i1, i0) KERNEL_2[(i3) * (_C2 * _K * _K) + (i2) * (_K * _K) + (i1) * (_K) + i0]

    // Load X_share_mem_3
    // #pragma unroll
    for (int c = 0; c < _C2; c++) {
        // #pragma unroll
        for (int i = h_index; i < SHARE_MEM_WIDTH_2; i += TILE_WIDTH_2) {
            // #pragma unroll
            for (int j = w_index; j < SHARE_MEM_WIDTH_2; j += TILE_WIDTH_2) {
                if ((i + h_base < _H2) && (j + w_base < _W2))
                    X_share_mem_3[c * SHARE_MEM_WIDTH_2 * SHARE_MEM_WIDTH_2 + i * SHARE_MEM_WIDTH_2 + j] = x4d(b, c, i + h_base, j + w_base);
            }
        }
    }
    __syncthreads();

    // Do conv
    float acc = 0.0;
    if ((h < _H2_OUT) && (w < _W2_OUT)) {
        // #pragma unroll
        for (int c = 0; c < _C2; c++) {
            // #pragma unroll
            for (int p = 0; p < _K; p++) {
                // #pragma unroll
                for (int q = 0; q < _K; q++) {
                    acc += X_share_mem_3[c * SHARE_MEM_WIDTH_2 * SHARE_MEM_WIDTH_2 + (h_index + p) * SHARE_MEM_WIDTH_2 + (w_index + q)] * k4d(m, c, p, q);
                }
            }
        }
        y4d(b, m, h, w) = acc;
    }
    #undef y4d
    #undef x4d
    #undef k4d
}

__global__ void gemm_unroll(int b, const int C, const int H, const int W, const int K, float *x, float *x_unroll) {
    int thread = blockIdx.x * blockDim.x + threadIdx.x;
    int H_out = H - K + 1;
    int W_out = W - K + 1;
    int W_unroll_size = H_out * W_out;

    if (thread < C * K * K * W_unroll_size) {
        int row = thread / W_unroll_size;
        int col = thread % W_unroll_size;
        int kernel_row = row / K;
        x_unroll[thread] = x[b * C * H * W + (kernel_row / K) * H * W + (col / W_out + (kernel_row % K)) * W + (col % W_out + row % K)];
    }
}

/*
    // __global__ void gemm_unroll_layer_1(int b, float *x, float *x_unroll) {
    //     int thread = blockIdx.x * blockDim.x + threadIdx.x;
    //
    //     if (thread < _K * _K * _H1_OUT * _W1_OUT) {
    //         int row = thread / (_H1_OUT * _W1_OUT);
    //         int col = thread % (_H1_OUT * _W1_OUT);
    //         int kernel_row = row / _K;
    //         x_unroll[thread] = x[b * _C1 * _H1 * _W1 + (kernel_row / _K) * _H1 * _W1 + (col / _W1_OUT + (kernel_row % _K)) * _W1 + (col % _W1_OUT + row % _K)];
    //     }
    // }
    //
    // __global__ void gemm_unroll_layer_2(int b, float *x, float *x_unroll) {
    //     int thread = blockIdx.x * blockDim.x + threadIdx.x;
    //
    //     if (thread < _K * _K * _H2_OUT * _W2_OUT) {
    //         int row = thread / (_H2_OUT * _W2_OUT);
    //         int col = thread % (_H2_OUT * _W2_OUT);
    //         int kernel_row = row / _K;
    //         x_unroll[thread] = x[b * _C2 * _H2 * _W2 + (kernel_row / _K) * _H2 * _W2 + (col / _W2_OUT + (kernel_row % _K)) * _W2 + (col % _W2_OUT + row % _K)];
    //     }
    // }
*/

// This code is from MP3 with minor modification
// matrixMultiplyShared<<<gridDim, blockDim>>>(w.dptr_, x_unroll, y.dptr_, K, H_unroll, H_unroll, W_unroll, M, W_unroll, b);
__global__ void matrixMultiplyShared(float * __restrict__ A, float * __restrict__ B, float * __restrict__ C, int numARows, int numAColumns, int numBRows, int numBColumns, int numCRows, int numCColumns, int b) {
    if (numAColumns != numBRows) return;

    __shared__ float subTileA[TILE_WIDTH][TILE_WIDTH];
    __shared__ float subTileB[TILE_WIDTH][TILE_WIDTH];

    float value = 0;
    int row = blockIdx.y * TILE_WIDTH + threadIdx.y;
    int col = blockIdx.x * TILE_WIDTH + threadIdx.x;

    int offset = b * numCRows * numCColumns;

    #pragma unroll
    for (int m = 0; m < ceil(numAColumns / (float)(TILE_WIDTH)); m++) {
        int row_m = m * TILE_WIDTH + threadIdx.y;
        int col_m = m * TILE_WIDTH + threadIdx.x;

        if (col_m < numAColumns)
            subTileA[threadIdx.y][threadIdx.x] = A[row * numAColumns + col_m];
        else
            subTileA[threadIdx.y][threadIdx.x] = 0.0;

        if (row_m < numBRows)
            subTileB[threadIdx.y][threadIdx.x] = B[row_m * numBColumns + col];
        else
            subTileB[threadIdx.y][threadIdx.x] = 0.0;

        __syncthreads();
        #pragma unroll
        for (int k = 0; k < TILE_WIDTH; k++)
            value += subTileA[threadIdx.y][k] * subTileB[k][threadIdx.x];
        __syncthreads();
    }

    if ((row < numCRows) && (col < numCColumns))
        C[offset + row * numCColumns + col] = value;
}
/*
// __global__ void matrixMultiplyShared_layer_1(float *A, float *B, float *C, int numARows, int numAColumns, int numBRows, int numBColumns, int numCRows, int numCColumns, int b) {
//     if (numAColumns != numBRows) return;
//
//     __shared__ float subTileA[TILE_WIDTH_1][TILE_WIDTH_1];
//     __shared__ float subTileB[TILE_WIDTH_1][TILE_WIDTH_1];
//
//     float value = 0;
//     int row = blockIdx.y * TILE_WIDTH_1 + threadIdx.y;
//     int col = blockIdx.x * TILE_WIDTH_1 + threadIdx.x;
//
//     int offset = b * numCRows * numCColumns;
//
//     for (int m = 0; m < ceil(numAColumns / (float)(TILE_WIDTH_1)); m++) {
//         int row_m = m * TILE_WIDTH_1 + threadIdx.y;
//         int col_m = m * TILE_WIDTH_1 + threadIdx.x;
//
//         if (col_m < numAColumns)
//             subTileA[threadIdx.y][threadIdx.x] = A[row * numAColumns + col_m];
//         else
//             subTileA[threadIdx.y][threadIdx.x] = 0.0;
//
//         if (row_m < numBRows)
//             subTileB[threadIdx.y][threadIdx.x] = B[row_m * numBColumns + col];
//         else
//             subTileB[threadIdx.y][threadIdx.x] = 0.0;
//
//         __syncthreads();
//         for (int k = 0; k < TILE_WIDTH_1; k++)
//             value += subTileA[threadIdx.y][k] * subTileB[k][threadIdx.x];
//         __syncthreads();
//     }
//
//     if ((row < numCRows) && (col < numCColumns))
//         C[offset + row * numCColumns + col] = value;
// }
//
// __global__ void matrixMultiplyShared_layer_2(float *A, float *B, float *C, int numARows, int numAColumns, int numBRows, int numBColumns, int numCRows, int numCColumns, int b) {
//     if (numAColumns != numBRows) return;
//
//     __shared__ float subTileA[TILE_WIDTH_2][TILE_WIDTH_2];
//     __shared__ float subTileB[TILE_WIDTH_2][TILE_WIDTH_2];
//
//     float value = 0;
//     int row = blockIdx.y * TILE_WIDTH_2 + threadIdx.y;
//     int col = blockIdx.x * TILE_WIDTH_2 + threadIdx.x;
//
//     int offset = b * numCRows * numCColumns;
//
//     for (int m = 0; m < ceil(numAColumns / (float)(TILE_WIDTH_2)); m++) {
//         int row_m = m * TILE_WIDTH_2 + threadIdx.y;
//         int col_m = m * TILE_WIDTH_2 + threadIdx.x;
//
//         if (col_m < numAColumns)
//             subTileA[threadIdx.y][threadIdx.x] = A[row * numAColumns + col_m];
//         else
//             subTileA[threadIdx.y][threadIdx.x] = 0.0;
//
//         if (row_m < numBRows)
//             subTileB[threadIdx.y][threadIdx.x] = B[row_m * numBColumns + col];
//         else
//             subTileB[threadIdx.y][threadIdx.x] = 0.0;
//
//         __syncthreads();
//         for (int k = 0; k < TILE_WIDTH_2; k++)
//             value += subTileA[threadIdx.y][k] * subTileB[k][threadIdx.x];
//         __syncthreads();
//     }
//
//     if ((row < numCRows) && (col < numCColumns))
//         C[offset + row * numCColumns + col] = value;
// }
*/

__global__ void forward_kernel_fusion(const int C, const int H, const int W, const int M, float *k, float *x, float *y, int row_a, int col_a, int row_b, int col_b, int row_c, int col_c) {
    __shared__ float tile_m[TILE_WIDTH][TILE_WIDTH]; // M for x shared
    __shared__ float tile_n[TILE_WIDTH][TILE_WIDTH]; // N for k shared

    int H_out = H - _K + 1;
    int W_out = W - _K + 1;
    int K_unroll = _K * _K;
    int row = blockIdx.y * TILE_WIDTH + threadIdx.y;
    int col = blockIdx.z * TILE_WIDTH + threadIdx.x;

    float acc = 0.0;

    for (int i = 0; i < ceil(col_a / (float)(TILE_WIDTH)); ++i) {
        int base = i * TILE_WIDTH;
        int chan = (base + threadIdx.y) / K_unroll;
        if ((col < col_b) && (base + threadIdx.y < row_b))
            tile_m[threadIdx.y][threadIdx.x] = x[blockIdx.x * (C * H * W) + chan * H * W + (col / W_out) * W + (col % W_out)];
        else
            tile_m[threadIdx.y][threadIdx.x] = 0;

        if ((row < row_a) && (base + threadIdx.x < col_a))
            tile_n[threadIdx.y][threadIdx.x] = k[row * C * K_unroll + chan * K_unroll + ((base + threadIdx.y) % K_unroll)];
        else
            tile_n[threadIdx.y][threadIdx.x] = 0;
        __syncthreads();

        for (int j = 0; j < TILE_WIDTH; ++j)
            acc += tile_m[j][threadIdx.x] * tile_n[threadIdx.y][j];
        __syncthreads();
    }
    if (row < row_c && col < col_c)
        y[blockIdx.x * (M * H_out * W_out) + row * col_c + col] = acc;
}

/*
   This function is called by new-inl.h
   Any code you write should be executed by this function.
   For ECE408, we only expect the float version of the operator to be called, so here we specialize with only floats.
*/
template <>
void forward<gpu, float>(mshadow::Tensor<gpu, 4, float> &y, const mshadow::Tensor<gpu, 4, float> &x, const mshadow::Tensor<gpu, 4, float> &w) {
    // Extract the tensor dimensions into B,M,C,H,W,K
    const int B = x.shape_[0];  // Mini Batch
    const int M = y.shape_[1];  // Output Feature Map
    const int C = x.shape_[1];  // Channel
    const int H = x.shape_[2];  // Height
    const int W = x.shape_[3];  // Width
    const int K = w.shape_[3];  // Kernel
    const int H_out = H - K + 1;
    const int W_out = W - K + 1;
    const int Y = ceil(H_out / (float)(TILE_WIDTH)) * ceil(W_out / (float)(TILE_WIDTH));

    // std::cout << "B: " << B << " M: " << M << " C: " << C << " H: " << H << " W: " << W << " K: " << K << " H_OUT: " << H_out << " W_OUT: " << W_out << std::endl;
    // std::cout << "Kernel: " << M * C * K * K << std::endl;

    // 0: Original GPU implementation with no optimization: TILE = 32; 33.42ms
    // dim3 grid_dim(B, M, Y);
    // dim3 block_dim(TILE_WIDTH, TILE_WIDTH, 1);
    // forward_kernel_no_op<<<grid_dim, block_dim>>>(y.dptr_, x.dptr_, w.dptr_, B, M, C, H, W, K);

    // 1: Shared memory convolution: TILE = 32; 54.4ms
    // dim3 grid_dim(B, M, Y);
    // dim3 block_dim(TILE_WIDTH, TILE_WIDTH, 1);
    // int share_mem_size = ((TILE_WIDTH + K - 1) * (TILE_WIDTH + K - 1)) * sizeof(float); // Why we really need this...
    // forward_kernel_share_mem_conv<<<grid_dim, block_dim, share_mem_size>>>(y.dptr_, x.dptr_, w.dptr_, B, M, C, H, W, K);

    // 2: Shared memory with kernel in constant memory: TILE = 32; 49.152ms; TILE = 16; 42.36ms;
    // cudaMemcpyToSymbol(KERNEL_2, w.dptr_, M * C * K * K * sizeof(float));
    // dim3 grid_dim(B, M, Y);
    // dim3 block_dim(TILE_WIDTH, TILE_WIDTH, 1);
    // int share_mem_size = ((TILE_WIDTH + K - 1) * (TILE_WIDTH + K - 1)) * sizeof(float);
    // forward_kernel_share_mem_const_kernel<<<grid_dim, block_dim, share_mem_size>>>(y.dptr_, x.dptr_, w.dptr_, B, M, C, H, W, K);

    // 3: Multiple kernel implementations for different layer sizes; TILE_1 = 22; TILE_2 = 9; 14.899ms;
    // if (C == _C1) {
    //     cudaMemcpyToSymbol(KERNEL_1, w.dptr_, CONST_KERNEL_SIZE_1 * sizeof(float));
    //     dim3 grid_dim(B, _M1, ceil(_H1_OUT / (float)(TILE_WIDTH_1)) * ceil(_W1_OUT / (float)(TILE_WIDTH_1)));
    //     dim3 block_dim(TILE_WIDTH_1, TILE_WIDTH_1, 1);
    //     int share_mem_size = SHARE_MEM_SIZE_1 * sizeof(float);
    //     forward_kernel_layer_1<<<grid_dim, block_dim, share_mem_size>>>(y.dptr_, x.dptr_, B);
    // } else if (C == _C2) {
    //     cudaMemcpyToSymbol(KERNEL_2, w.dptr_, CONST_KERNEL_SIZE_2 * sizeof(float));
    //     dim3 grid_dim(B, _M2, ceil(_H2_OUT / (float)(TILE_WIDTH_2)) * ceil(_W2_OUT / (float)(TILE_WIDTH_2)));
    //     dim3 block_dim(TILE_WIDTH_2, TILE_WIDTH_2, 1);
    //     int share_mem_size = SHARE_MEM_SIZE_2 * sizeof(float);
    //     forward_kernel_layer_2<<<grid_dim, block_dim, share_mem_size>>>(y.dptr_, x.dptr_, B);
    // }

    // 4. gemm, TILE_WIDTH = 25, 24ms; TILE_WIDTH = 32, 23ms
    int H_unroll = C * K * K;
    int W_unroll = H_out * W_out;

    float* x_unroll;
    cudaMalloc((void **)&x_unroll, W_unroll * H_unroll * sizeof(float));

    dim3 blockDim(TILE_WIDTH, TILE_WIDTH);
    dim3 gridDim(ceil(W_unroll / (float)(TILE_WIDTH)), ceil(M / (float)(TILE_WIDTH)));
    for (int b = 0; b < B; b++) {
        gemm_unroll<<<ceil((W_unroll * H_unroll) / (float)MAX_THREADS), MAX_THREADS>>>(b, C, H, W, K, x.dptr_, x_unroll);
        matrixMultiplyShared<<<gridDim, blockDim>>>(w.dptr_, x_unroll, y.dptr_, K, H_unroll, H_unroll, W_unroll, M, W_unroll, b);
    }
    cudaFree(x_unroll);

    // 5. kernel fusion
    // int H_unroll = C * K * K;
    // int W_unroll = H_out * W_out;
    // dim3 block_dim(TILE_WIDTH, TILE_WIDTH, 1);
    // dim3 grid_dim(B, ceil(W_unroll / (float)(TILE_WIDTH)), ceil(M / (float)(TILE_WIDTH)));
    // forward_kernel_fusion<<<grid_dim, block_dim>>>(C, H, W, M, w.dptr_, x.dptr_, y.dptr_, M, W_unroll, W_unroll, H_unroll, M, H_unroll);

    // 6. unroll and restrict on part 3 multiple kernel

    // 7. parameter sweeping on part 3 multiple kernel

    // 8. gemm multiple kernel
    // if (C == _C1) {
    //     int H_unroll = _C1 * _K * _K;
    //     int W_unroll = _H1_OUT * _W1_OUT;
    //     float* x_unroll;
    //     cudaMalloc((void **)&x_unroll, W_unroll * H_unroll * sizeof(float));
    //
    //     dim3 grid_dim(ceil(W_unroll / (float)(TILE_WIDTH_1)), ceil(_M1 / (float)(TILE_WIDTH_1)));
    //     dim3 block_dim(TILE_WIDTH_1, TILE_WIDTH_1, 1);
    //     for (int b = 0; b < B; b++) {
    //         gemm_unroll_layer_1<<<ceil((W_unroll * H_unroll) / (float)MAX_THREADS), MAX_THREADS>>>(b, x.dptr_, x_unroll);
    //         matrixMultiplyShared_layer_1<<<gridDim, blockDim>>>(w.dptr_, x_unroll, y.dptr_, _K, H_unroll, H_unroll, W_unroll, _M1, W_unroll, b);
    //     }
    //     cudaFree(x_unroll);
    // } else if (C == _C2) {
    //     int H_unroll = _C2 * _K * _K;
    //     int W_unroll = _H2_OUT * _W2_OUT;
    //     float* x_unroll;
    //     cudaMalloc((void **)&x_unroll, W_unroll * H_unroll * sizeof(float));
    //
    //     dim3 grid_dim(ceil(W_unroll / (float)(TILE_WIDTH_2)), ceil(_M2 / (float)(TILE_WIDTH_2)));
    //     dim3 block_dim(TILE_WIDTH_2, TILE_WIDTH_2, 1);
    //     for (int b = 0; b < B; b++) {
    //         gemm_unroll_layer_2<<<ceil((W_unroll * H_unroll) / (float)MAX_THREADS), MAX_THREADS>>>(b, x.dptr_, x_unroll);
    //         matrixMultiplyShared_layer_2<<<gridDim, blockDim>>>(w.dptr_, x_unroll, y.dptr_, _K, H_unroll, H_unroll, W_unroll, _M2, W_unroll, b);
    //     }
    //     cudaFree(x_unroll);
    // }

    // Use MSHADOW_CUDA_CALL to check for CUDA runtime errors.
    MSHADOW_CUDA_CALL(cudaDeviceSynchronize());
}

/*
    This tells mxnet how to do an op when it's not a float.
    This is not used in the ECE408 project
*/
template <typename gpu, typename DType>
void forward(mshadow::Tensor<gpu, 4, DType> &y, const mshadow::Tensor<gpu, 4, DType> &x, const mshadow::Tensor<gpu, 4, DType> &w) {
    CHECK_EQ(0,1) << "Remove this line and replace it with your implementation.";
}
}
}

#endif
