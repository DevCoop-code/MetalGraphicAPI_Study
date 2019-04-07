//
//  Vertex.swift
//  MetalPractice04
//
//  Created by HanGyo Jeong on 07/04/2019.
//  Copyright © 2019 HanGyoJeong. All rights reserved.
//

struct Vertex {
    var x,y,z: Float
    var r,g,b,a: Float
    
    func floatBuffer() -> [Float]{
        return [x,y,z,r,g,b,a]
    }
}
