//
//  ViewController.swift
//  MetalPractice02
//
//  Created by DINO2 on 22/02/2019.
//  Copyright © 2019 DINO2. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var device: MTLDevice!
    var metalLayer: CAMetalLayer!
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    var objectToDraw: Triangle!
    
    var timer: CADisplayLink!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        metalSetUp()
        
        timer = CADisplayLink(target: self, selector: #selector(gameloop))
        //RunLoop.main : loop of the main thread
        timer.add(to: RunLoop.main, forMode: .default)
    }
    
    public func metalSetUp(){
        device = MTLCreateSystemDefaultDevice()
        
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        
        objectToDraw = Triangle(device: device);
        
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
        guard let drawable = metalLayer?.nextDrawable() else { return }
        objectToDraw.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawable, clearColor: nil)
    }
    
    @objc func gameloop(){
        autoreleasepool {
            self.render()
        }
    }
}

