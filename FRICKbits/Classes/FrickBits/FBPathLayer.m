//
//  FBPathLayer.m
//  FrickBits
//
//  Created by Matt McGlincy on 1/17/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBPathLayer.h"
#import "FBUtils.h"

@implementation FBPathLayer

@dynamic length;

- (id)initWithRecipe:(FBPathRecipe *)recipe p1:(CGPoint)p1 p2:(CGPoint)p2 {
  self = [super init];
  if (self) {
    _p1 = p1;
    _p2 = p2;
    self.masksToBounds = NO;
    self.recipe = recipe;
    self.rasterizationScale = [[UIScreen mainScreen] scale];
    self.lineCap = kCALineCapButt;
    self.lineJoin = kCALineJoinMiter;
    self.strokeColor = recipe.color.CGColor;
    self.fillColor = [UIColor clearColor].CGColor;
    self.shadowRadius = 0.0;
    self.shadowOpacity = 0.0;
    self.shadowOffset = CGSizeMake(0, 0);
    self.lineWidth = recipe.lineWidth;
    
    [self recalculateWithP1:p1 p2:p2];
  }
  return self;
}

- (CGFloat)length {
    return DistanceBetweenPoints(self.p1, self.p2);
}

- (void)recalculateWithP1:(CGPoint)p1 p2:(CGPoint)p2 {
  _smoothPath = [[FBSmoothPath alloc] initWithRecipe:self.recipe p1:p1 p2:p2];
  self.path = _smoothPath.CGPath;
}

@end
