//
// Created by Matt McGlincy on 4/23/14.
// Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "TBQuadTree.h"

@class FBSparseMapGrid;

extern CGFloat ZPositionForAnnotationView(UIView *view);

@interface FBMapAnnotations : NSObject

+ (NSMutableArray *)gridCellAnnotationsForGrid:(FBSparseMapGrid *)grid;

+ (NSMutableArray *)dotAnnotationsWithMapGrid:(FBSparseMapGrid *)mapGrid;
+ (NSMutableArray *)dotAnnotationsWithMapRect:(MKMapRect)mapRect mapGrid:(FBSparseMapGrid *)mapGrid;

+ (NSMutableArray *)polylineOverlaysWithMapGrid:(FBSparseMapGrid *)mapGrid;
+ (NSMutableArray *)polylineOverlaysWithMapRect:(MKMapRect)mapRect mapGrid:(FBSparseMapGrid *)mapGrid;

+ (NSMutableArray *)clusterCountAnnotationsWithinMapRect:(MKMapRect)rect
    withZoomScale:(double)zoomScale treeNode:(TBQuadTreeNode *)treeNode;

+ (NSMutableArray *)cellLocationsOverlaysWithMapGrid:(FBSparseMapGrid *)mapGrid;

@end