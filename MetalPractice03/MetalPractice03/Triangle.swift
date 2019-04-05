//
//  Triangle.swift
//  MetalPractice03
//
//  Created by DINO2 on 05/04/2019.
//  Copyright © 2019 DINO2. All rights reserved.
//

import Foundation
import Metal

class Triangle: Node{
    init(device: MTLDevice) {
        let V0 = Vertex(x: 0.0, y: 1.0, z: 0.0, r: 1.0, g: 0.0, b: 0.0, a: 1.0)
        let V1 = Vertex(x:-1.0, y:-1.0, z: 0.0, r: 0.0, g: 1.0, b: 0.0, a: 1.0)
        let V2 = Vertex(x: 1.0, y:-1.0, z: 0.0, r: 0.0, g: 0.0, b: 1.0, a: 1.0)
        
        let verticesArray = [V0,V1,V2]
        super.init(name: "Triangle", vertices: verticesArray, device: device)
    }
}
