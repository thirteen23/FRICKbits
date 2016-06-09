//
// Created by Matt McGlincy on 4/2/14.
// Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBAnalytics.h"
//#import "GAI.h"
//#import "GAIDictionaryBuilder.h"
//#import "GAIFields.h"

/*
 To add Google Analytics include it in the Podfile, uncomment the imports and following
 code and add your tracking id. Analytics will start being collected automatically.
 */

@interface FBAnalytics ()
@end

@implementation FBAnalytics

+ (void)configure {
//  // Optional: automatically send uncaught exceptions to Google Analytics.
//  [GAI sharedInstance].trackUncaughtExceptions = YES;
//
//  // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
//  [GAI sharedInstance].dispatchInterval = 20;
//
//  // Optional: set Logger to VERBOSE for debug information.
//  [[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelError];
//
//  // Initialize tracker.
//  [[GAI sharedInstance] trackerWithTrackingId:@"UA-XXXXXXXX-1"];
}

+ (void)sendView:(NSString *)screen {
//  [[[GAI sharedInstance] defaultTracker] send:[[[GAIDictionaryBuilder
//      createAppView]
//      set:screen
//   forKey:kGAIScreenName] build]];
////  [[[GAI sharedInstance] defaultTracker] sendView:screen];
}

@end