//
//  FBJoining.h
//  FRICKbits
//
//  Created by Matt McGlincy on 6/2/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBUtils.h"

@protocol FBJoinNode <NSObject>

@property(nonatomic, readonly) CGPoint topAnchorInParent;
@property(nonatomic, readonly) CGPoint rightAnchorInParent;
@property(nonatomic, readonly) CGPoint bottomAnchorInParent;
@property(nonatomic, readonly) CGPoint leftAnchorInParent;

@property(nonatomic, readonly) CGPoint topAnchorInSelf;
@property(nonatomic, readonly) CGPoint rightAnchorInSelf;
@property(nonatomic, readonly) CGPoint bottomAnchorInSelf;
@property(nonatomic, readonly) CGPoint leftAnchorInSelf;

@property(nonatomic, readonly) CGPoint centerInParent;
@property(nonatomic, readonly) CGPoint centerInSelf;

@property(nonatomic, readonly) CGFloat radius;

// which anchor point is closest to the given point
- (CGPoint)closestAnchorToPointInParent:(CGPoint)point;

// which side should an exterior point be joined to?
- (FBJoinSide)joinSideForPointInSelf:(CGPoint)point;

- (FBJoinSide)joinSideForEndPointInSelf1:(CGPoint)p1
                         endPointInSelf2:(CGPoint)p2;

// what pair of points to use for joining to the given side
- (CGPointPair)joinPointsInSelfForSide:(FBJoinSide)side;

// which of our anchor points corresponds to the given side
- (CGPoint)anchorInParentForSide:(FBJoinSide)side;
- (CGPoint)anchorInSelfForSide:(FBJoinSide)side;

// TODO: eliminate this from protocol
- (void)forceRedraw;

// TODO: eliminate this from protocol
- (void)showDotOnly;

// TODO: eliminate this from protocol
- (void)animateIn;

- (CGFloat)animationInDuration;

@end
