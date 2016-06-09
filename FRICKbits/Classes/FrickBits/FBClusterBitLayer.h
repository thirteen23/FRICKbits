//
//  FBClusterBitLayer.h
//  FRICKbits
//
//  Created by Matt McGlincy on 5/30/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBJoineryBitLayer.h"
#import "FBJoinNode.h"

typedef NS_ENUM(NSInteger, FBClusterSize) {
  FBClusterSizeExtraSmall = 0,  // aka a joinery bit
  FBClusterSizeSmall,
  FBClusterSizeMedium,
  FBClusterSizeLarge
};

typedef NS_ENUM(NSInteger, FBClusterDensity) {
  FBClusterDensityLow,
  FBClusterDensityMedium,
  FBClusterDensityHigh
};

@interface FBClusterBitLayer : CALayer <FBJoinNode>

@property(nonatomic, strong) FBJoineryBitLayer *joineryBit;
@property(nonatomic, strong) FBSegmentedBitLayer *topBit;
@property(nonatomic, strong) FBSegmentedBitLayer *bottomBit;
@property(nonatomic, strong) NSMutableArray *leftSideBits;
@property(nonatomic, strong) NSMutableArray *rightSideBits;

+ (CGFloat)radiusWithClusterSize:(FBClusterSize)clusterSize;
+ (FBClusterSize)downgradedClusterSize:(FBClusterSize)clusterSize overlap:(CGFloat)overlap;

- (id)initWithFactory:(FBRecipeFactory *)factory
       centerInParent:(CGPoint)point
          clusterSize:(FBClusterSize)clusterSize
       clusterDensity:(FBClusterDensity)clusterDensity;

@end
