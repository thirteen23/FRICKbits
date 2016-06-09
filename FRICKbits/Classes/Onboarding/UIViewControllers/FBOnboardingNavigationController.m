//
//  FBOnboardingNavigationController.m
//  FRICKbits
//
//  Created by Michael Van Milligan on 6/27/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBOnboardingNavigationController.h"
#import "FBOnboardingAnimationViewController.h"
#import "FBOnboardingViewController.h"
#import "FBOnboardingMapViewController.h"
#import "FBOnboardingVCAnimationDelegate.h"
#import "FBOnboarding.h"
#import "FBUtils.h"

@interface FBOnboardingNavigationController ()
@property(nonatomic, strong)
    FBOnboardingVCAnimationDelegate *strongAnimationDelegate;
@property(nonatomic, strong) FBColorPalette *palette;
@end

@implementation FBOnboardingNavigationController

- (id)init {
  if (self = [super init]) {
    self.navigationBarHidden = YES;

    _strongAnimationDelegate = [[FBOnboardingVCAnimationDelegate alloc] init];
    self.delegate = _strongAnimationDelegate;
    self.transitioningDelegate = _strongAnimationDelegate;
  }
  return self;
}

- (instancetype)initWithOnboardingViewControllerAtStartingPoint {
  if (self = [self init]) {
    FBOnboardingViewController *onboardingVC =
        [[FBOnboardingViewController alloc] initAtStartingPoint];
    onboardingVC.view.hidden = NO;
    onboardingVC.edgesForExtendedLayout = UIRectEdgeNone;
    onboardingVC.extendedLayoutIncludesOpaqueBars = NO;
    onboardingVC.automaticallyAdjustsScrollViewInsets = NO;

    FBOnboardingAnimationViewController *onboardingAnimationVC =
        [[FBOnboardingAnimationViewController alloc] init];
    onboardingAnimationVC.view.hidden = NO;
    onboardingAnimationVC.edgesForExtendedLayout = UIRectEdgeNone;
    onboardingAnimationVC.extendedLayoutIncludesOpaqueBars = NO;
    onboardingAnimationVC.automaticallyAdjustsScrollViewInsets = NO;

    [self pushViewController:onboardingVC animated:NO];
    [self pushViewController:onboardingAnimationVC animated:NO];
  }
  return self;
}

- (instancetype)initWithOnboardingViewControllerAtPickerPointWithColorIndex:
                    (NSUInteger)index {
  if (self = [self init]) {
    FBOnboardingViewController *onboardingVC =
        [[FBOnboardingViewController alloc]
            initAtPickerPointWithColorIndex:index];
    onboardingVC.view.hidden = NO;
    onboardingVC.edgesForExtendedLayout = UIRectEdgeNone;
    onboardingVC.extendedLayoutIncludesOpaqueBars = NO;
    onboardingVC.automaticallyAdjustsScrollViewInsets = NO;

    [self pushViewController:onboardingVC animated:NO];
  }
  return self;
}

- (void)cancel {
  dispatch_async(dispatch_get_main_queue(), ^(void) {
      if (_onboardingAnimationDelegate &&
          [_onboardingAnimationDelegate
              respondsToSelector:
                  @selector(onboardingNavigationControllerDidCancel:)]) {
        [_onboardingAnimationDelegate
            onboardingNavigationControllerDidCancel:self];
      }
  });
}

- (void)transitionToOnboardingViewController {

  /* callback block for animation transition */
  __typeof__(self) __weak weakSelf = self;
  _strongAnimationDelegate.animationCompletionBlock = ^void(void) {

    id potentialVC = [weakSelf.viewControllers firstObject];
    if (_ISA_(potentialVC, FBOnboardingViewController)) {
      FBOnboardingViewController *onboardingVC =
          (FBOnboardingViewController *)potentialVC;
      [onboardingVC doInitialPickerTransition];
    }
  };

  [self popToRootViewControllerAnimated:YES];
}

- (void)transitionToMapViewControllerWithColorPalette:
            (FBColorPalette *)palette {

  self.palette = palette;

  if (![FBOnboarding onboardingCompleted]) {

    /* Point of no return */
    [FBOnboarding setOnboardingCompleted:YES];

    /* callback block for animation transition */
    __typeof__(self) __weak weakSelf = self;
    _strongAnimationDelegate.animationCompletionBlock = ^void(void) {
      [weakSelf signalOnboardingDelegate];
    };

    FBOnboardingMapViewController *mapVC =
        [[FBOnboardingMapViewController alloc] initWithColorPalette:palette];
    mapVC.view.hidden = NO;
    mapVC.edgesForExtendedLayout = UIRectEdgeNone;
    mapVC.extendedLayoutIncludesOpaqueBars = NO;
    mapVC.automaticallyAdjustsScrollViewInsets = NO;

    NSMutableArray *vcList = [self.viewControllers mutableCopy];
    [vcList insertObject:mapVC atIndex:0];

    [self setViewControllers:vcList animated:NO];
    [self popToViewController:mapVC animated:YES];
  } else {

    /* Just signal the delegate */
    dispatch_async(dispatch_get_main_queue(),
                   ^(void) { [self signalOnboardingDelegate]; });
  }
}

- (void)didTransitionToNoLocationViewWithColorPalette:
            (FBColorPalette *)palette {

  self.palette = palette;

  if (![FBOnboarding onboardingCompleted]) {

    /* Point of no return */
    [FBOnboarding setOnboardingCompleted:YES];

    /* Just signal the delegate */
    dispatch_async(dispatch_get_main_queue(),
                   ^(void) { [self signalOnboardingDelegate]; });
  }
}

- (void)signalOnboardingDelegate {
  if (_onboardingAnimationDelegate &&
      [_onboardingAnimationDelegate
          respondsToSelector:@selector(onboardingNavigationController:
                                                didChooseColorPalette:)]) {
    [_onboardingAnimationDelegate onboardingNavigationController:self
                                           didChooseColorPalette:_palette];
  } else {
#if DEBUG
    NSLog(@"Not signaling delegate because there isn't one or they don't have "
          @"@selector(onboardingNavigationController:didChooseColorPalette:) "
          @"defined");
#endif
  }
}

@end
