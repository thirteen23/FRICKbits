//
//  FBNotReadyYetViewController.m
//  FrickBits
//
//  Created by Matt McGlincy on 4/23/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <MBXMapKit/MBXMapKit.h>
#import "FBAppDelegate.h"
#import "FBChrome.h"
#import "FBColorPalette.h"
#import "FBColorPaletteManager.h"
#import "FBDataset.h"
#import "FBDotAnnotation.h"
#import "FBDotAnnotationView.h"
#import "FBGridCellLocationsOverlay.h"
#import "FBGridCellLocationsOverlayRenderer.h"
#import "FBHeaderView.h"
#import "FBMapAnnotations.h"
#import "FBNotReadyYetViewController.h"
#import "FBOnboardingPresentationView.h"
#import "FBSparseMapGrid.h"
#import "FBUtils.h"

@interface
FBNotReadyYetViewController () <CLLocationManagerDelegate, MKMapViewDelegate>
@property(nonatomic, strong) MKMapView *mapView;
@property(nonatomic, strong) MBXRasterTileOverlay *rasterOverlay;
@property(nonatomic, strong) FBOnboardingPresentationView *messageView;
@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic) BOOL shouldUpdateMapAnnotations;
@end

@implementation FBNotReadyYetViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.screenName = @"Not Ready Yet Screen";

  // the map
  _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
  _mapView.rotateEnabled = NO;
  _mapView.delegate = self;
  _mapView.zoomEnabled = NO;
  _mapView.scrollEnabled = NO;
  _mapView.userInteractionEnabled = NO;
  [self.view addSubview:_mapView];

  FBHeaderView *headerView = [[FBHeaderView alloc] init];
  [headerView addToView:self.view];

  // not-ready-yet message overlay
  NSString *messageTitle = @"Not quite ready.\n";
  NSString *messageText =
      @"It can take a couple days to gather enough data for your portrait.";

  NSMutableAttributedString *messageString = [[NSMutableAttributedString alloc]
      initWithAttributedString:[FBChrome attributedTextTitle:(NSString *)
                                         messageTitle]];

  [messageString
      appendAttributedString:[FBChrome attributedParagraph:messageText]];

  _messageView =
      [[FBOnboardingPresentationView alloc] initWithHelpText:messageString
                                                  andMargins:25.0f];
  [self.view addSubview:_messageView];
  [_messageView autoAlignAxisToSuperviewAxis:ALAxisVertical];
  [_messageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
  [_messageView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];
  [_messageView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:75.0f];

  _locationManager = [[CLLocationManager alloc] init];
  _locationManager.delegate = self;
  [_locationManager startUpdatingLocation];

  // don't update map annotations until we explicitly trigger our map animation
  _shouldUpdateMapAnnotations = NO;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.navigationController setNavigationBarHidden:YES animated:NO];
  _rasterOverlay = [[MBXRasterTileOverlay alloc] initWithMapID:FBMapboxMapIDFull];
  [_mapView addOverlay:_rasterOverlay];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
  // adding/removing overlays in viewWillAppear / viewDidDisappear as a workaround
  // for possible MKMapKit crash as per https://github.com/mapbox/mbxmapkit/issues/15
  // Make sure we invalidateAndCancel overlays before removing, as per @bug note in MXBRasterTileOverlay.
  [_rasterOverlay invalidateAndCancel];
  [_mapView removeOverlay:_rasterOverlay];
  [super viewDidDisappear:animated];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
  CLLocation *location = [locations lastObject]; // most recent
  _locationManager.delegate = nil;
  [_locationManager stopUpdatingLocation];
  _locationManager = nil;

  MKCoordinateRegion region =
      MKCoordinateRegionMake(location.coordinate, DefaultZoomMapSpan());
  _shouldUpdateMapAnnotations = YES;
  [_mapView setRegion:region animated:YES];
}

- (void)updateMapAnnotations {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                 ^{
      FBDataset *dataset = [FBDataset userLocationDataset];

      double zoomScale = ZoomLevelToMKZoomScale(12);
      FBSparseMapGrid *mapGrid =
          [[FBSparseMapGrid alloc] initWithZoomScale:zoomScale];
      [mapGrid populateWithDataset:dataset];

      NSArray *annotations = [[FBMapAnnotations
          dotAnnotationsWithMapRect:self.mapView.visibleMapRect
                            mapGrid:mapGrid] mutableCopy];

      NSArray *overlays = [FBMapAnnotations
          polylineOverlaysWithMapRect:self.mapView.visibleMapRect
                              mapGrid:mapGrid];

      dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapView removeAnnotations:self.mapView.annotations];
          [self.mapView addOverlays:overlays];
          [self.mapView addAnnotations:annotations];
      });
  });
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
  // mapView:regionDidChanged:animated may get invoked multiple times as the map
  // is initting/loading/etc.
  // we don't want to update our annotations until we've explicitly set our
  // region
  if (_shouldUpdateMapAnnotations) {
    [self updateMapAnnotations];
  }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation {

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
    dotView.dotColor = [colorPalette nextPrimaryColor];
    return dotView;
  }

  return nil;
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id<MKOverlay>)overlay {
  // make sure we handle tile overlays, so MBXMapView continues to show custom
  // tiles
  if ([overlay isKindOfClass:[MBXRasterTileOverlay class]]) {
    return [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
  }

  if ([overlay isKindOfClass:[MKPolyline class]]) {
    MKPolylineRenderer *renderer =
        [[MKPolylineRenderer alloc] initWithPolyline:overlay];
    renderer.strokeColor = [FBChrome lineOverlayLineColor];
    renderer.lineWidth = FBLineOverlayLineWidth;
    return renderer;
  }

  if ([overlay isKindOfClass:[FBGridCellLocationsOverlay class]]) {
    FBGridCellLocationsOverlayRenderer *renderer = [[FBGridCellLocationsOverlayRenderer alloc] initWithOverlay:overlay];
    return renderer;
  }

  return nil;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
  for (UIView *view in views) {
    view.layer.zPosition = ZPositionForAnnotationView(view);
  }
}

@end
