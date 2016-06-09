//
//  FBCoordinateQuadTree.m
//  TBAnnotationClustering
//
//  Created by Theodore Calmes on 9/27/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import "FBCoordinateQuadTree.h"
#import "FBLocation.h"
#import "FBMapGridCell.h"
#import "FBMapGridCellConnection.h"
#import "FBUtils.h"
#import "TBUtils.h"

TBQuadTreeNodeData FBDataFromOpenPathsLine(NSString *line) {
  NSArray *components = [line componentsSeparatedByString:@","];
  double latitude = [components[0] doubleValue];
  double longitude = [components[1] doubleValue];
  FBNodeInfo *nodeInfo = malloc(sizeof(FBNodeInfo));
  // TODO: we could ditch NodeInfo and just pass a pointer to FBLocation
  // directly
  return TBQuadTreeNodeDataMake(latitude, longitude, nodeInfo);
}

TBQuadTreeNodeData FBDataFromFBLocation(FBLocation *location) {
  FBNodeInfo *nodeInfo = malloc(sizeof(FBNodeInfo));
  nodeInfo->location = location;
  return TBQuadTreeNodeDataMake(location.latitude, location.longitude,
                                nodeInfo);
}

#pragma mark -

@interface FBCoordinateQuadTree ()
@property(nonatomic, strong) FBDataset *dataset;
@end

@implementation FBCoordinateQuadTree

- (id)init {
  self = [super init];
  if (self) {
  }
  return self;
}

- (void)buildTreeWithCSVFilename:(NSString *)csvFilename {
  @autoreleasepool {
    NSString *data =
        [NSString stringWithContentsOfFile:[[NSBundle mainBundle]
                                               pathForResource:csvFilename
                                                        ofType:nil]
                                  encoding:NSASCIIStringEncoding
                                     error:nil];
    NSArray *lines = [data componentsSeparatedByString:@"\n"];
    NSInteger count = lines.count - 1;

    TBQuadTreeNodeData *dataArray = malloc(sizeof(TBQuadTreeNodeData) * count);
    for (NSInteger i = 0; i < count; i++) {
      dataArray[i] = FBDataFromOpenPathsLine(lines[i]);
    }

    TBBoundingBox world = TBBoundingBoxMake(19, -166, 72, -53);
    _root = TBQuadTreeBuildWithData(dataArray, (int)count, world, 4);
  }
}

- (void)buildTreeWithDataset:(FBDataset *)dataset {
  // keep the dataset around, so our unretained FBNodeInfo pointers stay live
  self.dataset = dataset;
  @autoreleasepool {
    NSInteger count = dataset.locations.count;

    TBQuadTreeNodeData *dataArray = malloc(sizeof(TBQuadTreeNodeData) * count);
    for (NSInteger i = 0; i < count; i++) {
      dataArray[i] = FBDataFromFBLocation(dataset.locations[i]);
    }

    TBBoundingBox world = TBBoundingBoxMake(19, -166, 72, -53);
    _root = TBQuadTreeBuildWithData(dataArray, (int)count, world, 4);
  }
}

@end
