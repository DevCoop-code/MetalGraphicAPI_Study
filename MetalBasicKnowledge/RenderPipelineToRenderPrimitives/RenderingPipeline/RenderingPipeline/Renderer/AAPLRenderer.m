//
//  AAPLRenderer.m
//  RenderingPipeline
//
//  Created by HanGyo Jeong on 2020/02/23.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//
@import simd;
@import MetalKit;

#import "AAPLRenderer.h"
#import "AAPLShaderTypes.h"

@implementation AAPLRenderer
{
    id<MTLDevice> _device;
    
    // The render pipeline generated from the vertex and fragment shaders in the .metal shader file
    id<MTLRenderPipelineState> _pipelineState;
    
    // The command queue used to pass commands to the device
    id<MTLCommandQueue> _commandQueue;
    
    // The current size of the view, used as an input to the vertex shader
    vector_uint2 _viewportSize;
}

- (nonnull instancetype)initWithMetalKitView:(MTKView *)mtkView
{
    self = [super init];
    if(self)
    {
        NSError *error = NULL;
        
        _device = mtkView.device;
        
        // Load all the shader files with a .metal file extension in the project
        id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
        
        id<MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];
        id<MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"fragmentShader"];
        
        // Configure a pipeline descriptor that is used to create a pipeline state
        MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
        pipelineStateDescriptor.label = @"Simple Pipeline";
        pipelineStateDescriptor.vertexFunction = vertexFunction;
        pipelineStateDescriptor.fragmentFunction = fragmentFunction;
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat;
        
        _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&error];
        
        NSAssert(_pipelineState, @"Failed to created pipeline state: %@", error);
        
        // Create the command queue
        _commandQueue = [_device newCommandQueue];
    }
    return self;
}

// MARK: Called whenever view changes orientation or is resized
- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size
{
    // Save the size of the drawable to pass to the vertex shader
    _viewportSize.x = size.width;
    _viewportSize.y = size.height;
}

// MARK: Called whenever the view needs to render a frame
- (void)drawInMTKView:(MTKView *)view
{
    static const AAPLVertex triangleVertices[] =
    {
        //2D positions, RGBA colors
        {{ 250, -250}, {1, 0, 0, 1}},
        {{-250, -250}, {0, 1, 0, 1}},
        {{   0,  250}, {0, 0, 1, 1}},
    };
    
    // Create a new command buffer for each render pass to the current drawable
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"MyCommand";
    
    // Obtain a renderPassDescriptor generated from the view's drawable texture
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    
    if(nil != renderPassDescriptor)
    {
        // Create a render command encoder
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"MyRenderEncoder";
        
        // Set the region of the drawable to draw into
        [renderEncoder setViewport:(MTLViewport){0.0, 0.0, _viewportSize.x, _viewportSize.y, 0.0, 1.0}];
        
        [renderEncoder setRenderPipelineState:_pipelineState];
        
        // Pass in the parameter data
        [renderEncoder setVertexBytes:triangleVertices length:sizeof(triangleVertices) atIndex:AAPLVertexInputIndexVertices];
        
        [renderEncoder setVertexBytes:&_viewportSize length:sizeof(_viewportSize) atIndex:AAPLVertexInputIndexViewportSize];
        
        // Draw the triangle
        [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
        
        [renderEncoder endEncoding];
        
        // Schedule a present once the framebuffer is complete using the current drawable
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    
    //Finalize rendering here & push the command buffer to the GPU
    [commandBuffer commit];
}
@end
