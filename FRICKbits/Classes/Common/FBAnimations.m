//
//  FBAnimations.m
//  FrickBits
//
//  Created by Matt McGlincy on 1/16/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBAnimations.h"

@implementation FBAnimations

+ (CAKeyframeAnimation *)bounceIn {
  CAKeyframeAnimation *bounceAnimation =
      [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
  bounceAnimation.values = @[ @(0.05), @(1.1), @(0.9), @(1) ];
  bounceAnimation.duration = 0.6;
  NSMutableArray *timingFunctions =
      [[NSMutableArray alloc] initWithCapacity:bounceAnimation.values.count];
  for (NSUInteger i = 0; i < bounceAnimation.values.count; i++) {
    [timingFunctions
        addObject:[CAMediaTimingFunction
                      functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
  }
  [bounceAnimation setTimingFunctions:timingFunctions.copy];
  bounceAnimation.removedOnCompletion = NO;
  return bounceAnimation;
}

+ (CABasicAnimation *)fadeIn {
  CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"opacity"];
  anim.duration = 0.5;
  anim.fromValue = [NSNumber numberWithFloat:0.0f];
  anim.toValue = [NSNumber numberWithFloat:1.0f];
  return anim;
}

+ (CABasicAnimation *)scaleIn {
  CABasicAnimation *anim =
      [CABasicAnimation animationWithKeyPath:@"transform.scale"];
  anim.duration = 0.0;
  anim.fromValue = [NSNumber numberWithFloat:0.0f];
  anim.toValue = [NSNumber numberWithFloat:1.0f];
  return anim;
}

+ (CABasicAnimation *)strokeIn {
  CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
  anim.duration = 0.5;
  anim.fromValue = [NSNumber numberWithFloat:0.0f];
  anim.toValue = [NSNumber numberWithFloat:1.0f];
  return anim;
}

+ (void)animateView:(UIView *)view scale:(CGFloat)scale {
  view.transform = CGAffineTransformMakeScale(0, 0);
  [UIView animateWithDuration:0.5
      delay:0.0
      options:UIViewAnimationOptionCurveLinear
      animations:^{ view.transform = CGAffineTransformMakeScale(scale, scale); }
      completion:^(BOOL finished) {}];
}

+ (void)animateView:(UIView *)view
              alpha:(CGFloat)alpha
           duration:(CGFloat)duration {
  [UIView animateWithDuration:duration
      delay:0.0
      options:UIViewAnimationOptionCurveLinear
      animations:^{ view.alpha = alpha; }
      completion:^(BOOL finished) {}];
}

+ (void)animateView:(UIView *)view alpha:(CGFloat)alpha {
  [FBAnimations animateView:view alpha:alpha duration:0.5];
}

@end
