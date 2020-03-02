//
//  AAPLShaderTypes.h
//  TextureSample
//
//  Created by HanGyo Jeong on 2020/02/25.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#ifndef AAPLShaderTypes_h
#define AAPLShaderTypes_h

#include <simd/simd.h>

typedef enum AAPLVertexInputIndex
{
    AAPLVertexInputIndexVertices        = 0,
    AAPLVertexInputIndexViewportSize    = 1,
}AAPLVertexInputIndex;

// Texture index values shared between shader and C code to ensure Metal shader buffer inputs match Metal API texture set calls
typedef enum AAPLTextureIndex
{
    AAPLTextureIndexBaseColor = 0,
}AAPLTextureIndex;

typedef struct
{
    vector_float2 position;
    
    // 2D texture coordinate
    vector_float2 textureCoordinate;
}AAPLVertex;

#endif /* AAPLShaderTypes_h */
