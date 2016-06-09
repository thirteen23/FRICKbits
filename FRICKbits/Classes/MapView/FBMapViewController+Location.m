//
//  FBMapViewController+Location.m
//  FRICKbits
//
//  Created by Matt McGlincy on 7/15/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBDataset.h"
#import "FBLocation.h"
#import "FBMapViewController+DataDisplay.h"
#import "FBMapViewController+Location.h"
#import "FBUtils.h"

@implementation FBMapViewController (Location)

- (void)doInitialLocationAndLoad {
  // Get an updated location.
  // After we get the location, we'll also reload our dataset from file.
  self.haveLocation.value = NO;
  self.dataLoaded.value = NO;
  
  if ([CLLocationManager locationServicesEnabled]) {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    // guard ourselves vs. location manager failures, or simulator f-ups
    self.locationTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(locationTimeout:) userInfo:nil repeats:NO];
  } else {
    // proceed without a location
    [self loadDefaultDataAndUpdateMapWithLocation:nil];
  }
}

- (void)locationTimeout:(NSTimer *)timer {
  @synchronized(self) {
    if (!self.haveLocation.value) {
      // this timer callback should be happening on the main thread, along with the CLLocationManager callbacks
      [self.locationManager stopUpdatingLocation];
      self.locationManager = nil;
      [self.locationTimeoutTimer invalidate];
      self.locationTimeoutTimer = nil;
      // proceed without a location
      [self loadDefaultDataAndUpdateMapWithLocation:nil];
    }
  }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  @synchronized(self) {
    CLLocation *location = [locations lastObject];
    if (location && !self.haveLocation.value) {
      self.haveLocation.value = YES;
      [self.locationTimeoutTimer invalidate];
      self.locationTimeoutTimer = nil;
      [self.locationManager stopUpdatingLocation];
      self.locationManager = nil;
      [self loadDefaultDataAndUpdateMapWithLocation:location];
    }
  }
}

- (void)loadDefaultDataAndUpdateMapWithLocation:(CLLocation *)location {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // load our local location CSV data
    if (FBLocationOverrideDatasetFileName) {
      [self loadDataWithFilename:FBLocationOverrideDatasetFileName];
    } else {
      [self loadDataWithFilename:FBLocationCSVFileName];
    }

    self.menuButton.enabled = YES;

    // deal with no location passed in, by defaulting to the last datapoint
    CLLocation *mapCenter = location;
    if (!mapCenter || FBLocationOverrideDatasetFileName) {
      FBLocation *lastDatapoint = [self.dataset.locations lastObject];
      mapCenter = [[CLLocation alloc] initWithLatitude:lastDatapoint.latitude longitude:lastDatapoint.longitude];
      self.haveLocation.value = YES;
    }
    
    // debugging: set fixed Austin location
    //mapCenter = [[CLLocation alloc] initWithLatitude:30.30 longitude:-97.70];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
      MKCoordinateRegion region = MKCoordinateRegionMake(mapCenter.coordinate, DefaultZoomMapSpan());
      [self.waterOnlyMapView setRegion:region animated:NO];
      [self.fullMapView setRegion:region animated:NO];
      self.waterOnlyMapView.hidden = NO;
      self.fullMapView.hidden = NO;
      
      // Do the initial update of our data display.
      // Subsequently, this will only be triggered by our gesture recognizers
      [self updateDataDisplay];
    });
  });
}

@end
