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

typedef struct
{
    vector_float2 position;
}AAPLVertex;

#endif /* AAPLShaderTypes_h */
