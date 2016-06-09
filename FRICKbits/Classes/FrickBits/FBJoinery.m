//
//  FBJoinery.m
//  FrickBits
//
//  Created by Matt McGlincy on 2/25/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBJoinery.h"
#import "FBUtils.h"

#import "FBJoineryBitLayer.h"

@implementation FBJoinery

CGFloat JoineryBitAngleForBits(FBFrickBitLayer *bit1, FBFrickBitLayer *bit2) {
  // since we're square, the most we need to rotate is 45 degrees clockwise or
  // counterclockwise
  CGFloat angle = (bit1.angle + bit2.angle) / 2.0;

  // positive
  if (angle < 0) {
    angle += 360;
  }
  // between 0 and 180
  if (angle > 180) {
    angle -= 180;
  }
  // between 0 and 90
  if (angle > 90) {
    angle -= 90;
  }
  if (angle > 45) {
    angle -= 90;
  }

  // TODO: just fixing the angle at zero for now. I.e., NO ANGLE.
  // return angle;
  return 0;
}

CGLine ExtendedLineMake(CGPoint p1, CGPoint p2) {
  CGLine line = CGLineMake(p1, p2);
  // scale the line in both directions from point1
  CGLine ext1 = CGLineScale(line, 100);
  CGLine ext2 = CGLineScale(line, -100);
  // then make line between those 2 extended endpoints
  return CGLineMake(ext1.point2, ext2.point2);
}

+ (FBJoinSidePair)closestSidesBetweenJoinNode1:(CALayer<FBJoinNode> *)joinNode1
                                     joinNode2:(CALayer<FBJoinNode> *)joinNode2 {
  FBJoinSide side1;
  FBJoinSide side2;
  CGFloat minDistance = MAXFLOAT;
  for (int s1 = FBJoinSideTop; s1 <= FBJoinSideLeft; s1++) {
    for (int s2 = FBJoinSideTop; s2 <= FBJoinSideLeft; s2++) {
      
      // TODO: using convertPoint:fromLayer is giving inconsistent results for converting/comparing anchorInSelves.
      // For now, we're just relying on the joinNodes having the same immediate parent.
      
      // make sure we compare in a common coordinate system
      // CGPoint a1 = [joinNode1 anchorInSelfForSide:s1];
      // CGPoint a2 = [joinNode2 anchorInSelfForSide:s2];
      // CGPoint a2InJ1 = [joinNode1 convertPoint:a2 fromLayer:joinNode2];
      // CGFloat distance = DistanceBetweenPoints(a1, a2InJ1);
      
      CGPoint a1 = [joinNode1 anchorInParentForSide:s1];
      CGPoint a2 = [joinNode2 anchorInParentForSide:s2];
      CGFloat distance = DistanceBetweenPoints(a1, a2);
      
      if (distance < minDistance) {
        side1 = s1;
        side2 = s2;
        minDistance = distance;
      }
    }
  }
  //NSLog(@"picking side %d and %d with a distance of %f", side1, side2, minDistance);
  FBJoinSidePair pair = {side1, side2};
  return pair;
}

#pragma mark - FrickBit miter joins

+ (void)miterJoinFrickBit1:(FBFrickBitLayer *)bit1 bit2:(FBFrickBitLayer *)
    bit2 {
  [FBJoinery miterJoinFrickBit1:bit1 bit2:bit2 withAngleFilter:NULL_NUMBER];
}

