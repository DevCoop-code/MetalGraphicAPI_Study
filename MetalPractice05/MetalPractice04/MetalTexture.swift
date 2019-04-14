//
//  MetalTexture.swift
//  MetalPractice04
//
//  Created by HanGyo Jeong on 13/04/2019.
//  Copyright © 2019 HanGyoJeong. All rights reserved.
//

import UIKit

class MetalTexture: NSObject{
    var texture: MTLTexture!
    var target: MTLTextureType!
    var width: Int!
    var height: Int!
    var depth: Int!
    var format: MTLPixelFormat!
    var hasAlpha: Bool!
    var path: String!
    var isMipmaped: Bool!
    
    let bytesPerPixel: Int! = 4
    let bitsPerComponent: Int! = 8
    
    init(resourceName: String, ext: String, mipmaped: Bool) {
        path = Bundle.main.path(forResource: resourceName, ofType: ext)
        width = 0
        height = 0
        depth = 1
        format = MTLPixelFormat.rgba8Unorm
        target = MTLTextureType.type2D
        texture = nil
        isMipmaped = mipmaped
        
        super.init()
    }
    
    //Actually creates MTLTexture
    func loadTexture(device: MTLDevice, commandQ: MTLCommandQueue, flip: Bool){
        let image = (UIImage(contentsOfFile: path)?.cgImage)!
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        width = image.width
        height = image.height
        
        let rowBytes = width * bytesPerPixel
        
        //https://developer.apple.com/documentation/coregraphics/cgcontext/1455939-init
        let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: rowBytes, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        let bounds = CGRect(x: 0, y: 0, width: Int(width), height: Int(height))
        //Paints a transparent rectangle
        context?.clear(bounds)
        
        if flip == false{
            //Changes the origin of the user coordinate system in a context
            context?.translateBy(x: 0, y: CGFloat(self.height))
            //Changes the scale of the user coordinate system in a context
            context?.scaleBy(x: 1.0, y: -1.0)
        }
        
        //Draws an image in the specified area
        context?.draw(image, in: bounds)
        
        let texDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: MTLPixelFormat.rgba8Unorm,
                                                                     width: Int(width),
                                                                     height: Int(height),
                                                                     mipmapped: isMipmaped)
        target = texDescriptor.textureType
        texture = device.makeTexture(descriptor: texDescriptor)
        
        //Returns a pointer to the image data associated with a bitmap context
        let pixelsData = context?.data!
        //Returns a 2D, rectangular region for image or texture data
        let region = MTLRegionMake2D(0, 0, Int(width), Int(height))
        
        //Copies a block of pixels into a section of texture slice
        texture.replace(region: region, mipmapLevel: 0, withBytes: pixelsData! , bytesPerRow: Int(rowBytes))
        
        if isMipmaped == true {
            generateMipMapLayersUsingSystemFunc(texture: texture,
                                                device: device,
                                                commandQ: commandQ,
                                                block: {(buffer) -> Void in
                                                    print("mips generated")
            })
        }
        print("mipCount:\(texture.mipmapLevelCount)")
    }
    
    func generateMipMapLayersUsingSystemFunc(texture: MTLTexture, device: MTLDevice, commandQ: MTLCommandQueue, block: @escaping MTLCommandBufferHandler){
        let commandBuffer = commandQ.makeCommandBuffer()
        
        commandBuffer?.addCompletedHandler(block)
        
        let blitCommandEncoder = commandBuffer?.makeBlitCommandEncoder()
        blitCommandEncoder?.generateMipmaps(for: texture)
        blitCommandEncoder?.endEncoding()
        
        commandBuffer?.commit()
    }
}
