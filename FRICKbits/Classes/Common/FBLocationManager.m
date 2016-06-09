//
//  FBLocationManager.m
//  FrickBits
//
//  Created by Matt McGlincy on 2/7/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBConstants.h"
#import "FBOnboarding.h"
#import "FBLocationManager.h"
#import "FBUtils.h"
#import "FBAppDelegate.h"

NSString *const kFBLocationManagerAuthorizationChangedNotification =
    @"FBLocationManagerAuthChange";
NSString *const kFBLocationManagerDidFailWithErrorNotification =
    @"FBLocationManagerError";
NSString *const kFBLocationManagerBackgroundTaskId =
    @"com.FRICKbits.FBLocationManager.backgroundTaskId";

@interface FBLocationManager () <CLLocationManagerDelegate>
@property(nonatomic, strong) CLLocationManager *locationManager;
@end

@implementation FBLocationManager

+ (instancetype)sharedInstance {
  static id _sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{ _sharedInstance = [[self alloc] init]; });
  return _sharedInstance;
}

- (id)init {
  self = [super init];
  if (self) {
    self.locationManager = [[CLLocationManager alloc] init];

    // If we were launched because of a location update, we may already have a
    // location ready to be written.
    // "...the location property of your location manager object is populated
    // with the most recent location
    // object even before you start location services."
    if (self.locationManager.location) {
      [self saveLocation:self.locationManager.location];
    }

    self.locationManager.delegate = self;
    [self requestAuthorization];
  }
  return self;
}

- (void)requestAuthorization {
/*
 * Gross hack because iOS7 doesn't include this method in its symbol table
 * yet is exposed in iOS8 SDK
 */
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
  if ([self.locationManager
          respondsToSelector:@selector(requestAlwaysAuthorization)]) {
    [self.locationManager requestAlwaysAuthorization];
  }
#endif

  [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)deleteLocationData {
  NSString *filePath = DocumentsFilePath(FBLocationCSVFileName);
  if ([[NSFileManager defaultManager] isDeletableFileAtPath:filePath]) {
    NSLog(@"deleting file %@", filePath);
    NSError *error;
    BOOL success =
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    if (!success || error) {
      NSLog(@"Error removing file at path: %@", error.localizedDescription);
    }
  } else {
    NSLog(@"no deletable file %@", filePath);
  }
}

NSString *FBCSVStringForLocation(CLLocation *location) {
  return [NSString stringWithFormat:@"%.14f,%.14f,%f",
                                    location.coordinate.latitude,
                                    location.coordinate.longitude,
                                    [location.timestamp timeIntervalSince1970]];
}

- (void)saveLocation:(CLLocation *)location {
  // get the file path
  NSString *filePath = DocumentsFilePath(FBLocationCSVFileName);

  // create file if it doesn't exist
  if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
    [[NSFileManager defaultManager] createFileAtPath:filePath
                                            contents:nil
                                          attributes:nil];
    NSLog(@"Creating new location data file %@", filePath);
  }

  // new CSV line
  NSString *csv = FBCSVStringForLocation(location);

  // append line to file, with newline
  NSFileHandle *file = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
  if (file) {
    [file seekToEndOfFile];
    NSString *csvWithNewline = [NSString stringWithFormat:@"%@\n", csv];
    [file writeData:[csvWithNewline dataUsingEncoding:NSUTF8StringEncoding]];
    [file closeFile];
    // NSLog(@"Wrote location %@", csv);
  } else {
    NSLog(@"Could not find location file %@", filePath);
  }
}

#if DEBUG
- (void)saveDummyLocation {
  // Roughly Texas is between 36º and 26º Lat & 106º and 94º Lon
  CLLocationDegrees baseTexasLat = texasLatitude;
  CLLocationDegrees baseTexasLon = texasLongitude;

  baseTexasLat += ((CLLocationDegrees)arc4random_uniform(UINT32_MAX) /
                   (CLLocationDegrees)UINT32_MAX) *
                  texasLatitudeDelta;

  baseTexasLon += ((CLLocationDegrees)arc4random_uniform(UINT32_MAX) /
                   (CLLocationDegrees)UINT32_MAX) *
                  texasLongitudeDelta;

  CLLocation *dummy =
      [[CLLocation alloc] initWithLatitude:baseTexasLat longitude:baseTexasLon];

  [self saveLocation:dummy];
}
#endif /* DEBUG */

- (CLAuthorizationStatus)authorizationStatus {
  return [CLLocationManager authorizationStatus];
}

- (UIBackgroundRefreshStatus)locationBackgroundRefreshStatus {
  return [[UIApplication sharedApplication] backgroundRefreshStatus];
}

+ (unsigned long long)estimatedLocationCount {
  // example CSV line:
  // 37.33240904999999,-122.03051210999995,1409773966.897476
  static NSUInteger kBytesPerLocationLine = 56;
  return FileSize(DocumentsFilePath(FBLocationCSVFileName)) /
         kBytesPerLocationLine;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
  // locations delivered in oldest-first order

  // We should hold off backgrounding until loop finishes
  FBAppDelegate *appDelegate =
      (FBAppDelegate *)[[UIApplication sharedApplication] delegate];

  [appDelegate
      beginBackgroundUpdateTaskForId:kFBLocationManagerBackgroundTaskId];

  for (CLLocation *location in locations) {
    [self saveLocation:location];
  }

  [appDelegate testAndHandleForLocationNotification];

  [appDelegate endBackgroundUpdateTaskForId:kFBLocationManagerBackgroundTaskId];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
  [[NSNotificationCenter defaultCenter]
      postNotificationName:kFBLocationManagerDidFailWithErrorNotification
                    object:error];
}

- (void)locationManager:(CLLocationManager *)manager
    didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
  [[NSNotificationCenter defaultCenter]
      postNotificationName:kFBLocationManagerAuthorizationChangedNotification
                    object:[NSNumber numberWithInteger:status]];
}

@end
