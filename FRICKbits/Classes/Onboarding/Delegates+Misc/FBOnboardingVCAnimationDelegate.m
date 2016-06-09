//
//  FBOnboardingVCAnimationDelegate.m
//  FRICKbits
//
//  Created by Michael Van Milligan on 6/26/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBOnboardingNavigationController.h"
#import "FBMapViewController+Menu.h"
#import "FBOnboardingVCAnimationDelegate.h"
#import "FBOnboardingViewController.h"
#import "FBOnboardingMapViewController.h"
#import "FBOnboardingAnimationViewController.h"
#import "FBColorPalette.h"
#import "FBColorPaletteManager.h"
#import "FBUtils.h"
#import "FBOnboarding.h"
#import "FBAppDelegate.h"
#import "T23AtomicBoolean.h"

@interface FBOnboardingVCAnimationDelegate ()
@property(nonatomic, strong) FBColorPalette *currentPalette;
@end

@implementation FBOnboardingVCAnimationDelegate

- (id<UIViewControllerAnimatedTransitioning>)
    animationControllerForPresentedController:(UIViewController *)presented
                         presentingController:(UIViewController *)presenting
                             sourceController:(UIViewController *)source {

  // NSLog(@"animationControllerForPresentedController:%@presentingController:%@
  // @sourceController:%@",
  //      presented, presenting, source);
  //
  //  return (_ISA_(presented, FBOnboardingNavigationController)) ? self : nil;

  return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)
    animationControllerForDismissedController:(UIViewController *)dismissed {

  // NSLog(@"animationControllerForDismissedController:%@", dismissed);
  //
  //  return (_ISA_(dismissed, FBOnboardingNavigationController)) ? self : nil;

  return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)
               navigationController:
                   (UINavigationController *)navigationController
    animationControllerForOperation:(UINavigationControllerOperation)operation
                 fromViewController:(UIViewController *)fromVC
                   toViewController:(UIViewController *)toVC {

  //  NSLog(@"navigationController:%@ animationControllerForOperation:%lu "
  //        @"fromViewController:%@ toViewController:%@",
  //        navigationController, operation, fromVC, toVC);

  return ((_ISA_(fromVC, FBOnboardingViewController) &&
           _ISA_(toVC, FBOnboardingMapViewController)) ||
          (_ISA_(toVC, FBOnboardingViewController) &&
           _ISA_(fromVC, FBOnboardingMapViewController)) ||
          (_ISA_(fromVC, FBOnboardingAnimationViewController) &&
           (_ISA_(toVC, FBOnboardingViewController))))
             ? self
             : nil;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)
                  transitionContext {
  UIViewController *fromViewController = [transitionContext
      viewControllerForKey:UITransitionContextFromViewControllerKey];

  return (_ISA_(fromViewController, FBOnboardingAnimationViewController))
             ? 0.33f
             : 1.0f;
}

- (void)animationEnded:(BOOL)transitionCompleted {
  if (transitionCompleted) {
    if (_animationCompletionBlock) {
      dispatch_async(dispatch_get_main_queue(), _animationCompletionBlock);
    }
  }
}

- (void)animateTransition:
            (id<UIViewControllerContextTransitioning>)transitionContext {

  UIViewController *fromViewController = [transitionContext
      viewControllerForKey:UITransitionContextFromViewControllerKey];
  UIViewController *toViewController = [transitionContext
      viewControllerForKey:UITransitionContextToViewControllerKey];
  UIView *container = [transitionContext containerView];
  container.backgroundColor = [UIColor whiteColor];

  toViewController.view.alpha = 0.0f;

  [container insertSubview:toViewController.view
              aboveSubview:fromViewController.view];

  [toViewController.view layoutIfNeeded];
  [UIView animateWithDuration:[self transitionDuration:transitionContext]
      delay:0.0f
      options:(UIViewAnimationOptionBeginFromCurrentState |
               UIViewAnimationOptionCurveEaseOut)
      animations:^(void) {
          fromViewController.view.alpha = 0.0f;
          toViewController.view.alpha = 1.0f;
          [toViewController.view layoutIfNeeded];
      }
      completion:^(BOOL finished) {

          if (finished) {
            [transitionContext
                completeTransition:![transitionContext transitionWasCancelled]];
          }
      }];
}

@end
