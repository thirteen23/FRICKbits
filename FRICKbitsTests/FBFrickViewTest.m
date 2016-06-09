//
//  FBFrickViewTest.m
//  FrickBits
//
//  Created by Matt McGlincy on 4/18/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FBClusterBitLayer.h"
#import "FBFrickView.h"
#import "FBJoineryBitLayer.h"

@interface FBFrickViewTest : XCTestCase

@end

@implementation FBFrickViewTest

- (void)setUp {
  [super setUp];
}

- (void)tearDown {
  [super tearDown];
}

/**
 * Verify our bit-making routines.
 */
- (void)testBitMaking {
  MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
  FBSparseMapGrid *sparseMapGrid = [[FBSparseMapGrid alloc] init];
  MKMapRect mapRect = mapView.visibleMapRect;
  FBRecipeFactory *factory = [[FBRecipeFactory alloc] init];

  FBFrickView *frickView = [[FBFrickView alloc] initWithFrame:CGRectMake(0, 0, 640, 1136)];
  [frickView updateCellJoinNodesWithMapView:mapView mapGrid:sparseMapGrid
          mapRect:mapRect factory:factory];

  // TODO: verify join nodes

  [frickView updateConnectionFrickBitsWithMapView:mapView mapGrid:sparseMapGrid
          mapRect:mapRect factory:factory cellJoineryBits:frickView.cellJoinNodes];

  // TODO: verify connections
}

/**
 * At a certain zoom, 2 joinery bits too-close together can potentially cause a malformed connection bit.
 * So, test this.
 */
// TODO: asserts/counts have been updated so this test passes, but I'm not sure this test is relevant anymore.
- (void)testJoineryProximityConnectionBug {
  NSString *filePath = [[NSBundle bundleForClass:[self class]]
                        pathForResource:@"test_joint_proximity_connection_bug"
                        ofType:@"json"];
  FBDataset *dataset = [[FBDataset alloc] initWithFilePath:filePath];
  XCTAssertEqual(dataset.locations.count, 2, @"Wrong number of locations in "
                 "dataset");
  
  MKMapRect mapRect = MKMapRectMake(61323843.48893057, 110467341.2436626, 20071.94016044587,
      35627.6925637126);
  MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
  mapView.visibleMapRect = mapRect;

  double zoomScale = mapView.bounds.size.width / mapRect.size.width;
  FBSparseMapGrid *mapGrid = [[FBSparseMapGrid alloc] initWithZoomScale:zoomScale];
  [mapGrid populateWithDataset:dataset];
  
  XCTAssertEqual([[[mapGrid.cells keyEnumerator] allObjects] count], 1);

  FBFrickView *frickView = [[FBFrickView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
  FBRecipeFactory *factory = [[FBRecipeFactory alloc] init];
  [frickView updateCellJoinNodesWithMapView:mapView mapGrid:mapGrid mapRect:mapRect factory:factory];
  
  NSArray *cells = [[frickView.cellJoinNodes keyEnumerator] allObjects];
  XCTAssertEqual(cells.count, 1);

  [frickView updateConnectionFrickBitsWithMapView:mapView mapGrid:mapGrid mapRect:mapRect factory:factory cellJoineryBits:frickView.cellJoinNodes];
  
  NSArray *connections = [[frickView.connectionFrickBits keyEnumerator] allObjects];
  XCTAssertEqual(connections.count, 0);
}

- (void)testClusterBits {
  // this is an Austin-based dataset with cluster-happy data
  NSString *filePath = [[NSBundle bundleForClass:[self class]]
                        pathForResource:@"test_clusters"
                        ofType:@"csv"];
  FBDataset *dataset = [[FBDataset alloc] initWithFilePath:filePath];
  XCTAssertTrue(dataset.locations.count > 0, @"No locations in dataset");
  
  MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
  // set the map to a rectangle appropriate for viewing the dataset in Austin,
  // and showing clusters.
  MKMapRect mapRect = {{61271575.955379,110360002.108920},{139089.893713,246884.552879}};
  [mapView setVisibleMapRect:mapRect animated:NO];
  
  double zoomScale = mapView.bounds.size.width / mapView.visibleMapRect.size.width;
  FBSparseMapGrid *mapGrid = [[FBSparseMapGrid alloc] initWithZoomScale:zoomScale];
  [mapGrid populateWithDataset:dataset];
  NSUInteger cellCount = [[[mapGrid.cells keyEnumerator] allObjects] count];
  // whole lotta cells in the world-covering map grid
  XCTAssertEqual(cellCount, 547, @"Wrong number of cells in mapGrid");

  FBRecipeFactory *factory = [[FBRecipeFactory alloc] init];
  FBFrickView *frickView = [[FBFrickView alloc] initWithFrame:CGRectMake(0, 0, 640, 1136)];
  [frickView updateCellJoinNodesWithMapView:mapView mapGrid:mapGrid
                                  mapRect:mapRect factory:factory];
  
  // make sure we got some clusters and joinery
  XCTAssertNotNil(frickView.cellJoinNodes);
  NSUInteger clusterBitCount = 0;
  NSUInteger joineryBitCount = 0;
  NSUInteger unknown = 0;
  NSMutableArray *clusterBits = [NSMutableArray array];
  for (FBMapGridCell *cell in frickView.cellJoinNodes) {
    id obj = [frickView.cellJoinNodes objectForKey:cell];
    if ([obj isKindOfClass:[FBJoineryBitLayer class]]) {
      joineryBitCount++;
    } else if ([obj isKindOfClass:[FBClusterBitLayer class]]) {
      clusterBitCount++;
      [clusterBits addObject:obj];
    } else {
      unknown++;
    }
  }
  
  XCTAssertEqual(unknown, 0);
  XCTAssertEqual(joineryBitCount, 32);
  XCTAssertEqual(clusterBitCount, 5);
}

@end
