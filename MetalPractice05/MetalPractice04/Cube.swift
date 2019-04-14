/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import Foundation
import Metal

class Cube: Node {
    
    init(device: MTLDevice, commandQ: MTLCommandQueue){
        
        // Front
        let A = Vertex(x: -1.0, y:   1.0, z:   1.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0, s: 0.25, t: 0.25)
        let B = Vertex(x: -1.0, y:  -1.0, z:   1.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0, s: 0.25, t: 0.50)
        let C = Vertex(x:  1.0, y:  -1.0, z:   1.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0, s: 0.50, t: 0.50)
        let D = Vertex(x:  1.0, y:   1.0, z:   1.0, r:  0.1, g:  0.6, b:  0.4, a:  1.0, s: 0.50, t: 0.25)
        
        //Left
        let E = Vertex(x: -1.0, y:   1.0, z:  -1.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0, s: 0.00, t: 0.25)
        let F = Vertex(x: -1.0, y:  -1.0, z:  -1.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0, s: 0.00, t: 0.50)
        let G = Vertex(x: -1.0, y:  -1.0, z:   1.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0, s: 0.25, t: 0.50)
        let H = Vertex(x: -1.0, y:   1.0, z:   1.0, r:  0.1, g:  0.6, b:  0.4, a:  1.0, s: 0.25, t: 0.25)
        
        //Right
        let I = Vertex(x:  1.0, y:   1.0, z:   1.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0, s: 0.50, t: 0.25)
        let J = Vertex(x:  1.0, y:  -1.0, z:   1.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0, s: 0.50, t: 0.50)
        let K = Vertex(x:  1.0, y:  -1.0, z:  -1.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0, s: 0.75, t: 0.50)
        let L = Vertex(x:  1.0, y:   1.0, z:  -1.0, r:  0.1, g:  0.6, b:  0.4, a:  1.0, s: 0.75, t: 0.25)
        
        //Top
        let M = Vertex(x: -1.0, y:   1.0, z:  -1.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0, s: 0.25, t: 0.00)
        let N = Vertex(x: -1.0, y:   1.0, z:   1.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0, s: 0.25, t: 0.25)
        let O = Vertex(x:  1.0, y:   1.0, z:   1.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0, s: 0.50, t: 0.25)
        let P = Vertex(x:  1.0, y:   1.0, z:  -1.0, r:  0.1, g:  0.6, b:  0.4, a:  1.0, s: 0.50, t: 0.00)
        
        //Bot
        let Q = Vertex(x: -1.0, y:  -1.0, z:   1.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0, s: 0.25, t: 0.50)
        let R = Vertex(x: -1.0, y:  -1.0, z:  -1.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0, s: 0.25, t: 0.75)
        let S = Vertex(x:  1.0, y:  -1.0, z:  -1.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0, s: 0.50, t: 0.75)
        let T = Vertex(x:  1.0, y:  -1.0, z:   1.0, r:  0.1, g:  0.6, b:  0.4, a:  1.0, s: 0.50, t: 0.50)
        
        //Back
        let U = Vertex(x:  1.0, y:   1.0, z:  -1.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0, s: 0.75, t: 0.25)
        let V = Vertex(x:  1.0, y:  -1.0, z:  -1.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0, s: 0.75, t: 0.50)
        let W = Vertex(x: -1.0, y:  -1.0, z:  -1.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0, s: 1.00, t: 0.50)
        let X = Vertex(x: -1.0, y:   1.0, z:  -1.0, r:  0.1, g:  0.6, b:  0.4, a:  1.0, s: 1.00, t: 0.25)
        
        let verticesArray:Array<Vertex> = [
            A,B,C ,A,C,D,   //Front
            E,F,G ,E,G,H,   //Left
            I,J,K ,I,K,L,   //Right
            M,N,O ,M,O,P,   //Top
            Q,R,S ,Q,S,T,   //Bot
            U,V,W ,U,W,X    //Back
        ]
        
        let texture = MetalTexture(resourceName: "cube", ext: "png", mipmaped: true)
        texture.loadTexture(device: device, commandQ: commandQ, flip: true)
        
        super.init(name: "Cube", vertices: verticesArray, device: device, texture: texture.texture)
    }
    
    override func updateWithDelta(delta: CFTimeInterval) {
        
        super.updateWithDelta(delta: delta)
        
        let secsPerMove: Float = 6.0
        rotationY = sinf( Float(time) * 2.0 * Float(M_PI) / secsPerMove)
        rotationX = sinf( Float(time) * 2.0 * Float(M_PI) / secsPerMove)
    }
}
