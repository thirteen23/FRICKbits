//
//  FBMapGridCellConnection2.m
//  FrickBits
//
//  Created by Matt McGlincy on 1/31/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBMapGridCellConnection.h"
#import "FBUtils.h"

@implementation FBMapGridCellConnection

+ (id)connectionWithCell1:(FBMapGridCell *)cell1 cell2:(FBMapGridCell *)cell2 {
  FBMapGridCellConnection *conn = [[FBMapGridCellConnection alloc] init];
  conn.cell1 = cell1;
  conn.cell2 = cell2;
  return conn;
}

- (NSUInteger)hash {
  //return [self.cell1 hash] ^ [self.cell2 hash];
  NSUInteger hash = _cell1.row;
  hash = hash * 17 + _cell1.col;
  hash = hash * 31 + _cell2.row;
  hash = hash * 13 + _cell2.col;
  return hash;
}

- (BOOL)isEqual:(id)other {
  if (other == self) {
    return YES;
  }
  if (![other isKindOfClass:[FBMapGridCellConnection class]]) {
    return NO;
  }
  return [self isEqualToMapGridCellConnection:other];
}

- (BOOL)isEqualToMapGridCellConnection:(FBMapGridCellConnection *)connection {
  if (self == connection) {
    return YES;
  }
  
  // directed
  return ([self.cell1 isEqualToMapGridCell:connection.cell1] &&
          [self.cell2 isEqualToMapGridCell:connection.cell2]);

  // undirected
//  return (([self.cell1 isEqualToMapGridCell:connection.cell1] &&
//           [self.cell2 isEqualToMapGridCell:connection.cell2]) ||
//          ([self.cell1 isEqualToMapGridCell:connection.cell2] &&
//           [self.cell2 isEqualToMapGridCell:connection.cell1]));
}

- (NSString *)stringKey {
  return [NSString stringWithFormat:@"(%ld,%ld)=>(%ld,%ld)",
                                    (long)self.cell1.row, (long)self.cell1.col,
                                    (long)self.cell2.row, (long)self.cell2.col];
}

- (CGFloat)angleDegrees {
  MKMapPoint p1 = MKMapPointForCoordinate(self.cell1.averageCoordinate);
  MKMapPoint p2 = MKMapPointForCoordinate(self.cell2.averageCoordinate);
  return DegreesBetweenPoints(CGPointMake(p1.x, p1.y), CGPointMake(p2.x, p2.y));
}

- (CGFloat)positiveAngleDegrees {
  MKMapPoint p1 = MKMapPointForCoordinate(self.cell1.averageCoordinate);
  MKMapPoint p2 = MKMapPointForCoordinate(self.cell2.averageCoordinate);
  CGFloat degrees =
      DegreesBetweenPoints(CGPointMake(p1.x, p1.y), CGPointMake(p2.x, p2.y));
  // since connections are undirected, we're only considering the positive angle
  // between them
  if (degrees < 0) {
    degrees += 180;
  }
  return degrees;
}

- (BOOL)includesCell:(FBMapGridCell *)cell {
  return ([self.cell1 isEqualToMapGridCell:cell] ||
          [self.cell2 isEqualToMapGridCell:cell]);
}

- (NSString *)description {
  return [NSString stringWithFormat:@"FBMapGridCellConnection <%p> %@", self, [self stringKey]];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
  id copy = [[[self class] alloc] init];
  if (copy) {
    [copy setCell1:self.cell1];
    [copy setCell2:self.cell2];
  }
  return copy;
}

@end
