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
import QuartzCore
import Metal

class Node {
    
    let device: MTLDevice
    let name: String
    var vertexCount: Int
    var vertexBuffer: MTLBuffer
    var time:CFTimeInterval = 0.0
    
    var bufferProvider: BufferProvider
    
    var positionX: Float = 0.0
    var positionY: Float = 0.0
    var positionZ: Float = 0.0
    
    var rotationX: Float = 0.0
    var rotationY: Float = 0.0
    var rotationZ: Float = 0.0
    var scale: Float     = 1.0
    
    var texture: MTLTexture
    lazy var samplerState: MTLSamplerState? = Node.defaultSampler(device: self.device)
    
    init(name: String, vertices: Array<Vertex>, device: MTLDevice, texture: MTLTexture){
        
        var vertexData = Array<Float>()
        for vertex in vertices{
            vertexData += vertex.floatBuffer()
        }
        
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])!
        
        self.name = name
        self.device = device
        vertexCount = vertices.count
        self.texture = texture
        
        self.bufferProvider = BufferProvider(device: device,
                                             inflightBuffersCount: 3,
                                             sizeOfUniformsBuffer: MemoryLayout<Float>.size * Matrix4.numberOfElements() * 2)
    }
    
    func render(commandQueue: MTLCommandQueue, pipelineState: MTLRenderPipelineState, drawable: CAMetalDrawable, parentModelViewMatrix: Matrix4, projectionMatrix: Matrix4, clearColor: MTLClearColor?) {
        
        //Make CPU wait in case bufferProvider.availableResourcesSemaphore has no free resources.
        bufferProvider.availableResourcesSemaphore.wait(timeout: DispatchTime.distantFuture)
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        //Signal the semaphore when the resource becomes available
        //https://developer.apple.com/documentation/metal/mtlcommandbuffer/1442997-addcompletedhandler?language=objc
        //https://developer.apple.com/documentation/dispatch/dispatchsemaphore/1452919-signal
        //When the GPU finishes rendering, it executes a completion handler to signal the semaphore and bumps its count back up again
        commandBuffer?.addCompletedHandler{
            (_) in self.bufferProvider.availableResourcesSemaphore.signal()
        }
        
        let renderEncoder = commandBuffer!.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        //For now cull mode is used instead of depth buffer
        renderEncoder!.setCullMode(MTLCullMode.front)
        renderEncoder!.setRenderPipelineState(pipelineState)
        renderEncoder!.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        //Passes the texture and sampler to the shaders
        renderEncoder?.setFragmentTexture(texture, index: 0)
        if let samplerState = samplerState{
            renderEncoder?.setFragmentSamplerState(samplerState, index: 0)
        }
        
        let nodeModelMatrix = self.modelMatrix()
        nodeModelMatrix.multiplyLeft(parentModelViewMatrix)
        
        let uniformBuffer = bufferProvider.nextUniformsBuffer(projectionMatrix: projectionMatrix, modelViewMatrix: nodeModelMatrix)
        
        renderEncoder!.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        
        renderEncoder!.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount, instanceCount: vertexCount/3)
        renderEncoder!.endEncoding()
        
        commandBuffer!.present(drawable)
        commandBuffer!.commit()
    }
    
    func modelMatrix() -> Matrix4 {
        let matrix = Matrix4()
        matrix.translate(positionX, y: positionY, z: positionZ)
        matrix.rotateAroundX(rotationX, y: rotationY, z: rotationZ)
        matrix.scale(scale, y: scale, z: scale)
        return matrix
    }
    
    func updateWithDelta(delta: CFTimeInterval){
        time += delta
    }
    
    class func defaultSampler(device: MTLDevice) -> MTLSamplerState{
        let sampler = MTLSamplerDescriptor()
        sampler.minFilter = MTLSamplerMinMagFilter.nearest
        sampler.magFilter = MTLSamplerMinMagFilter.nearest
        sampler.mipFilter = MTLSamplerMipFilter.nearest
        sampler.maxAnisotropy = 1
        sampler.sAddressMode = MTLSamplerAddressMode.clampToEdge
        sampler.tAddressMode = MTLSamplerAddressMode.clampToEdge
        sampler.rAddressMode = MTLSamplerAddressMode.clampToEdge
        sampler.normalizedCoordinates = true
        sampler.lodMinClamp = 0
        sampler.lodMaxClamp = FLT_MAX
        
        return device.makeSamplerState(descriptor: sampler)!
    }
}
