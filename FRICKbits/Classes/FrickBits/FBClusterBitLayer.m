//
//  FBClusterBitLayer.m
//  FRICKbits
//
//  Created by Matt McGlincy on 5/30/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBClusterBitLayer.h"
#import "FBUtils.h"

@interface FBClusterBitLayer()
@property(nonatomic) FBClusterSize clusterSize;
@property(nonatomic) FBClusterDensity clusterDensity;
@property(nonatomic) CGFloat radius;
@property(nonatomic) CGPoint centerInSelf;
@property(nonatomic) CGPoint centerInParent;
@end

@implementation FBClusterBitLayer

+ (CGFloat)radiusWithClusterSize:(FBClusterSize)clusterSize {
  switch (clusterSize) {
    case FBClusterSizeExtraSmall:
      // 14
      return 7;
    case FBClusterSizeSmall:
      // 7-14-7
      return 14;
    case FBClusterSizeMedium:
      // 14-14-14
      return 21;
      // 7-14-14-14-7
    case FBClusterSizeLarge:
      return 28;
  }
}

+ (FBClusterSize)clusterSizeWithRadius:(CGFloat)radius {
  if (radius <= 7) {
    return FBClusterSizeExtraSmall;
  }
  if (radius <= 14) {
    return FBClusterSizeSmall;
  }
  if (radius <= 21) {
    return FBClusterSizeMedium;
  }
  return FBClusterSizeLarge;
}

+ (FBClusterSize)downgradedClusterSize:(FBClusterSize)clusterSize overlap:(CGFloat)overlap {
  if (overlap <= 0) {
    // no overlap
    return clusterSize;
  }
  
  // each size "step" is 7px different.
  // minimum 1 step
  NSUInteger downgradeSteps = (NSUInteger)ceilf(overlap / 7.0);
  
  // can't downgrade past smallest size
  downgradeSteps = MIN(clusterSize, downgradeSteps);
  
  return clusterSize - downgradeSteps;
}

+ (CGFloatPair)topSegmentRangeForSize:(FBClusterSize)size density:(FBClusterDensity)density {
  if (size == FBClusterSizeSmall && density == FBClusterDensityLow) {
    return CGFloatPairMake(0.4, 1.0);
  } else if (size == FBClusterSizeSmall && density == FBClusterDensityMedium) {
    return CGFloatPairMake(0.3, 1.0);
  } else if (size == FBClusterSizeSmall && density == FBClusterDensityHigh) {
    return CGFloatPairMake(0.2, 1.0);
  } else if (size == FBClusterSizeMedium && density == FBClusterDensityLow) {
    return CGFloatPairMake(0.3, 0.6);
  } else if (size == FBClusterSizeMedium && density == FBClusterDensityMedium) {
    return CGFloatPairMake(0.2, 0.6);
  } else if (size == FBClusterSizeMedium && density == FBClusterDensityHigh) {
    return CGFloatPairMake(0.1, 0.6);
  } else if (size == FBClusterSizeLarge && density == FBClusterDensityLow) {
    return CGFloatPairMake(0.2, 0.4);
  } else if (size == FBClusterSizeLarge && density == FBClusterDensityMedium) {
    return CGFloatPairMake(0.2, 0.3);
  } else if (size == FBClusterSizeLarge && density == FBClusterDensityHigh) {
    return CGFloatPairMake(0.1, 0.2);
  }
  
  return CGFloatPairMake(0.1, 0.4);
}

