//
//  FBSparseMapGridTest.m
//  FrickBits
//
//  Created by Matt McGlincy on 3/13/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FBLocation.h"
#import "FBMapGridCellConnection.h"
#import "FBSparseMapGrid.h"
#import "T23CountedSet.h"

@interface FBSparseMapGridTest : XCTestCase

@end

@implementation FBSparseMapGridTest

- (void)setUp {
  [super setUp];
}

- (void)tearDown {
  [super tearDown];
}

- (FBSparseMapGrid *)makeGridWithRows:(NSInteger)rows cols:(NSInteger)cols {
  FBSparseMapGrid *grid = [[FBSparseMapGrid alloc] init];
  for (int row = 0; row < rows; row++) {
    for (int col = 0; col < cols; col++) {
      FBMapGridCell *cell = [[FBMapGridCell alloc] init];
      cell.row = row;
      cell.col = col;
      cell.mapRect = MKMapRectMake(col * grid.cellSize, row * grid.cellSize, grid.cellSize, grid.cellSize);
      [grid.cells setObject:cell forKey:RowColKey(row, col)];
    }
  }
  return grid;
}

- (void)testCellAtRowCol {
  int rows = 4;
  int cols = 3;
  FBSparseMapGrid *grid = [self makeGridWithRows:rows cols:cols];
  for (int row = 0; row < rows; row++) {
    for (int col = 0; col < cols; col++) {
      FBMapGridCell *cell = [grid cellAtRow:row col:col];
      XCTAssertNotNil(cell, @"Shouldn't be nil.");
      XCTAssertEqual(cell.row, row, @"Wrong row");
      XCTAssertEqual(cell.col, col, @"Wrong col");
    }
  }
}

MKMapPoint MKMapRectCenter(MKMapRect rect) {
  return MKMapPointMake(rect.origin.x + rect.size.width / 2.0, rect.origin.y + rect.size.height / 2.0);
}

- (void)addCenterLocationToCell:(FBMapGridCell *)cell {
  MKMapPoint mapPoint = MKMapRectCenter(cell.mapRect);
  CLLocationCoordinate2D coord = MKCoordinateForMapPoint(mapPoint);
  FBLocation *loc = [[FBLocation alloc] initWithLatitude:coord.latitude longitude:coord.longitude];
  [cell.locations addObject:loc];
  // TODO: should averageCoordinate be a computed value rather than a property?
  cell.averageCoordinate = coord;
}

- (void)testHitShortcutSingleRow {
  // simplest case: 1 row, 3 columns, try to connect the left- and right-most,
  // and we should hit the center as the nearest if it has locations within in.
  
  // TODO: for some reason, MKMapPointForCoordinate is returning the same map point for different
  // coordinates near the edges of the map. Maybe a projection issue near the poles?
  // We use a bigger grid to ensure we're getting sufficiently different map points.
  int rows = 100;
  int cols = 100;
  FBSparseMapGrid *grid = [self makeGridWithRows:rows cols:cols];
  
  FBMapGridCell *left = [grid cellAtRow:50 col:50];
  [self addCenterLocationToCell:left];
  
  FBMapGridCell *center = [grid cellAtRow:50 col:55];
  
  FBMapGridCell *right = [grid cellAtRow:50 col:60];
  [self addCenterLocationToCell:right];
  
  // no locations in the center, so we should keep going until the end
  XCTAssertTrue([[grid hitShortcutFromCell:left toCell:right]
                 isEqualToMapGridCell:right],
                @"Wrong cell");
  XCTAssertTrue([[grid hitShortcutFromCell:right toCell:left]
                 isEqualToMapGridCell:left],
                @"Wrong cell");
  
  // but with locations, the center is now a valid short-circuit
  [self addCenterLocationToCell:center];
  XCTAssertTrue([[grid hitShortcutFromCell:left toCell:right]
                 isEqualToMapGridCell:center],
                @"Wrong cell");
  XCTAssertTrue([[grid hitShortcutFromCell:right toCell:left]
                 isEqualToMapGridCell:center],
                @"Wrong cell");
}

- (void)testHitShortcutSingleColumn {
  // same sort of simple test, but this time with only one column
  
  // TODO: for some reason, MKMapPointForCoordinate is returning the same map point for different
  // coordinates near the edges of the map. Maybe a projection issue near the poles?
  // We use a bigger grid to ensure we're getting sufficiently different map points.
  int rows = 100;
  int cols = 100;
  FBSparseMapGrid *grid = [self makeGridWithRows:rows cols:cols];
  
  FBMapGridCell *top = [grid cellAtRow:50 col:50];
  [self addCenterLocationToCell:top];

  FBMapGridCell *center = [grid cellAtRow:55 col:50];
  
  FBMapGridCell *bottom = [grid cellAtRow:60 col:50];
  [self addCenterLocationToCell:bottom];
  
  // no locations in the center, so we should keep going until the end
  XCTAssertTrue([[grid hitShortcutFromCell:top toCell:bottom]
                 isEqualToMapGridCell:bottom],
                @"Wrong cell");
  XCTAssertTrue([[grid hitShortcutFromCell:bottom toCell:top]
                 isEqualToMapGridCell:top],
                @"Wrong cell");
  
  // but with locations, the center is now a valid short-circuit
  [self addCenterLocationToCell:center];
  XCTAssertTrue([[grid hitShortcutFromCell:top toCell:bottom]
                 isEqualToMapGridCell:center],
                @"Wrong cell");
  XCTAssertTrue([[grid hitShortcutFromCell:bottom toCell:top]
                 isEqualToMapGridCell:center],
                @"Wrong cell");
}

