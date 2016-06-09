//
//  FBSparseMapGrid.m
//  FrickBits
//
//  Created by Matt McGlincy on 3/13/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBLocation.h"
#import "FBMapGridCell.h"
#import "FBMapGridCellConnection.h"
#import "FBSparseMapGrid.h"
#import "FBUtils.h"
#import "MTGeometry.h"
#import "NSCountedSet+T23.h"

RowCol RowColMake(NSUInteger row, NSUInteger col) {
  RowCol rowCol = {row, col};
  return rowCol;
}

NSString *RowColKey(NSUInteger row, NSUInteger col) {
  return [NSString stringWithFormat:@"%ld,%ld", (long)row, (long)col];
}

NSString *KeyForRowCol(RowCol rowCol) {
  return [NSString
      stringWithFormat:@"%ld,%ld", (long)rowCol.row, (long)rowCol.col];
}

CGFloat FBCellSizeForZoomScale(MKZoomScale zoomScale) {
  // peg cell size for all zoom levels
  return 64;

  /* >>>
   NSInteger zoomLevel = MKZoomScaleToZoomLevel(zoomScale);
   // min zoom (i.e., world view) is 2
   // max MapKit zoom-in is 19
   switch (zoomLevel) {
   case 13:
   case 14:
   case 15:
   return 64;
   case 16:
   case 17:
   case 18:
   return 32;
   case 19:
   return 16;
   default:
   return 64;
   }
   <<< */
}

@interface FBSparseMapGrid ()
// cell size, vs. projected MKMapRectWorld height and width
@property(nonatomic) double cellSize;

@property(nonatomic) NSUInteger minRow;
@property(nonatomic) NSUInteger maxRow;
@property(nonatomic) NSUInteger minCol;
@property(nonatomic) NSUInteger maxCol;

@property(nonatomic) CGFloat averageLocationCount;
@end

@implementation FBSparseMapGrid

- (id)init {
  // some defaults that match our normal FBMapViewController+DataDisplay setup
  double defaultScreenWidth = 320.0;
  double defaultMapWidth = 154573.54443792999;
  double defaultZoomScale = defaultScreenWidth / defaultMapWidth;
  return [self initWithZoomScale:defaultZoomScale];
}

- (id)initWithZoomScale:(double)zoomScale {
  self = [super init];
  if (self) {
    self.cells = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory
                                       valueOptions:NSMapTableStrongMemory];
    self.cellConnections = [NSCountedSet set];

    // zoomScale is pixels per map point
    // previously we were gridding on a 64-pixel-wide cell,
    // so convert to world scale
    self.cellSize = 64.0 * (1.0 / zoomScale);

    self.minRow = UINT_MAX;
    self.maxRow = 0;
    self.minCol = UINT_MAX;
    self.maxCol = 0;
  }
  return self;
}

- (FBMapGridCell *)cellForLocation:(FBLocation *)location {
  RowCol rowCol = [self rowColForCoordinate:location.coordinate];
  NSString *key = KeyForRowCol(rowCol);
  return [self.cells objectForKey:key];
}

- (void)populateWithDataset:(FBDataset *)dataset {
  // add all locations, creating grid cells as we need them
  for (FBLocation *location in dataset.locations) {
    [self addLocation:location];
  }

  // now that we have all our cells with locations assigned, do various
  // additional assignments, like connections
  [self createConnectionsWithDataset:dataset];
  [self calculateCellAverageLocations];

  // simplify connections
  // for shortcutting, we care about connection directionality,
  // so do it before removing inverse connections
  [self simplifyHitShortcut];
  [self removeUnnecessaryDiagonals];

  // connections are directional, but for building the frick view we don't care
  // about direction
  [self removeInverseConnections];

  _averageLocationCount = [self calculateAverageLocationCount];

  // NSLog(@"Populated SparseMapGrid with %ld cells",
  // (long)[_cells.keyEnumerator allObjects].count);
}

- (void)addLocation:(FBLocation *)location {
  RowCol rowCol = [self rowColForCoordinate:location.coordinate];
  NSString *key = KeyForRowCol(rowCol);

  FBMapGridCell *cell = [self.cells objectForKey:key];
  if (!cell) {
    cell = [[FBMapGridCell alloc] init];
    cell.row = rowCol.row;
    cell.col = rowCol.col;
    cell.mapRect = [self mapRectForRowCol:rowCol];
    [self.cells setObject:cell forKey:key];

    // keep track of min/max rowCols of populated cells
    if (rowCol.row < self.minRow) {
      self.minRow = rowCol.row;
    }
    if (rowCol.row > self.maxRow) {
      self.maxRow = rowCol.row;
    }
    if (rowCol.col < self.minCol) {
      self.minCol = rowCol.col;
    }
    if (rowCol.col > self.maxCol) {
      self.maxCol = rowCol.col;
    }
  }

  [cell.locations addObject:location];
  location.cell = cell;
}

