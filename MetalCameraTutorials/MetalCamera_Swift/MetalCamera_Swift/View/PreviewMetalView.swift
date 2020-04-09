//
//  PreviewMetalView.swift
//  MetalCamera_Swift
//
//  Created by HanGyo Jeong on 2020/04/07.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

import Foundation
import Metal
import MetalKit

/*
 Custom subclass of MTKView
 */
class PreviewMetalView: MTKView
{
    private let syncQueue = DispatchQueue(label: "Preview View Sync Queue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
    
    private var internalPixelBuffer: CVPixelBuffer?
    var pixelBuffer:CVPixelBuffer?
    {
        didSet
        {
            syncQueue.sync
            {
                internalPixelBuffer = pixelBuffer
            }
        }
    }
    
    private var textureCache: CVMetalTextureCache?
    
    private var textureWidth: Int = 0
    private var textureHeight: Int = 0
    
    private var sampler: MTLSamplerState!
    
    private var renderPipelineState: MTLRenderPipelineState!
    
    private var commandQueue: MTLCommandQueue?
    
    private var vertexCoordBuffer: MTLBuffer!
    private var textCoordBuffer: MTLBuffer!
    
    private var internalBounds: CGRect!
    private var textureTransform: CGAffineTransform?
    
    required init(coder: NSCoder)
    {
        super.init(coder: coder)
        
        device = MTLCreateSystemDefaultDevice()
        
        configureMetal()
        
        createTextureCache()
        
        colorPixelFormat = .bgra8Unorm
    }
    
    func flushTextureCache()
    {
        textureCache = nil
    }
    
    private func setupTransform(width: Int, height: Int)
    {
        var scaleX: Float = 1.0
        var scaleY: Float = 1.0
        var resizeAspect: Float = 1.0
        
        internalBounds = self.bounds
        textureWidth = width
        textureHeight = height
        
        if textureWidth > 0 && textureHeight > 0
        {
            // Rotate 0 Degree
            scaleX = Float(internalBounds.width / CGFloat(textureWidth))
            scaleY = Float(internalBounds.height / CGFloat(textureHeight))
        }
        
        //Resize aspect Ratio
        resizeAspect = min(scaleX, scaleY)
        if scaleX < scaleY
        {
            scaleY = scaleX / scaleY
            scaleX = 1.0
        }
        else
        {
            scaleX = scaleY / scaleX
            scaleY = 1.0
        }
        
        // Vertex coordinate takes the gravity into account
        let vertexData: [Float] = [
            -scaleX, -scaleY, 0.0, 1.0,
            scaleX, -scaleY, 0.0, 1.0,
            -scaleX, scaleY, 0.0, 1.0,
            scaleX, scaleY, 0.0, 1.0
        ]
        vertexCoordBuffer = device!.makeBuffer(bytes: vertexData, length: vertexData.count * MemoryLayout<Float>.size, options: [])
        
        // Texture coordinate takes the rotation into account
        var textData: [Float]
        textData = [
            0.0, 1.0,
            1.0, 1.0,
            0.0, 0.0,
            1.0, 0.0
        ]
        textCoordBuffer = device?.makeBuffer(bytes: textData, length: textData.count * MemoryLayout<Float>.size, options: [])
        
        // Calculate the transform from texture coordinates to view coordinates
        var transform = CGAffineTransform.identity
        // Affine - Rotation
        transform = transform.concatenating(CGAffineTransform(rotationAngle: CGFloat(0)))
        // Affine - Scaling
        transform = transform.concatenating(CGAffineTransform(scaleX: CGFloat(resizeAspect), y: CGFloat(resizeAspect)))
        // Affine - Shift
        let transformRect = CGRect(origin: .zero, size: CGSize(width: textureWidth, height: textureHeight)).applying(transform)
        let xShift = (internalBounds.size.width - transformRect.size.width) / 2
        let yShift = (internalBounds.size.height - transformRect.size.height) / 2
        transform = transform.concatenating(CGAffineTransform(translationX: xShift, y: yShift))
        
        textureTransform = transform.inverted()
    }
    
    func configureMetal()
    {
        let defaultLibrary = device!.makeDefaultLibrary()
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        pipelineDescriptor.vertexFunction = defaultLibrary?.makeFunction(name: "vertexPassThrough")
        pipelineDescriptor.fragmentFunction = defaultLibrary?.makeFunction(name: "fragmentPassThrough")
        do
        {
            renderPipelineState = try device!.makeRenderPipelineState(descriptor: pipelineDescriptor)
        }
        catch
        {
            fatalError("Unable to create preview Metal view pipeline statte. (\(error))")
        }
        
        // To determine how textures are sampled, create a sampler descriptor to query for a sampler state from the device
        let samplerDescriptor = MTLSamplerDescriptor()
        samplerDescriptor.sAddressMode = .clampToEdge
        samplerDescriptor.tAddressMode = .clampToEdge
        samplerDescriptor.minFilter = .linear
        samplerDescriptor.magFilter = .linear
        sampler = device!.makeSamplerState(descriptor: samplerDescriptor)
        
        commandQueue = device!.makeCommandQueue()
    }
    
    func createTextureCache()
    {
        var newTextureCache: CVMetalTextureCache?
        if CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device!, nil, &newTextureCache) == kCVReturnSuccess
        {
            textureCache = newTextureCache
        }
        else
        {
            assertionFailure("Unable to allocate texture cache")
        }
    }
    
