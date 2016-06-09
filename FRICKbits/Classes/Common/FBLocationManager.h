//
//  FBLocationManager.h
//  FrickBits
//
//  Created by Matt McGlincy on 2/7/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

/*
 * Notification that fires for when CLLocation didChangeAuthorizationStatus:
 * fires. NSNumber *value included in posted notification wraps a
 * CLAuthorizationStatus value. See <CoreLocation/CLLocationManager.h> for
 * appropriate values.
 */
extern NSString *const kFBLocationManagerAuthorizationChangedNotification;

/*
 * Notification that fires for when CLLocation didFailWithError:
 * fires. NSError *value included in posted notification wraps a CLError
 * value. See <CoreLocation/CLError.h> for appropriate values.
 */
extern NSString *const kFBLocationManagerDidFailWithErrorNotification;

@interface FBLocationManager : NSObject

@property(nonatomic, readonly) CLAuthorizationStatus authorizationStatus;
@property(nonatomic, readonly)
    UIBackgroundRefreshStatus locationBackgroundRefreshStatus;

+ (instancetype)sharedInstance;
- (void)deleteLocationData;
- (void)requestAuthorization;

// number of location lines in the default CSV file, based on file size.
+ (unsigned long long)estimatedLocationCount;

#if DEBUG
- (void)saveDummyLocation;
#endif /* DEBUG */

@end