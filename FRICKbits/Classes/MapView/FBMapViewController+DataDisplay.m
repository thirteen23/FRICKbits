//
// Created by Matt McGlincy on 4/9/14.
// Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBCoordinateQuadTree.h"
#import "FBFrickView.h"
#import "FBMapViewController+DataDisplay.h"
#import "FBMapViewController+Map.h"
#import "FBSettingsManager.h"
#import "FBUtils.h"
#import "MBXMapKit.h"
#import "T23AtomicBoolean.h"
#import "FBMapAnnotations.h"

@implementation FBMapViewController (DataDisplay)

- (void)loadDataWithFilename:(NSString *)filename {
  [self.sparseMapGrids removeAllObjects];
  self.dataset = [[FBDataset alloc] initWithFilename:filename maxLocations:FBDatasetMaxLocations];
  self.coordinateQuadTree = [[FBCoordinateQuadTree alloc] init];
  self.coordinateQuadTree.mapView = self.fullMapView;
  [self.coordinateQuadTree buildTreeWithDataset:self.dataset];
  self.dataLoaded.value = YES;
}

- (void)zoomMapToFitDataset {
  if (self.dataset.locations.count == 0) {
    return;
  }

  // zoom to show all data
  CLLocationCoordinate2D centerCoord = CLLocationCoordinate2DMake(
      (self.dataset.minLatitude + self.dataset.maxLatitude) / 2.0,
      (self.dataset.minLongitude + self.dataset.maxLongitude) / 2.0);
  MKCoordinateSpan span = MKCoordinateSpanMake(
      fabs(self.dataset.maxLatitude - self.dataset.minLatitude),
      fabs(self.dataset.maxLongitude - self.dataset.minLongitude));
  MKCoordinateRegion region = MKCoordinateRegionMake(centerCoord, span);

  [self.fullMapView setRegion:region animated:NO];
}

- (void)updateDataDisplay {
  
  // only keep one update op at a time
  // TODO: is this the right place to cancel/clear?
  [self.frickView cancelAnimating];
  [self.frickView clear];
  [self.updateQueue cancelAllOperations];

  if ([self mapIsGreaterThanMaxZoom]) {
    // ignore any updates while the map is overzoomed
    // we assume mapRegionWillChange / DidChange will override the map zoom and re-call updateDataDisplay
    return;
  }
  
  [FBTimeManager sharedInstance].updateDataDisplayStartTime = [NSDate date];

  // use a weak reference to avoid the self->operationqueue->operation->self retain cycle
  __weak FBMapViewController *weakSelf = self;
  NSOperation *updateOp = [NSBlockOperation blockOperationWithBlock:^{
    [self.snapshotLock lock];
    [FBTimeManager sharedInstance].updateOpStartTime = [NSDate date];
    
    [weakSelf.frickView cancelAnimating];
    [weakSelf setSparseGridForCurrentZoomLevel];
    
    // we only need to recalculate map annotations and overlays when the sparseMapgrid changes
    if (self.previousSparseMapGrid != self.currentSparseMapGrid) {
      // add dots and lines for the entire grid/globe, so we can pan through them on the map
      NSMutableArray *annotations = [FBMapAnnotations dotAnnotationsWithMapGrid:weakSelf.currentSparseMapGrid];
      if ([FBSettingsManager sharedInstance].debug) {
        [annotations
         addObjectsFromArray:[FBMapAnnotations gridCellAnnotationsForGrid:
                              weakSelf.currentSparseMapGrid]];
      }
      NSMutableArray *lineOverlays = [FBMapAnnotations polylineOverlaysWithMapGrid:weakSelf.currentSparseMapGrid];
      NSMutableArray *cellLocationsOverlays = [FBMapAnnotations cellLocationsOverlaysWithMapGrid:weakSelf.currentSparseMapGrid];
      
      NSMutableArray *overlays = [NSMutableArray array];
      [overlays addObjectsFromArray:lineOverlays];
      [overlays addObjectsFromArray:cellLocationsOverlays];
    
      [weakSelf updateMapViewController:weakSelf annotations:annotations overlays:overlays];
    }
    
    // update and animate the frickView
    [weakSelf.frickView updateWithMapView:weakSelf.fullMapView
                                  mapGrid:weakSelf.currentSparseMapGrid
                                  mapRect:weakSelf.fullMapView.visibleMapRect
                                 quadTree:weakSelf.coordinateQuadTree];
    [self.snapshotLock unlock];
  }];

  [self.updateQueue addOperation:updateOp];
}

