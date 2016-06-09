//
//  FBPathLayer.h
//  FrickBits
//
//  Created by Matt McGlincy on 1/17/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FBSmoothPath.h"

@interface FBPathLayer : CAShapeLayer

@property (nonatomic, strong) FBPathRecipe *recipe;
@property (nonatomic, strong) FBSmoothPath *smoothPath;
@property (nonatomic, readonly) CGPoint p1;
@property (nonatomic, readonly) CGPoint p2;
@property (nonatomic, readonly) CGFloat length;

- (id)initWithRecipe:(FBPathRecipe *)recipe p1:(CGPoint)p1 p2:(CGPoint)p2;

- (void)recalculateWithP1:(CGPoint)p1 p2:(CGPoint)p2;

@end
