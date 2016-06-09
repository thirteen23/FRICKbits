//
//  FBFillerBitLayer.m
//  FRICKbits
//
//  Created by Matt McGlincy on 6/25/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBFillerBitLayer.h"
#import "FBUtils.h"

@implementation FBFillerBitLayer

- (id)initWithFactory:(FBRecipeFactory *)factory
    fromPointInParent:(CGPoint)fromPointInParent
      toPointInParent:(CGPoint)toPointInParent
     numberOfSegments:(NSUInteger)numberOfSegments {
  
  self = [super initWithRecipe:[factory makePerfectFrickBitRecipe] fromPointInParent:fromPointInParent
               toPointInParent:toPointInParent];
  if (self) {
    self.frickBitLayers = [NSMutableArray array];
    self.factory = factory;
    self.numberOfSegments = numberOfSegments;

    // TODO: apparently self.quadPath is necessary for the current animate-in to work right
    // [self.quadPath removeFromSuperlayer];
    // self.quadPath = nil;
    
    [self addSegments:self.numberOfSegments];
    
    // draw our quad line on top of our sub-bits
    //XXXX self.quadPath.zPosition = 99;
  }
  
  return self;
}

- (void)addRandomDetail {
  // override to do nothing
}

-  (void)refill {
  [self removeAllSegments];
  [self addSegments:self.numberOfSegments];
}

- (void)removeAllSegments {
  for (FBFrickBitLayer *layer in self.frickBitLayers) {
    [layer removeFromSuperlayer];
  }
  [self.frickBitLayers removeAllObjects];
}

- (void)addSegments:(NSUInteger)numberOfSegments {
  if (numberOfSegments == 0) {
    return;
  }
  
  CGLine midLine = CGLineMake(self.fromPointInSelf, self.toPointInSelf);
  CGFloat midLength = CGLineLength(midLine);
  
  NSArray *fractions = SplitOneIntoEndWeightedFractions(numberOfSegments, 0.1);
  CGFloat startFraction = 0.0;
  for (int i = 0; i < fractions.count; i++) {
    NSNumber *fraction = fractions[i];
    CGFloat endFraction = startFraction + [fraction floatValue];
    CGPoint fromPoint = CGPointAlongLine(midLine, midLength * startFraction);
    CGPoint toPoint = CGPointAlongLine(midLine, midLength * endFraction);

    FBFrickBitRecipe *recipe = [self.factory makePerfectFrickBitRecipe];
    
    // maybe use a complementary color, but never on end bits
    if (i != 0 && i != (fractions.count - 1) && RandChance(50)) {
      recipe.fillColor = [self.factory.colorPalette nextComplementaryColor];
    }
    
    FBFrickBitLayer *bit = [[FBFrickBitLayer alloc] initWithRecipe:recipe fromPointInParent:fromPoint toPointInParent:toPoint];
    [self.frickBitLayers addObject:bit];
    [self addSublayer:bit];
    
    startFraction = endFraction;
  }
}

- (void)forceRedraw {
  [super forceRedraw];
  for (FBFrickBitLayer *bit in self.frickBitLayers) {
    [bit forceRedraw];
  }
}

- (void)show {
  [super show];
  for (FBFrickBitLayer *bit in self.frickBitLayers) {
    [bit show];
  }
}

- (void)hide {
  [super hide];
  for (FBFrickBitLayer *bit in self.frickBitLayers) {
    [bit hide];
  }
}

@end
