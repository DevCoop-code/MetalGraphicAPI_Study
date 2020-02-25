//
//  ViewController.m
//  RenderingPipeline
//
//  Created by HanGyo Jeong on 2020/02/21.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import "AAPLViewController.h"
#import "AAPLRenderer.h"

@implementation AAPLViewController
{
    MTKView *_view;
    
    AAPLRenderer *_renderer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set the view to use the default device
    _view = (MTKView *)self.view;
    
    _view.device = MTLCreateSystemDefaultDevice();
    
    NSAssert(_view.device, @"Metal is not supported on this device");
    
    _renderer = [[AAPLRenderer alloc] initWithMetalKitView:_view];
    
    NSAssert(_view.device, @"Renderer failed initialization");
    
    // Initialize renderer with the view size
    [_renderer mtkView:_view drawableSizeWillChange:_view.drawableSize];
    
    _view.delegate = _renderer;
}


- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}


@end
