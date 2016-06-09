//
//  FBOnboardingMapViewController.m
//  FrickBits
//
//  Created by Michael Van Milligan on 4/7/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "FBAppDelegate.h"
#import "FBOnboardingNavigationController.h"
#import "FBOnboardingMapViewController.h"
#import "FBOnboardingPresentationView.h"
#import "FBHeaderView.h"
#import "T23AtomicBoolean.h"
#import "FBUtils.h"
#import "FBChrome.h"
#import "MBXMapKit.h"

#define FBOnboardingMapViewControllerPresentationMargins (40.0f)

static NSString *const waitAndGoText =
    @"OK! Go someplace.\nGive it a few days. We'll ping you when it's ready.";

@interface FBOnboardingMapViewController () <MKMapViewDelegate,
                                             CLLocationManagerDelegate>

// Private
@property(nonatomic, strong) FBHeaderView *titleView;

@property(nonatomic, strong) FBOnboardingPresentationView *waitAndGoView;
@property(nonatomic, strong) NSMutableArray *waitAndGoViewConstraints;
@property(nonatomic, strong) UILabel *waitAndGoTextLabel;

@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) MKMapView *fullMapView;
@property(nonatomic) MBXRasterTileOverlay *rasterOverlay;
@property(nonatomic, strong) FBColorPalette *palette;
@property(nonatomic, strong) T23AtomicBoolean *haveLocation;
@property(nonatomic, strong) T23AtomicBoolean *loadLocationOnce;

@property(nonatomic, strong) UIView *greyScreen;

@end
@implementation FBOnboardingMapViewController
- (instancetype)initWithColorPalette:(FBColorPalette *)palette {
  if (self = [self init]) {
    _palette = palette;
  }
  return self;
}

- (id)init {
  if (self = [super init]) {
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _haveLocation = [[T23AtomicBoolean alloc] init];
    _loadLocationOnce = [[T23AtomicBoolean alloc] init];
    _waitAndGoViewConstraints = [[NSMutableArray alloc] init];
  }

  return self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.navigationController setNavigationBarHidden:YES animated:NO];
  _rasterOverlay =
      [[MBXRasterTileOverlay alloc] initWithMapID:FBMapboxMapIDFull];
  [_fullMapView addOverlay:_rasterOverlay];

  [_locationManager startUpdatingLocation];
}

