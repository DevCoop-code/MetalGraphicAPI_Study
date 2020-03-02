//
//  AAPLShaders.metal
//  TextureSample
//
//  Created by HanGyo Jeong on 2020/03/02.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

#import "AAPLShaderTypes.h"

typedef struct
{
    float4 position [[position]];
    
    float2 textureCoordinate;
}RasterizerData;

// Vertex function
vertex RasterizerData vertexShader(uint vertexID [[ vertex_id ]],
                                   constant AAPLVertex *vertexArray [[ buffer(AAPLVertexInputIndexVertices) ]],
                                   constant vector_uint2 *viewportSizePointer [[ buffer(AAPLVertexInputIndexViewportSize) ]])
{
    RasterizerData out;
    
    float2 pixelSpacePosition = vertexArray[vertexID].position.xy;
    
    float2 viewportSize = float2(*viewportSizePointer);
    
    out.position = vector_float4(0.0, 0.0, 0.0, 1.0);
    out.position.xy = pixelSpacePosition / (viewportSize / 2.0);
    
    out.textureCoordinate = vertexArray[vertexID].textureCoordinate;
    
    return out;
}

// Fragment function
fragment float4 samplingShader(RasterizerData in [[stage_in]],
                               texture2d<half> colorTexture [[ texture(AAPLTextureIndexBaseColor )]])
{
    constexpr sampler textureSampler (mag_filter::linear, min_filter::linear);
    
    //Sample the texture to obtain a color
    const half4 colorSample = colorTexture.sample(textureSampler, in.textureCoordinate);
    
    //Return the color of the texture
    return float4(colorSample);
}
