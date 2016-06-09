//
//  FBAppDelegate.m
//  FrickBits
//
//  Created by Matt McGlincy on 1/9/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBAnalytics.h"
#import "FBAppDelegate.h"
#import "FBChrome.h"
#import "FBColorPaletteManager.h"
#import "FBConstants.h"
#import "FBDataset.h"
#import "FBLocationManager.h"
#import "FBMapViewController.h"
#import "FBNotReadyYetViewController.h"
#import "FBOnboarding.h"
#import "FBOnboardingViewController.h"
#import "FBOnboardingNavigationController.h"
#import "FBSettingsManager.h"
#import "FBUtils.h"

NSString *const kFBAppDelegateBackgroundTaskId =
    @"com.FRICKbits.FBAppDelegate.backgroundTaskId";

NSString *const kFBAppDelegateBackgroundFetchTaskId =
    @"com.FRICKbits.FBAppDelegate.backgroundFetchTaskId";

@interface FBAppDelegate ()
@property(nonatomic, strong) NSMutableDictionary *backgroundTasks;
@property(nonatomic, strong) dispatch_queue_t iVarQ;
@property(nonatomic) NSTimeInterval fetchInterval;
@end

@implementation FBAppDelegate

#pragma mark - Application Delegate Methods

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  static dispatch_once_t backgroundTaskOnce;
  dispatch_once(&backgroundTaskOnce, ^(void) {
      if (NULL == _iVarQ) {
        _iVarQ =
            dispatch_queue_create("com.FRICKbits.FBAppDelegate.iVarQ", NULL);
      }
      if (!_backgroundTasks) {
        _backgroundTasks = [[NSMutableDictionary alloc] initWithCapacity:4];
      }
  });

  // If we've already done onboarding, kick up the location manager so
  // we're accumulating data.
  if ([FBOnboarding onboardingCompleted]) {
    // If the app was awakened because of significant location change, initting
    // the sharedInstance will also immediate write that location.
    [FBLocationManager sharedInstance];
  }

  // Setup backgound fetch interval. We're not really hitting the network but we
  // want to make sure we can check for number of data points. We only want this
  // enabled if we're not yet done with location data
  //  _fetchInterval = (![FBOnboarding onboardingLocalNotificationCompleted])
  //                       ? UIApplicationBackgroundFetchIntervalMinimum
  //                       : UIApplicationBackgroundFetchIntervalNever;
  //
  //  [application setMinimumBackgroundFetchInterval:_fetchInterval];

  // Acquire the palette information; synchronously
  [[FBColorPaletteManager sharedInstance] getPalettesFromResources];

  // for testing, we're wiping out any saved settings and
  // restoring the default settings
  [FBSettingsManager sharedInstance];
  [[FBSettingsManager sharedInstance] setDefaults];
  [[FBSettingsManager sharedInstance] save];
  [[FBSettingsManager sharedInstance] reloadSettings];

  // appearance
  NSDictionary *navAppearanceDict = @{
    NSFontAttributeName : [FBChrome navigationBarFont],
    NSForegroundColorAttributeName : [FBChrome textGrayColor]
  };
  [[UINavigationBar appearance] setTitleTextAttributes:navAppearanceDict];

  [[UINavigationBar appearance]
      setBackgroundColor:[FBChrome navigationBarColor]];
  [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
  [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init]
                                     forBarMetrics:UIBarMetricsDefault];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

  // our visible view controller is set in applicationDidBecomeActive:,
  // so we do it once and consistently for both app starts and app foregrounding

  if (FBLocationOverrideDatasetFileName ||
      ![self shouldShowNotReadyYetViewController]) {
    // If we're testing or if there are enough data points then we should
    // probably just show the map view controller
    [self showMapViewController];
  } else if (![FBOnboarding onboardingCompleted]) {
    // Onboarding isn't completed yet or if there was a weird bug with
    // NSUserDefaults this would get masked
    [self showOnboardingViewController];
  } else {
    // We're clearly done with onboarding but not ready to show the map
    [self showNotReadyYetViewController];
  }

  [self.window makeKeyAndVisible];

  return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // during app foregrounding, possibly advance from onboarding or the
  // not-ready-yet screen

  UIViewController *rootVC = self.window.rootViewController;

  UINavigationController *nav = _ISA_(rootVC, UINavigationController)
                                    ? (UINavigationController *)rootVC
                                    : nil;

  UIViewController *topVC = (nav) ? nav.viewControllers.lastObject : rootVC;

  FBOnboardingViewController *oVC = _ISA_(topVC, FBOnboardingViewController)
                                        ? (FBOnboardingViewController *)topVC
                                        : nil;

  FBNotReadyYetViewController *nrVC = _ISA_(topVC, FBNotReadyYetViewController)
                                          ? (FBNotReadyYetViewController *)topVC
                                          : nil;

  if (_ISA_(nav, FBOnboardingNavigationController)) {
    if (![FBOnboarding onboardingCompleted]) {
      // We may be stuck in the no location view
      if (oVC && oVC.stuckInLocationPermissions) {
        // if we are then reload onboarding from the start
        [self showOnboardingViewController];
      }
    } else {
      // finished onboarding...
      if ([self shouldShowNotReadyYetViewController]) {
        // but don't have enough points yet
        [self showNotReadyYetViewController];
      } else {
        // and have enough points
        [self showMapViewController];
      }
    }
  } else if (nrVC && ![self shouldShowNotReadyYetViewController]) {
    // have enough points
    [self showMapViewController];
  }
}

