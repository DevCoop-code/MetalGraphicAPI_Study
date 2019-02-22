//
//  Vertex.swift
//  MetalPractice03
//
//  Created by DINO2 on 22/02/2019.
//  Copyright © 2019 DINO2. All rights reserved.
//

import Foundation

struct Vertex {
    var x,y,z: Float    //position data
    var r,g,b,a: Float   //color data
    
    func floatBuffer() -> [Float]{
        return [x,y,z,r,g,b,a]
    }
}
