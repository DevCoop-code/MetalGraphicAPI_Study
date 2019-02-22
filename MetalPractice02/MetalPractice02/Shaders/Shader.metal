//
//  Shader.metal
//  MetalPractice02
//
//  Created by HanGyo Jeong on 22/02/2019.
//  Copyright © 2019 HanGyo Jeong. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn{
    packed_float3 position;
    packed_float4 color;
};

struct VertexOut{
    float4 position [[position]];
    float4 color;
};

vertex VertexOut basic_vertex(
    const device VertexIn* vertex_array [[buffer(0)]],
    unsigned int vid [[vertex_id]]){
    
    VertexIn vertexIn = vertex_array[vid];
    
    VertexOut vertexOut;
    vertexOut.position = float4(vertexIn.position, 1);
    vertexOut.color = vertexIn.color;
    
    return vertexOut;
}

fragment half4 basic_fragment(VertexOut interpolated [[stage_in]]){
    return half4(interpolated.color[0], interpolated.color[1], interpolated.color[2], interpolated.color[3]);
}