#pragma mark - View Controller Presentation

- (void)showOnboardingViewController {
  // Note that we DO NOT set a delegate on the onboarding VC.
  // Initial app onboarding is basically a dead-end, and the app needs to
  // be dismissed or killed to continue with other screens.
  self.window.rootViewController = [[FBOnboardingNavigationController
          alloc] initWithOnboardingViewControllerAtStartingPoint];
}

- (BOOL)shouldShowNotReadyYetViewController {
  return [FBLocationManager estimatedLocationCount] <
         FBNotReadyUntilThisManyLocations;
}

- (void)showNotReadyYetViewController {
  FBNotReadyYetViewController *vc = [[FBNotReadyYetViewController alloc] init];
  self.window.rootViewController =
      [[UINavigationController alloc] initWithRootViewController:vc];
}

- (void)showMapViewController {
  // We want to stop any attempt by the background fetch to send a local
  // notification in case we reach this before the background fetch resumes.
  if (![FBOnboarding onboardingLocalNotificationCompleted]) {
    [FBOnboarding setOnboardingLocalNotificationCompleted:YES];
  }

  FBMapViewController *vc = [[FBMapViewController alloc] init];
  self.window.rootViewController =
      [[UINavigationController alloc] initWithRootViewController:vc];
}

#pragma mark - Handling Keyboard Events

- (void)dismissKeyboard {
  for (UIWindow *window in [UIApplication sharedApplication].windows) {
    [self dismissKeyboardWithView:window.rootViewController.view];
  }
}

- (void)dismissKeyboardWithView:(UIView *)view {
  [view endEditing:YES];
  for (UIView *sub in view.subviews) {
    [self dismissKeyboardWithView:sub];
  }
}

#pragma mark - Background Task Management

- (void)beginBackgroundUpdateTaskForId:(id<NSCopying>)identifier {
  if (!identifier) {
    return;
  }

  dispatch_sync(_iVarQ, ^(void) {

      if (!_backgroundTasks) {
        return;
      }

      UIBackgroundTaskIdentifier backgroundTask = UIBackgroundTaskInvalid;

      if (!_backgroundTasks[identifier]) {
        backgroundTask = [[UIApplication sharedApplication]
            beginBackgroundTaskWithExpirationHandler:^(void) {
                [self endBackgroundUpdateTaskForId:identifier];
            }];

        _backgroundTasks[identifier] =
            [NSNumber numberWithUnsignedInteger:backgroundTask];
      }
  });
}

- (void)endBackgroundUpdateTaskForId:(id<NSCopying>)identifier {
  if (!identifier) {
    return;
  }

  dispatch_sync(_iVarQ, ^(void) {

      if (!_backgroundTasks) {
        return;
      }

      id nsnumberForTask = nil;
      UIBackgroundTaskIdentifier backgroundTask = UIBackgroundTaskInvalid;

      if ((nsnumberForTask = _backgroundTasks[identifier])) {
        if (_ISA_(nsnumberForTask, NSNumber)) {
          backgroundTask = [(NSNumber *)nsnumberForTask unsignedIntegerValue];
          [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];

          [_backgroundTasks removeObjectForKey:identifier];
        }
      }
  });
}

#pragma mark - Local Notifications

/* >>>
- (void)application:(UIApplication *)application
    performFetchWithCompletionHandler:
        (void (^)(UIBackgroundFetchResult))completionHandler {
  // I don't trust that this contract is being honored so we're going to
  // explicitly try to hold up the background task.
  [self beginBackgroundUpdateTaskForId:kFBAppDelegateBackgroundFetchTaskId];

#if DEBUG
  // This is how we'll test that the locations are being updated properly.
  for (size_t i = 0; i < FBNotReadyUntilThisManyLocations; i++) {
    [[FBLocationManager sharedInstance] saveDummyLocation];
  }
#endif

  [self testAndHandleForLocationNotification];

  // We need to make sure we always return new data so that the heuristic always
  // scales up on calling us as much as possible.
  completionHandler(UIBackgroundFetchResultNewData);

  [self endBackgroundUpdateTaskForId:kFBAppDelegateBackgroundFetchTaskId];
}
<<< */

- (void)testAndHandleForLocationNotification {
  // Test if we have enough data points necessary to send a new local
  // notification
  if (![FBOnboarding onboardingLocalNotificationCompleted]) {
    if (![self shouldShowNotReadyYetViewController]) {
      [FBOnboarding sendLocalNotification];
    }
  }
}

- (void)askToRegisterForLocalNotifications {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
  // The following line must only run under iOS 8. This runtime check prevents
  // it from running if it doesn't exist (such as running under iOS 7 or
  // earlier).
  if ([[UIApplication sharedApplication]
          respondsToSelector:@selector(registerUserNotificationSettings:)]) {
    [[UIApplication sharedApplication]
        registerUserNotificationSettings:
            [UIUserNotificationSettings
                settingsForTypes:UIUserNotificationTypeAlert |
                                 UIUserNotificationTypeBadge |
                                 UIUserNotificationTypeSound
                      categories:nil]];
  }
#endif
}

- (void)application:(UIApplication *)application
    didRegisterUserNotificationSettings:
        (UIUserNotificationSettings *)notificationSettings {
  // We don't really do anything here because if the user is dumb enough to say
  // no to this then they just won't get the local notification.
}

@end
