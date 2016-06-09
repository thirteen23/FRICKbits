//
//  FBSplitBit.m
//  FrickBits
//
//  Created by Matt McGlincy on 2/24/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBSplitBitLayer.h"
#import "FBUtils.h"

@interface FBSplitBitLayer ()
@property(nonatomic, strong) FBRecipeFactory *factory;
@end

@implementation FBSplitBitLayer

- (id)initWithFactory:(FBRecipeFactory *)factory
    fromPointInParent:(CGPoint)fromPointInParent
    toPointInParent:(CGPoint)toPointInParent {
  self = [super init];
  if (self) {
    self.factory = factory;
    self.fromPointInParent = fromPointInParent;
    self.toPointInParent = toPointInParent;

    // instead of using from/to as-is,
    // we figure out the smallest box/rect that will contain them,
    // and make our layer that big.
    // Our actual from/to will be normalized within this newly-offset rect.
    CGRect boundingBox =
        CGRectSurroundingPoints(fromPointInParent, toPointInParent);
    // expand the bounding box to allow for bit thickness
    CGFloat padding = [factory makePerfectFrickBitRecipe].thickness;
    boundingBox = CGRectInset(boundingBox, -2 * padding, -2 * padding);
    self.frame = boundingBox;

    self.fromPointInSelf = CGPointMinusPoint(self.fromPointInParent, self.frame.origin);
    self.toPointInSelf = CGPointMinusPoint(self.toPointInParent, self.frame.origin);
    self.quadInSelf = FBQuadMakeAroundPoints(self.fromPointInSelf, self.toPointInSelf, self.recipe.thickness);

    [self makeSplits];
    [self updateQuad];
    [self updatePaths];
  }
  return self;
}

- (void)setFrame:(CGRect)frame {
  [super setFrame:frame];
  self.bit1.frame = self.bounds;
  self.bit2.frame = self.bounds;
}

- (void)makeSplits {
  FBFrickBitRecipe *originalRecipe = [self.factory makePerfectFrickBitRecipe];
  FBFrickBitRecipe *splitRecipe1 = [self.factory makePerfectFrickBitRecipe];
  FBFrickBitRecipe *splitRecipe2 = [self.factory makePerfectFrickBitRecipe];

  // adjust the widths of our split recipes
  CGFloat middleSpacing = 0;
  CGFloat originalWidth = originalRecipe.thickness * 2;
  splitRecipe1.thickness = (originalWidth / 2 - middleSpacing) / 2;
  splitRecipe2.thickness = (originalWidth / 2 - middleSpacing) / 2;

  // Figure out the points for our split bits
  // To do so, we make a quad around our 2 endpoints (center and wherever), wide
  // enough to the thickness of each split.
  // Each corner of the quad will be endpoints for our 2 splitbits.
  CGFloat thickness = MAX(splitRecipe1.thickness, splitRecipe2.thickness)
          + (middleSpacing / 2);
  FBQuad quad = FBQuadMakeAroundPoints(self.fromPointInSelf, self.toPointInSelf,
      thickness);
  CGPoint b1p1 = quad.upperLeft;
  CGPoint b1p2 = quad.upperRight;
  CGPoint b2p1 = quad.lowerLeft;
  CGPoint b2p2 = quad.lowerRight;

  self.bit1 = [[FBFrickBitLayer alloc] initWithRecipe:splitRecipe1
      fromPointInParent:b1p1 toPointInParent:b1p2];
  [self addSublayer:self.bit1];

  self.bit2 = [[FBFrickBitLayer alloc] initWithRecipe:splitRecipe2
      fromPointInParent:b2p1 toPointInParent:b2p2];
  [self addSublayer:self.bit2];
}

- (void)forceRedraw {
  [super forceRedraw];
  [self.bit1 forceRedraw];
  [self.bit2 forceRedraw];
}

- (BOOL)isTwisted {
  // a split bit is "twisted" if the quads of its bits intersect.
  // we test this with a quad "center line"
  // TODO: we could add a FBQuadIntersectsQuad() method.
  CGPoint from1 =
      [self convertPoint:MidpointBetween(self.bit1.quadInSelf.upperLeft,
          self.bit1.quadInSelf.lowerLeft) fromLayer:self.bit1];
  CGPoint to1 =
      [self convertPoint:MidpointBetween(self.bit1.quadInSelf.upperRight,
          self.bit1.quadInSelf.lowerRight) fromLayer:self.bit1];
  CGPoint from2 =
      [self convertPoint:MidpointBetween(self.bit2.quadInSelf.upperLeft,
          self.bit2.quadInSelf.lowerLeft) fromLayer:self.bit2];
  CGPoint to2 =
      [self convertPoint:MidpointBetween(self.bit2.quadInSelf.upperRight,
          self.bit2.quadInSelf.lowerRight) fromLayer:self.bit2];
  return LinesIntersect(from1, to1, from2, to2);
}

- (void)untwist {
  if ([self isTwisted]) {
    // twisted, so untwist by swapping to-side quad points
    // and make sure we properly handle coordinate space conversions

    FBQuad q1 = FBQuadConvert(self.bit1.quadInSelf, self.bit1, self);
    FBQuad q2 = FBQuadConvert(self.bit2.quadInSelf, self.bit2, self);

    FBQuad newQ1 = FBQuadMake(q1.upperLeft, q2.upperRight, q2.lowerRight,
        q1.lowerLeft);
    FBQuad newQ2 = FBQuadMake(q2.upperLeft, q1.upperRight, q1.lowerRight,
        q2.lowerLeft);

    self.bit1.quadInSelf = FBQuadConvert(newQ1, self, self.bit1)
        ;
    self.bit2.quadInSelf = FBQuadConvert(newQ2, self, self.bit2);
  }
}

