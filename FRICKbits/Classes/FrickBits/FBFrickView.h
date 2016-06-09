//
//  FBFrickView.h
//  FrickBits
//
//  Created by Matthew McGlincy on 2/20/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBCoordinateQuadTree.h"
#import "FBRecipeFactory.h"
#import "FBSparseMapGrid.h"

@interface FBFrickView : UIView

@property(nonatomic, strong) FBRecipeFactory *recipeFactory;

// map of cell => join nodes
@property(nonatomic, strong) NSMapTable *cellJoinNodes;

// map of connection => frick bit
@property(nonatomic, strong) NSMapTable *connectionFrickBits;

// pause any already-enqueued animations
- (void)pauseAnimating;

// resume any already-enqueued animations
- (void)resumeAnimating;

// cancel any already-enqueued animations
- (void)cancelAnimating;

// remove all frick bits and layers
- (void)clear;

// update this frickview, creating new join nodes and connection bits
- (void)updateWithMapView:(MKMapView *)mapView
                  mapGrid:(FBSparseMapGrid *)mapGrid
                  mapRect:(MKMapRect)mapRect
                 quadTree:(FBCoordinateQuadTree *)quadTree;

// exposed for unit testing: create new join nodes
- (void)updateCellJoinNodesWithMapView:(MKMapView *)mapView
                                 mapGrid:(FBSparseMapGrid *)mapGrid mapRect:(MKMapRect)mapRect
                                 factory:(FBRecipeFactory *)factory;

// exposed for unit testing: create new connection bits
- (void)updateConnectionFrickBitsWithMapView:(MKMapView *)mapView
                                     mapGrid:(FBSparseMapGrid *)mapGrid mapRect:(MKMapRect)mapRect
                                     factory:(FBRecipeFactory *)factory
                             cellJoineryBits:(NSMapTable *)cellJoineryBits;

@end
