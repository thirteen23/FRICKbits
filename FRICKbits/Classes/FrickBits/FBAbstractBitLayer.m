//
//  FBAbstractBitLayer.m
//  FrickBits
//
//  Created by Matt McGlincy on 3/21/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBAbstractBitLayer.h"
#import "FBJoinery.h"
#import "FBUtils.h"
#import "MTGeometry.h"
#import "CAAnimation+Blocks.h"

@implementation FBAbstractBitLayer

@dynamic centerInParent, centerInSelf;

- (id)init {
  self = [super init];
  if (self) {
    self.masksToBounds = NO;
    
#warning TODO: verify layer settings
    // TODO: experimenting with various performance-related layer settings
    //self.shouldRasterize = YES;
    //self.rasterizationScale = self.contentsScale;
    //self.drawsAsynchronously = YES;
  }
  return self;
}

- (void)forceRedraw {
  [self setNeedsDisplay];
}

static CGFloat const FBFrickBitDefaultAnimationDuration = 1.0;

- (void)animateIn {
  [self animateInWithCompletion:nil];
}

- (void)animateInWithCompletion:(void (^)(BOOL finished))completion {
//  [self animateFromToWithDuration:FBFrickBitDefaultAnimationDuration completion:completion];
  [self animateFromCenterWithDuration:FBFrickBitDefaultAnimationDuration completion:completion];
}

- (void)animateInWithDuration:(CGFloat)duration {
  [self animateInWithDuration:duration completion:nil];
}

- (void)animateInWithDuration:(CGFloat)duration
                   completion:(void (^)(BOOL finished))completion {

  [self animateFromToWithDuration:duration completion:completion];
}

- (void)animateFromToWithDuration:(CGFloat)duration {
  [self animateFromToWithDuration:duration completion:nil];
}

- (void)animateFromToWithDuration:(CGFloat)duration
                   completion:(void (^)(BOOL finished))completion {
  UIBezierPath *path = [self fromToAnimationStartingPath];
  [self animateInWithStartingPath:path
                         duration:duration
                       completion:completion];
}

- (UIBezierPath *)fromToAnimationStartingPath {
  // from-to == left-to-right
  UIBezierPath *path = [UIBezierPath bezierPath];
  CGLine upper = CGLineMake(self.quadInSelf.upperLeft, self.quadInSelf.upperRight);
  CGLine lower = CGLineMake(self.quadInSelf.lowerLeft, self.quadInSelf.lowerRight);
  if (CGLineLength(upper) > 0 && CGLineLength(lower) > 0) {
    // make a teeny-tiny quad
    CGFloat infinitiseminal = .001;
    CGPoint closerUR = CGPointAlongLine(upper, infinitiseminal);
    CGPoint closerLR = CGPointAlongLine(lower, infinitiseminal);
    [path moveToPoint:self.quadInSelf.upperLeft];
    [path addLineToPoint:closerUR];
    [path addLineToPoint:closerLR];
    [path addLineToPoint:self.quadInSelf.lowerLeft];
    [path addLineToPoint:self.quadInSelf.upperLeft];
  } else {
    // make just a line
    [path moveToPoint:self.quadInSelf.upperLeft];
    [path moveToPoint:self.quadInSelf.lowerLeft];
  }
  return path;
}

- (UIBezierPath *)toFromAnimationStartingPath {
  // to-from == right-to-left
  UIBezierPath *path = [UIBezierPath bezierPath];
  CGLine upper =
  CGLineMake(self.quadInSelf.upperRight, self.quadInSelf.upperLeft);
  CGLine lower =
  CGLineMake(self.quadInSelf.lowerRight, self.quadInSelf.lowerLeft);
  if (CGLineLength(upper) > 0 && CGLineLength(lower) > 0) {
    // make a teeny-tiny quad
    CGFloat infinitesimal = .001;
    CGPoint closerUL = CGPointAlongLine(upper, infinitesimal);
    CGPoint closerLL = CGPointAlongLine(lower, infinitesimal);
    [path moveToPoint:self.quadInSelf.upperRight];
    [path addLineToPoint:closerUL];
    [path addLineToPoint:closerLL];
    [path addLineToPoint:self.quadInSelf.lowerRight];
    [path addLineToPoint:self.quadInSelf.upperRight];
  } else {
    // make just a line
    [path moveToPoint:self.quadInSelf.upperRight];
    [path moveToPoint:self.quadInSelf.lowerRight];
  }
  return path;
}

- (void)animateToFromWithDuration:(CGFloat)duration {
  [self animateToFromWithDuration:duration completion:nil];
}

- (void)animateToFromWithDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion {
  UIBezierPath *path = [self toFromAnimationStartingPath];
  [self animateInWithStartingPath:path
                         duration:duration
                       completion:completion];
}