- (void)viewDidDisappear:(BOOL)animated {
  // adding/removing overlays in viewWillAppear / viewDidDisappear as a
  // workaround
  // for possible MKMapKit crash as per
  // https://github.com/mapbox/mbxmapkit/issues/15
  // Make sure we invalidateAndCancel overlays before removing, as per @bug note
  // in MXBRasterTileOverlay.
  [_rasterOverlay invalidateAndCancel];
  [_fullMapView removeOverlay:_rasterOverlay];
  [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = [UIColor clearColor];

  [self setupPresentationOfView];
}

#pragma mark - Initialization

- (void)setupPresentationOfView {
  /*
   * Map View
   */
  _fullMapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
  _fullMapView.translatesAutoresizingMaskIntoConstraints = NO;
  _fullMapView.rotateEnabled = NO;
  _fullMapView.delegate = self;
  _fullMapView.userInteractionEnabled = NO;

  [self.view addSubview:_fullMapView];

  [_fullMapView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];

  /*
   * Title message
   */
  _titleView = [[FBHeaderView alloc] init];

  [self.view addSubview:_titleView];
  [self.view bringSubviewToFront:_titleView];

  [_titleView autoSetDimension:ALDimensionHeight toSize:70.0f];

  [_titleView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view];
  [_titleView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view];
  [_titleView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view];

  [self setupWaitView];
}

- (void)setupWaitView {
  /*
   * Wait And Go Text
   */
  NSRange newline = [waitAndGoText rangeOfString:@"\n"];
  NSString *okGoText = [NSString
      stringWithString:[waitAndGoText substringToIndex:newline.location + 1]];

  NSMutableAttributedString *okGoAttrText =
      [[FBChrome attributedTextTitle:okGoText] mutableCopy];

  NSAttributedString *waitText =
      [FBChrome attributedParagraphForOnboarding:
                    [waitAndGoText substringFromIndex:newline.location + 1]];

  [okGoAttrText appendAttributedString:waitText];

  _waitAndGoTextLabel = [[UILabel alloc] init];
  _waitAndGoTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
  _waitAndGoTextLabel.backgroundColor = [UIColor clearColor];

  _waitAndGoTextLabel.attributedText = okGoAttrText;
  _waitAndGoTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
  _waitAndGoTextLabel.numberOfLines = 0;
  [_waitAndGoTextLabel sizeToFit];
  _waitAndGoTextLabel.alpha = 0.0f;

  /*
   * Wait View
   */
  _waitAndGoView = [[FBOnboardingPresentationView alloc]
      initWithViews:_waitAndGoTextLabel, nil];

  [self.view addSubview:_waitAndGoView];

  [_waitAndGoViewConstraints addObject:[_waitAndGoView autoPinEdge:ALEdgeBottom
                                                            toEdge:ALEdgeBottom
                                                            ofView:self.view]];

  [_waitAndGoViewConstraints addObject:[_waitAndGoView autoPinEdge:ALEdgeLeft
                                                            toEdge:ALEdgeLeft
                                                            ofView:self.view]];

  [_waitAndGoViewConstraints addObject:[_waitAndGoView autoPinEdge:ALEdgeRight
                                                            toEdge:ALEdgeRight
                                                            ofView:self.view]];
}

#pragma mark - Transitions

- (void)doWaitTransition {
  dispatch_block_t completion = ^void(void) {
      [FBUtils animateView:_waitAndGoTextLabel
                 withAlpha:1.0f
            withCompletion:nil];
  };

  [_waitAndGoView.superview layoutIfNeeded];
  [UIView animateWithDuration:0.17f
      delay:0.0f
      options:(UIViewAnimationOptionBeginFromCurrentState)
      animations:^(void) {

          [_waitAndGoView.superview
              removeConstraints:_waitAndGoViewConstraints];
          [_waitAndGoViewConstraints removeAllObjects];

          [_waitAndGoViewConstraints
              addObject:[_waitAndGoView autoPinEdge:ALEdgeBottom
                                             toEdge:ALEdgeBottom
                                             ofView:_waitAndGoView.superview]];

          [_waitAndGoViewConstraints
              addObject:[_waitAndGoView autoPinEdge:ALEdgeLeft
                                             toEdge:ALEdgeLeft
                                             ofView:_waitAndGoView.superview]];

          [_waitAndGoViewConstraints
              addObject:[_waitAndGoView autoPinEdge:ALEdgeRight
                                             toEdge:ALEdgeRight
                                             ofView:_waitAndGoView.superview]];
          [_waitAndGoView.superview layoutIfNeeded];
      }
      completion:^(BOOL finished) {
          if (finished) {
            if (completion) {
              completion();
            }
          }
      }];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
  NSLog(@"didFailWithError: %@", error);
  UIAlertView *errorAlert =
      [[UIAlertView alloc] initWithTitle:@"Error"
                                 message:@"Failed to Get Your Location"
                                delegate:nil
                       cancelButtonTitle:@"OK"
                       otherButtonTitles:nil];
  [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
  // do a one-time zoom of the map to the current location
  if (!_loadLocationOnce.value) {
    _loadLocationOnce.value = YES;

    [self.locationManager stopUpdatingLocation];
    self.locationManager = nil;
    CLLocation *location = [locations lastObject];
    [self updateMapViewWithLocation:location];

    // Now we need to check whether we need to ask the user for permission to
    // present a local notification
    FBAppDelegate *appDelegate =
        (FBAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate askToRegisterForLocalNotifications];
  }
}

- (void)updateMapViewWithLocation:(CLLocation *)location {
  MKCoordinateSpan span = MKCoordinateSpanMake(0.025, 0.025);
  MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate, span);

  MKCircle *circle =
      [MKCircle circleWithCenterCoordinate:location.coordinate radius:5];

  [_fullMapView addOverlay:circle];

  [_haveLocation setValue:YES];
  [_fullMapView setRegion:region animated:NO];

  dispatch_async(dispatch_get_main_queue(),
                 ^(void) { [self doWaitTransition]; });
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView
            rendererForOverlay:(id<MKOverlay>)overlay {
  if (_ISA_(overlay, MBXRasterTileOverlay)) {
    return [[MKTileOverlayRenderer alloc] initWithTileOverlay:overlay];
  }

  if (_ISA_(overlay, MKCircle)) {
    MKCircleRenderer *circleRenderer =
        [[MKCircleRenderer alloc] initWithOverlay:overlay];

    circleRenderer.strokeColor = _palette.seedColor;
    circleRenderer.fillColor = _palette.seedColor;
    return circleRenderer;
  }

  return nil;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

@end
