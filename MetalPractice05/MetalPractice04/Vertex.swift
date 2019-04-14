//
//  Vertex.swift
//  MetalPractice04
//
//  Created by HanGyo Jeong on 07/04/2019.
//  Copyright © 2019 HanGyoJeong. All rights reserved.
//

struct Vertex {
    var x,y,z: Float        //position data
    var r,g,b,a: Float      //color data
    var s,t: Float          //texture coordinates
    
    func floatBuffer() -> [Float]{
        return [x,y,z,r,g,b,a,s,t]
    }
}
