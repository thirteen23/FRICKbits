//
//  FBJoineryBitLayer.m
//  FrickBits
//
//  Created by Matt McGlincy on 2/25/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "CAAnimation+Blocks.h"
#import "FBJoineryBitLayer.h"
#import "FBUtils.h"

@interface FBJoineryBitLayer ()
@property(nonatomic) CGFloat radius;
@end

@implementation FBJoineryBitLayer

- (id)initWithFactory:(FBRecipeFactory *)factory centerInParent:(CGPoint)centerInParent {
  // make a square-looking bit (length = width)
  CGFloat bitLength = [factory makePerfectFrickBitRecipe].thickness * 2.0;
  // start with our points below/above the origin
  CGPoint fromPoint = CGPointMake(centerInParent.x, centerInParent.y - bitLength / 2.0);
  CGPoint toPoint = CGPointMake(centerInParent.x, centerInParent.y + bitLength / 2.0);
  return [self initWithFactory:factory fromPointInParent:fromPoint toPointInParent:toPoint];
}

- (id)initWithFactory:(FBRecipeFactory *)factory
    fromPointInParent:(CGPoint)fromPointInParent
    toPointInParent:(CGPoint)toPointInParent {
  NSUInteger numberOfSegments = arc4random_uniform(5) + 1;  // 1 - 5
  self = [super initWithFactory:factory fromPointInParent:fromPointInParent
      toPointInParent:toPointInParent numberOfSegments:numberOfSegments restrictEndBitSizes:NO];
  if (self) {
    _radius = DistanceBetweenPoints(fromPointInParent, toPointInParent) / 2.0;
  }
  return self;
}

- (void)animateIn {
  [self animateFromDotToBits];
}

- (CGFloat)animationInDuration {
  // grow dot + shrink dot + grow mask
  // .170 + .170 + .170
  return .510;
}

/* >>>
- (FBJoinSide)joinSideForEndPointInParent1:(CGPoint)p1
    endPointInParent2:(CGPoint)p2 {
  // use whichever point is NOT inside our quad.
  // TODO: this assumes one or the other is inside
  CGRect jBitRect = FBQuadBoundingRect(self.quadInParent);
  CGPoint whichPoint = CGRectContainsPoint(jBitRect, p1) ? p2 : p1;
  return [self joinSideForPointInParent:whichPoint];
}
<<< */

- (FBJoinSide)joinSideForEndPointInSelf1:(CGPoint)p1
    endPointInSelf2:(CGPoint)p2 {
  // use whichever point is NOT inside our quad.
  // TODO: this assumes one or the other is inside
  CGRect jBitRect = FBQuadBoundingRect(self.quadInSelf);
  CGPoint whichPoint = CGRectContainsPoint(jBitRect, p1) ? p2 : p1;
  return [self joinSideForPointInSelf:whichPoint];
}

/* >>>
- (FBJoinSide)joinSideForPointInParent:(CGPoint)point {
  CGFloat angle = DegreesBetweenPoints(self.centerInParent, point);

  // adjust our directional-test by our rotation
  // (positive angle is counterclockwise in iOS)
  angle -= self.rotationDegrees;

  if (angle < 0) {
    angle += 360;
  }

  // for "vertical" bit
  if (angle < 45) {
    return FBJoinSideTop;
  } else if (angle < 135) {
    return FBJoinSideRight;
  } else if (angle < 225) {
    return FBJoinSideBottom;
  } else if (angle < 315) {
    return FBJoinSideLeft;
  } else {
    return FBJoinSideTop;
  }
}
 <<< */