- (RowCol)rowColForCoordinate:(CLLocationCoordinate2D)coordinate {
  MKMapPoint point = MKMapPointForCoordinate(coordinate);
  return [self rowColForMapPoint:point];
}

- (RowCol)rowColForMapPoint:(MKMapPoint)point {
  NSUInteger row = floor(point.x / self.cellSize);
  NSUInteger col = floor(point.y / self.cellSize);
  RowCol rowCol = {row, col};
  return rowCol;
}

- (MKMapPoint)mapPointForRowCol:(RowCol)rowCol {
  double x = rowCol.row * self.cellSize;
  double y = rowCol.col * self.cellSize;
  return MKMapPointMake(x, y);
}

- (MKMapRect)mapRectForRowCol:(RowCol)rowCol {
  MKMapPoint mapPoint = [self mapPointForRowCol:rowCol];
  return MKMapRectMake(mapPoint.x, mapPoint.y, self.cellSize, self.cellSize);
}

- (void)createConnectionsWithDataset:(FBDataset *)dataset {

  // Doesn't make sense to have less than 2 points to connect.
  if (dataset.locations.count < 2) {
    return;
  }

  for (NSUInteger i = 0; i < dataset.locations.count - 1; i++) {
    FBMapGridCell *cell = [dataset.locations[i] cell];
    FBMapGridCell *nextCell = [dataset.locations[i + 1] cell];
    if (![cell isEqualToMapGridCell:nextCell]) {
      // these 2 locations cross a cell boundary, so make connections between
      // the cells
      FBMapGridCellConnection *conn1 =
          [FBMapGridCellConnection connectionWithCell1:cell cell2:nextCell];
      [cell.connections addObject:conn1];
      [self.cellConnections addObject:conn1];

      FBMapGridCellConnection *conn2 =
          [FBMapGridCellConnection connectionWithCell1:nextCell cell2:cell];
      [nextCell.connections addObject:conn2];
      [self.cellConnections addObject:conn2];
    }
  }
}

- (void)calculateCellAverageLocations {
  for (id key in self.cells) {
    FBMapGridCell *cell = [self.cells objectForKey:key];
    double latSum = 0;
    double lonSum = 0;

    for (FBLocation *location in cell.locations) {
      latSum += location.latitude;
      lonSum += location.longitude;
    }

    double latAve = latSum / cell.locations.count;
    double lonAve = lonSum / cell.locations.count;
    cell.averageCoordinate = CLLocationCoordinate2DMake(latAve, lonAve);
  }
}

- (void)removeInverseConnections {
  NSMutableSet *toRemove = [NSMutableSet set];
  for (FBMapGridCellConnection *conn in self.cellConnections) {
    if ([toRemove containsObject:conn]) {
      // already marked for removal, so ignore
      continue;
    }
    FBMapGridCellConnection *inverse =
        [FBMapGridCellConnection connectionWithCell1:conn.cell2
                                               cell2:conn.cell1];
    if ([self.cellConnections containsObject:inverse]) {
      [toRemove addObject:inverse];
    }
  }

  for (FBMapGridCellConnection *conn in toRemove) {
    [conn.cell1.connections zeroObject:conn];
    [conn.cell2.connections zeroObject:conn];
    [self.cellConnections zeroObject:conn];
  }
}

- (void)addConnectionsToCells {
  // each cell keeps a list of connections involving it
  for (FBMapGridCellConnection *conn in self.cellConnections) {
    [conn.cell1.connections addObject:conn];
    [conn.cell2.connections addObject:conn];
  }
}

- (FBMapGridCell *)cellAtRow:(NSUInteger)row col:(NSUInteger)col {
  NSString *key = RowColKey(row, col);
  return [self.cells objectForKey:key];
}

