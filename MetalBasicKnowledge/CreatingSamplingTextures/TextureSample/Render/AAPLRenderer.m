//
//  AAPLRenderer.m
//  TextureSample
//
//  Created by HanGyo Jeong on 2020/02/25.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import "AAPLRenderer.h"

#import "AAPLShaderTypes.h"
#import "AAPLImage.h"

#import "AAPLShaderTypes.h"

@implementation AAPLRenderer
{
    id<MTLDevice> _device;
    
    id<MTLRenderPipelineState> _pipelineState;
    
    id<MTLCommandQueue> _commandQueue;
    
    // The Metal texture object
    id<MTLTexture> _texture;
    
    id<MTLBuffer> _vertices;
    
    NSUInteger _numVertices;
    
    vector_uint2 _viewportSizel;
}

- (id<MTLTexture>)loadTextureUsingAAPLImage:(NSURL *) url
{
    AAPLImage *image = [[AAPLImage alloc] initWithTGAFileAtLocation:url];
    
    NSAssert(image, @"Failed to create the image from %@", url.absoluteString);
    
    MTLTextureDescriptor *textureDescriptor = [[MTLTextureDescriptor alloc] init];
    
    // Indicate that each pixel has a blue, green, red, and alpha channel, where each channel is an 8-bit unsigned normalized value(0 maps to 0.0 and 255 maps to 1.0)
    textureDescriptor.pixelFormat = MTLPixelFormatBGRA8Unorm;
    
    // Set the pixel dimensions of the texture
    textureDescriptor.width = image.width;
    textureDescriptor.height = image.height;
    
    // Create the texture from the device by using the descriptor
    id<MTLTexture> texture = [_device newTextureWithDescriptor:textureDescriptor];
    
    // Calculate the number of bytes per row in the image
    NSUInteger bytesPerRow = 4 * image.width;
    
    MTLRegion region = {
        {0, 0, 0},      //MTLOrigin
        {image.width, image.height, 1}  //MTLSize
    };
    
    // Copy the bytes from the data object into the texture
    [texture replaceRegion:region mipmapLevel:0 withBytes:image.data.bytes bytesPerRow:bytesPerRow];
    
    return texture;
}
@end
