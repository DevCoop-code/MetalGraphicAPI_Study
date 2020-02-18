//
//  MetalAdder.h
//  PerformingCalcOnGPU
//
//  Created by HanGyo Jeong on 2020/02/15.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

@interface MetalAdder : NSObject
- (instancetype) initWithDevice: (id<MTLDevice>) device;
@end

NS_ASSUME_NONNULL_END