- (void)updateQuad {
  // make sure our quad encloses our 2 child bits

  // Because our twisting/untwisting can muck with the points,
  // choose the "outer" points to enclose the bits.
  
  FBQuad b1QuadInSelf = FBQuadConvert(self.bit1.quadInSelf, self.bit1, self);
  FBQuad b2QuadInSelf = FBQuadConvert(self.bit2.quadInSelf, self.bit2, self);
  
  CGPointPair b1Left = {b1QuadInSelf.upperLeft, b1QuadInSelf.lowerLeft};
  CGPointPair b2Left = {b2QuadInSelf.upperLeft, b2QuadInSelf.lowerLeft};
  CGPointPair b1Right = {b1QuadInSelf.upperRight, b1QuadInSelf.lowerRight};
  CGPointPair b2Right = {b2QuadInSelf.upperRight, b2QuadInSelf.lowerRight};
  
  CGPointPair leftOuter = FarthestPoints(b1Left, b2Left);
  CGPointPair rightOuter = FarthestPoints(b1Right, b2Right);

  self.quadInSelf = FBQuadMakeUntwisted(FBQuadMake(leftOuter.p1, rightOuter.p1, rightOuter.p2, leftOuter.p2));
}

- (void)updatePaths {
  [self.bit1 updatePaths];
  [self.bit2 updatePaths];
  CAShapeLayer *maskLayer = (CAShapeLayer *) self.mask;
  maskLayer.path = [self fillPath].CGPath;
}

#pragma mark - joining

- (void)endJoinToJoinNode:(CALayer<FBJoinNode> *)joinNode side:(FBJoinSide)side {
  // We can't miter bits that don't have a common parent,
  // as we need to convert points between their two coordinate systems.
  // We could walk the layer hierarchy to verify this, but as a shortcut
  // check, just make sure we have *some* parent layer for each bit.
  CGPointPair joinPoints = [joinNode joinPointsInSelfForSide:side];
  
  // do everything in the our own coordinate system
  CGPoint joinPoint1InSelf = [self convertPoint:joinPoints.p1 fromLayer:joinNode];
  CGPoint joinPoint2InSelf = [self convertPoint:joinPoints.p2 fromLayer:joinNode];
  
  // when joining splitbits, we move the outer point of the child split bits
  // to match the joinery bit, but keep the splitbit thickness the same.
  //
  // e.g.,
  // >>>>>+-----+
  // >>>>>|     |
  //      |     |
  // >>>>>|     |
  // >>>>>+-----+
  //
  
  // adjust interior point. Keep original split thickness if we can.
  CGFloat joinSideLength = DistanceBetweenPoints(joinPoint1InSelf, joinPoint2InSelf);
  CGFloat bit1Width = MIN(self.bit1.recipe.thickness * 2, joinSideLength / 2.0);
  CGFloat bit2Width = MIN(self.bit2.recipe.thickness * 2, joinSideLength / 2.0);
  
  CGPoint joinPoint1InBit1 = [self.bit1 convertPoint:joinPoint1InSelf fromLayer:self];
  CGPoint interiorPoint1InSelf = CGPointAlongLine(CGLineMake(joinPoint1InSelf, joinPoint2InSelf), bit1Width);
  CGPoint interiorPoint1InBit1 = [self.bit1 convertPoint:interiorPoint1InSelf fromLayer:self];

  CGPoint joinPoint2InBit2 = [self.bit2 convertPoint:joinPoint2InSelf fromLayer:self];
  CGPoint interiorPoint2InSelf = CGPointAlongLine(CGLineMake(joinPoint2InSelf, joinPoint1InSelf), bit2Width);
  CGPoint interiorPoint2InBit2 = [self.bit2 convertPoint:interiorPoint2InSelf fromLayer:self];
  
  // figure out which end of the bit to join to the joinPoints
  CGPoint endPointInSelf = [self endPointInSelfToJoinWithJoinNode:joinNode];
  if (CGPointEqualToPoint(endPointInSelf, self.toPointInSelf)) {
    // change toPoint (right) vertices
    self.bit1.quadInSelf = FBQuadMake(self.bit1.quadInSelf.upperLeft, interiorPoint1InBit1,
                                      joinPoint1InBit1, self.bit1.quadInSelf.lowerLeft);
    self.bit2.quadInSelf = FBQuadMake(self.bit2.quadInSelf.upperLeft, interiorPoint2InBit2,
                                      joinPoint2InBit2, self.bit2.quadInSelf.lowerLeft);
  } else {
    // change fromPoint (left) vertices
    self.bit1.quadInSelf = FBQuadMake(joinPoint1InBit1, self.bit1.quadInSelf.upperRight,
                                      self.bit1.quadInSelf.lowerRight, interiorPoint1InBit1);
    self.bit2.quadInSelf = FBQuadMake(interiorPoint2InBit2, self.bit2.quadInSelf.upperRight,
                                      self.bit2.quadInSelf.lowerRight, joinPoint2InBit2);
  }

  // deal with any crossing of bit1 and bit2
  [self untwist];
  
  // Resolve any internal twisting of each individual sub-bit
  // This could occur because of our joining, or because of our untwisting
  // (thus it's important to untwist each bit *after* the call to [self untwist]).
  self.bit1.quadInSelf = FBQuadMakeUntwisted(self.bit1.quadInSelf);
  self.bit2.quadInSelf = FBQuadMakeUntwisted(self.bit2.quadInSelf);
  
  [self updateQuad];
  [self updatePaths];
}

- (void)hide {
  [self.bit1 hide];
  [self.bit2 hide];
}

- (void)show {
  [self.bit1 show];
  [self.bit2 show];
}

@end
