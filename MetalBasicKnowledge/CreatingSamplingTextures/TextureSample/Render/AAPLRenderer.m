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

@implementation AAPLRenderer
{
    id<MTLDevice> _device;
    
    id<MTLRenderPipelineState> _pipelineState;
    
    id<MTLCommandQueue> _commandQueue;
    
    // The Metal texture object
    id<MTLTexture> _texture;
    
    id<MTLBuffer> _vertices;
    
    NSUInteger _numVertices;
    
    vector_uint2 _viewportSize;
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

- (nonnull instancetype)initWithMetalKitView:(MTKView *)mtkView
{
    self = [super init];
    if(self)
    {
        _device = mtkView.device;
        
        NSURL *imageFileLocation = [[NSBundle mainBundle] URLForResource:@"Image" withExtension:@"tga"];
        
        _texture = [self loadTextureUsingAAPLImage:imageFileLocation];
        
        // Set up a simple MTLBuffer with vertices which include texture coordinates
        static const AAPLVertex quadVertices[] =
        {
            // Pixel positions, Texture coordinates
            { {  250,  -250 },  { 1.f, 1.f } },
            { { -250,  -250 },  { 0.f, 1.f } },
            { { -250,   250 },  { 0.f, 0.f } },

            { {  250,  -250 },  { 1.f, 1.f } },
            { { -250,   250 },  { 0.f, 0.f } },
            { {  250,   250 },  { 1.f, 0.f } },
        };
        
        // Create a vertex buffer, and initialize it with the quadVertices array
        _vertices = [_device newBufferWithBytes:quadVertices length:sizeof(quadVertices) options:MTLResourceStorageModeShared];
        
        // Calculate the number of vertices by dividing the byte length by the size of each vertex
        _numVertices = sizeof(quadVertices) / sizeof(AAPLVertex);
        
        //MARK: Create the render pipeline
        
        //Load the shaders from the default library
        id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
        id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];
        id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"samplingShader"];
        
        // Set up a descriptor for creating a pipeline state object
        MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
        pipelineStateDescriptor.label = @"Texturing Pipeline";
        pipelineStateDescriptor.vertexFunction = vertexFunction;
        pipelineStateDescriptor.fragmentFunction = fragmentFunction;
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
        
        NSError *error = NULL;
        _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&error];
        NSAssert(_pipelineState, @"Failed to created pipeline state, error %@", error);
        
        _commandQueue = [_device newCommandQueue];
    }
    return self;
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size
{
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
}

//MARK: called whenever the view needs to render a frame
- (void)drawInMTKView:(nonnull MTKView *)view
{
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"MyCommand";
    
    // Obtain a renderPassDescriptor generated from the view's drawable textures
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    
    if(nil != renderPassDescriptor)
    {
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"MyRenderEncoder";
        
        // Set the region of the drawable to draw into
        [renderEncoder setViewport:(MTLViewport){0.0, 0.0, _viewportSize.x, _viewportSize.y, -1.0, 1.0}];
        
        [renderEncoder setRenderPipelineState:_pipelineState];
        
        [renderEncoder setVertexBuffer:_vertices offset:0 atIndex:AAPLVertexInputIndexVertices];
        
        [renderEncoder setVertexBytes:&_viewportSize length:sizeof(_viewportSize) atIndex:AAPLVertexInputIndexViewportSize];
        
        // Set the texture object.
        [renderEncoder setFragmentTexture:_texture atIndex:AAPLTextureIndexBaseColor];
        
        //Draw the triangles
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:_numVertices];
        
        [renderEncoder endEncoding];
        
        //Schedule a present once the framebuffer is complete using the current drawable
        [commandBuffer presentDrawable:view.currentDrawable];
        
        //Finalize rendering here & push the command buffer to the GPU
        [commandBuffer commit];
    }
}
@end
