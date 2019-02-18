//
//  Shaders.metal
//  MetalPractice01
//
//  Created by HanGyo Jeong on 18/02/2019.
//  Copyright © 2019 HanGyoJeong. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

//All vertex shaders must begin with the keyword 'vertex', Function must return(at least) the final position of the vertex
vertex float4 basic_vertex(
                           const device packed_float3* vertex_array [[buffer(0)]], //First Parameter: position of each vertex. "[[...]]" syntax to declare attributes which you can use to specify additional information such as resource locations, shader inputs and built-in variables
                           unsigned int vid [[vertex_id]]) {    //vertex_id attribute : Metal will fill it in with the index of this particular vertex inside the vertex array
    return float4(vertex_array[vid], 1.0);
}

//All fragment shaders must begin with the keyword "fragment", Function must return(at least) the final color of the fragment
//half4 : four-component color value RGBA
fragment half4 basic_fragment(){
    return half4(1.0);  //Return (1,1,1,1) for the color, which is white
}
