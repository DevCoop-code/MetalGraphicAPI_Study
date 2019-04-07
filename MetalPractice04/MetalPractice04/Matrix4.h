//
//  Matrix4.h
//  MetalPractice04
//
//  Created by HanGyo Jeong on 07/04/2019.
//  Copyright © 2019 HanGyoJeong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKMath.h>

@interface Matrix4 : NSObject{
@public
    GLKMatrix4 glkMatrix;
}

+ (Matrix4 *_Nonnull)makePerspectiveViewAngle:(float)angleRad
                                  aspectRatio:(float)aspect
                                        nearZ:(float)nearZ
                                         farZ:(float)farZ;
- (_Nonnull instancetype)init;
- (_Nonnull instancetype)copy;

- (void)scale:(float)x y:(float)y z:(float)z;
- (void)rotateAroundX:(float)xAngleRad y:(float)yAngleRad z:(float)zAngleRad;
- (void)translate:(float)x y:(float)y z:(float)z;
- (void)multiplyLeft:(Matrix4 *_Nonnull)matrix;

- (void *_Nonnull)raw;
- (void)transpose;

+ (float)degreesToRad:(float)degrees;
+ (NSInteger)numberOfElements;

@end
