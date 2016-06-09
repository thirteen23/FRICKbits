//
//  FBSmoothPath.m
//  FrickBits
//
//  Created by Matt McGlincy on 1/14/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBSmoothPath.h"
#import "UIBezierPath-Smoothing.h"

@implementation FBSmoothPath

- (id)initWithRecipe:(FBPathRecipe *)recipe p1:(CGPoint)p1 p2:(CGPoint)p2 {
  self = [super init];
  if (self) {
    // make initial curve points
    CGPoint cp1 = p1;
    CGPoint cp2 = CGPointMake(p1.x + (p2.x - p1.x) / 3.0,
                              p1.y + (p2.y - p1.y) / 3.0); // 1/3rd point
    CGPoint cp3 = CGPointMake(p1.x + (p2.x - p1.x) * 2.0 / 3.0,
                              p1.y + (p2.y - p1.y) * 2.0 / 3.0); // 2/3rds point
    CGPoint cp4 = p2;

    // jiggle them as per recipe
    CGPoint jp1 =
        CGPointMake(cp1.x + recipe.p1Jiggle.x, cp1.y + recipe.p1Jiggle.y);
    CGPoint jp2 =
        CGPointMake(cp2.x + recipe.p2Jiggle.x, cp2.y + recipe.p2Jiggle.y);
    CGPoint jp3 =
        CGPointMake(cp3.x + recipe.p3Jiggle.x, cp3.y + recipe.p3Jiggle.y);
    CGPoint jp4 =
        CGPointMake(cp4.x + recipe.p4Jiggle.x, cp4.y + recipe.p4Jiggle.y);

    // keep track of our original points
    _p1 = jp1;
    _p2 = jp2;
    _p3 = jp3;
    _p4 = jp4;
    
    // Hold into the color
    _strokeColor = recipe.color;
    
    // Hold onto the line width
    self.lineWidth = recipe.lineWidth;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:jp1];
    [path addLineToPoint:jp2];
    [path addLineToPoint:jp3];
    [path addLineToPoint:jp4];
    path = [path smoothedPath:(int)recipe.smoothness];
    [self appendPath:path];
  }
  return self;
}

- (void)renderInContext:(CGContextRef)context {
  CGContextAddPath(context, self.CGPath);
  CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
  CGContextSetLineWidth(context, self.lineWidth);
  CGContextDrawPath(context, kCGPathStroke);
}

@end