    override func draw(_ rect: CGRect)
    {
        var pixelBuffer: CVPixelBuffer?
        
        guard let drawable = currentDrawable,
            let currentRenderPassDescriptor = currentRenderPassDescriptor,
            let previewPixelBuffer = pixelBuffer else {
                return
        }
        
        // Create a Metal texture from image buffer
        let width = CVPixelBufferGetWidth(previewPixelBuffer)
        let height = CVPixelBufferGetHeight(previewPixelBuffer)
        
        if textureCache == nil
        {
            createTextureCache()
        }
        var cvTextureOut: CVMetalTexture?
        CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                  textureCache!,
                                                  previewPixelBuffer,
                                                  nil,
                                                  .bgra8Unorm,
                                                  width,
                                                  height,
                                                  0,
                                                  &cvTextureOut)
        guard let cvTexture = cvTextureOut, let texture = CVMetalTextureGetTexture(cvTexture) else
        {
            print("Failed to create preview texture")
            
            CVMetalTextureCacheFlush(textureCache!, 0)
            return
        }
        
        if texture.width != textureWidth || texture.height != textureHeight || self.bounds != internalBounds
        {
            setupTransform(width: texture.width, height: texture.height)
        }
        
        // Set up command buffer and encoder
        guard let commandQueue = commandQueue else
        {
            print("Failed to create Metal command queue")
            CVMetalTextureCacheFlush(textureCache!, 0)
            return
        }
        guard let commandBuffer = commandQueue.makeCommandBuffer() else
        {
            print("Failed to create Metal command buffer")
            CVMetalTextureCacheFlush(textureCache!, 0)
            return
        }
        guard let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: currentRenderPassDescriptor) else
        {
            print("Failed to create Metal command encoder")
            CVMetalTextureCacheFlush(textureCache!, 0)
            return
        }
        
        commandEncoder.label = "Preview display"
        commandEncoder.setRenderPipelineState(renderPipelineState!)
        commandEncoder.setVertexBuffer(vertexCoordBuffer, offset: 0, index: 0)
        commandEncoder.setVertexBuffer(textCoordBuffer, offset: 0, index: 1)
        commandEncoder.setFragmentTexture(texture, index: 0)
        commandEncoder.setFragmentSamplerState(sampler, index: 0)
        commandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 4)
        commandEncoder.endEncoding()
        
        // Draw to the screen
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
