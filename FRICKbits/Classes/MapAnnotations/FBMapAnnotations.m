//
// Created by Matt McGlincy on 4/23/14.
// Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBClusterCountAnnotation.h"
#import "FBClusterCountAnnotationView.h"
#import "FBDotAnnotation.h"
#import "FBDotAnnotationView.h"
#import "FBGridCellAnnotation.h"
#import "FBGridCellAnnotationView.h"
#import "FBGridCellLocationsOverlay.h"
#import "FBMapAnnotations.h"
#import "FBMapGridCellConnection.h"
#import "FBSparseMapGrid.h"
#import "FBGridCellAnnotation.h"
#import "FBLocation.h"
#import "TBQuadTree.h"
#import "FBClusterCountAnnotation.h"
#import "TBUtils.h"


static CGFloat kZPositionClusterCount = 1;
static CGFloat kZPositionDot = 2;
static CGFloat kZPositionGridCell = 0;

// We put different annotations at different Z positions.
// E.g., dots on top of lines.
CGFloat ZPositionForAnnotationView(UIView *view) {
  // TODO: we could make a ZPositionAnnotation protocol for the
  // MKAnnotationView
  // subclasses
  if ([view isKindOfClass:[FBClusterCountAnnotationView class]]) {
    return kZPositionClusterCount;
  }
  if ([view isKindOfClass:[FBDotAnnotationView class]]) {
    return kZPositionDot;
  }
  if ([view isKindOfClass:[FBGridCellAnnotationView class]]) {
    return kZPositionGridCell;
  }
  return 0;
}

@implementation FBMapAnnotations

+ (NSMutableArray *)gridCellAnnotationsForGrid:(FBSparseMapGrid *)grid {
  NSMutableArray *annotations = [NSMutableArray array];
  for (id key in grid.cells) {
    FBMapGridCell *cell = [grid.cells objectForKey:key];
    CLLocationCoordinate2D
        originLocation = MKCoordinateForMapPoint(cell.mapRect.origin);
    FBGridCellAnnotation *cellAnno =
        [[FBGridCellAnnotation alloc] initWithCoordinate:originLocation];
    cellAnno.cell = cell;
    [annotations addObject:cellAnno];
  }
  return annotations;
}

+ (NSMutableArray *)dotAnnotationsWithMapGrid:(FBSparseMapGrid *)mapGrid {
  NSMutableArray *annotations = [[NSMutableArray alloc] init];

  for (id key in mapGrid.cells) {
    FBMapGridCell *cell = [mapGrid.cells objectForKey:key];
    if (cell.locations.count > 0) {
      // dot for the average location
      FBDotAnnotation *dotAnno = [[FBDotAnnotation alloc] initWithCoordinate:cell.averageCoordinate];
      [annotations addObject:dotAnno];
      
#if FB_INCLUDE_POINT_ANNOTATIONS
      // point for each location
      for (FBLocation *location in cell.locations) {
        FBPointAnnotation *pointAnno = [[FBPointAnnotation alloc] initWithCoordinate:location.coordinate];
        [annotations addObject:pointAnno];
      }
#endif
    }
  }
  return annotations;
}

+ (NSMutableArray *)dotAnnotationsWithMapRect:(MKMapRect)mapRect mapGrid:(FBSparseMapGrid *)mapGrid {
  NSMutableArray *annotations = [[NSMutableArray alloc] init];

  // get the upper-left and lower-right rowCol for our sparse grid
  MKMapPoint ulMapPoint =
      MKMapPointMake(MKMapRectGetMinX(mapRect), MKMapRectGetMinY(mapRect));
  MKMapPoint lrMapPoint =
      MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect));
  RowCol ulRowCol = [mapGrid rowColForMapPoint:ulMapPoint];
  RowCol lrRowCol = [mapGrid rowColForMapPoint:lrMapPoint];

  // annotations for each cell
  for (NSUInteger row = ulRowCol.row; row <= lrRowCol.row; row++) {
    for (NSUInteger col = ulRowCol.col; col <= lrRowCol.col; col++) {
      FBMapGridCell *cell = [mapGrid cellAtRow:row col:col];
      if (!cell) {
        continue;
      }
      if (cell.locations.count > 0) {
        // dot for the average location
        FBDotAnnotation *dotAnno =
            [[FBDotAnnotation alloc] initWithCoordinate:cell.averageCoordinate];
        [annotations addObject:dotAnno];        
      }
    }
  }
  return annotations;
}

