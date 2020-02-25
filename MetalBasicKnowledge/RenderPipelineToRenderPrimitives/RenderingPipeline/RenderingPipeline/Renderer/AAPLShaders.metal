//
//  AAPLShaders.metal
//  RenderingPipeline
//
//  Created by HanGyo Jeong on 2020/02/23.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

#import "AAPLShaderTypes.h"

// Vertex shader outputs and fragment shader inputs
typedef struct
{
    float4 position [[position]];
    float4 color;
} RasterizerData;

vertex RasterizerData
vertexShader(uint vertexID [[vertex_id]],
             constant AAPLVertex *vertices [[buffer(AAPLVertexInputIndexVertices)]],
             constant vector_uint2 *viewportSizePointer [[buffer(AAPLVertexInputIndexViewportSize)]])
{
    RasterizerData out;
    
    // Index into the array of positions to get the current vertex
    float2 pixelSpacePosition = vertices[vertexID].position.xy;
    
    // Get the viewport size and cast to float
    vector_float2 viewportSize = vector_float2(*viewportSizePointer);
    
    // To convert from positions in pixel space to positions in clip-space
    // Divide the pixel coordinates by half the size of the viewport
    out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = pixelSpacePosition / (viewportSize / 2.0);
    
    // Pass the input color directory to the rasterizer
    out.color = vertices[vertexID].color;
    
    return out;
}

fragment float4 fragmentShader(RasterizerData in [[stage_in]])
{
    //Return the interpolated color
    return in.color;
}
