//
//  FBSmoothPath.h
//  FrickBits
//
//  Created by Matt McGlincy on 1/14/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBFrickBitRecipe.h"

@interface FBSmoothPath : UIBezierPath

// smoothed curve points
@property(nonatomic) CGPoint p1;
@property(nonatomic) CGPoint p2;
@property(nonatomic) CGPoint p3;
@property(nonatomic) CGPoint p4;

// keep the color around
@property(nonatomic, strong) UIColor *strokeColor;

- (id)initWithRecipe:(FBPathRecipe *)recipe p1:(CGPoint)p1 p2:(CGPoint)p2;

- (void)renderInContext:(CGContextRef)context;

@end
