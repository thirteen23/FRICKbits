//
//  FBSmoothQuadPath.m
//  FRICKbits
//
//  Created by Matt McGlincy on 7/14/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBSmoothQuadPath.h"

@implementation FBSmoothQuadPath

- (id)initWithRecipe:(FBQuadRecipe *)recipe p1:(CGPoint)p1 p2:(CGPoint)p2 p3:(CGPoint)p3 p4:(CGPoint)p4 {
  FBQuad quad = FBQuadMake(p1, p2, p3, p4);
  return [self initWithRecipe:recipe quad:quad];
}

- (id)initWithRecipe:(FBQuadRecipe *)recipe quad:(FBQuad)quad {
  self = [super init];
  if (self) {
    _recipe = recipe;
  }
  return self;
}

- (void)renderInContext:(CGContextRef)context {
  [_topPath renderInContext:context];
  [_rightPath renderInContext:context];
  [_bottomPath renderInContext:context];
  [_leftPath renderInContext:context];
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
  [fp moveToPoint:self.topPath.p1];
  [fp addLineToPoint:self.rightPath.p1];
  [fp addLineToPoint:self.bottomPath.p1];
  [fp addLineToPoint:self.leftPath.p1];
  return fp;
}

- (void)recalculateWithP1:(CGPoint)p1 p2:(CGPoint)p2 p3:(CGPoint)p3 p4:(CGPoint)p4 {
  FBQuad quad = FBQuadMake(p1, p2, p3, p4);
  [self recalculateWithQuad:quad];
}

- (void)recalculateWithQuad:(FBQuad)quad {
  self.topPath = [[FBSmoothPath alloc] initWithRecipe:_recipe.pathRecipe1 p1:quad.upperLeft p2:quad.upperRight];
  self.rightPath = [[FBSmoothPath alloc] initWithRecipe:_recipe.pathRecipe2 p1:quad.upperRight p2:quad.lowerRight];
  self.bottomPath = [[FBSmoothPath alloc] initWithRecipe:_recipe.pathRecipe3 p1:quad.lowerRight p2:quad.lowerLeft];
  self.leftPath = [[FBSmoothPath alloc] initWithRecipe:_recipe.pathRecipe4 p1:quad.lowerLeft p2:quad.upperLeft];
}

@end