+ (void)miterJoinFrickBit1:(FBFrickBitLayer *)bit1 bit2:(FBFrickBitLayer *)
    bit2 withAngleFilter:(CGFloat)radians {
  // We can't miter bits that don't have a common parent,
  // as we need to convert points between their two coordinate systems.
  // We could walk the layer hierarchy to verify this, but as a shortcut
  // check, just make sure we have *some* parent layer for each bit.
//  NSParameterAssert(bit1.superlayer && bit2.superlayer);

  // Make sure we do all our calculations in one coordinate space.
  // We arbitrarily choose bit1 for this.

  // We assume bit1 and bit2 share a common parent, and thus can
  // convertPoint: between each other.

  // Figure out the intersection between top lines and bottom lines
  // extend the line segment in both directions, so we can be assured of an
  // intersection.
  CGLine topLine1 = ExtendedLineMake(bit1.quadInSelf.upperLeft,
      bit1.quadInSelf.upperRight);
  CGLine topLine2 = ExtendedLineMake(
      [bit1 convertPoint:bit2.quadInSelf.upperLeft fromLayer:bit2],
      [bit1 convertPoint:bit2.quadInSelf.upperRight fromLayer:bit2]);
  CGLine bottomLine1 = ExtendedLineMake(bit1.quadInSelf.lowerLeft,
      bit1.quadInSelf.lowerRight);
  CGLine bottomLine2 = ExtendedLineMake(
      [bit1 convertPoint:bit2.quadInSelf.lowerLeft fromLayer:bit2],
      [bit1 convertPoint:bit2.quadInSelf.lowerRight fromLayer:bit2]);
  CGPoint topIntersection = CGLinesIntersectAtPoint(topLine1, topLine2);
  CGPoint
      bottomIntersection = CGLinesIntersectAtPoint(bottomLine1, bottomLine2);

  if (NULL_NUMBER == topIntersection.x || NULL_NUMBER == topIntersection.y ||
      NULL_NUMBER == bottomIntersection.x || NULL_NUMBER ==
      bottomIntersection.y) {
    return;
  }

  if (radians <= ((2.0 * M_PI))) {
    if ((radians > RadiansBetweenLines(topLine1, topLine2)) ||
        (radians > RadiansBetweenLines(bottomLine1, bottomLine2))) {
      // Make sure the angle isn't too acute for the filter
      return;
    }
  }

  if (FLOORF_PI(2) <= RadiansBetweenLines(topLine1, topLine2) || FLOORF_PI(2) <=
      RadiansBetweenLines(bottomLine1, bottomLine2)) {
    // Make sure the angle isn't 0º
    return;

  } else if (NAN == RadiansBetweenLines(topLine1, topLine2) || NAN ==
             RadiansBetweenLines(bottomLine1, bottomLine2)) {
    // Make sure the angle isn't a NaN
    return;
  }

  CGPoint topIntersectionInBit2 = [bit2 convertPoint:topIntersection
      fromLayer:bit1];
  CGPoint bottomIntersectionInBit2 = [bit2 convertPoint:bottomIntersection
      fromLayer:bit1];

  // Figure out which ends to join.

  CGPoint convertedBit2FromPoint = [bit1 convertPoint:bit2.fromPointInSelf
      fromLayer:bit2];
  CGPoint convertedBit2ToPoint = [bit1 convertPoint:bit2.toPointInSelf
      fromLayer:bit2];

  CGFloat pointEqualityTolerance = 0.001;
  if (CGPointEqualToPointWithTolerance(bit1.toPointInSelf, convertedBit2FromPoint,
      pointEqualityTolerance)) {
    // bit1.toPoint <==> bit2.fromPoint
    bit1.quadInSelf = FBQuadMake(bit1.quadInSelf.upperLeft, topIntersection,
        bottomIntersection, bit1.quadInSelf.lowerLeft);
    bit2.quadInSelf =
        FBQuadMake(topIntersectionInBit2,
            bit2.quadInSelf.upperRight,
            bit2.quadInSelf.lowerRight,
            bottomIntersectionInBit2);

  } else if (CGPointEqualToPointWithTolerance(bit1.fromPointInSelf,
      convertedBit2ToPoint,
        pointEqualityTolerance)) {
    // bit1.fromPoint <==> bit2.toPoint
    bit1.quadInSelf =
        FBQuadMake(topIntersection, bit1.quadInSelf.upperRight,
            bit1.quadInSelf.lowerRight, bottomIntersection);
    bit2.quadInSelf = FBQuadMake(bit2.quadInSelf.upperLeft,
        topIntersectionInBit2,
        bottomIntersectionInBit2, bit2.quadInSelf.lowerLeft);
  } else {
    NSLog(@"Can't miter-join 2 bits that lack a set of matching endpoints.");
  }

  // deal with "twists" in the quads
  bit1.quadInSelf = FBQuadMakeUntwisted(bit1.quadInSelf);
  bit2.quadInSelf = FBQuadMakeUntwisted(bit2.quadInSelf);

  [bit1 updatePaths];
  [bit2 updatePaths];

  [bit1 setNeedsDisplay];
  [bit2 setNeedsDisplay];
}

#pragma mark - SegmentedBit miter joins

+ (void)miterJoinSegmentedBit1:(FBSegmentedBitLayer *)bit1
    bit2:(FBSegmentedBitLayer *)bit2 {
  [FBJoinery miterJoinSegmentedBit1:bit1 bit2:bit2 withAngleFilter:NULL_NUMBER];
}

+ (void)miterJoinSegmentedBit1:(FBSegmentedBitLayer *)bit1
    bit2:(FBSegmentedBitLayer *)bit2
    withAngleFilter:(CGFloat)radians {

  FBFrickBitLayer *lastSegmentOfBit1 = [bit1.frickBitLayers lastObject];
  FBFrickBitLayer *firstSegmentOfBit2 = [bit2.frickBitLayers firstObject];

  [FBJoinery miterJoinFrickBit1:lastSegmentOfBit1
      bit2:firstSegmentOfBit2 withAngleFilter:radians];

  [lastSegmentOfBit1 setNeedsDisplay];
  [firstSegmentOfBit2 setNeedsDisplay];

  // make sure the segmented bits' quads enclose their possibly-modified
  // children
  [bit1 updateQuad];
  [bit2 updateQuad];

  // and update paths, in case we modified quads
  [bit1 updatePaths];
  [bit2 updatePaths];

  [bit1 setNeedsDisplay];
  [bit2 setNeedsDisplay];
}

@end
