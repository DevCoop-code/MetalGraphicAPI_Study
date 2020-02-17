//
//  add.metal
//  PerformingCalcOnGPU
//
//  Created by HanGyo Jeong on 2020/02/18.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

kernel void add_arrays(device const float* inA,
                       device const float* inB,
                       device float* result,
                       uint index [[thread_position_in_grid]])
{
    result[index] = inA[index] + inB[index];
}
