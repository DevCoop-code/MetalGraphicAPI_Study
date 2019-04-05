//
//  Node.swift
//  MetalPractice03
//
//  Created by DINO2 on 05/04/2019.
//  Copyright © 2019 DINO2. All rights reserved.
//

import Foundation
import QuartzCore
import Metal

class Node{
    let device: MTLDevice!
    let name: String!
    let vertexCount: Int!
    var vertexBuffer: MTLBuffer!
    
    var positionX: Float = 0.0
    var positionY: Float = 0.0
    var positionZ: Float = 0.0
    
    var rotationX: Float = 0.0
    var rotationY: Float = 0.0
    var rotationZ: Float = 0.0
    var scale: Float     = 1.0
    
    init(name: String, vertices: Array<Vertex>, device: MTLDevice) {
        var vertexData = Array<Float>()
        for vertex in vertices{
            vertexData += vertex.floatBuffer()
        }
        
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
        
        self.name = name
        self.device = device
        vertexCount = vertices.count
    }
    
    func render(commandQueue: MTLCommandQueue, pipelineState: MTLRenderPipelineState, drawable: CAMetalDrawable, projectionMatrix: Matrix4, clearColor: MTLClearColor?){
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoder!.setRenderPipelineState(pipelineState)
        renderEncoder!.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        // Get Transform Matrix
        let nodeModelMatrix = self.modelMatrix()
        // Ask the device to create a buffer with shared CPU/GPU memory.
        let uniformBuffer = device.makeBuffer(length: MemoryLayout<Float>.size * Matrix4.numberOfElements() * 2, options: [])
        // Get a raw pointer from buffer
        let bufferPoint = uniformBuffer!.contents()
        // Copy your matrix data into the buffer
        memcpy(bufferPoint, nodeModelMatrix.raw(), MemoryLayout<Float>.size * Matrix4.numberOfElements())
        
        memcpy(bufferPoint + MemoryLayout<Float>.size * Matrix4.numberOfElements(),
               projectionMatrix.raw(),
               MemoryLayout<Float>.size * Matrix4.numberOfElements())
        
        // Pass uniformBuffer
        renderEncoder?.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        
        renderEncoder!.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: vertexCount/3)
        renderEncoder!.endEncoding()
        
        commandBuffer!.present(drawable)
        commandBuffer!.commit()
    }
    
    func modelMatrix() -> Matrix4{
        let matrix = Matrix4()
        matrix.translate(positionX, y: positionY, z: positionZ)
        matrix.rotateAroundX(rotationX, y: rotationY, z: rotationZ)
        matrix.scale(scale, y: scale, z: scale)
        return matrix
    }
}
