//
//  FBAppDelegate.h
//  FrickBits
//
//  Created by Matt McGlincy on 1/9/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBAppDelegate : UIResponder<UIApplicationDelegate>

@property(strong, nonatomic) UIWindow *window;

- (void)showMapViewController;
- (void)showNotReadyYetViewController;
- (void)showOnboardingViewController;
- (void)beginBackgroundUpdateTaskForId:(id<NSCopying>)identifier;
- (void)endBackgroundUpdateTaskForId:(id<NSCopying>)identifier;
- (void)askToRegisterForLocalNotifications;
- (void)testAndHandleForLocationNotification;

@end