- (void)animateInWithStartingPath:(UIBezierPath *)path
                         duration:(CGFloat)duration
                       completion:(void (^)(BOOL finished))completion {
  CGPathRef startPath = path.CGPath;
  CGPathRef endPath = [self fillPath].CGPath;

  CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
  anim.fromValue = (__bridge id)startPath;
  anim.toValue = (__bridge id)endPath;
  anim.duration = duration;
  anim.timingFunction =
      [CAMediaTimingFunction functionWithControlPoints:0.3:0.0:0.3:1.0];
  anim.completion = completion;
  CAShapeLayer *shapeLayer = (CAShapeLayer *)self.mask;
  shapeLayer.path = endPath;

  [self.mask addAnimation:anim forKey:@"animateIn"];
}

- (void)animateFromCenterWithDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion {
  // start as a sliver bit in the center
  CGPoint midPoint = CGPointMake((self.fromPointInSelf.x + self.toPointInSelf.x) / 2.0,
                                 (self.fromPointInSelf.y + self.toPointInSelf.y) / 2.0);
  CGFloat infinitesimal = .001;
  CGLine line1 = CGLineMake(midPoint, self.fromPointInSelf);
  CGLine line2 = CGLineMake(midPoint, self.toPointInSelf);
  CGPoint p1 = CGPointAlongLine(line1, infinitesimal);
  CGPoint p2 = CGPointAlongLine(line2, infinitesimal);
  FBQuad quad = FBQuadMakeAroundPoints(p1, p2, self.recipe.thickness);
  UIBezierPath *path = FBQuadBezierPath(quad);
  
  [self animateInWithStartingPath:path duration:duration completion:completion];
}

#pragma mark - 

- (UIBezierPath *)fillPath {
  return FBQuadBezierPath(self.quadInSelf);
}

- (FBQuad)quadInParent {
  CGPoint offset = CGPointMake(self.frame.origin.x, self.frame.origin.y);
  return FBQuadOffset(_quadInSelf, offset);
}

- (CGPoint)centerInSelf {
  return CGPointMake((self.fromPointInSelf.x + self.toPointInSelf.x) / 2,
                     (self.fromPointInSelf.y + self.toPointInSelf.y) / 2);
}

- (CGPoint)centerInParent {
  return CGPointMake((self.fromPointInParent.x + self.toPointInParent.x) / 2,
                     (self.fromPointInParent.y + self.toPointInParent.y) / 2);
}

- (void)maybeJoinToJoinNode1:(CALayer<FBJoinNode> *)joinNode1 joinNode2:(CALayer<FBJoinNode> *)joinNode2 {
  if (joinNode1 && joinNode2) {
    [self endJoinToJoinNode1:joinNode1 joinNode2:joinNode2];
  } else if (joinNode1) {
    [self endJoinToJoinNode:joinNode1];
  } else if (joinNode2) {
    [self endJoinToJoinNode:joinNode2];
  }
}

- (void)endJoinToJoinNode1:(CALayer<FBJoinNode> *)joinNode1 joinNode2:(CALayer<FBJoinNode> *)joinNode2 {
  // pick the 2 closest sides between the 2 joinery bits
  FBJoinSidePair sides = [FBJoinery closestSidesBetweenJoinNode1:joinNode1 joinNode2:joinNode2];
  [self endJoinToJoinNode:joinNode1 side:sides.side1];
  [self endJoinToJoinNode:joinNode2 side:sides.side2];
}

- (FBJoinSide)sideToJoinWithJoinNode:(CALayer<FBJoinNode> *)joinNode {
  // convert our end points into joinNode's coordinate space
  CGPoint endPoint1 = [joinNode convertPoint:self.fromPointInSelf fromLayer:self];
  CGPoint endPoint2 = [joinNode convertPoint:self.toPointInSelf fromLayer:self];
  FBJoinSide side = [joinNode joinSideForEndPointInSelf1:endPoint1 endPointInSelf2:endPoint2];
  return side;
}

- (CGPoint)endPointInSelfToJoinWithJoinNode:(CALayer<FBJoinNode> *)joinNode {
  // figure out which end of the bit to join to the joinPoints
  CGPoint joinCenter = joinNode.centerInSelf;
  CGPoint centerInSelf = [self convertPoint:joinCenter fromLayer:joinNode];
  CGFloat toPointDist = DistanceBetweenPoints(self.toPointInSelf, centerInSelf);
  CGFloat fromPointDist = DistanceBetweenPoints(self.fromPointInSelf, centerInSelf);
  return (toPointDist < fromPointDist) ? self.toPointInSelf : self.fromPointInSelf;
}

- (void)endJoinToJoinNode:(CALayer<FBJoinNode> *)joinNode {  // children to override
  FBJoinSide side = [self sideToJoinWithJoinNode:joinNode];
  [self endJoinToJoinNode:joinNode side:side];
}

- (void)endJoinToJoinNode:(CALayer<FBJoinNode> *)jBit side:(FBJoinSide)side {
  // children to override
}

- (void)hide {
  // children to override
}

- (void)show {
  // children to override
}

- (CGFloat)bitWidth {
  return self.recipe.thickness * 2;
}

- (CGFloat)bitLength {
  return DistanceBetweenPoints(self.fromPointInSelf, self.toPointInSelf);
}

- (CGFloat)angle {
  return DegreesBetweenPoints(self.fromPointInSelf, self.toPointInSelf);
}

@end
