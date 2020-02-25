//
//  AAPLImage.h
//  TextureSample
//
//  Created by HanGyo Jeong on 2020/02/25.
//  Copyright © 2020 HanGyoJeong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AAPLImage : NSObject

- (nullable instancetype) initWithTGAFileAtLocation:(nonnull NSURL *)location;

// Width of image in pixels
@property (nonatomic, readonly) NSUInteger width;

// Height of image in pixels
@property (nonatomic, readonly) NSUInteger height;

// Image data in 32-bits-per-pixel (bpp(bits per pixel)) BGRA form(which is equivalent to MTLPixelFormatBGRA8Unorn)
@property (nonatomic, readonly, nonnull) NSData *data;
@end

NS_ASSUME_NONNULL_END
