//
//  FBQuadPathLayer.m
//  FrickBits
//
//  Created by Matt McGlincy on 1/17/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBQuadPathLayer.h"

@interface FBQuadPathLayer()

@end

@implementation FBQuadPathLayer

- (id)initWithRecipe:(FBQuadRecipe *)recipe p1:(CGPoint)p1 p2:(CGPoint)p2 p3:(CGPoint)p3 p4:(CGPoint)p4 {
  FBQuad quad = FBQuadMake(p1, p2, p3, p4);
  return [self initWithRecipe:recipe quad:quad];
}

- (id)initWithRecipe:(FBQuadRecipe *)recipe quad:(FBQuad)quad {
  self = [super init];
    if (self) {
      _quad = quad;
      self.masksToBounds = NO;
      self.topLayer = [[FBPathLayer alloc] initWithRecipe:recipe.pathRecipe1 p1:quad.upperLeft p2:quad.upperRight];
      self.rightLayer = [[FBPathLayer alloc] initWithRecipe:recipe.pathRecipe2 p1:quad.upperRight p2:quad.lowerRight];
      self.bottomLayer = [[FBPathLayer alloc] initWithRecipe:recipe.pathRecipe3 p1:quad.lowerRight p2:quad.lowerLeft];
      self.leftLayer = [[FBPathLayer alloc] initWithRecipe:recipe.pathRecipe4 p1:quad.lowerLeft p2:quad.upperLeft];
        
      [self addSublayer:self.topLayer];
      [self addSublayer:self.rightLayer];
      [self addSublayer:self.bottomLayer];
      [self addSublayer:self.leftLayer];
    }
    return self;
}

- (UIBezierPath *)makeFillPath {
    UIBezierPath *fp = [UIBezierPath bezierPath];
    // TODO: currently using only 4 control points, to make it easier to animate path
    /*
    [fp moveToPoint:self.topLayer.smoothPath.p1];
    [fp addLineToPoint:self.topLayer.smoothPath.p2];
    [fp addLineToPoint:self.rightLayer.smoothPath.p1];
    [fp addLineToPoint:self.rightLayer.smoothPath.p2];
    [fp addLineToPoint:self.bottomLayer.smoothPath.p1];
    [fp addLineToPoint:self.bottomLayer.smoothPath.p2];
    [fp addLineToPoint:self.leftLayer.smoothPath.p1];
    [fp addLineToPoint:self.leftLayer.smoothPath.p2];
    [fp addLineToPoint:self.topLayer.smoothPath.p1];
     */
    [fp moveToPoint:self.topLayer.smoothPath.p1];
    [fp addLineToPoint:self.rightLayer.smoothPath.p1];
    [fp addLineToPoint:self.bottomLayer.smoothPath.p1];
    [fp addLineToPoint:self.leftLayer.smoothPath.p1];
    return fp;
}

- (void)recalculateWithQuad:(FBQuad)quad {
    [self recalculateWithP1:quad.upperLeft p2:quad.upperRight p3:quad.lowerRight p4:quad.lowerLeft];
}

- (void)recalculateWithP1:(CGPoint)p1 p2:(CGPoint)p2 p3:(CGPoint)p3 p4:(CGPoint)p4 {
    [self.topLayer recalculateWithP1:p1 p2:p2];
    [self.rightLayer recalculateWithP1:p2 p2:p3];
    [self.bottomLayer recalculateWithP1:p3 p2:p4];
    [self.leftLayer recalculateWithP1:p4 p2:p1];
}

@end