- (FBJoinSide)joinSideForPointInSelf:(CGPoint)point {
  CGFloat angle = DegreesBetweenPoints(self.centerInSelf, point);

  // adjust our directional-test by our rotation
  // (positive angle is counterclockwise in iOS)
  angle -= self.rotationDegrees;

  if (angle < 0) {
    angle += 360;
  }

  // for "vertical" bit.
  // Joinery bits are drawn vertically (bottom to top) so segments look the way we want (horizontal).
  // This also means the side-to-join-to is offset to 90 degrees... so, the northern side is actually the bit's
  // right (UR-LR).
  if (angle < 45) {
    return FBJoinSideTop;
  } else if (angle < 135) {
    return FBJoinSideRight;
  } else if (angle < 225) {
    return FBJoinSideBottom;
  } else if (angle < 315) {
    return FBJoinSideLeft;
  } else {
    return FBJoinSideTop;
  }

  // TODO: cleanup / comment / nuke the commented-out code
  
//  if (angle < 45) {
//    return FBJoinSideRight;
//  } else if (angle < 135) {
//    return FBJoinSideTop;
//  } else if (angle < 225) {
//    return FBJoinSideLeft;
//  } else if (angle < 315) {
//    return FBJoinSideBottom;
//  } else {
//    return FBJoinSideRight;
//  }

  // for "horizontal" bit
  /* >>>
   // this is the angle 0-360 FROM the bit TO the joinery bit,
   // so decide what side of the joinery bit it should join to
   if (angle < 45) {
   return FBJoinSideRight;
   } else if (angle < 135) {
   // in iOS coordinates, positive y is down, so switch top/bottom
   // return FBJoinSideTop;
   return FBJoinSideBottom;
   } else if (angle < 225) {
   return FBJoinSideLeft;
   } else if (angle < 315) {
   // in iOS coordinates, positive y is down, so switch top/bottom
   // return FBJoinSideBottom;
   return FBJoinSideTop;
   } else {
   return FBJoinSideRight;
   }
   <<< */
}

- (CGPoint)closestAnchorToPointInParent:(CGPoint)point {
  CGPoint anchor = CGPointZero;
  CGFloat minDistance = MAXFLOAT;

  CGFloat topDistance = DistanceBetweenPoints(point, self.topAnchorInParent);
  if (topDistance < minDistance) {
    anchor = self.topAnchorInParent;
    minDistance = topDistance;
  }

  CGFloat
      rightDistance = DistanceBetweenPoints(point, self.rightAnchorInParent);
  if (rightDistance < minDistance) {
    anchor = self.rightAnchorInParent;
    minDistance = rightDistance;
  }

  CGFloat
      bottomDistance = DistanceBetweenPoints(point, self.bottomAnchorInParent);
  if (bottomDistance < minDistance) {
    anchor = self.bottomAnchorInParent;
    minDistance = bottomDistance;
  }

  CGFloat leftDistance = DistanceBetweenPoints(point, self.leftAnchorInParent);
  if (leftDistance < minDistance) {
    anchor = self.leftAnchorInParent;
  }

  return anchor;
}

- (FBJoinSide)closestSideToPointInParent:(CGPoint)point {
  FBJoinSide side = FBJoinSideTop;
  CGFloat minDistance = MAXFLOAT;

  CGFloat topDistance = DistanceBetweenPoints(point, self.topAnchorInParent);
  if (topDistance < minDistance) {
    side = FBJoinSideTop;
    minDistance = topDistance;
  }

  CGFloat
      rightDistance = DistanceBetweenPoints(point, self.rightAnchorInParent);
  if (rightDistance < minDistance) {
    side = FBJoinSideRight;
    minDistance = rightDistance;
  }

  CGFloat
      bottomDistance = DistanceBetweenPoints(point, self.bottomAnchorInParent);
  if (bottomDistance < minDistance) {
    side = FBJoinSideBottom;
    minDistance = bottomDistance;
  }

  CGFloat leftDistance = DistanceBetweenPoints(point, self.leftAnchorInParent);
  if (leftDistance < minDistance) {
    side = FBJoinSideLeft;
  }

  return side;
}

/* >>>
- (CGPoint)centerRotatedPoint:(CGPoint)p {
  CGPoint center = [self center];
  // translate to origin
  p = CGPointMake(p.x - center.x, p.y - center.y);
  // rotate
  p = CGPointApplyAffineTransform(
      p,
      CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(self.rotationDegrees)));
  // translate back
  p = CGPointMake(p.x + center.x, p.y + center.y);
  return p;
}
 <<< */

- (CGPoint)anchorInParentForSide:(FBJoinSide)side {
  switch (side) {
    case FBJoinSideTop:
      return self.topAnchorInParent;
    case FBJoinSideRight:
      return self.rightAnchorInParent;
    case FBJoinSideBottom:
      return self.bottomAnchorInParent;
    case FBJoinSideLeft:
    default:
      return self.leftAnchorInParent;
  }
}

- (CGPoint)anchorInSelfForSide:(FBJoinSide)side {
  switch (side) {
    case FBJoinSideTop:
      return self.topAnchorInSelf;
    case FBJoinSideRight:
      return self.rightAnchorInSelf;
    case FBJoinSideBottom:
      return self.bottomAnchorInSelf;
    case FBJoinSideLeft:
    default:
      return self.leftAnchorInSelf;
  }
}