- (void)updateMapViewController:(FBMapViewController *)vc
                    annotations:(NSArray *)annotations overlays:(NSArray *)overlays {
  // figure out which annotations we need to keep, add, or remove

  NSMutableSet *before = [NSMutableSet setWithArray:self.fullMapView.annotations];
  [before removeObject:[self.fullMapView userLocation]];
  NSSet *after = [NSSet setWithArray:annotations];

  NSMutableSet *toKeep = [NSMutableSet setWithSet:before];
  [toKeep intersectSet:after];

  NSMutableSet *toAdd = [NSMutableSet setWithSet:after];
  [toAdd minusSet:toKeep];

  NSMutableSet *toRemove = [NSMutableSet setWithSet:before];
  [toRemove minusSet:after];

  // filter any possibly crash-causing illegal-location annotations
  NSMutableSet *filtered = [NSMutableSet set];
  for (id <MKAnnotation> anno in toAdd) {
    if (CLLocationCoordinate2DIsValid(anno.coordinate)) {
      [filtered addObject:anno];
    } else {
      NSLog(@"annotation with invalid coordinate: %@", anno);
    }
  }

  dispatch_async(dispatch_get_main_queue(), ^{
    [vc.fullMapView addAnnotations:[filtered allObjects]];
    [vc.fullMapView removeAnnotations:[toRemove allObjects]];

    [vc.fullMapView removeOverlays:vc.mapOverlays];
    [vc.fullMapView addOverlays:overlays];
    [vc.mapOverlays addObjectsFromArray:overlays];
  });
}

- (void)setSparseGridForCurrentZoomLevel {
  double zoomScale = self.fullMapView.bounds.size.width /
                     self.fullMapView.visibleMapRect.size.width;
  NSUInteger actualZoomLevel = MKZoomScaleToZoomLevel(zoomScale);
  NSUInteger
      snappedZoomLevel = [FBMapViewController snappedZoomLevel:actualZoomLevel];
  NSNumber *num = @(snappedZoomLevel);
  FBSparseMapGrid *mapGrid = [self.sparseMapGrids objectForKey:num];
  if (!mapGrid) {
    [self showActivityIndicator];
    double snappedZoomScale = ZoomLevelToMKZoomScale(snappedZoomLevel);
    mapGrid = [[FBSparseMapGrid alloc] initWithZoomScale:snappedZoomScale];
    [mapGrid populateWithDataset:self.dataset];
    [self.sparseMapGrids setObject:mapGrid forKey:num];
    [self hideActivityIndicator];
  }
  self.previousSparseMapGrid = self.currentSparseMapGrid;
  self.currentSparseMapGrid = mapGrid;
}

#pragma mark - activity indicator
static CGFloat kActivityIndicatorFadeDuration = 0.2;

- (void)showActivityIndicator {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.activityIndicator startAnimating];
    [UIView animateWithDuration:kActivityIndicatorFadeDuration animations:^{
      self.activityIndicator.alpha = 1.0;
    }];
  });
}

- (void)hideActivityIndicator {
  dispatch_async(dispatch_get_main_queue(), ^{
    [UIView animateWithDuration:kActivityIndicatorFadeDuration animations:^{
      self.activityIndicator.alpha = 0.0;
    } completion:^(BOOL finished) {
      [self.activityIndicator stopAnimating];
    }];
  });
}

@end