//
//  FBJoineryBitLayerTest.m
//  FRICKbits
//
//  Created by Matt McGlincy on 6/24/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FBJoineryBitLayer.h"
#import "FBTestUtils.h"

@interface FBJoineryBitLayerTest : XCTestCase

@end

@implementation FBJoineryBitLayerTest

- (void)testJoinSideForPointInSelf {
  // make a joinery bit around the origin
  FBRecipeFactory *factory = [[FBRecipeFactory alloc] init];
  FBJoineryBitLayer *jBit = [[FBJoineryBitLayer alloc] initWithFactory:factory centerInParent:CGPointZero];

  // CALayer origin is lower left
  CGPoint north = CGPointMake(jBit.centerInSelf.x, jBit.centerInSelf.y + 100);
  CGPoint east = CGPointMake(jBit.centerInSelf.x + 100, jBit.centerInSelf.y);
  CGPoint south = CGPointMake(jBit.centerInSelf.x, jBit.centerInSelf.y - 100);
  CGPoint west = CGPointMake(jBit.centerInSelf.x - 100, jBit.centerInSelf.y);

  // a joinery bit points "up" (-y to +y), so its right side is north
  XCTAssertEqual([jBit joinSideForPointInSelf:north], FBJoinSideRight);
  XCTAssertEqual([jBit joinSideForPointInSelf:east], FBJoinSideTop);
  XCTAssertEqual([jBit joinSideForPointInSelf:south], FBJoinSideLeft);
  XCTAssertEqual([jBit joinSideForPointInSelf:west], FBJoinSideBottom);
}

@end
