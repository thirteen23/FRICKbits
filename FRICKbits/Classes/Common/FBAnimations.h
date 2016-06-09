//
//  FBAnimations.h
//  FrickBits
//
//  Created by Matt McGlincy on 1/16/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBAnimations : NSObject

+ (CAKeyframeAnimation *)bounceIn;
+ (CABasicAnimation *)fadeIn;
+ (CABasicAnimation *)scaleIn;
+ (CABasicAnimation *)strokeIn;

+ (void)animateView:(UIView *)view alpha:(CGFloat)alpha;
+ (void)animateView:(UIView *)view alpha:(CGFloat)alpha duration:(CGFloat)duration;
+ (void)animateView:(UIView *)view scale:(CGFloat)scale;

@end
