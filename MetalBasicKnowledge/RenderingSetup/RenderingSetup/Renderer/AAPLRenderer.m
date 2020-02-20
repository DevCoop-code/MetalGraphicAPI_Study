//
//  AAPLRenderer.m
//  RenderingSetup
//
//  Created by HanGyo Jeong on 2020/02/21.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import "AAPLRenderer.h"

@implementation AAPLRenderer
{
    id<MTLDevice> _device;
    
    // The command queue used to pass commands to the device
    id<MTLCommandQueue> _commandQueue;
}

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)mtkView
{
    self = [super init];
    if(self)
    {
        _device = mtkView.device;
        
        //Create the command queue
        _commandQueue = [_device newCommandQueue];
    }
    
    return self;
}

//MARK: Called whenever the view needs to render a frame
- (void)drawInMTKView:(nonnull MTKView *)view
{
    // The render pass descriptor references the texture into which Metal should draw
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if(nil == renderPassDescriptor)
    {
        return;
    }
    
    id<MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    
    // Create a render pass and immediately end encoding, causing the drawable to be cleared
    id<MTLRenderCommandEncoder> commandEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    
    [commandEncoder endEncoding];
    
    // Get the drawable that will be presented at the end of the frame
    id<MTLDrawable> drawable = view.currentDrawable;
    
    // Request that the drawable texture be presented by the windowing system once drawing is done
    [commandBuffer presentDrawable:drawable];
    
    [commandBuffer commit];
}

//MARK: Called whenever view change orientation or is resized
- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size
{
    
}
@end
