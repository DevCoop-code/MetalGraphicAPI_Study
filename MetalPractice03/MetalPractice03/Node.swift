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
    
    func render(commandQueue: MTLCommandQueue, pipelineState: MTLRenderPipelineState, drawable: CAMetalDrawable, clearColor: MTLClearColor?){
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        let renderEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoder!.setRenderPipelineState(pipelineState)
        renderEncoder!.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder!.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: vertexCount/3)
        renderEncoder!.endEncoding()
        
        commandBuffer!.present(drawable)
        commandBuffer!.commit()
    }
}
