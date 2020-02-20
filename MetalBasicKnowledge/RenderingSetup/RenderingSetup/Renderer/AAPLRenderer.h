//
//  AAPLRenderer.h
//  RenderingSetup
//
//  Created by HanGyo Jeong on 2020/02/21.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import <Foundation/Foundation.h>

@import MetalKit;
NS_ASSUME_NONNULL_BEGIN

@interface AAPLRenderer : NSObject<MTKViewDelegate>

- (nonnull instancetype)initWithMetalKitView:(nonnull MTKView*)mtkView;

@end

NS_ASSUME_NONNULL_END
