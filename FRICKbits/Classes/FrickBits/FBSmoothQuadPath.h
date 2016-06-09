//
//  FBSmoothQuadPath.h
//  FRICKbits
//
//  Created by Matt McGlincy on 7/14/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBQuad.h"
#import "FBSmoothPath.h"

@interface FBSmoothQuadPath : NSObject

@property (nonatomic, strong) FBQuadRecipe *recipe;
@property (nonatomic, strong) FBSmoothPath *topPath;
@property (nonatomic, strong) FBSmoothPath *rightPath;
@property (nonatomic, strong) FBSmoothPath *bottomPath;
@property (nonatomic, strong) FBSmoothPath *leftPath;

- (id)initWithRecipe:(FBQuadRecipe *)recipe quad:(FBQuad)quad;
- (id)initWithRecipe:(FBQuadRecipe *)recipe p1:(CGPoint)p1 p2:(CGPoint)p2 p3:(CGPoint)p3 p4:(CGPoint)p4;

- (void)renderInContext:(CGContextRef)context;

// make a path suitable for filling this quad
- (UIBezierPath *)makeFillPath;

- (void)recalculateWithQuad:(FBQuad)quad;
- (void)recalculateWithP1:(CGPoint)p1 p2:(CGPoint)p2 p3:(CGPoint)p3 p4:(CGPoint)p4;

@end
