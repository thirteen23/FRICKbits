//
// Created by Matt McGlincy on 4/17/14.
// Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBAnimations.h"
#import "FBChrome.h"
#import "FBClusterCountAnnotation.h"
#import "FBClusterCountAnnotationView.h"
#import "FBColorPaletteManager.h"
#import "FBDotAnnotation.h"
#import "FBDotAnnotationView.h"
#import "FBFrickView.h"
#import "FBGridCellAnnotation.h"
#import "FBGridCellAnnotationView.h"
#import "FBGridCellLocationsOverlay.h"
#import "FBGridCellLocationsOverlayRenderer.h"
#import "FBMapAnnotations.h"
#import "FBMapViewController.h"
#import "FBMapViewController+DataDisplay.h"
#import "FBMapViewController+Gesture.h"
#import "FBMapViewController+Map.h"
#import "FBUtils.h"
#import "MBXMapKit.h"
#import "T23AtomicBoolean.h"


static NSInteger const FBMaxMapZoomLevel = 16;

@implementation FBMapViewController (Map)

#pragma mark - map handling

+ (NSInteger)snappedZoomLevel:(NSInteger)zoomLevel {
  // zooms range from 2 to 19, but we're restricting it to N different fixed zooms
  // 2-11 => 2-11
  if (zoomLevel < 12) {
    return zoomLevel;
  }
  // 12-13 => 12
  if (zoomLevel < 14) {
    return 12;
  }
  // 14-19 => 14
  return 14;
}

- (CGFloat)currentZoomScale {
  return (CGFloat)(self.fullMapView.bounds.size.width /
                   self.fullMapView.visibleMapRect.size.width);
}

- (NSInteger)currentZoomLevel {
  return MKZoomScaleToZoomLevel([self currentZoomScale]);
}

#pragma mark - MKMapViewDelegate

- (BOOL)mapIsGreaterThanMaxZoom {
  NSInteger currentZoomLevel = [self currentZoomLevel];
  return (currentZoomLevel > FBMaxMapZoomLevel);
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
  if (mapView == self.fullMapView) {
    // keep the inactive map in sync
    [self.waterOnlyMapView setRegion:self.fullMapView.region animated:NO];
  }
  // restrict maximum zoom
  NSInteger currentZoomLevel = [self currentZoomLevel];
  if (currentZoomLevel > FBMaxMapZoomLevel) {
    [self.fullMapView mbx_setCenterCoordinate:self.fullMapView.centerCoordinate
                                    zoomLevel:FBMaxMapZoomLevel
                                     animated:NO];
    // make sure we update the data display to match
    [self updateDataDisplay];
  }
}