- (void)simplifyHitShortcut {
  // Where possible, replace any of our cell connections with "shortcuts":
  // where the path from the from-cell hits another cell with locations before
  // arriving at the intended to-cell target.
  NSCountedSet *simplifiedConns = [NSCountedSet set];
  for (FBMapGridCellConnection *conn in self.cellConnections) {
    FBMapGridCell *nearest =
        [self hitShortcutFromCell:conn.cell1 toCell:conn.cell2];
    if ([nearest isEqualToMapGridCell:conn.cell1] ||
        [nearest isEqualToMapGridCell:conn.cell2]) {
      // no improvement
      [simplifiedConns addObject:conn];
    } else {
      // found a shortcut, so make a new connection from our start cell to the
      // shortcut cell
      FBMapGridCellConnection *shortcutConn =
          [FBMapGridCellConnection connectionWithCell1:conn.cell1
                                                 cell2:nearest];
      [simplifiedConns addObject:shortcutConn];

      // update the cells' connections, too
      NSUInteger count = [conn.cell1.connections countForObject:conn];
      [conn.cell1.connections zeroObject:conn];
      [conn.cell2.connections zeroObject:conn];

      [shortcutConn.cell1.connections addObject:shortcutConn count:count];
      [shortcutConn.cell2.connections addObject:shortcutConn count:count];

      // To avoid orphan segments and gaps, also make a connection from the
      // shortcut to the previous end cell.
      // We only add this remainder connection when the shortcut and destination
      // are adjacent.
      // This addresses our most common gap-creating problem scenario:
      // 0---->1-------->2------->3
      //           4<------------
      // without creating too many new connections or diagonals.
      if ([nearest isNonDiagonalAdjacentToMapGridCell:conn.cell2]) {
        FBMapGridCellConnection *remainderConn =
            [FBMapGridCellConnection connectionWithCell1:nearest
                                                   cell2:conn.cell2];
        [simplifiedConns addObject:remainderConn];
        [remainderConn.cell1.connections addObject:remainderConn count:count];
        [remainderConn.cell2.connections addObject:remainderConn count:count];
      }
    }
  }
  self.cellConnections = simplifiedConns;
}

- (FBMapGridCell *)hitShortcutFromCell:(FBMapGridCell *)fromCell
                                toCell:(FBMapGridCell *)toCell {
  NSInteger rowDelta = toCell.row - fromCell.row;
  NSInteger colDelta = toCell.col - fromCell.col;
  if ((labs(rowDelta) <= 1 && colDelta == 0) ||
      (rowDelta == 0 && labs(colDelta) <= 1)) {
    // same cell, or just 1 row or col adjacent, non-diagonal
    return toCell;
  }

  if (labs(rowDelta) > 25 || labs(colDelta) > 25) {
    // performance optimization: don't try to detect shortcuts across large
    // distances,
    // because our nested do-while loops below have horrible performance.
    // TODO: improve our hit-shortcut algorithm :P
    return toCell;
  }

  MKMapPoint fromMapPoint = MKMapPointForCoordinate(fromCell.averageCoordinate);
  MKMapPoint toMapPoint = MKMapPointForCoordinate(toCell.averageCoordinate);
  CGPoint fromPoint = CGPointMake(fromMapPoint.x, fromMapPoint.y);
  CGPoint toPoint = CGPointMake(toMapPoint.x, toMapPoint.y);
  if (CGPointEqualToPoint(fromPoint, toPoint)) {
    // coordinates map to the same x/y point, so give up.
    // (This apparently can happen for edge or aberrant points on the map.)
    return toCell;
  }

  CGLine line = CGLineMake(fromPoint, toPoint);

  NSInteger rowIncrement, colIncrement;
  if (rowDelta > 0) {
    rowIncrement = 1;
  } else if (rowDelta < 0) {
    rowIncrement = -1;
  } else {
    rowIncrement = 0;
  }
  if (colDelta > 0) {
    colIncrement = 1;
  } else if (colDelta < 0) {
    colIncrement = -1;
  } else {
    colIncrement = 0;
  }

  // Start at the from cell, and iterate over the grid of cells towards the to
  // cell, looking for shortcuts.
  // We use a do-while so we include the toCell row/col iteration in our checks.
  NSUInteger row = fromCell.row;
  do {
    NSUInteger col = fromCell.col;
    do {
      if (row == toCell.row && col == toCell.col) {
        // made it to the toCell without finding a shortcut
        return toCell;
      }

      // check everything except the starting cell
      if (row != fromCell.row || col != fromCell.col) {
        FBMapGridCell *cell = [self cellAtRow:row col:col];
        // only check valid cells
        if (cell && cell.locations.count > 0) {
          CGRect cellRect =
              CGRectMake(cell.mapRect.origin.x, cell.mapRect.origin.y,
                         cell.mapRect.size.width, cell.mapRect.size.height);
          CGPoint intersection = CGLineIntersectsRectAtPoint(cellRect, line);
          if (!CGPointEqualToPoint(intersection, NULL_POINT)) {
            // intersection with a valid cell, so thus a valid shortcut
            return cell;
          }
        }
      }

      col += colIncrement;
    } while (col != (toCell.col + colIncrement));

    row += rowIncrement;
  } while (row != (toCell.row + rowIncrement));

  return toCell;
}

