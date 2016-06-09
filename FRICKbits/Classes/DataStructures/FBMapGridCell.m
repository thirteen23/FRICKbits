//
//  FBMapGridCell.m
//  FrickBits
//
//  Created by Matt McGlincy on 1/31/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBMapGridCell.h"
#import "FBMapGridCellConnection.h"
#import "FBUtils.h"

@implementation FBMapGridCell

- (id)init {
  self = [super init];
  if (self) {
    self.connections = [NSCountedSet set];
    self.locations = [NSMutableArray array];
  }
  return self;
}

#pragma mark - isEqual

- (NSUInteger)hash {
  return _row + 9999 * _col;
}

- (BOOL)isEqual:(id)other {
  if (other == self) {
    return YES;
  }
  if (![other isKindOfClass:[FBMapGridCell class]]) {
    return NO;
  }
  return [self isEqualToMapGridCell:(FBMapGridCell *)other];
}

- (BOOL)isEqualToMapGridCell:(FBMapGridCell *)cell {
  // 2 cells are equal if they have the same row and col
  if (self == cell) {
    return YES;
  }
  return (_row == cell.row && _col == cell.col);
}

- (BOOL)isAdjacentToMapGridCell:(FBMapGridCell *)cell {
  NSInteger rowDelta = labs(_row - cell.row);
  NSInteger colDelta = labs(_col - cell.col);
  return (
      // next to, same row
      (rowDelta == 0 && colDelta == 1) ||
      // next to, same col
      (rowDelta == 1 && colDelta == 0) ||
      // next to, diagonal
      (rowDelta == 1 && colDelta == 1));
}

- (BOOL)isNonDiagonalAdjacentToMapGridCell:(FBMapGridCell *)cell {
  NSInteger rowDelta = labs(_row - cell.row);
  NSInteger colDelta = labs(_col - cell.col);
  return (
          // next to, same row
          (rowDelta == 0 && colDelta == 1) ||
          // next to, same col
          (rowDelta == 1 && colDelta == 0)
          );
}

- (CGFloat)averageConnectionDegrees {
  if (self.connections.count == 0) {
    return 0;
  }
  CGFloat sum = 0;
  for (FBMapGridCellConnection *conn in self.connections) {
    MKMapPoint p1 = MKMapPointForCoordinate(conn.cell1.averageCoordinate);
    MKMapPoint p2 = MKMapPointForCoordinate(conn.cell2.averageCoordinate);
    CGFloat degrees =
        DegreesBetweenPoints(CGPointMake(p1.x, p1.y), CGPointMake(p2.x, p2.y));
    // since connections are undirected, we're only considering the positive
    // angle between them
    if (degrees < 0) {
      degrees += 180;
    }
    sum += degrees;
  }
  return sum / (CGFloat)self.connections.count;
}

- (FBMapGridCellConnection *)anyConnection {
  return [[self.connections objectEnumerator] nextObject];
}

- (FBMapGridCellConnection *)strongestConnection {
  FBMapGridCellConnection *strongestConn = nil;
  NSUInteger highestCount = 0;
  for (FBMapGridCellConnection *conn in self.connections) {
    NSUInteger count = [self.connections countForObject:conn];
    if (count > highestCount) {
      highestCount = count;
      strongestConn = conn;
    }
  }
  return strongestConn;
}

- (BOOL)hasConnectionToCell:(FBMapGridCell *)cell {
  for (FBMapGridCellConnection *conn in self.connections) {
    if ([conn.cell1 isEqualToMapGridCell:cell] ||
        [conn.cell2 isEqualToMapGridCell:cell]) {
      return YES;
    }
  }
  return NO;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@: %p, (%ld,%ld)>", [self class], self,
                   (long)self.row,
                   (long)self.col];
}

- (void)debugLog {
  NSLog(@"cell (%ld,%ld)", (long)self.row, (long)self.col);
  for (FBMapGridCellConnection *conn in self.connections) {
    NSLog(@"(%ld,%ld)<=>(%ld,%ld)", (long)conn.cell1.row, (long)conn.cell1.col,
          (long)conn.cell2.row, (long)conn.cell2.col);
  }
}

- (void)addConnectionToCell:(FBMapGridCell *)cell {
  FBMapGridCellConnection *conn = [FBMapGridCellConnection connectionWithCell1:self cell2:cell];
  [self.connections addObject:conn];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
  id copy = [[[self class] alloc] init];

  if (copy) {
    // Copy NSObject subclasses
    [copy setRow:self.row];
    [copy setCol:self.col];
    [copy setMapRect:self.mapRect];
    [copy setAverageCoordinate:self.averageCoordinate];
    [copy setLocations:[self.locations copyWithZone:zone]];
    [copy setConnections:[self.connections copyWithZone:zone]];
  }

  return copy;
}

@end
