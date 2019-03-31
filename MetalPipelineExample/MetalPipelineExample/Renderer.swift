//
//  Renderer.swift
//  MetalPipelineExample
//
//  Created by HanGyo Jeong on 24/03/2019.
//  Copyright © 2019 HanGyoJeong. All rights reserved.
//

import Foundation
import MetalKit

class Renderer: NSObject {
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    var mesh: MTKMesh!
    var vertexBuffer: MTLBuffer!
    var pipelineState: MTLRenderPipelineState!
    
    var timer: Float = 0
    
    init(metalView: MTKView){
        guard let device = MTLCreateSystemDefaultDevice() else{
            fatalError("GPU not available")
        }
        metalView.device = device;
        Renderer.commandQueue = device.makeCommandQueue()
        
        let mdlMesh = Primitive.makeCube(device: device, size: 1)
        do{
            mesh = try MTKMesh(mesh: mdlMesh, device: device)
        }catch let error{
            print(error.localizedDescription)
        }
        
        //the vertex data that you’ll send to the GPU
        vertexBuffer = mesh.vertexBuffers[0].buffer
        super.init()
        
        //Make MTLLibrary
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction = library?.makeFunction(name: "fragment_main")
        
        //Create PipelineState
        /*
         This is how the GPU will know how to interpret the vertex data that you’ll present in the mesh data
        */
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
        pipelineStateDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mdlMesh.vertexDescriptor)
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat    //An array of attachments that store color data
        do{
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        }catch let error{
            fatalError(error.localizedDescription)
        }
        
        
        metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 0.8, alpha: 1.0)
        metalView.delegate = self;
    }
}

extension Renderer: MTKViewDelegate{
    
    //Gets called every time the size of the window changes
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    //Gets called every frame
    func draw(in view: MTKView) {
        guard let descriptor = view.currentRenderPassDescriptor,
            let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else{
                return
        }
        
        timer += 0.05
        var currentTime = sin(timer)
        
        renderEncoder.setVertexBytes(&currentTime,
                                     length: MemoryLayout<Float>.stride,
                                     index: 1)
        
        // drawing code goes here
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        //Primitive Assembly
        for submesh in mesh.submeshes {
            renderEncoder.drawIndexedPrimitives(type: .triangle,
                                                indexCount: submesh.indexCount,
                                                indexType: submesh.indexType,
                                                indexBuffer: submesh.indexBuffer.buffer,
                                                indexBufferOffset: submesh.indexBuffer.offset)
        }
        
        renderEncoder.endEncoding()
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
