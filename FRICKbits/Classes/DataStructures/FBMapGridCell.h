//
//  FBMapGridCell.h
//  FrickBits
//
//  Created by Matt McGlincy on 1/31/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

@class FBJoineryBitLayer;
@class FBMapGridCellConnection;

@interface FBMapGridCell : NSObject<NSCopying>

@property(nonatomic) NSInteger row;
@property(nonatomic) NSInteger col;

@property(nonatomic) MKMapRect mapRect;

// average coordinate of all our locations
@property(nonatomic) CLLocationCoordinate2D averageCoordinate;

// FBLocations found within this grid cell
@property(nonatomic, strong) NSMutableArray *locations;

// FBMapGridCellConnections going to/from this cell
@property(nonatomic, strong) NSCountedSet *connections;

- (BOOL)isEqualToMapGridCell:(FBMapGridCell *)cell;
- (BOOL)isAdjacentToMapGridCell:(FBMapGridCell *)cell;
- (BOOL)isNonDiagonalAdjacentToMapGridCell:(FBMapGridCell *)cell;

- (FBMapGridCellConnection *)anyConnection;
- (FBMapGridCellConnection *)strongestConnection;

- (CGFloat)averageConnectionDegrees;

- (BOOL)hasConnectionToCell:(FBMapGridCell *)cell;

- (void)addConnectionToCell:(FBMapGridCell *)cell;

- (void)debugLog;

@end
