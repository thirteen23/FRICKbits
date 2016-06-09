//
//  FBSegmentedBitLayer.m
//  FrickBits
//
//  Created by Matt McGlincy on 2/25/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBFrickBitLayer.h"
#import "FBSegmentedBitLayer.h"
#import "FBUtils.h"

@interface FBSegmentedBitLayer ()
@property(nonatomic, strong) FBRecipeFactory *factory;
@end

@implementation FBSegmentedBitLayer

// TODO: refactor init methods
- (id)initWithFactory:(FBRecipeFactory *)factory
    fromPointInParent:(CGPoint)fromPointInParent
      toPointInParent:(CGPoint)toPointInParent
     numberOfSegments:(NSUInteger)numberOfSegments
  restrictEndBitSizes:(BOOL)restrictEndBitSizes {
  return [self initWithFactory:factory fromPointInParent:fromPointInParent toPointInParent:toPointInParent
              numberOfSegments:numberOfSegments restrictEndBitSizes:restrictEndBitSizes skinny:NO];
}

- (id)initWithFactory:(FBRecipeFactory *)factory
    fromPointInParent:(CGPoint)fromPointInParent
      toPointInParent:(CGPoint)toPointInParent
     numberOfSegments:(NSUInteger)numberOfSegments
  restrictEndBitSizes:(BOOL)restrictEndBitSizes
               skinny:(BOOL)skinny {

  self = [super init];
  if (self) {
    self.frickBitLayers = [NSMutableArray array];
    self.factory = factory;
    self.fromPointInParent = fromPointInParent;
    self.toPointInParent = toPointInParent;

    // create a recipe to get a bit thickness for size calculations
    if (skinny) {
      self.recipe = [factory makeSkinnyFrickBitRecipe];
    } else {
      self.recipe = [factory makePerfectFrickBitRecipe];
    }

    CGRect boundingBox =
        CGRectSurroundingPoints(fromPointInParent, toPointInParent);
    // expand the bounding box to allow for bit thickness
    CGFloat padding = self.recipe.thickness;
    boundingBox = CGRectInset(boundingBox, -2 * padding, -2 * padding);
    self.frame = boundingBox;

    self.fromPointInSelf =
        CGPointMinusPoint(self.fromPointInParent, self.frame.origin);
    self.toPointInSelf =
        CGPointMinusPoint(self.toPointInParent, self.frame.origin);
    self.quadInSelf = FBQuadMakeAroundPoints(self.fromPointInSelf, self.toPointInSelf, self.recipe.thickness);

    [self makeSegments:numberOfSegments restrictEndBitSizes:restrictEndBitSizes skinny:skinny];
  }
  return self;
}

- (id)initWithFactory:(FBRecipeFactory *)factory
    fromPointInParent:(CGPoint)fromPointInParent
      toPointInParent:(CGPoint)toPointInParent
            fractions:(NSArray *)fractions {
  return [self initWithFactory:factory fromPointInParent:fromPointInParent toPointInParent:toPointInParent
                     fractions:fractions skinny:NO];
}

- (id)initWithFactory:(FBRecipeFactory *)factory
    fromPointInParent:(CGPoint)fromPointInParent
      toPointInParent:(CGPoint)toPointInParent
            fractions:(NSArray *)fractions
               skinny:(BOOL)skinny {
  self = [super init];
  if (self) {
    self.frickBitLayers = [NSMutableArray array];
    self.factory = factory;
    self.fromPointInParent = fromPointInParent;
    self.toPointInParent = toPointInParent;
    
    // create a recipe to get a bit thickness for size calculations
    if (skinny) {
      self.recipe = [factory makeSkinnyFrickBitRecipe];
    } else {
      self.recipe = [factory makePerfectFrickBitRecipe];
    }
    
    // TODO: is there any reason for us to keep a local recipe?
    // self.recipe = recipe;
    
    CGRect boundingBox = CGRectSurroundingPoints(fromPointInParent, toPointInParent);
    // expand the bounding box to allow for bit thickness
    CGFloat padding = self.recipe.thickness;
    boundingBox = CGRectInset(boundingBox, -2 * padding, -2 * padding);
    self.frame = boundingBox;
    
    self.fromPointInSelf = CGPointMinusPoint(self.fromPointInParent, self.frame.origin);
    self.toPointInSelf = CGPointMinusPoint(self.toPointInParent, self.frame.origin);
    self.quadInSelf = FBQuadMakeAroundPoints(self.fromPointInSelf, self.toPointInSelf, self.recipe.thickness);
    
    [self makeSegmentsWithFractions:fractions skinny:skinny];
  }
  return self;
}