// remove diagonals if we have a horizontal + vertical to cover it
// +--+
// | /
// |/
// +
//    +
//   /|
//  / |
// +--+
// +--+
//  \ |
//   \|
//    +
// +
// |\
// | \
// +--+
- (void)removeUnnecessaryDiagonals {
  for (id key in self.cells) {
    // treat current row-col as UL corner for our check
    // +--+
    // |  |
    // |  |
    // +--+
    FBMapGridCell *ul = [self.cells objectForKey:key];

    FBMapGridCell *ur = [self cellAtRow:ul.row col:ul.col + 1];
    FBMapGridCell *lr = [self cellAtRow:ul.row + 1 col:ul.col + 1];
    FBMapGridCell *ll = [self cellAtRow:ul.row + 1 col:ul.col];
    // TODO: decide how we want to handle sparseness
    if (!ur || !lr || !ll) {
      // if we don't have all 4 cells/corners, don't bother eliminating
      // diagonals
      continue;
    }

    BOOL top = [ul hasConnectionToCell:ur] || [ur hasConnectionToCell:ul];
    BOOL bottom = [ll hasConnectionToCell:lr] || [lr hasConnectionToCell:ll];
    BOOL left = [ul hasConnectionToCell:ll] || [ll hasConnectionToCell:ul];
    BOOL right = [ur hasConnectionToCell:lr] || [lr hasConnectionToCell:ur];

    if ((top && left) || (bottom && right)) {
      // +--+
      // | /
      // |/
      // +
      //    +
      //   /|
      //  / |
      // +--+
      [self removeConnectionsFromCell:ll toCell:ur];
      [self removeConnectionsFromCell:ur toCell:ll];
    }

    if ((top && right) || (bottom && left)) {
      // +--+
      //  \ |
      //   \|
      //    +
      // +
      // |\
      // | \
      // +--+
      [self removeConnectionsFromCell:ul toCell:lr];
      [self removeConnectionsFromCell:lr toCell:ul];
    }
  }
}

- (void)removeConnectionsFromCell:(FBMapGridCell *)cell1
                           toCell:(FBMapGridCell *)cell2 {
  NSMutableSet *connsToRemove = [NSMutableSet set];

  for (FBMapGridCellConnection *conn in cell1.connections) {
    if ([conn.cell1 isEqualToMapGridCell:cell2] ||
        [conn.cell2 isEqualToMapGridCell:cell2]) {
      [connsToRemove addObject:conn];
    }
  }

  for (FBMapGridCellConnection *conn in connsToRemove) {
    [self.cellConnections zeroObject:conn];
  }
}

- (CGFloat)calculateAverageLocationCount {
  CGFloat sum = 0;
  NSUInteger count = 0;

  for (NSString *key in self.cells.keyEnumerator) {
    FBMapGridCell *cell = [self.cells objectForKey:key];
    sum += cell.locations.count;
    count++;
  }

  return sum / count;
}

// calculate the average location count for cells in a map grid, within the
// given upper-left and lower-right bounds.
- (CGFloat)averageLocationCountWithULRowCol:(RowCol)ulRowCol
                                   lrRowCol:(RowCol)lrRowCol {
  CGFloat sum = 0;
  NSUInteger count = 0;

  // add joinery bits, and keep track of currently-onscreen connections
  for (NSUInteger row = ulRowCol.row; row <= lrRowCol.row; row++) {
    for (NSUInteger col = ulRowCol.col; col <= lrRowCol.col; col++) {
      FBMapGridCell *cell = [self cellAtRow:row col:col];
      // cell might not exist in sparse grid
      if (cell) {
        count++;
        sum += cell.locations.count;
      }
    }
  }

  if (count == 0) {
    return 0.0;
  } else {
    return sum / count;
  }
}

@end