+ (CGFloatPair)sideSegmentRangeForSize:(FBClusterSize)size density:(FBClusterDensity)density skinny:(BOOL)skinny {
  if (skinny) {
    if (size == FBClusterSizeSmall && density == FBClusterDensityLow) {
      return CGFloatPairMake(0.4, 1.0);
    } else if (size == FBClusterSizeSmall && density == FBClusterDensityMedium) {
      return CGFloatPairMake(0.3, 1.0);
    } else if (size == FBClusterSizeSmall && density == FBClusterDensityHigh) {
      return CGFloatPairMake(0.2, 0.9);
    } else if (size == FBClusterSizeMedium && density == FBClusterDensityLow) {
      return CGFloatPairMake(0.3, 0.6);
    } else if (size == FBClusterSizeMedium && density == FBClusterDensityMedium) {
      return CGFloatPairMake(0.2, 0.6);
    } else if (size == FBClusterSizeMedium && density == FBClusterDensityHigh) {
      return CGFloatPairMake(0.1, 0.6);
    } else if (size == FBClusterSizeLarge && density == FBClusterDensityLow) {
      return CGFloatPairMake(0.3, 0.4);
    } else if (size == FBClusterSizeLarge && density == FBClusterDensityMedium) {
      return CGFloatPairMake(0.2, 0.4);
    } else if (size == FBClusterSizeLarge && density == FBClusterDensityHigh) {
      return CGFloatPairMake(0.1, 0.3);
    }
  } else {
    if (size == FBClusterSizeSmall && density == FBClusterDensityLow) {
      return CGFloatPairMake(0.4, 0.9);
    } else if (size == FBClusterSizeSmall && density == FBClusterDensityMedium) {
      return CGFloatPairMake(0.3, 0.9);
    } else if (size == FBClusterSizeSmall && density == FBClusterDensityHigh) {
      return CGFloatPairMake(0.2, 0.9);
    } else if (size == FBClusterSizeMedium && density == FBClusterDensityLow) {
      return CGFloatPairMake(0.2, 0.6);
    } else if (size == FBClusterSizeMedium && density == FBClusterDensityMedium) {
      return CGFloatPairMake(0.1, 0.5);
    } else if (size == FBClusterSizeMedium && density == FBClusterDensityHigh) {
      return CGFloatPairMake(0.1, 0.3);
    } else if (size == FBClusterSizeLarge && density == FBClusterDensityLow) {
      return CGFloatPairMake(0.2, 0.3);
    } else if (size == FBClusterSizeLarge && density == FBClusterDensityMedium) {
      return CGFloatPairMake(0.1, 0.3);
    } else if (size == FBClusterSizeLarge && density == FBClusterDensityHigh) {
      return CGFloatPairMake(0.05, 0.2);
    }
  }
  
  return CGFloatPairMake(0.1, 0.4);
}

- (id)initWithFactory:(FBRecipeFactory *)factory
       centerInParent:(CGPoint)point
          clusterSize:(FBClusterSize)clusterSize
       clusterDensity:(FBClusterDensity)clusterDensity {

  self = [super init];
  if (self) {

    _clusterSize = clusterSize;
    _clusterDensity = clusterDensity;
    _radius = [FBClusterBitLayer radiusWithClusterSize:clusterSize];

    // square around the center
    self.frame = CGRectMake(point.x - _radius, point.y - _radius, _radius * 2, _radius * 2);

    self.leftSideBits = [NSMutableArray array];
    self.rightSideBits = [NSMutableArray array];
    
    _centerInParent = point;
    _centerInSelf = [self convertPointFromParentToSelf:_centerInParent];
    
    // joinery bit at our center
    CGFloat joineryBitThickness = [factory makePerfectFrickBitRecipe].thickness;
    CGPoint joineryFromPoint = CGPointMake(_centerInSelf.x, _centerInSelf.y - joineryBitThickness);
    CGPoint joineryToPoint = CGPointMake(_centerInSelf.x, _centerInSelf.y + joineryBitThickness);
    self.joineryBit = [[FBJoineryBitLayer alloc] initWithFactory:factory
                                               fromPointInParent:joineryFromPoint
                                                 toPointInParent:joineryToPoint];
    [self addSublayer:self.joineryBit];

    CGPoint top = CGPointMake(_centerInSelf.x, _centerInSelf.y - _radius);
    CGFloatPair topRange = [FBClusterBitLayer topSegmentRangeForSize:self.clusterSize density:self.clusterDensity];
    self.topBit = [[FBSegmentedBitLayer alloc] initWithFactory:factory
                                             fromPointInParent:joineryFromPoint
                                               toPointInParent:top
                                                     fractions:SplitOneIntoRandomFractions(topRange.f1, topRange.f2)
                                                        skinny:NO];
    [self addSublayer:self.topBit];

    CGPoint bottom = CGPointMake(_centerInSelf.x, _centerInSelf.y + _radius);
    CGFloatPair bottomRange = [FBClusterBitLayer topSegmentRangeForSize:self.clusterSize density:self.clusterDensity];
    self.bottomBit = [[FBSegmentedBitLayer alloc] initWithFactory:factory
                                                fromPointInParent:joineryToPoint
                                                  toPointInParent:bottom
                                                        fractions:SplitOneIntoRandomFractions(bottomRange.f1, bottomRange.f2)
                                                           skinny:NO];
    [self addSublayer:self.bottomBit];

    [self addSideBitsWithFactory:factory density:clusterDensity];
  }
  return self;
}