- (void)setFrame:(CGRect)frame {
  [super setFrame:frame];
  self.mask.frame = self.bounds;
  [self setNeedsDisplay];
}

- (void)makeSegments:(NSUInteger)numberOfSegments restrictEndBitSizes:(BOOL)restrictEndBitSizes skinny:(BOOL)skinny {
  // decide how many striations we can actually fit
  CGFloat totalBitLength =
      DistanceBetweenPoints(self.fromPointInSelf, self.toPointInSelf);
  NSUInteger maxSegments = (NSUInteger)(totalBitLength / FBMinimumBitLength);
  numberOfSegments = CLAMP(numberOfSegments, 1, maxSegments);

  CGFloat xDiff = self.toPointInSelf.x - self.fromPointInSelf.x;
  CGFloat yDiff = self.toPointInSelf.y - self.fromPointInSelf.y;

  // divide 100% (1.0) into sections for each bit
  // e.g., 0.1, 0.2, 0.1, 0.6.
  CGFloat bitLength =
      DistanceBetweenPoints(self.fromPointInSelf, self.toPointInSelf);
  CGFloat minPercent = FBMinimumBitLength / bitLength;
  NSArray *fractions =
      SplitOneIntoEndWeightedFractions(numberOfSegments, minPercent);
  if (restrictEndBitSizes) {
    CGFloat minEndPercent = FBMinimumSegmentEndBitLength / bitLength;
    fractions = GlomEndFractionsLessThan(fractions, minEndPercent);
  }
  
  CGPoint fromPoint = self.fromPointInSelf;

  for (int i = 0; i < fractions.count; i++) {
    CGFloat fraction = [fractions[i] floatValue];
    CGFloat xIncrement = xDiff * fraction;
    CGFloat yIncrement = yDiff * fraction;
    CGPoint toPoint =
        CGPointMake(fromPoint.x + xIncrement, fromPoint.y + yIncrement);

    FBFrickBitRecipe *recipe;
    if (skinny) {
      recipe = [self.factory makeSkinnyFrickBitRecipe];
    } else {
      recipe = [self.factory makePerfectFrickBitRecipe];
    }

    // maybe use a complementary color, but never on end bits
    if (i != 0 && i != fractions.count - 1 && RandChance(50)) {
      recipe.fillColor = [self.factory.colorPalette nextComplementaryColor];
    }

    FBFrickBitLayer *frickBit =
        [[FBFrickBitLayer alloc] initWithRecipe:recipe
                              fromPointInParent:fromPoint
                                toPointInParent:toPoint];
    [self.frickBitLayers addObject:frickBit];
    [self addSublayer:frickBit];
    fromPoint = toPoint;
  }
}

