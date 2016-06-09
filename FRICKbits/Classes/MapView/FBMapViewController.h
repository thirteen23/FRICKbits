//
//  FBMapViewController.h
//  FrickBits
//
//  Created by Matt McGlincy on 1/31/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBTrackedViewController.h"
#import "T23AtomicBoolean.h"

@class FBCoordinateQuadTree;
@class FBColorPalette;
@class FBDataset;
@class FBDateRangeOverlayView;
@class FBFrickView;
@class FBHeaderView;
@class FBMenuViewController;
@class FBOnboardingPresentationView;
@class FBSparseMapGrid;
@class MBXMapView;
@class T23AtomicBoolean;

@interface FBMapViewController : FBTrackedViewController

@property(nonatomic, strong) MKMapView *fullMapView;
// container to hold water and frick bits for screenshots
@property(nonatomic, strong) UIView *screenshotContainerView;
@property(nonatomic, strong) MKMapView *waterOnlyMapView;
@property(nonatomic, strong) FBFrickView *frickView;

@property(nonatomic, strong) UIButton *menuButton;
@property(nonatomic, strong) FBMenuViewController *menuViewController;
@property(nonatomic, strong) FBDateRangeOverlayView *dateRangeOverlay;

@property(nonatomic, strong) FBDataset *dataset;
@property(nonatomic, strong) FBCoordinateQuadTree *coordinateQuadTree;

// zoomLevel => sparse map grid
@property(nonatomic, strong) NSMutableDictionary *sparseMapGrids;

// sparse map grid for current zoom
@property(nonatomic, strong) FBSparseMapGrid *currentSparseMapGrid;

// sparse map grid for previous map update
@property(nonatomic, strong) FBSparseMapGrid *previousSparseMapGrid;

@property(nonatomic, strong) NSMutableArray *mapAnnotations;
@property(nonatomic, strong) NSMutableArray *mapOverlays;

@property (nonatomic, strong) T23AtomicBoolean *dataLoaded;
@property (nonatomic, strong) T23AtomicBoolean *haveLocation;

@property(nonatomic, strong) UITapGestureRecognizer *tapRecognizer;

@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic) BOOL controlsHidden;
@property(nonatomic) BOOL usingLocationServices;
@property(nonatomic, strong) NSTimer *locationTimeoutTimer;

// timer to delay updating the map, to deal with repeated gesture callbacks
@property(nonatomic, strong) NSTimer *updateDelayTimer;

// queue for updating of data display
@property(nonatomic, strong) NSOperationQueue *updateQueue;

// activity indicator used for data/map grid loading
@property(nonatomic, strong) UIActivityIndicatorView *activityIndicator;

// STUE overlays
@property(nonatomic, strong) FBHeaderView *headerView;
@property(nonatomic, strong) FBOnboardingPresentationView *welcomeView;


@property(nonatomic, strong) NSLock *snapshotLock;

@end