- (void)recolorDots {
  FBColorPalette *colorPalette = [FBColorPaletteManager sharedInstance].colorPalette;
  for (id<MKAnnotation> anno in self.fullMapView.annotations) {
    MKAnnotationView *view = [self.fullMapView viewForAnnotation:anno];
    if ([view isKindOfClass:[FBDotAnnotationView class]]) {
      FBDotAnnotationView *dot = (FBDotAnnotationView *)view;
      [dot setDotColor:[colorPalette nextPrimaryColor]];
      [dot setNeedsDisplay];
    }
  }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

  if ([annotation isKindOfClass:[FBClusterCountAnnotation class]]) {
    static NSString *const ClusterCountReuseIdentifier =
        @"FBClusterCountAnnotationViewReuseID";
    FBClusterCountAnnotationView *clusterCountView =
        (FBClusterCountAnnotationView *)
    [mapView dequeueReusableAnnotationViewWithIdentifier:
                 ClusterCountReuseIdentifier];
    if (!clusterCountView) {
      clusterCountView = [[FBClusterCountAnnotationView alloc]
                                                        initWithAnnotation:annotation
          reuseIdentifier:ClusterCountReuseIdentifier];
    }
    clusterCountView.count = [(FBClusterCountAnnotation *)annotation count];
    return clusterCountView;
  }

  if ([annotation isKindOfClass:[FBDotAnnotation class]]) {
    static NSString *const DotReuseIdentifier = @"FBDotAnnotationViewReuseID";
    FBDotAnnotationView *dotView = (FBDotAnnotationView *)[mapView
        dequeueReusableAnnotationViewWithIdentifier:DotReuseIdentifier];
    if (!dotView) {
      dotView =
          [[FBDotAnnotationView alloc] initWithAnnotation:annotation
              reuseIdentifier:DotReuseIdentifier];
    }
    FBColorPalette *colorPalette = [FBColorPaletteManager sharedInstance].colorPalette;
    [dotView setDotColor:[colorPalette nextPrimaryColor]];
    return dotView;
  }

  if ([annotation isKindOfClass:[FBGridCellAnnotation class]]) {
    static NSString *const GridCellReuseIdentifier =
        @"FBGridCellAnnotationViewReuseID";
    FBGridCellAnnotationView *gridCellView = (FBGridCellAnnotationView *)
    [mapView dequeueReusableAnnotationViewWithIdentifier:
                 GridCellReuseIdentifier];
    if (!gridCellView) {
      gridCellView = [[FBGridCellAnnotationView alloc]
                                                initWithAnnotation:annotation
          reuseIdentifier:GridCellReuseIdentifier];
      gridCellView.canShowCallout = NO;
    }
    FBGridCellAnnotation *gridCellAnno = (FBGridCellAnnotation *)annotation;
    MKCoordinateRegion region =
        MKCoordinateRegionForMapRect(gridCellAnno.cell.mapRect);

    CGRect rect =
        [self.fullMapView convertRegion:region toRectToView:self.fullMapView];
    gridCellView.frame = rect;

    // position the annotation view so upper-left corner is on the coordinate
    // 54 cells, 9 rows, 6 cols. Which are visible when scrolling/holding.
    // but WTF does the grid start offscreen to the left and up?
    // also, there are dots outside the grid???
    // dots appear outside to the right, and down of the grid, but still in
    // screen. But NOT left or up (offscreen).
    //(or maybe the grid is getting clipped? NO)
    gridCellView.centerOffset = CGPointMake(gridCellView.frame.size.width / 2,
        gridCellView.frame.size.height / 2);

    return gridCellView;
  }

  return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
  for (UIView *view in views) {
    view.layer.zPosition = ZPositionForAnnotationView(view);
  }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
  // make sure we handle tile overlays, so MBXMapView continues to show custom
  // tiles
  if ([overlay isKindOfClass:[MBXRasterTileOverlay class]]) {
    return [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
  }

  if ([overlay isKindOfClass:[MKPolyline class]]) {
    MKPolylineRenderer *renderer =
        [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    renderer.strokeColor = [FBChrome lineOverlayLineColor];
    renderer.lineWidth = 2.0;
    return renderer;
  }
  
  if ([overlay isKindOfClass:[FBGridCellLocationsOverlay class]]) {
    FBGridCellLocationsOverlayRenderer *renderer = [[FBGridCellLocationsOverlayRenderer alloc] initWithOverlay:overlay];
    return renderer;
  }

  return nil;
}

#pragma mark - MBXRasterTileOverlayDelegate implementation

// TODO: do we want to set ourselves up as the tileOverlay delegate?
/* >>>
- (void)tileOverlay:(MBXRasterTileOverlay *)overlay didLoadMetadata:(NSDictionary *)metadata withError:(NSError *)error {
  // This delegate callback is for centering the map once the map metadata has been loaded
  //
  if (error) {
    NSLog(@"Failed to load metadata for map ID %@ - (%@)", overlay.mapID, error?error:@"");
  } else {
    //[_mapView mbx_setCenterCoordinate:overlay.center zoomLevel:overlay.centerZoom animated:NO];
  }
}


- (void)tileOverlay:(MBXRasterTileOverlay *)overlay didLoadMarkers:(NSArray *)markers withError:(NSError *)error {

}

- (void)tileOverlayDidFinishLoadingMetadataAndMarkers:(MBXRasterTileOverlay *)overlay {
}
<<< */

@end