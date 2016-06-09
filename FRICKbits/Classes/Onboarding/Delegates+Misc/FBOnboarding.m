//
// Created by Matt McGlincy on 4/24/14.
// Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBColorPalette.h"
#import "FBColorPaletteManager.h"
#import "FBLocationManager.h"
#import "FBOnboarding.h"

static NSString *const FBDefaultsKeyOnboardingComplete =
    @"FBDefaultsKeyOnboardingCompleted";
static NSString *const FBDefaultsKeyOnboardingNotificationCount =
    @"FBDefaultsKeyOnboardingNotificationCount";
static NSString *const FBDefaultsKeyOnboardingNotificationCompleted =
    @"FBDefaultsKeyOnboardingNotificationCompleted";

@implementation FBOnboarding

+ (BOOL)onboardingCompleted {
  BOOL onboardingCompleted = NO;
  
  if ([[NSUserDefaults standardUserDefaults]
       objectForKey:FBDefaultsKeyOnboardingComplete]) {
    onboardingCompleted =
      [[NSUserDefaults standardUserDefaults]
          boolForKey:FBDefaultsKeyOnboardingComplete];
  } else {
    [FBOnboarding setOnboardingCompleted: onboardingCompleted];
  }
  
  return onboardingCompleted;
}

+ (void)setOnboardingCompleted:(BOOL)completed {
  [[NSUserDefaults standardUserDefaults]
      setBool:completed
       forKey:FBDefaultsKeyOnboardingComplete];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)finishOnboardingWithColorPalette:(FBColorPalette *)colorPalette {
  // save our common color palette
  //  FBColorPaletteManager *colorPaletteManager =
  //      [FBColorPaletteManager sharedInstance];

  // TODO: until we've polished palette generation,
  // we throw away the onboarding palette
  //  colorPaletteManager.colorPalette = colorPalette;
  //  [colorPaletteManager savePalette];

  // poke the location manager, so we start saving locations
  [FBLocationManager sharedInstance];

  // mark that we've completed onboarding
  [FBOnboarding setOnboardingCompleted:YES];
}

+ (BOOL)onboardingLocalNotificationCompleted {
  BOOL onboardingLocalNotificationsCompleted = NO;

  if ([[NSUserDefaults standardUserDefaults]
          objectForKey:FBDefaultsKeyOnboardingNotificationCompleted]) {
    onboardingLocalNotificationsCompleted =
        [[NSUserDefaults standardUserDefaults]
            boolForKey:FBDefaultsKeyOnboardingNotificationCompleted];
  } else {
    [FBOnboarding setOnboardingLocalNotificationCompleted:
                      onboardingLocalNotificationsCompleted];
  }

  return onboardingLocalNotificationsCompleted;
}

+ (void)setOnboardingLocalNotificationCompleted:(BOOL)completed {
  [[NSUserDefaults standardUserDefaults]
      setBool:completed
       forKey:FBDefaultsKeyOnboardingNotificationCompleted];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)sendLocalNotification {
  NSCalendar *calendar = [NSCalendar currentCalendar];
  NSDate *date = [NSDate date];

  NSDateComponents *components = [[NSDateComponents alloc] init];
  [components setSecond:FBLocalNotificationMessageDelay];

  UILocalNotification *localNotification = [[UILocalNotification alloc] init];
  localNotification.fireDate =
      [calendar dateByAddingComponents:components toDate:date options:0];
  localNotification.alertBody = FBLocalNotificationMessage;
  localNotification.timeZone = [NSTimeZone defaultTimeZone];

  [[UIApplication sharedApplication] cancelAllLocalNotifications];
  [[UIApplication sharedApplication]
      scheduleLocalNotification:localNotification];

  [FBOnboarding setOnboardingLocalNotificationCompleted:YES];
}

@end