- (CGPoint)topAnchorInParent {
  return MidpointBetween(self.quadInParent.upperLeft,
      self.quadInParent.upperRight);
}

- (CGPoint)rightAnchorInParent {
  return MidpointBetween(self.quadInParent.upperRight,
      self.quadInParent.lowerRight);
}

- (CGPoint)bottomAnchorInParent {
  return MidpointBetween(self.quadInParent.lowerLeft,
      self.quadInParent.lowerRight);
}

- (CGPoint)leftAnchorInParent {
  return MidpointBetween(self.quadInParent.upperLeft,
      self.quadInParent.lowerLeft);
}

- (CGPoint)topAnchorInSelf {
  return MidpointBetween(self.quadInSelf.upperLeft,
      self.quadInSelf.upperRight);
}

- (CGPoint)rightAnchorInSelf {
  return MidpointBetween(self.quadInSelf.upperRight,
      self.quadInSelf.lowerRight);
}

- (CGPoint)bottomAnchorInSelf {
  return MidpointBetween(self.quadInSelf.lowerLeft,
      self.quadInSelf.lowerRight);
}

- (CGPoint)leftAnchorInSelf {
  return MidpointBetween(self.quadInSelf.upperLeft,
      self.quadInSelf.lowerLeft);
}

- (CGPointPair)joinPointsInParentForSide:(FBJoinSide)side {
  CGPoint jp1;
  CGPoint jp2;

  switch (side) {
    case FBJoinSideTop:
      jp1 = self.quadInParent.upperLeft;
      jp2 = self.quadInParent.upperRight;
      break;
    case FBJoinSideRight:
      jp1 = self.quadInParent.upperRight;
      jp2 = self.quadInParent.lowerRight;
      break;
    case FBJoinSideBottom:
      jp1 = self.quadInParent.lowerLeft;
      jp2 = self.quadInParent.lowerRight;
      break;
    case FBJoinSideLeft:
      jp1 = self.quadInParent.upperLeft;
      jp2 = self.quadInParent.lowerLeft;
      break;
  }

  CGPointPair pair = {jp1, jp2};
  return pair;
}

- (CGPointPair)joinPointsInSelfForSide:(FBJoinSide)side {
  CGPoint jp1;
  CGPoint jp2;

  switch (side) {
    case FBJoinSideTop:
      jp1 = self.quadInSelf.upperLeft;
      jp2 = self.quadInSelf.upperRight;
      break;
    case FBJoinSideRight:
      jp1 = self.quadInSelf.upperRight;
      jp2 = self.quadInSelf.lowerRight;
      break;
    case FBJoinSideBottom:
      jp1 = self.quadInSelf.lowerLeft;
      jp2 = self.quadInSelf.lowerRight;
      break;
    case FBJoinSideLeft:
      jp1 = self.quadInSelf.upperLeft;
      jp2 = self.quadInSelf.lowerLeft;
      break;
  }

  CGPointPair pair = {jp1, jp2};
  return pair;
}

#pragma mark - dot

- (void)showDotOnly {
  for (FBFrickBitLayer *layer in self.frickBitLayers) {
    layer.hidden = YES;
  }
  
  self.dotLayer = [CAShapeLayer layer];
  FBFrickBitLayer *firstBit = [self.frickBitLayers firstObject];
  self.dotLayer.fillColor = firstBit.recipe.fillColor.CGColor;
  self.dotLayer.path = [self dotPath];
  [self addSublayer:self.dotLayer];
  
  CAShapeLayer *maskLayer = (CAShapeLayer *)self.mask;
  maskLayer.path = [self fillPath].CGPath;
}

- (CGRect)dotRect {
  return CGRectMake(self.centerInSelf.x - FBDotRadius,
                    self.centerInSelf.y - FBDotRadius, FBDotRadius * 2,
                    FBDotRadius * 2);
}

- (CGPathRef)dotPath {
  return [UIBezierPath bezierPathWithOvalInRect:[self dotRect]].CGPath;
}

- (CGPathRef)smallerDotPath {
  CGRect dotRect = [self dotRect];
  CGRect smallerDotRect =
  CGRectInset(dotRect, dotRect.size.width / 2.0, dotRect.size.height / 2.0);
  return [UIBezierPath bezierPathWithOvalInRect:smallerDotRect].CGPath;
}

