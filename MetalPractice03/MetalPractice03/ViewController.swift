//
//  ViewController.swift
//  MetalPractice03
//
//  Created by DINO2 on 22/02/2019.
//  Copyright © 2019 DINO2. All rights reserved.
//

//https://www.raywenderlich.com/728-metal-tutorial-with-swift-3-part-2-moving-to-3d

import UIKit
import Metal

class ViewController: UIViewController {

    var objectToDraw: Cube!
    
    var device: MTLDevice!
    var metalLayer: CAMetalLayer!
    var pipelineState: MTLRenderPipelineState!
    var commandQueue: MTLCommandQueue!
    var timer: CADisplayLink!
    
    var projectionMatrix: Matrix4!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Making ProjectionMatrix
        projectionMatrix = Matrix4.makePerspectiveViewAngle(Matrix4.degrees(toRad: 85.0),
                                                            aspectRatio: Float(self.view.bounds.size.width/self.view.bounds.size.height),
                                                            nearZ: 0.01,
                                                            farZ: 100.0)
        
        device = MTLCreateSystemDefaultDevice()
        
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        
        objectToDraw = Cube(device: device)
        objectToDraw.positionX = 0.0
        objectToDraw.positionY = 0.0
        objectToDraw.positionZ = -12.0
        objectToDraw.rotationZ = Matrix4.degrees(toRad: 45)
        objectToDraw.scale = 0.5
        
        //MTLLibrary
        let defaultLibrary = device.makeDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex")
        
        //MTLRenderPipelineState
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        commandQueue = device.makeCommandQueue()
        
        timer = CADisplayLink(target: self, selector: #selector(ViewController.gameloop))
        timer.add(to: RunLoop.main, forMode: RunLoop.Mode.default)
    }

    func render(){
        guard let drawable = metalLayer?.nextDrawable() else { return }
        objectToDraw.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawable, projectionMatrix: projectionMatrix, clearColor: nil)
    }
    
    @objc func gameloop(){
        autoreleasepool{
            self.render()
        }
    }
}