- (void)addSideBitsWithFactory:(FBRecipeFactory *)factory density:(FBClusterDensity)density {
  CGFloat fullBitThickness = [factory makePerfectFrickBitRecipe].thickness;
  CGFloat skinnyBitThickness = fullBitThickness / 2.0;
  CGFloat xOffset = fullBitThickness;
  CGFloat yIncrement = 5.0;
  CGFloat yOffset = _radius - yIncrement;
  while (xOffset < _radius) {
    CGFloat spaceLeft = _radius - xOffset;
    if (spaceLeft >= skinnyBitThickness * 2) {
      // there's room for another bit column on the left/right
      BOOL skinny;
      CGFloat bitThickness;
      CGFloat minFraction;
      CGFloat maxFraction;
      if (spaceLeft >= fullBitThickness * 2) {
        // room for a full-thickness bit
        skinny = NO;
        bitThickness = fullBitThickness;
        minFraction = 0.1;
        maxFraction = 0.4;
      } else {
        // only room for a skinny bit
        skinny = YES;
        bitThickness = skinnyBitThickness;
        // skinny bits are less segmented
        minFraction = 0.1;
        maxFraction = 1.0;
      }
      
      xOffset += bitThickness;
      CGPoint rightColTop = CGPointMake(_centerInSelf.x + xOffset, _centerInSelf.y - yOffset);
      CGPoint rightColBottom = CGPointMake(_centerInSelf.x + xOffset, _centerInSelf.y + yOffset);
      CGPoint leftColTop = CGPointMake(_centerInSelf.x - xOffset, _centerInSelf.y - yOffset);
      CGPoint leftColBottom = CGPointMake(_centerInSelf.x - xOffset, _centerInSelf.y + yOffset);
      CGFloatPair rightRange = [FBClusterBitLayer sideSegmentRangeForSize:self.clusterSize density:self.clusterDensity skinny:skinny];
      FBSegmentedBitLayer *rightBit = [[FBSegmentedBitLayer alloc] initWithFactory:factory
                                                                 fromPointInParent:rightColTop
                                                                   toPointInParent:rightColBottom
                                                                         fractions:SplitOneIntoRandomFractions(rightRange.f1, rightRange.f2)
                                                                            skinny:skinny];
      [self addSublayer:rightBit];
      [self.rightSideBits addObject:rightBit];
        
      CGFloatPair leftRange = [FBClusterBitLayer sideSegmentRangeForSize:self.clusterSize density:self.clusterDensity skinny:skinny];
      FBSegmentedBitLayer *leftBit = [[FBSegmentedBitLayer alloc] initWithFactory:factory
                                                                 fromPointInParent:leftColTop
                                                                   toPointInParent:leftColBottom
                                                                         fractions:SplitOneIntoRandomFractions(leftRange.f1, leftRange.f2)
                                                                            skinny:skinny];
      [self addSublayer:leftBit];
      [self.leftSideBits addObject:leftBit];
        
      xOffset += bitThickness;
    } else {
      // no room for anything
      break;
    }
    yOffset -= yIncrement;
  }
}

#pragma mark - stuff to abstract

// all these methods are things in AbstractBitLayer or JoineryBitLayer
// we need to figure out how that'll work w/ ClusterBitLayer

- (void)forceRedraw {
  [self.joineryBit forceRedraw];
  [self.topBit forceRedraw];
  [self.bottomBit forceRedraw];
  for (FBAbstractBitLayer *bit in self.leftSideBits) {
    [bit forceRedraw];
  }
  for (FBAbstractBitLayer *bit in self.rightSideBits) {
    [bit forceRedraw];
  }
}

#pragma mark - animation

- (void)showDotOnly {
  [self.joineryBit showDotOnly];
  
  [self.topBit hide];
  [self.bottomBit hide];
  
  for (FBFrickBitLayer *bit in self.leftSideBits) {
    [bit hide];
  }
  for (FBFrickBitLayer *bit in self.rightSideBits) {
    [bit hide];
  }
}

static const CGFloat FBClusterBitRowAnimationDuration = 0.170;