- (CGPathRef)biggerDotPath {
  CGRect biggerDotRect = CGRectInset([self dotRect], -2.0, -2.0);
  return [UIBezierPath bezierPathWithOvalInRect:biggerDotRect].CGPath;
}

#pragma mark - animation

static CGFloat const FBJoineryBitDotGrowDuration = 0.170f;
static CGFloat const FBJoineryBitDotShrinkDuration = 0.170f;
static CGFloat const FBJoineryBitMaskGrowDuration = 0.170f;
static CGFloat const FBJoineryBitMaskShrinkDuration = 0.170f;

- (void)animateFromDotToBitsWithCompletion:(void (^)(BOOL finished))completion {
  // 1. start as dot
  // 2. dot grows from 100% to to 120% scale
  // 3. dot shrinks to 0% scale
  // 4. joinery bit grows from 0% to 100% scale
  
  // hide all frickbit layers, so we see only our dot
  for (FBAbstractBitLayer *bitLayer in self.frickBitLayers) {
    bitLayer.hidden = YES;
  }
  
  // don't need a mask yet
  self.mask = nil;
  
  // use a weak reference since we're adding an animation to a child layer we own, and the animation
  // has a reference back to us.
  __weak FBJoineryBitLayer *weakSelf = self;
  
  CGPathRef smallerDot = [self smallerDotPath];
  CGPathRef regularDot = [self dotPath];
  CGPathRef biggerDot = [self biggerDotPath];
  
  CABasicAnimation *dotGrowAnim =
  [self dotAnimationFromPath:regularDot
                      toPath:biggerDot
                    duration:FBJoineryBitDotGrowDuration];
  CABasicAnimation *maskGrowAnim = [self maskGrowAnimation];
  CABasicAnimation *dotShrinkAnim =
  [self dotAnimationFromPath:biggerDot
                      toPath:smallerDot
                    duration:FBJoineryBitDotShrinkDuration];
  
  dotGrowAnim.completion = ^(BOOL finished) {
    // keep the bigger overgrown dot
    weakSelf.dotLayer.path = [weakSelf biggerDotPath];
    [weakSelf.dotLayer addAnimation:dotShrinkAnim forKey:@"dotShrinkAnim"];
  };
  
  dotShrinkAnim.completion = ^(BOOL finished) {
    // done with the dot layer
    [weakSelf.dotLayer removeFromSuperlayer];
    weakSelf.dotLayer = nil;
    
    if (!self.mask) {
      // start our mask as a tiny point
      CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
      CGRect rect = CGRectMake(weakSelf.centerInSelf.x, weakSelf.centerInSelf.y, 1.0, 1.0);
      CGPathRef path = [UIBezierPath bezierPathWithOvalInRect:rect].CGPath;
      shapeLayer.path = path;
      weakSelf.mask = shapeLayer;
    }
    
    // unhide bits
    for (FBAbstractBitLayer *bitLayer in weakSelf.frickBitLayers) {
      bitLayer.hidden = NO;
    }
    
    // expand our mask
    [weakSelf.mask addAnimation:maskGrowAnim forKey:@"maskGrowAnim"];
  };
  
  maskGrowAnim.completion = ^(BOOL finished) {
    // reset paths so we keep our full size/mask
    [self updatePaths];
    
    // call client back
    if (completion) {
      completion(YES);
    }
  };
  
  // start the animation chain
  [self.dotLayer addAnimation:dotGrowAnim forKey:@"dotGrowAnim"];
}

- (void)animateFromDotToBits {
  [self animateFromDotToBitsWithCompletion:nil];
}