- (void)testHitShortcutDiagonal {
  // TODO: for some reason, MKMapPointForCoordinate is returning the same map point for different
  // coordinates near the edges of the map. Maybe a projection issue near the poles?
  // We use a bigger grid to ensure we're getting sufficiently different map points.
  int rows = 100;
  int cols = 100;
  FBSparseMapGrid *grid = [self makeGridWithRows:rows cols:cols];
  
  FBMapGridCell *top = [grid cellAtRow:50 col:50];
  [self addCenterLocationToCell:top];
  
  FBMapGridCell *center = [grid cellAtRow:55 col:55];
  
  FBMapGridCell *bottom = [grid cellAtRow:60 col:60];
  [self addCenterLocationToCell:bottom];

  // no locations in the center, so we should keep going until the end
  XCTAssertTrue([[grid hitShortcutFromCell:top toCell:bottom]
                 isEqualToMapGridCell:bottom],
                @"Wrong cell");
  XCTAssertTrue([[grid hitShortcutFromCell:bottom toCell:top]
                 isEqualToMapGridCell:top],
                @"Wrong cell");
  
  // but with locations, the center is now a valid short-circuit
  [center.locations addObject:[[FBLocation alloc] init]];
  [self addCenterLocationToCell:center];

  XCTAssertTrue([[grid hitShortcutFromCell:top toCell:bottom]
                 isEqualToMapGridCell:center],
                @"Wrong cell");
  XCTAssertTrue([[grid hitShortcutFromCell:bottom toCell:top]
                 isEqualToMapGridCell:center],
                @"Wrong cell");
}

- (void)testRowColSize {
  // fit entire world into one screen-width
  MKMapRect mapRect = MKMapRectWorld;
  CGFloat screenWidth = 320.0;
  double zoomScale = screenWidth / mapRect.size.width;
  FBSparseMapGrid *mapGrid =
      [[FBSparseMapGrid alloc] initWithZoomScale:zoomScale];
  double expectedCellSize = 64.0 * (1 / zoomScale);
  XCTAssertEqualWithAccuracy(mapGrid.cellSize, expectedCellSize, 0.00001,
                             @"Wrong cell size");

  // at 64 screen pixels per cell, our screen should have about 320 / 64 = 5
  // cells
  // to cover the entire world width.
  XCTAssertEqual(floor(mapRect.size.width / mapGrid.cellSize), 5,
                 @"Wrong number of cells");
}

- (void)testRowColForMapPoint {
  MKMapRect mapRect = MKMapRectWorld;
  CGFloat screenWidth = 320.0;
  double zoomScale = screenWidth / mapRect.size.width;
  FBSparseMapGrid *mapGrid =
      [[FBSparseMapGrid alloc] initWithZoomScale:zoomScale];

  RowCol rc = [mapGrid rowColForMapPoint:MKMapPointMake(0, 0)];
  XCTAssertEqual(rc.row, 0, @"Wrong rowCol");
  XCTAssertEqual(rc.col, 0, @"Wrong rowCol");

  MKMapPoint lr =
      MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect));
  RowCol lrRowCol = [mapGrid rowColForMapPoint:lr];
  XCTAssertEqual(lrRowCol.row, 5, @"Wrong rowCol");
  XCTAssertEqual(lrRowCol.col, 5, @"Wrong rowCol");
}

- (void)testOrphan {
  NSString *filePath = [[NSBundle bundleForClass:[self class]]
                        pathForResource:@"test_orphan_point"
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
  NSArray *cells = [[mapGrid.cells objectEnumerator] allObjects];
  XCTAssertEqual(cells.count, 2);
  FBMapGridCell *cell1 = cells[0];
  FBMapGridCell *cell2 = cells[1];
  
  // after simplification and inverse removal, we have only one connection between the cells
  XCTAssertEqual(mapGrid.cellConnections.count, 1);
  FBMapGridCellConnection *conn = [FBMapGridCellConnection connectionWithCell1:cell1 cell2:cell2];
  XCTAssertTrue([mapGrid.cellConnections containsObject:conn]);
}

@end
