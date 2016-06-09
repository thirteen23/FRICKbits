//
//  FBJoinery.h
//  FrickBits
//
//  Created by Matt McGlincy on 2/25/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBFrickBitLayer.h"
#import "FBJoin.h"
#import "FBJoinNode.h"
#import "FBSegmentedBitLayer.h"
#import "FBSplitBitLayer.h"
#import "FBMapGridCellConnection.h"


@interface FBJoinery : NSObject

+ (FBJoinSidePair)closestSidesBetweenJoinNode1:(CALayer<FBJoinNode> *)joinNode1
                                     joinNode2:(CALayer<FBJoinNode> *)joinNode2;

// miter-joins

+ (void)miterJoinFrickBit1:(FBFrickBitLayer *)bit1 bit2:(FBFrickBitLayer *)
    bit2;
+ (void)miterJoinFrickBit1:(FBFrickBitLayer *)bit1
                 bit2:(FBFrickBitLayer *)bit2
      withAngleFilter:(CGFloat)radians;

// Miter two segmentedbits together.
// NOTE: the order of arguments to miter is important!
// (the last segment of bit1 will get mited to the first segment of bit2)
+ (void)miterJoinSegmentedBit1:(FBSegmentedBitLayer *)bit1 bit2:
    (FBSegmentedBitLayer *)bit2;
+ (void)miterJoinSegmentedBit1:(FBSegmentedBitLayer *)bit1
    bit2:(FBSegmentedBitLayer *)bit2
    withAngleFilter:(CGFloat)radians;

@end
