//
//  ViewController.swift
//  MetalPractice01
//
//  Created by HanGyo Jeong on 18/02/2019.
//  Copyright © 2019 HanGyoJeong. All rights reserved.
//
// https://www.raywenderlich.com/7475-metal-tutorial-getting-started

import UIKit
import Metal

class ViewController: UIViewController {

    var device: MTLDevice!
    var metalLayer: CAMetalLayer!
    
    //Buffer
    let vertexData: [Float] = [
        0.0, 1.0, 0.0,
        -1.0, -1.0, 0.0,
        1.0, -1.0, 0.0
    ]
    
    //vertexData is created by CPU so need to send this data to the GPU by using MTLBuffer
    var vertexBuffer: MTLBuffer!
    
    //Keep track of the compiled render pipeline you're about to create
    var pipelineState: MTLRenderPipelineState!
    
    var commandQueue: MTLCommandQueue!
    
    //Need to redraw the screen every time the device screen refreshes
    //CADisplayLink : Timer synchronized to the displays refresh rate
    var timer: CADisplayLink!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        metalSetUp()
        
        timer = CADisplayLink(target: self, selector: #selector(gameloop))
        //RunLoop.main : loop of the main thread
        timer.add(to: RunLoop.main, forMode: .default)
    }
    
    public func metalSetUp(){
        //Get MTLDevice Reference
        device = MTLCreateSystemDefaultDevice()
    
        //Get CAMetalLayer
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        //bgra8Unorm = 8 bytes for blue, green, red and alpha - with normalized values between 0 and 1
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
    
        //Get the size of the vertex data in bytes
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        //Create a new buffer on the GPU passing in the data from the CPU
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
    
        //Can access any of the precompiled shaders included the project through the MTLLibrary
        let defaultLibrary = device.makeDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex")
    
        //Set up render pipeline configuration
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    
        //Compile the pipeline configuration
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    
        //Creating a CommandQueue
        commandQueue = device.makeCommandQueue()
    }
    
    func render(){
        //nextDrawable: returns the texture in which you need to draw in order for something to appear on the screen
        guard let drawable = metalLayer?.nextDrawable() else { return }
        
        //MTLRenderPassDescriptor: object that configures which texture is being rendered to, what the clear color is and a bit of other configuration
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 55.0/255.0, alpha: 1.0)
        
        //Creating a Command Buffer
        let commandBuffer = commandQueue.makeCommandBuffer()!
        
        //Creating a Render Command Encoder
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1) //Telling the GPU to draw a set of triangles, based on the vertex buffer
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    @objc func gameloop(){
        autoreleasepool {
            self.render()
        }
    }
}

