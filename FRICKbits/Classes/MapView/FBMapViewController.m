//
//  FBMapViewController.m
//  FrickBits
//
//  Created by Matt McGlincy on 1/31/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBAnimations.h"
#import "FBConstants.h"
#import "FBDateRangeOverlayView.h"
#import "FBFrickView.h"
#import "FBMapViewController+DataDisplay.h"
#import "FBMapViewController+Gesture.h"
#import "FBMapViewController+Location.h"
#import "FBMapViewController+Map.h"
#import "FBMapViewController+Menu.h"
#import "FBMapViewController+STUE.h"
#import "FBTouchGestureRecognizer.h"
#import "FBUtils.h"
#import "MBXMapKit.h"
#import "MKMapView+AttributionView.h"

@interface FBMapViewController ()
@property (nonatomic, strong) MBXRasterTileOverlay *fullMapOverlay;
@property (nonatomic, strong) MBXRasterTileOverlay *waterOnlyOverlay;
@end

@implementation FBMapViewController

- (void)dealloc {
  _fullMapView.delegate = nil;
  _waterOnlyMapView.delegate = nil;
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - VC lifecycle

- (void)didReceiveMemoryWarning {
  NSLog(@"*$*$*$*$*$*$*$ MEMORY WANRING $*$*$*$*$*$*$");
}

- (void)viewDidLoad {
  [super viewDidLoad];
  self.screenName = @"Map Screen";
  
  self.view.backgroundColor = [UIColor whiteColor];

  _dataLoaded = [[T23AtomicBoolean alloc] init];
  _haveLocation = [[T23AtomicBoolean alloc] init];

  _fullMapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
  // note that we do NOT set the map delegate yet;
  // we do that after loading our dataset and before manually setting our map
  _fullMapView.rotateEnabled = NO;
  [_fullMapView attributionView].hidden = YES;
  [self.view addSubview:_fullMapView];
  _fullMapView.translatesAutoresizingMaskIntoConstraints = NO;
  [_fullMapView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
   _fullMapView.delegate = self;
  // hide maps until data is loaded
  _fullMapView.hidden = YES;
  
  _screenshotContainerView = [[UIView alloc] init];
  _screenshotContainerView.userInteractionEnabled = NO;
  [self.view addSubview:_screenshotContainerView];
  _screenshotContainerView.translatesAutoresizingMaskIntoConstraints = NO;
  [_screenshotContainerView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
  
  _waterOnlyMapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
  _waterOnlyMapView.rotateEnabled = NO;
  [_waterOnlyMapView attributionView].hidden = YES;
  _waterOnlyMapView.delegate = self;
  [_screenshotContainerView addSubview:_waterOnlyMapView];
  _waterOnlyMapView.translatesAutoresizingMaskIntoConstraints = NO;
  [_waterOnlyMapView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
  _waterOnlyMapView.userInteractionEnabled = NO;
  _waterOnlyMapView.hidden = YES;
  
  _frickView = [[FBFrickView alloc] initWithFrame:self.view.bounds];
  _frickView.userInteractionEnabled = NO;
  [_screenshotContainerView addSubview:_frickView];

  _sparseMapGrids = [NSMutableDictionary dictionary];

  _mapAnnotations = [NSMutableArray array];
  _mapOverlays = [NSMutableArray array];

  _dateRangeOverlay = [[FBDateRangeOverlayView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
  [self.view addSubview:_dateRangeOverlay];
  
  _menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [_menuButton setImage:[UIImage imageNamed:@"button_menu.png"]
               forState:UIControlStateNormal];
  [_menuButton setImage:[UIImage imageNamed:@"button_menu_selected.png"]
               forState:UIControlStateSelected];
  [_menuButton addTarget:self
                  action:@selector(menuButtonPressed:)
        forControlEvents:UIControlEventTouchUpInside];
  [self.view addSubview:_menuButton];
  _menuButton.translatesAutoresizingMaskIntoConstraints = NO;
  [_menuButton autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:11.0];
  [_menuButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:11.0];
  // don't enable the menu button until our dataset loads
  _menuButton.enabled = NO;

  _menuViewController =
      [[FBMenuViewController alloc] initWithMenuItems:[self menuItems]];
  _menuViewController.delegate = self;
  _menuViewController.view.frame = CGRectMake(
      0, self.view.frame.size.height, _menuViewController.view.frame.size.width,
      _menuViewController.view.frame.size.height);
  [self addChildViewController:_menuViewController];
  [self.view addSubview:_menuViewController.view];

  _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
  [self.view addSubview:_activityIndicator];
  _activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
  [_activityIndicator autoCenterInSuperview];
  _activityIndicator.alpha = 1.0;
  
  // tap toggles menu button
  self.tapRecognizer = [[UITapGestureRecognizer alloc]
      initWithTarget:self
              action:@selector(handleTapGesture:)];
  self.tapRecognizer.delegate = self;
  [_fullMapView addGestureRecognizer:self.tapRecognizer];

  // long press shows dots-and-lines
  UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                    action:@selector(handleLongPressGesture:)];
  longPressRecognizer.delegate = self;
  [_fullMapView addGestureRecognizer:longPressRecognizer];
  
  // pan shows dots-and-lines
  UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(handlePanGesture:)];
  panRecognizer.delegate = self;
  [_fullMapView addGestureRecognizer:panRecognizer];
  
  // pinch shows dots-and-lines
  UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
  pinchRecognizer.delegate = self;
  [_fullMapView addGestureRecognizer:pinchRecognizer];
  
  UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)];
  doubleTapRecognizer.numberOfTapsRequired = 2;
  doubleTapRecognizer.delegate = self;
  [_fullMapView addGestureRecognizer:doubleTapRecognizer];
  
  self.updateQueue = [[NSOperationQueue alloc] init];
  self.updateQueue.name = @"FBMapViewControllerUpdateQueue";
  self.updateQueue.maxConcurrentOperationCount = 1;
  
  self.snapshotLock = [[NSLock alloc] init];
  
  // Pay attention to didBecomeActive notifications.
  // This handler is where we actually load our location and data.
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(handleApplicationDidBecomeActiveNotification:)
                                               name:UIApplicationDidBecomeActiveNotification
                                             object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
  [self.navigationController setNavigationBarHidden:YES animated:NO];
  [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
  self.dateRangeOverlay.alpha = 0.0;
  
  // overlays get added to the map in viewWillAppear, as a crash workaround
  _fullMapOverlay = [[MBXRasterTileOverlay alloc] initWithMapID:FBMapboxMapIDFull];
  _waterOnlyOverlay = [[MBXRasterTileOverlay alloc] initWithMapID:FBMapboxMapIDWaterOnly];
  [_fullMapView addOverlay:_fullMapOverlay];
  [_waterOnlyMapView addOverlay:_waterOnlyOverlay];

  if (![FBMapViewController userCompletedSTUE]) {
    [self setupSTUEViews];
  }

}

- (void)viewDidDisappear:(BOOL)animated {

  // Adding/removing overlays in viewWillAppear / viewDidDisappear as a workaround
  // for possible MKMapKit crash as per https://github.com/mapbox/mbxmapkit/issues/15
  // Make sure we invalidateAndCancel overlays before removing, as per @bug note in MXBRasterTileOverlay.
  NSLog(@"*** removing overlays");

  [_fullMapOverlay invalidateAndCancel];
  [_waterOnlyOverlay invalidateAndCancel];
  [self.fullMapView removeOverlay:_fullMapOverlay];
  [self.waterOnlyMapView removeOverlay:_waterOnlyOverlay];
  
  NSLog(@"*** overlays removed");

  [super viewDidDisappear:animated];
  
}

- (void)handleApplicationDidBecomeActiveNotification:(NSNotification *)notification {
  // do location-centering and reload our data every time the application is foregrounded
  [self.sparseMapGrids removeAllObjects];
  [self.frickView clear];
  [self doInitialLocationAndLoad];
}

@end
