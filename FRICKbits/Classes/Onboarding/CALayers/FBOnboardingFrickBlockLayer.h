//
//  FBOnboardingFrickBlockLayer.h
//  FRICKbits
//
//  Created by Michael Van Milligan on 5/28/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface FBOnboardingFrickBlockLayer : CALayer

@property(nonatomic, strong) UIColor *fillColor;
@property(nonatomic) NSInteger tag;
@property(nonatomic) NSUInteger colorIdx;
@property(nonatomic) CGVector shift;
@property(nonatomic, readonly) BOOL isAnimating;
@property(nonatomic) BOOL doImperfections;

- (void)animate;
- (void)animateWithCompletion:(dispatch_block_t)completion;
- (void)animateWithDuration:(CGFloat)duration
              andCompletion:(dispatch_block_t)completion;

@end