//
//  FBCoordinateQuadTree.h
//  TBAnnotationClustering
//
//  Created by Theodore Calmes on 9/27/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import "FBDataset.h"
#import "FBLocation.h"
#import "TBQuadTree.h"

typedef struct FBNodeInfo {
    // because this is unretained (to keep ARC happy),
    // we need to retain the FBLocation elsewhere (e.g., by keeping the FBDataset around)
    __unsafe_unretained FBLocation *location;
} FBNodeInfo;

@interface FBCoordinateQuadTree : NSObject

@property (assign, nonatomic) TBQuadTreeNode *root;
@property (strong, nonatomic) MKMapView *mapView;

- (void)buildTreeWithCSVFilename:(NSString *)csvFilename;
- (void)buildTreeWithDataset:(FBDataset *)dataset;

@end