+ (NSMutableArray *)clusterCountAnnotationsWithinMapRect:(MKMapRect)rect
    withZoomScale:(double)zoomScale treeNode:(TBQuadTreeNode *)treeNode {
  double cellSize = FBCellSizeForZoomScale(zoomScale);
  double scaleFactor = zoomScale / cellSize;

  NSInteger minX = floor(MKMapRectGetMinX(rect) * scaleFactor);
  NSInteger maxX = floor(MKMapRectGetMaxX(rect) * scaleFactor);
  NSInteger minY = floor(MKMapRectGetMinY(rect) * scaleFactor);
  NSInteger maxY = floor(MKMapRectGetMaxY(rect) * scaleFactor);

  NSMutableArray *annotations = [[NSMutableArray alloc] init];

  // step through our grid cells, by col by row
  for (NSInteger x = minX; x <= maxX; x++) {
    for (NSInteger y = minY; y <= maxY; y++) {
      MKMapRect mapRect =
          MKMapRectMake(x / scaleFactor, y / scaleFactor, 1.0 / scaleFactor,
              1.0 / scaleFactor);
      __block double totalX = 0;
      __block double totalY = 0;
      __block int count = 0;

      TBQuadTreeGatherDataInRange(treeNode,
          TBBoundingBoxForMapRect(mapRect), ^(TBQuadTreeNodeData data) {
            totalX += data.x;
            totalY += data.y;
            count++;
          });

      CLLocationCoordinate2D coordinate =
          CLLocationCoordinate2DMake(totalX / count, totalY / count);
      FBClusterCountAnnotation *annotation = [[FBClusterCountAnnotation alloc]
                                                                        initWithCoordinate:coordinate
          count:count];
      [annotations addObject:annotation];
    }
  }

  return annotations;
}

#pragma mark - overlays

+ (NSMutableArray *)polylineOverlaysWithMapRect:(MKMapRect)mapRect mapGrid:(FBSparseMapGrid *)mapGrid {
  // get the upper-left and lower-right rowCol for our sparse grid
  MKMapPoint ulMapPoint =
      MKMapPointMake(MKMapRectGetMinX(mapRect), MKMapRectGetMinY(mapRect));
  MKMapPoint lrMapPoint =
      MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect));
  RowCol ulRowCol = [mapGrid rowColForMapPoint:ulMapPoint];
  RowCol lrRowCol = [mapGrid rowColForMapPoint:lrMapPoint];

  NSMutableArray *lines = [NSMutableArray array];
  for (FBMapGridCellConnection *conn in mapGrid.cellConnections) {
    CLLocationCoordinate2D fromCoord = conn.cell1.averageCoordinate;
    CLLocationCoordinate2D toCoord = conn.cell2.averageCoordinate;
    RowCol fromRowCol =
        [mapGrid rowColForMapPoint:MKMapPointForCoordinate(fromCoord)];
    RowCol
        toRowCol = [mapGrid rowColForMapPoint:MKMapPointForCoordinate(toCoord)];

    if (!((fromRowCol.row >= ulRowCol.row && fromRowCol.row <= lrRowCol.row &&
           fromRowCol.col >= ulRowCol.col && fromRowCol.col <= lrRowCol.col) ||
          (toRowCol.row >= ulRowCol.row && toRowCol.row <= lrRowCol.row &&
           toRowCol.col >= ulRowCol.col && toRowCol.col <= lrRowCol.col))) {
      // both rowCols are offscreen, so skip this connection
      continue;
    }

    CLLocationCoordinate2D coordinates[] = {fromCoord, toCoord};
    MKPolyline *line = [MKPolyline polylineWithCoordinates:coordinates count:2];
    [lines addObject:line];
  }
  return lines;
}

+ (NSMutableArray *)polylineOverlaysWithMapGrid:(FBSparseMapGrid *)mapGrid {
  NSMutableArray *lines = [NSMutableArray array];
  for (FBMapGridCellConnection *conn in mapGrid.cellConnections) {
    CLLocationCoordinate2D fromCoord = conn.cell1.averageCoordinate;
    CLLocationCoordinate2D toCoord = conn.cell2.averageCoordinate;
    CLLocationCoordinate2D coordinates[] = {fromCoord, toCoord};
    MKPolyline *line = [MKPolyline polylineWithCoordinates:coordinates count:2];
    [lines addObject:line];
  }
  return lines;
}

+ (NSMutableArray *)cellLocationsOverlaysWithMapGrid:(FBSparseMapGrid *)mapGrid {
  NSMutableArray *overlays = [NSMutableArray array];
  for (id key in mapGrid.cells) {
    FBMapGridCell *cell = [mapGrid.cells objectForKey:key];
    FBGridCellLocationsOverlay *overlay = [[FBGridCellLocationsOverlay alloc] initWithMapGridCell:cell];
    [overlays addObject:overlay];
  }
  return overlays;
}

@end