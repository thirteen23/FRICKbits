//
//  FBClusterBitLayerTest.m
//  FRICKbits
//
//  Created by Matt McGlincy on 6/24/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FBClusterBitLayer.h"

@interface FBClusterBitLayerTest : XCTestCase

@end

@implementation FBClusterBitLayerTest

- (void)testJoinSideForPointInSelf {
  // make a cluster around the origin
  FBRecipeFactory *factory = [[FBRecipeFactory alloc] init];
  FBClusterBitLayer *cluster = [[FBClusterBitLayer alloc] initWithFactory:factory
                                                           centerInParent:CGPointZero
                                                              clusterSize:FBClusterSizeSmall
                                                           clusterDensity:FBClusterDensityHigh];
  
  // CALayer origin is lower left
  CGPoint north = CGPointMake(cluster.centerInSelf.x, cluster.centerInSelf.y + 100);
  CGPoint east = CGPointMake(cluster.centerInSelf.x + 100, cluster.centerInSelf.y);
  CGPoint south = CGPointMake(cluster.centerInSelf.x, cluster.centerInSelf.y - 100);
  CGPoint west = CGPointMake(cluster.centerInSelf.x - 100, cluster.centerInSelf.y);
  
  XCTAssertEqual([cluster joinSideForPointInSelf:north], FBJoinSideTop);
  XCTAssertEqual([cluster joinSideForPointInSelf:east], FBJoinSideRight);
  XCTAssertEqual([cluster joinSideForPointInSelf:south], FBJoinSideBottom);
  XCTAssertEqual([cluster joinSideForPointInSelf:west], FBJoinSideLeft);
}


@end