- (void)makeSegmentsWithFractions:(NSArray *)fractions skinny:(BOOL)skinny {
  CGFloat xDiff = self.toPointInSelf.x - self.fromPointInSelf.x;
  CGFloat yDiff = self.toPointInSelf.y - self.fromPointInSelf.y;
  CGPoint fromPoint = self.fromPointInSelf;
  
  for (int i = 0; i < fractions.count; i++) {
    CGFloat fraction = [fractions[i] floatValue];
    CGFloat xIncrement = xDiff * fraction;
    CGFloat yIncrement = yDiff * fraction;
    CGPoint toPoint =
    CGPointMake(fromPoint.x + xIncrement, fromPoint.y + yIncrement);
    
    FBFrickBitRecipe *recipe;
    if (skinny) {
      recipe = [self.factory makeSkinnyFrickBitRecipe];
    } else {
      recipe = [self.factory makePerfectFrickBitRecipe];
    }
    
    // maybe use a complementary color, but never on end bits
    if (i != 0 && i != fractions.count - 1 && RandChance(50)) {
      recipe.fillColor = [self.factory.colorPalette nextComplementaryColor];
    }
    
    FBFrickBitLayer *frickBit =
    [[FBFrickBitLayer alloc] initWithRecipe:recipe
                          fromPointInParent:fromPoint
                            toPointInParent:toPoint];
    [self.frickBitLayers addObject:frickBit];
    [self addSublayer:frickBit];
    fromPoint = toPoint;
  }
}

- (void)updateQuad {
  // update our quad to enclose our children bits

  if (self.frickBitLayers.count < 1) {
    // nothing to update
    return;
  }

  FBFrickBitLayer *firstBit = [self.frickBitLayers firstObject];
  FBFrickBitLayer *lastBit = [self.frickBitLayers lastObject];

  CGPoint ul =
      [self convertPoint:firstBit.quadInSelf.upperLeft fromLayer:firstBit];
  CGPoint ur =
      [self convertPoint:lastBit.quadInSelf.upperRight fromLayer:lastBit];
  CGPoint lr =
      [self convertPoint:lastBit.quadInSelf.lowerRight fromLayer:lastBit];
  CGPoint ll =
      [self convertPoint:firstBit.quadInSelf.lowerLeft fromLayer:firstBit];
  self.quadInSelf = FBQuadMakeUntwisted(FBQuadMake(ul, ur, lr, ll));
}

- (void)updatePaths {
  for (FBFrickBitLayer *bit in self.frickBitLayers) {
    [bit updatePaths];
  }

  CAShapeLayer *maskLayer = (CAShapeLayer *)self.mask;
  maskLayer.path = [self fillPath].CGPath;
}

- (void)forceRedraw {
  [super forceRedraw];
  for (FBFrickBitLayer *bit in self.frickBitLayers) {
    [bit forceRedraw];
  }
}

#pragma mark - joinery

- (void)endJoinToJoinNode:(CALayer<FBJoinNode> *)joinNode side:(FBJoinSide)side {
  if (self.frickBitLayers.count == 0) {
    // nothing to join
    return;
  }

  if (self.frickBitLayers.count == 1) {
    // only one segment
    FBFrickBitLayer *onlySegment = self.frickBitLayers[0];
    [onlySegment endJoinToJoinNode:joinNode side:side];
  } else {
    // >1 segments
    // join either the first or the last segment, depending on from/to endpoint
    CGPoint endPointInSelf = [self endPointInSelfToJoinWithJoinNode:joinNode];
    if (CGPointEqualToPoint(endPointInSelf, self.fromPointInSelf)) {
      // from point = first segment
      FBFrickBitLayer *firstSegment = [self.frickBitLayers firstObject];
      [firstSegment endJoinToJoinNode:joinNode side:side];
    } else if (CGPointEqualToPoint(endPointInSelf, self.toPointInSelf)) {
      // to point = last segment
      FBFrickBitLayer *lastSegment = [self.frickBitLayers lastObject];
      [lastSegment endJoinToJoinNode:joinNode side:side];
    } else {
      NSLog(@"Incorrect endpoint calculated");
    }
  }
  
  [self updateQuad];
  [self updatePaths];
}

- (void)hide {
  for (FBFrickBitLayer *bit in self.frickBitLayers) {
    [bit hide];
  }
}

- (void)show {
  for (FBFrickBitLayer *bit in self.frickBitLayers) {
    [bit show];
  }
}

@end