- (void)addMasksToInnerBits {
  self.topBit.mask = [[CAShapeLayer alloc] init];
  self.bottomBit.mask = [[CAShapeLayer alloc] init];
  for (FBAbstractBitLayer *bit in self.leftSideBits) {
    bit.mask = [[CAShapeLayer alloc] init];
  }
  for (FBAbstractBitLayer *bit in self.rightSideBits) {
    bit.mask = [[CAShapeLayer alloc] init];
  }
}

- (void)animateIn {
  [self addMasksToInnerBits];
  __weak FBClusterBitLayer *weakSelf = self;
  [self.joineryBit animateFromDotToBitsWithCompletion:^(BOOL finished){
    
    [weakSelf.topBit show];
    [weakSelf.topBit animateFromToWithDuration:FBClusterBitRowAnimationDuration completion:^(BOOL finished) {
      if (weakSelf.leftSideBits.count == 0) {
        // only the joinery bit
      } else if (weakSelf.leftSideBits.count == 1) {
        [weakSelf.leftSideBits[0] show];
        [weakSelf.leftSideBits[0] animateFromCenterWithDuration:FBClusterBitRowAnimationDuration completion:nil];
        [weakSelf.rightSideBits[0] show];
        [weakSelf.rightSideBits[0] animateFromCenterWithDuration:FBClusterBitRowAnimationDuration completion:nil];
      } else if (weakSelf.leftSideBits.count == 2) {
        [weakSelf.leftSideBits[0] show];
        [weakSelf.leftSideBits[0] animateFromCenterWithDuration:FBClusterBitRowAnimationDuration completion:^(BOOL finished) {
          [weakSelf.leftSideBits[1] show];
          [weakSelf.leftSideBits[1] animateFromCenterWithDuration:FBClusterBitRowAnimationDuration completion:nil];
        }];
        [weakSelf.rightSideBits[0] show];
        [weakSelf.rightSideBits[0] animateFromCenterWithDuration:FBClusterBitRowAnimationDuration completion:^(BOOL finished) {
          [weakSelf.rightSideBits[1] show];
          [weakSelf.rightSideBits[1] animateFromCenterWithDuration:FBClusterBitRowAnimationDuration completion:nil];
        }];
      }
    }];

    [weakSelf.bottomBit show];
    [weakSelf.bottomBit animateFromToWithDuration:FBClusterBitRowAnimationDuration];
  }];
}

- (CGFloat)animationInDuration {
  FBClusterSize clusterSize = [FBClusterBitLayer clusterSizeWithRadius:self.radius];
  CGFloat joineryBitDuration = [self.joineryBit animationInDuration];
  switch (clusterSize) {
    case FBClusterSizeExtraSmall:
      // just the center joinery bit
      return joineryBitDuration;
    case FBClusterSizeSmall:
    case FBClusterSizeMedium:
      // small and medium both have one column
      // joinery + top/bottom + 1 column
      return joineryBitDuration + 2 * FBClusterBitRowAnimationDuration;
    case FBClusterSizeLarge:
      // joinery + top/bottom + 2 columns
      return joineryBitDuration + 3 * FBClusterBitRowAnimationDuration;
  }
}

#pragma mark - FBJoining

// CALayer convertPoint:toLayer: and convertPoint:fromLayer: only work properly if we have a superlayer.
// Since we're potentially joining and point-converting before having a superlayer, we do the math ourself.
- (CGPoint)convertPointFromSelfToParent:(CGPoint)point {
  return CGPointMake(point.x + self.frame.origin.x,
                     point.y + self.frame.origin.y);
}
- (CGPoint)convertPointFromParentToSelf:(CGPoint)point {
  return CGPointMake(point.x - self.frame.origin.x,
                     point.y - self.frame.origin.y);
}

- (CGPoint)closestAnchorToPointInParent:(CGPoint)point {
  CGPoint anchor = CGPointZero;
  CGFloat minDistance = MAXFLOAT;
  
  CGFloat topDistance = DistanceBetweenPoints(point, self.topAnchorInParent);
  if (topDistance < minDistance) {
    anchor = self.topAnchorInParent;
    minDistance = topDistance;
  }
  
  CGFloat rightDistance = DistanceBetweenPoints(point, self.rightAnchorInParent);
  if (rightDistance < minDistance) {
    anchor = self.rightAnchorInParent;
    minDistance = rightDistance;
  }
  
  CGFloat bottomDistance = DistanceBetweenPoints(point, self.bottomAnchorInParent);
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
  return [self convertPointFromSelfToParent:[self topAnchorInSelf]];
}

