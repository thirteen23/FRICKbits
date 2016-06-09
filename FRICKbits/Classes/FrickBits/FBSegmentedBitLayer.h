//
//  FBSegmentedBitLayer.h
//  FrickBits
//
//  Created by Matt McGlincy on 2/25/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBAbstractBitLayer.h"
#import "FBRecipeFactory.h"
#import "FBQuad.h"

@interface FBSegmentedBitLayer : FBAbstractBitLayer

@property(nonatomic, strong) NSMutableArray *frickBitLayers;

/**
 * Init a segmented bit with the given number of segments.
 * Segment sizes will be randomly determined.
 */
- (id)initWithFactory:(FBRecipeFactory *)factory
    fromPointInParent:(CGPoint)fromPointInParent
      toPointInParent:(CGPoint)toPointInParent
     numberOfSegments:(NSUInteger)numberOfSegments
  restrictEndBitSizes:(BOOL)restrictEndBitSizes;

- (id)initWithFactory:(FBRecipeFactory *)factory
    fromPointInParent:(CGPoint)fromPointInParent
      toPointInParent:(CGPoint)toPointInParent
     numberOfSegments:(NSUInteger)numberOfSegments
  restrictEndBitSizes:(BOOL)restrictEndBitSizes
               skinny:(BOOL)skinny;

/**
 * Init a segmented bit with the given fractional pieces.
 *
 * @param fractions an array of NSNumber/CGFloats that should sum to 1.0.
 */
- (id)initWithFactory:(FBRecipeFactory *)factory
    fromPointInParent:(CGPoint)fromPointInParent
      toPointInParent:(CGPoint)toPointInParent
            fractions:(NSArray *)fractions;

- (id)initWithFactory:(FBRecipeFactory *)factory
    fromPointInParent:(CGPoint)fromPointInParent
      toPointInParent:(CGPoint)toPointInParent
            fractions:(NSArray *)fractions
               skinny:(BOOL)skinny;

- (void)forceRedraw;

// update quad to enclose all children bits
- (void)updateQuad;

// update paths and mask to reflect current quad
- (void)updatePaths;

@end
