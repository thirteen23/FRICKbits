//
//  FBFrickBitLayerTest.m
//  FRICKbits
//
//  Created by Matt McGlincy on 6/5/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FBRecipeFactory.h"
#import "FBFrickBitLayer.h"
#import "FBJoineryBitLayer.h"
#import "FBTestUtils.h"

@interface FBFrickBitLayerTest : XCTestCase

@end

@implementation FBFrickBitLayerTest

- (void)setUp {
  [super setUp];
}

- (void)tearDown {
  [super tearDown];
}

- (void)testJoinToJoineryBit {
  
  FBRecipeFactory *factory = [[FBRecipeFactory alloc] init];
  CGPoint center = CGPointZero;
  // joinery bits runs bottom-to-top across the center
  FBJoineryBitLayer *joineryBit = [[FBJoineryBitLayer alloc] initWithFactory:factory centerInParent:center];

  CGFloat halfJBitLength = [factory makePerfectFrickBitRecipe].thickness;
  XCTAssertEqual(joineryBit.fromPointInParent.x, center.x);
  XCTAssertEqual(joineryBit.fromPointInParent.y, -halfJBitLength);
  XCTAssertEqual(joineryBit.toPointInParent.x, center.x);
  XCTAssertEqual(joineryBit.toPointInParent.y, halfJBitLength);
  
  FBFrickBitRecipe *recipe = [factory makePerfectFrickBitRecipe];
  CGPoint fromPoint = CGPointMake(0,20);
  FBFrickBitLayer *bit = [[FBFrickBitLayer alloc] initWithRecipe:recipe
                                               fromPointInParent:fromPoint
                                                 toPointInParent:center];

  // bit should stretch from-to-to, so upperleft/lowerleft surround the from-point
  CGFloat bitThickness = bit.recipe.thickness;
  XCTAssertTrue(CGPointEqualToPoint(bit.quadInParent.upperLeft, CGPointMake(-bitThickness, fromPoint.y)));
  XCTAssertTrue(CGPointEqualToPoint(bit.quadInParent.lowerLeft, CGPointMake(bitThickness, fromPoint.y)));
  XCTAssertTrue(CGPointEqualToPoint(bit.quadInParent.upperRight, CGPointMake(-bitThickness, center.y)));
  XCTAssertTrue(CGPointEqualToPoint(bit.quadInParent.lowerRight, CGPointMake(bitThickness, center.y)));

  // we should be joining to the north face, which for our vertically-drawn joinery bit is actually the right (UR-LR)
  FBJoinSide side = [bit sideToJoinWithJoinNode:joineryBit];
  XCTAssertEqual(side, FBJoinSideRight);
  
  // the right-side join points should be upper and lower right of joinery quad
  CGPointPair joinPointsInNode = [joineryBit joinPointsInSelfForSide:side];
  XCTAssertPointsEqual(joinPointsInNode.p1, joineryBit.quadInSelf.upperRight);
  XCTAssertPointsEqual(joinPointsInNode.p2, joineryBit.quadInSelf.lowerRight);
  
  [bit endJoinToJoinNode:joineryBit side:side];

  // the "from" quad points (upper and lower left) should be the same
  CGPoint expectedUL = CGPointMake(bitThickness, fromPoint.y);
  CGPoint expectedLL = CGPointMake(-bitThickness, fromPoint.y);

  XCTAssertPointsEqual(bit.quadInParent.upperLeft, expectedUL);
  XCTAssertPointsEqual(bit.quadInParent.lowerLeft, expectedLL);
  
  // TODO: quadInSelf gets updated when joining, but quadInParent doesn't?  Can we nuke quadInParent?
  /* >>>>
  // but the "to" quad points (upper and lower right) should now be on the corresponding joinery bit points
  // (since the joinery bit points "up", this end of the joinery bit is upper and lower right)
  XCTAssertEqual(bit.quadInParent.upperRight.x, joineryBit.quadInParent.lowerRight.x);
  XCTAssertEqual(bit.quadInParent.upperRight.y, joineryBit.quadInParent.lowerRight.y);
  XCTAssertEqual(bit.quadInParent.lowerRight.x, joineryBit.quadInParent.upperRight.x);
  XCTAssertEqual(bit.quadInParent.lowerRight.y, joineryBit.quadInParent.upperRight.y);
   <<<< */
}

@end