- (CGPoint)rightAnchorInParent {
  return [self convertPointFromSelfToParent:[self rightAnchorInSelf]];
}

- (CGPoint)bottomAnchorInParent {
  return [self convertPointFromSelfToParent:[self bottomAnchorInSelf]];
}

- (CGPoint)leftAnchorInParent {
  return [self convertPointFromSelfToParent:[self leftAnchorInSelf]];
}

- (CGPoint)topAnchorInSelf {
  return CGPointMake(_centerInSelf.x, _centerInSelf.y + _radius);
}

- (CGPoint)rightAnchorInSelf {
  if (self.rightSideBits.count > 0) {
    // anchor to the right side of the right-most side bit
    FBAbstractBitLayer *rightMostBit = [self.rightSideBits lastObject];
    CGFloat x = rightMostBit.fromPointInParent.x + rightMostBit.recipe.thickness;
    return CGPointMake(x, _centerInSelf.y);
  } else {
    // no side bits, so just delegate to our inner joineryBit
    return [self.joineryBit rightAnchorInParent];
  }
}

- (CGPoint)bottomAnchorInSelf {
  return CGPointMake(_centerInSelf.x, _centerInSelf.y - _radius);
}

- (CGPoint)leftAnchorInSelf {
  if (self.leftSideBits.count > 0) {
    // anchor to the left side of the left-most side bit
    FBAbstractBitLayer *leftMostBit = [self.leftSideBits lastObject];
    CGFloat x = leftMostBit.fromPointInParent.x - leftMostBit.recipe.thickness;
    return CGPointMake(x, _centerInSelf.y);
  } else {
    // no side bits, so just delegate to our inner joineryBit
    return [self.joineryBit leftAnchorInParent];
  }
}

- (CGPointPair)joinPointsInSelfForSide:(FBJoinSide)side {
  CGPoint jp1;
  CGPoint jp2;
  CGFloat thickness = self.joineryBit.recipe.thickness;
  
  switch (side) {
    case FBJoinSideTop:
    {
      CGPoint topAnchor = [self topAnchorInSelf];
      jp1 = CGPointMake(topAnchor.x - thickness, topAnchor.y);
      jp2 = CGPointMake(topAnchor.x + thickness, topAnchor.y);;
    }
      break;
    case FBJoinSideRight:
    {
      CGPoint rightAnchor = [self rightAnchorInSelf];
      jp1 = CGPointMake(rightAnchor.x, rightAnchor.y - thickness);
      jp2 = CGPointMake(rightAnchor.x, rightAnchor.y + thickness);
    }
      break;
    case FBJoinSideBottom:
    {
      CGPoint bottomAnchor = [self bottomAnchorInSelf];
      jp1 = CGPointMake(bottomAnchor.x - thickness, bottomAnchor.y);
      jp2 = CGPointMake(bottomAnchor.x + thickness, bottomAnchor.y);
    }
      break;
    case FBJoinSideLeft:
    {
      CGPoint leftAnchor = [self leftAnchorInSelf];
      jp1 = CGPointMake(leftAnchor.x, leftAnchor.y - thickness);
      jp2 = CGPointMake(leftAnchor.x, leftAnchor.y + thickness);
    }
      break;
  }
  
  CGPointPair pair = {jp1, jp2};
  return pair;
}

- (FBJoinSide)joinSideForEndPointInSelf1:(CGPoint)p1
                         endPointInSelf2:(CGPoint)p2 {
  CGPoint whichPoint;
  
  // use whichever point is NOT inside us.
  // TODO: this assumes one or the other is inside,
  // so as shorthand just pick the farthest away point
  if (DistanceBetweenPoints(p1, _centerInSelf) > DistanceBetweenPoints(p2, _centerInSelf)) {
    whichPoint = p1;
  } else {
    whichPoint = p2;
  }
  return [self joinSideForPointInSelf:whichPoint];
}

- (FBJoinSide)joinSideForPointInSelf:(CGPoint)point {
  CGFloat angle = DegreesBetweenPoints(self.centerInSelf, point);  
  if (angle < 45) {
    return FBJoinSideRight;
  } else if (angle < 135) {
    return FBJoinSideTop;
  } else if (angle < 225) {
    return FBJoinSideLeft;
  } else if (angle < 315) {
    return FBJoinSideBottom;
  } else {
    return FBJoinSideRight;
  }
}

@end
