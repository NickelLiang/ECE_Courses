#ifndef MXNET_OPERATOR_NEW_FORWARD_CUH_
#define MXNET_OPERATOR_NEW_FORWARD_CUH_

#include <mxnet/base.h>

#define TILE_WIDTH              16
#define SHARE_MEM_SIZE          ((TILE_WIDTH + _K - 1) * (TILE_WIDTH + _K - 1))

#define _K                      5

#define TILE_WIDTH_1            16
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

#define TILE_WIDTH_2            16
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
    for (int i = h_index; i < SHARE_MEM_WIDTH_1; i += TILE_WIDTH_1) {
        for (int j = w_index; j < SHARE_MEM_WIDTH_1; j += TILE_WIDTH_1) {
            if ((i + h_base < _H1) && (j + w_base < _W1))
                // X_share_mem_2[i * SHARE_MEM_WIDTH_1 + j] = x[b * _C1 * _H1 * _W1 + (i + h_base) * _W1 + (j + w_base)];
                X_share_mem_2[i * SHARE_MEM_WIDTH_1 + j] = x4d(b, 0, i + h_base, j + w_base);
            // else
            //     X_share_mem_2[i * SHARE_MEM_WIDTH_1 + j] = 0.0;
        }
    }
    __syncthreads();

    // Do conv
    float acc = 0.0;
    // if ((h < _H1_OUT) && (w < _W1_OUT) && (b < B) && (m < _M1)) {
    if ((h < _H1_OUT) && (w < _W1_OUT)) {
        for (int p = 0; p < _K; p++) {
            for (int q = 0; q < _K; q++) {
                // acc += X_share_mem_2[(h_index + p) * SHARE_MEM_WIDTH_1 + (w_index + q)] * KERNEL_1[m * _K * _K + p * _K + q];
                acc += X_share_mem_2[(h_index + p) * SHARE_MEM_WIDTH_1 + (w_index + q)] * k4d(m, 0, p, q);
            }
        }
        // y[b * _M1 * _H1_OUT * _W1_OUT + m * _H1_OUT * _W1_OUT + h * _W1_OUT + w] = acc;
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
    for (int c = 0; c < _C2; c++) {
        for (int i = h_index; i < SHARE_MEM_WIDTH_2; i += TILE_WIDTH_2) {
            for (int j = w_index; j < SHARE_MEM_WIDTH_2; j += TILE_WIDTH_2) {
                if ((i + h_base < _H2) && (j + w_base < _W2))
                    // X_share_mem_3[i * SHARE_MEM_WIDTH_2 + j] = x[b * _C2 * _H2 * _W2 + c * _H2 * _W2 + (i + h_base) * _W2 + (j + w_base)];
                    X_share_mem_3[c * SHARE_MEM_WIDTH_2 * SHARE_MEM_WIDTH_2 + i * SHARE_MEM_WIDTH_2 + j] = x4d(b, c, i + h_base, j + w_base);
                // else
                //     X_share_mem_3[i * SHARE_MEM_WIDTH_2 + j] = 0.0;
            }
        }
    }
    __syncthreads();

    // Do conv
    float acc = 0.0;
    // if ((h < _H2_OUT) && (w < _W2_OUT) && (b < B) && (m < _M2)) {
    if ((h < _H2_OUT) && (w < _W2_OUT)) {
        for (int c = 0; c < _C2; c++) {
            for (int p = 0; p < _K; p++) {
                for (int q = 0; q < _K; q++) {
                    // acc += X_share_mem_3[(h_index + p) * SHARE_MEM_WIDTH_2 + (w_index + q)] * KERNEL_2[m * _C2 * _K * _K + c * _K * _K + p * _K + q];
                    acc += X_share_mem_3[c * SHARE_MEM_WIDTH_2 * SHARE_MEM_WIDTH_2 + (h_index + p) * SHARE_MEM_WIDTH_2 + (w_index + q)] * k4d(m, c, p, q);
                }
            }
        }
        // y[b * _M2 * _H2_OUT * _W2_OUT + m * _H2_OUT * _W2_OUT + h * _W2_OUT + w] = acc;
        y4d(b, m, h, w) = acc;
    }
    #undef y4d
    #undef x4d
    #undef k4d
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

    // 3:
    if (C == _C1) {
        cudaMemcpyToSymbol(KERNEL_1, w.dptr_, CONST_KERNEL_SIZE_1 * sizeof(float));
        dim3 grid_dim(B, M, ceil(H_out / (float)(TILE_WIDTH_1)) * ceil(W_out / (float)(TILE_WIDTH_1)));
        dim3 block_dim(TILE_WIDTH_1, TILE_WIDTH_1, 1);
        int share_mem_size = SHARE_MEM_SIZE_1 * sizeof(float);
        forward_kernel_layer_1<<<grid_dim, block_dim, share_mem_size>>>(y.dptr_, x.dptr_, B);
    } else if (C == _C2) {
        cudaMemcpyToSymbol(KERNEL_2, w.dptr_, CONST_KERNEL_SIZE_2 * sizeof(float));
        dim3 grid_dim(B, M, ceil(H_out / (float)(TILE_WIDTH_2)) * ceil(W_out / (float)(TILE_WIDTH_2)));
        dim3 block_dim(TILE_WIDTH_2, TILE_WIDTH_2, 1);
        int share_mem_size = SHARE_MEM_SIZE_2 * sizeof(float);
        forward_kernel_layer_2<<<grid_dim, block_dim, share_mem_size>>>(y.dptr_, x.dptr_, B);
    }


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
