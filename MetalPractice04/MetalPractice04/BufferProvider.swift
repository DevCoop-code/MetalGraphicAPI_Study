//
//  BufferProvider.swift
//  MetalPractice04
//
//  Created by HanGyo Jeong on 07/04/2019.
//  Copyright © 2019 HanGyoJeong. All rights reserved.
//

import Foundation
import Metal

class BufferProvider : NSObject{
    // Store the number of buffers stored by BufferProvider
    let inflightBuffersCount: Int
    // Store the buffers themselves
    private var uniformsBuffers: [MTLBuffer]
    // Index of the next available buffer
    private var availableBufferIndex: Int = 0
    
    //Create Number of Buffers
    init(device: MTLDevice, inflightBuffersCount: Int, sizeOfUniformsBuffer: Int) {
        self.inflightBuffersCount = inflightBuffersCount
        uniformsBuffers = [MTLBuffer]()
        
        for _ in 0...inflightBuffersCount-1{
            let uniformsBuffer = device.makeBuffer(length: sizeOfUniformsBuffer, options: [])
            uniformsBuffers.append(uniformsBuffer!)
        }
    }
    
    func nextUniformsBuffer(projectionMatrix: Matrix4, modelViewMatrix: Matrix4) -> MTLBuffer{
        //Fetch MTLBuffer from the array at specific index
        let buffer = uniformsBuffers[availableBufferIndex]
        
        //Get void* pointer
        let bufferPointer = buffer.contents()
        
        //Copy the passed-in matrices data into the buffer using memcpy
        memcpy(bufferPointer, modelViewMatrix.raw(), MemoryLayout<Float>.size * Matrix4.numberOfElements())
        memcpy(bufferPointer + MemoryLayout<Float>.size * Matrix4.numberOfElements(),
               projectionMatrix.raw(),
               MemoryLayout<Float>.size * Matrix4.numberOfElements())
        
        availableBufferIndex+=1
        if availableBufferIndex == inflightBuffersCount {
            availableBufferIndex = 0
        }
        
        return buffer
    }
}
