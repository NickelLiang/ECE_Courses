#ifndef MXNET_OPERATOR_NEW_FORWARD_CUH_
#define MXNET_OPERATOR_NEW_FORWARD_CUH_

#include <mxnet/base.h>

#define TILE_WIDTH 32

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
    const int H_grid = ceil(H_out / (float)(TILE_WIDTH));
    const int W_grid = ceil(W_out / (float)(TILE_WIDTH));
    const int Y = H_grid * W_grid;
    // Set the kernel dimensions
    dim3 grid_dim(B, M, Y);
    dim3 block_dim(TILE_WIDTH, TILE_WIDTH, 1);

    // 0: Original GPU implementation with no optimization: TILE = 32; 33.42ms
    // forward_kernel_no_op<<<grid_dim, block_dim>>>(y.dptr_, x.dptr_, w.dptr_, B, M, C, H, W, K);

    // 1: Shared memory convolution: TILE = 32;
    int share_mem_tile_width = TILE_WIDTH + K - 1;
    int share_mem_size = (share_mem_tile_width * share_mem_tile_width) * sizeof(float); // Why we really need this...
    forward_kernel_share_mem_conv<<<grid_dim, block_dim, share_mem_size>>>(y.dptr_, x.dptr_, w.dptr_, B, M, C, H, W, K);

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
