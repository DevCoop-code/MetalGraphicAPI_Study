//
//  Vertex.swift
//  MetalPractice03
//
//  Created by DINO2 on 05/04/2019.
//  Copyright © 2019 DINO2. All rights reserved.
//

struct Vertex {
    var x,y,z: Float    //Position Data
    var r,g,b,a: Float  //Color Data
    
    func floatBuffer() -> [Float]{
        return [x,y,z,r,g,b,a];
    }
}
