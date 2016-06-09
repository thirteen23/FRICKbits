//
//  FBOnboardingNavigationController.h
//  FRICKbits
//
//  Created by Michael Van Milligan on 6/27/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FBColorPalette;
@class FBOnboardingMapViewController;
@class FBOnboardingNavigationController;

@protocol FBOnboardingNavigationControllerDelegate<NSObject>

@required
- (void)onboardingNavigationController:
            (FBOnboardingNavigationController *)onboardingNC
                 didChooseColorPalette:(FBColorPalette *)colorPalette;

- (void)onboardingNavigationControllerDidCancel:
        (FBOnboardingNavigationController *)onboardingNC;

@end

@interface FBOnboardingNavigationController : UINavigationController

@property(nonatomic, weak)
    id<FBOnboardingNavigationControllerDelegate> onboardingAnimationDelegate;

- (instancetype)initWithOnboardingViewControllerAtStartingPoint;
- (instancetype)initWithOnboardingViewControllerAtPickerPointWithColorIndex:
        (NSUInteger)index;

- (void)cancel;
- (void)transitionToOnboardingViewController;
- (void)transitionToMapViewControllerWithColorPalette:(FBColorPalette *)palette;
- (void)didTransitionToNoLocationViewWithColorPalette:(FBColorPalette *)palette;

@end