- (void)animateFromBitsToDotWithCompletion:(void (^)(BOOL finished))completion {
  // 1. start as bits
  // 2. bits shrink to 0% scale
  // 3. dot grows from 0% to 120% scale
  // 4. dot shrinks to 100% scale
  
  // make sure everything begins the way we need it
  if (!self.mask) {
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    self.mask = shapeLayer;
  }
  CAShapeLayer *maskLayer = (CAShapeLayer *)self.mask;
  maskLayer.path = [self fillPath].CGPath;
  
  for (FBAbstractBitLayer *bitLayer in self.frickBitLayers) {
    bitLayer.hidden = NO;
  }
  
  if (!self.dotLayer) {
    self.dotLayer = [CAShapeLayer layer];
    FBFrickBitLayer *firstBit = [self.frickBitLayers firstObject];
    self.dotLayer.fillColor = firstBit.recipe.fillColor.CGColor;
    [self addSublayer:self.dotLayer];
  }
  self.dotLayer.path = [self smallerDotPath];
  self.dotLayer.hidden = YES;
  
  // create our animations
  CGPathRef smallerDot = [self smallerDotPath];
  CGPathRef regularDot = [self dotPath];
  CGPathRef biggerDot = [self biggerDotPath];
  CABasicAnimation *maskShrinkAnim = [self maskShrinkAnimation];
  CABasicAnimation *dotGrowAnim =
  [self dotAnimationFromPath:smallerDot
                      toPath:biggerDot
                    duration:FBJoineryBitDotGrowDuration];
  CABasicAnimation *dotShrinkAnim =
  [self dotAnimationFromPath:biggerDot
                      toPath:regularDot
                    duration:FBJoineryBitDotShrinkDuration];
  
  // set up the animation chain
  
  // use a weak reference since we're adding an animation to a child layer we own, and the animation
  // has a reference back to us.
  __weak FBJoineryBitLayer *weakSelf = self;
  
  maskShrinkAnim.completion = ^(BOOL finished) {
    // hide bits
    for (FBAbstractBitLayer *bitLayer in weakSelf.frickBitLayers) {
      bitLayer.hidden = YES;
    }
    
    // make our mask big enough to show the entire bigger dot
    CAShapeLayer *maskLayer = (CAShapeLayer *)weakSelf.mask;
    maskLayer.path = [weakSelf biggerDotPath];
    
    // show&grow the dot
    weakSelf.dotLayer.hidden = NO;
    [weakSelf.dotLayer addAnimation:dotGrowAnim forKey:@"dotGrowAnim"];
  };
  
  dotGrowAnim.completion = ^(BOOL finished) {
    [weakSelf.dotLayer addAnimation:dotShrinkAnim forKey:@"dotShrinkAnim"];
  };
  
  dotShrinkAnim.completion = ^(BOOL finished) {
    weakSelf.dotLayer.path = regularDot;
    
    // call client back
    if (completion) {
      completion(YES);
    }
  };
  
  // start the animation chain
  [self.mask addAnimation:maskShrinkAnim forKey:@"maskShrinkAnim"];
}

- (void)animateFromBitsToDot {
  [self animateFromBitsToDotWithCompletion:nil];
}

#pragma mark - animations

- (CABasicAnimation *)dotAnimationFromPath:(CGPathRef)fromPath
                                    toPath:(CGPathRef)toPath
                                  duration:(CGFloat)duration {
  CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
  anim.fromValue = (__bridge id)fromPath;
  anim.toValue = (__bridge id)toPath;
  anim.duration = duration;
  return anim;
}

- (CABasicAnimation *)maskGrowAnimation {
  CAShapeLayer *maskLayer = (CAShapeLayer *)self.mask;
  CGPoint center = self.centerInSelf;
  CGRect startRect = CGRectMake(center.x, center.y, 1.0, 1.0);
  CGPathRef startPath =
  [UIBezierPath bezierPathWithOvalInRect:startRect].CGPath;
  CGPathRef endPath = [self fillPath].CGPath;
  
  CABasicAnimation *maskAnim = [CABasicAnimation animationWithKeyPath:@"path"];
  maskAnim.fromValue = (__bridge id)startPath;
  maskAnim.toValue = (__bridge id)endPath;
  maskAnim.duration = FBJoineryBitMaskGrowDuration;
  maskAnim.timingFunction =
  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
  maskLayer.path = endPath;
  
  return maskAnim;
}

- (CGPathRef)shrunkMaskPath {
  CGPoint center = self.centerInSelf;
  CGRect endRect = CGRectMake(center.x, center.y, 1.0, 1.0);
  return [UIBezierPath bezierPathWithOvalInRect:endRect].CGPath;
}

- (CABasicAnimation *)maskShrinkAnimation {
  CAShapeLayer *maskLayer = (CAShapeLayer *)self.mask;
  CGPathRef startPath = [self fillPath].CGPath;
  CGPathRef endPath = [self shrunkMaskPath];
  
  CABasicAnimation *maskAnim = [CABasicAnimation animationWithKeyPath:@"path"];
  maskAnim.fromValue = (__bridge id)startPath;
  maskAnim.toValue = (__bridge id)endPath;
  maskAnim.duration = FBJoineryBitMaskShrinkDuration;
  maskAnim.timingFunction =
  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
  maskLayer.path = endPath;
  
  return maskAnim;
}

@end
