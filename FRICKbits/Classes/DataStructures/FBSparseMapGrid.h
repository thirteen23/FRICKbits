//
//  FBSparseMapGrid.h
//  FrickBits
//
//  Created by Matt McGlincy on 3/13/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBDataset.h"
#import "FBLocation.h"
#import "FBMapGridCell.h"

typedef struct {
  NSUInteger row;
  NSUInteger col;
} RowCol;
extern RowCol RowColMake(NSUInteger row, NSUInteger col);
extern NSString *RowColKey(NSUInteger row, NSUInteger col);
extern NSString *KeyForRowCol(RowCol rowCol);

extern CGFloat FBCellSizeForZoomScale(MKZoomScale zoomScale);

@interface FBSparseMapGrid : NSObject

// cell size, vs. projected MKMapRectWorld height and width
@property(nonatomic, readonly) double cellSize;

// map of rowcol string key => FBMapGridCell
@property(nonatomic, strong) NSMapTable *cells;

// min/max populated cell row/col
@property(nonatomic, readonly) NSUInteger minRow;
@property(nonatomic, readonly) NSUInteger maxRow;
@property(nonatomic, readonly) NSUInteger minCol;
@property(nonatomic, readonly) NSUInteger maxCol;

// counts of all cell connections
@property(nonatomic, strong) NSCountedSet *cellConnections;

@property(nonatomic, readonly) CGFloat averageLocationCount;

- (id)initWithZoomScale:(double)zoomScale;
- (void)populateWithDataset:(FBDataset *)dataset;

- (FBMapGridCell *)cellAtRow:(NSUInteger)row col:(NSUInteger)col;
- (FBMapGridCell *)cellForLocation:(FBLocation *)location;

- (FBMapGridCell *)hitShortcutFromCell:(FBMapGridCell *)fromCell toCell:(FBMapGridCell *)toCell;

- (RowCol)rowColForCoordinate:(CLLocationCoordinate2D)coordinate;
- (RowCol)rowColForMapPoint:(MKMapPoint)point;

- (CGFloat)averageLocationCountWithULRowCol:(RowCol)ulRowCol lrRowCol:(RowCol)lrRowCol;

// exposed for unit testing
- (void)addLocation:(FBLocation *)location;
- (void)simplifyHitShortcut;
- (void)createConnectionsWithDataset:(FBDataset *)dataset;
- (void)calculateCellAverageLocations;
- (void)removeInverseConnections;

@end
