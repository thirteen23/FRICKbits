//
//  FBJoineryBitLayer.h
//  FrickBits
//
//  Created by Matt McGlincy on 2/25/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBJoin.h"
#import "FBJoinery.h"
#import "FBJoinNode.h"
#import "FBSegmentedBitLayer.h"

@interface FBJoineryBitLayer : FBSegmentedBitLayer <FBJoinNode>

@property(nonatomic) CGFloat rotationDegrees;

// colored dot layer, akin to dots-and-lines dot
@property(nonatomic, strong) CAShapeLayer *dotLayer;

- (id)initWithFactory:(FBRecipeFactory *)factory centerInParent:(CGPoint)centerInParent;

- (id)initWithFactory:(FBRecipeFactory *)factory
    fromPointInParent:(CGPoint)fromPointInParent
      toPointInParent:(CGPoint)toPointInParent;

// figure out which point is exterior, and then pick an appropriate join side
- (FBJoinSide)joinSideForEndPointInSelf1:(CGPoint)p1 endPointInSelf2:(CGPoint)p2;

// rotate a point around this joinery bit's center, by the bit's rotation angle.
// XXX - (CGPoint)centerRotatedPoint:(CGPoint)p;

// TODO: get rid of this method
- (CGPointPair)joinPointsInParentForSide:(FBJoinSide)side;

// hide all segment bits and show only the color dot
- (void)showDotOnly;

// start by showing only a dot, then pop-out-in to show our bits
- (void)animateFromDotToBits;
- (void)animateFromDotToBitsWithCompletion:(void (^)(BOOL finished))completion;

// start by showing bits, then pop-out-in to show our dot
- (void)animateFromBitsToDot;
- (void)animateFromBitsToDotWithCompletion:(void (^)(BOOL finished))completion;


@end
