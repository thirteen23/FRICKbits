//
//  FBQuadPathLayer.h
//  FrickBits
//
//  Created by Matt McGlincy on 1/17/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "FBPathLayer.h"
#import "FBQuad.h"
#import "FBSmoothPath.h"

@interface FBQuadPathLayer : CALayer

@property (nonatomic) FBQuad quad;

@property (nonatomic, strong) FBPathLayer *topLayer;
@property (nonatomic, strong) FBPathLayer *rightLayer;
@property (nonatomic, strong) FBPathLayer *bottomLayer;
@property (nonatomic, strong) FBPathLayer *leftLayer;

- (id)initWithRecipe:(FBQuadRecipe *)recipe quad:(FBQuad)quad;
- (id)initWithRecipe:(FBQuadRecipe *)recipe p1:(CGPoint)p1 p2:(CGPoint)p2 p3:(CGPoint)p3 p4:(CGPoint)p4;

// make a path suitable for filling this quad
- (UIBezierPath *)makeFillPath;

- (void)recalculateWithQuad:(FBQuad)quad;
- (void)recalculateWithP1:(CGPoint)p1 p2:(CGPoint)p2 p3:(CGPoint)p3 p4:(CGPoint)p4;

@end
