//
//  MetalAdder.m
//  PerformingCalcOnGPU
//
//  Created by HanGyo Jeong on 2020/02/15.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import "MetalAdder.h"
/*
 '<<' is the left shift operator
 1 << 0 == 2^0 == 1 == binary 0001
 1 << 1 == 2^1 == 2 == binary 0010
 1 << 2 == 2^2 == 4 == binary 0100
 1 << 3 == 2^3 == 8 == binary 1000
 */
//The number of floats in each array, and the size of the arrays in bytes
const unsigned int arrayLength = 1 << 24;
const unsigned int bufferSize = arrayLength * sizeof(float);

@implementation MetalAdder
{
    id<MTLDevice> _mDevice;
    
    //The compute pipeline generated from the compute kernel in the .metal shader file
    id<MTLComputePipelineState> _mAddFunctionPSO;
    
    //The command queue used to pass commands to the device
    id<MTLCommandQueue> _mCommandQueue;
    
    //Buffers to hold data
    id<MTLBuffer> _mBufferA;
    id<MTLBuffer> _mBufferB;
    id<MTLBuffer> _mBufferResult;
}

- (instancetype) initWithDevice:(id<MTLDevice>)device
{
    self = [super init];
    if(self)
    {
        _mDevice = device;
        
        NSError* error = nil;
        
        //Load the shader files with a .metal file extension in the project
        id<MTLLibrary> defaultLibrary = [_mDevice newDefaultLibrary];
        if(nil == defaultLibrary)
        {
            NSLog(@"Failed to find the default library");
            return nil;
        }
        
        //Create a compute pipeline state object
        id<MTLFunction> addFunction = [defaultLibrary newFunctionWithName:@"add_arrays"];
        if(nil == addFunction)
        {
            NSLog(@"Failed to find the adder function");
            return nil;
        }
        
        //Create a compute pipeline state object
        _mAddFunctionPSO = [_mDevice newComputePipelineStateWithFunction:addFunction error:&error];
        if(nil == _mAddFunctionPSO)
        {
            NSLog(@"Failed to create pipeline state object, error %@.", error);
            return nil;
        }
        
        _mCommandQueue = [_mDevice newCommandQueue];
        if(nil == _mCommandQueue)
        {
            NSLog(@"Failed to find the command queue");
            return nil;
        }
    }
    return self;
}

- (void) prepareData
{
    // Allocate three buffers to hold our initial data and the result
    _mBufferA = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    _mBufferB = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    _mBufferResult = [_mDevice newBufferWithLength:bufferSize options:MTLResourceStorageModeShared];
    
    [self generateRandomFloatData:_mBufferA];
    [self generateRandomFloatData:_mBufferB];
}

- (void) generateRandomFloatData: (id<MTLBuffer>)buffer
{
    float* dataPtr = buffer.contents;
    
    for(unsigned long index = 0; index < arrayLength; index++)
    {
        dataPtr[index] = (float)rand()/(float)(RAND_MAX);
    }
}
@end
