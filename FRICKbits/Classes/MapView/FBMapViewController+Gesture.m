//
//  FBMapViewController+Gesture.m
//  FRICKbits
//
//  Created by Matt McGlincy on 7/15/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBAnimations.h"
#import "FBDateRangeOverlayView.h"
#import "FBFrickView.h"
#import "FBMapViewController+DataDisplay.h"
#import "FBMapViewController+Gesture.h"

static CGFloat const FBFrickViewFadeInDuration = 0.5;
static CGFloat const FBFrickViewFadeOutDuration = 0.2;

@implementation FBMapViewController (Gesture)

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
  return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
  return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:
(UIGestureRecognizer *)otherGestureRecognizer {
  return YES;
}

#pragma mark - handlers

- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer {
  if (recognizer.state == UIGestureRecognizerStateEnded) {
    [self toggleControlVisibility];
  }
}

- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)recognizer {
  if (recognizer.state == UIGestureRecognizerStateEnded) {
    [self pushBackUpdate];
  }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)recognizer {
  if (recognizer.state == UIGestureRecognizerStateBegan) {
    [self hideFrickViewFromGesture];
  } else if (recognizer.state == UIGestureRecognizerStateEnded) {
    [self pushBackUpdate];
  }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer {
  if (recognizer.state == UIGestureRecognizerStateBegan) {
    [self hideFrickViewFromGesture];
  } else if (recognizer.state == UIGestureRecognizerStateChanged ||
             recognizer.state == UIGestureRecognizerStateEnded) {
    [self pushBackUpdate];
  }
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer {
  if (recognizer.state == UIGestureRecognizerStateBegan) {
    [self hideFrickViewFromGesture];
  } else if (recognizer.state == UIGestureRecognizerStateChanged ||
             recognizer.state == UIGestureRecognizerStateEnded) {
    [self pushBackUpdate];
  }
}

- (void)hideFrickViewFromGesture {
  [self hideControlsWithAnimation:YES];
  [self hideFrickView];
  // also reset our tap recognizer, so it doesn't handle the touch up and toggle controls
  self.tapRecognizer.enabled = NO;
  self.tapRecognizer.enabled = YES;
}

- (void)pushBackUpdate {
  // use a timer to smooth out any repeated gesture calls and only call updateDataDisplay once
  if (self.updateDelayTimer) {
    [self.updateDelayTimer invalidate];
  }
  self.updateDelayTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(delayedShowAndUpdate)
                                                         userInfo:nil
                                                          repeats:NO];
}

- (void)delayedShowAndUpdate {
  [self showFrickView];
  [self updateDataDisplay];
}

#pragma mark - show & hide

- (void)toggleControlVisibility {
  if (self.controlsHidden) {
    [self showControlsWithAnimation:YES];
  } else {
    [self hideControlsWithAnimation:YES];
  }
}

- (void)showControlsWithAnimation:(BOOL)animation {
  self.controlsHidden = NO;
  
  if (animation) {
    [[UIApplication sharedApplication]
     setStatusBarHidden:NO
     withAnimation:UIStatusBarAnimationFade];
    [UIView animateWithDuration:FBFrickViewFadeInDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                       self.menuButton.alpha = 1.0;
                       if ([self.dateRangeOverlay shouldShow]) {
                         self.dateRangeOverlay.alpha = 1.0;
                       }
                     }
                     completion:^(BOOL finished) { self.menuButton.enabled = YES; }];
  } else {
    [[UIApplication sharedApplication]
     setStatusBarHidden:NO
     withAnimation:UIStatusBarAnimationNone];
    self.menuButton.alpha = 1.0;
    self.menuButton.enabled = YES;
    if ([self.dateRangeOverlay shouldShow]) {
      self.dateRangeOverlay.alpha = 1.0;
    }
  }
}

- (void)hideControlsWithAnimation:(BOOL)animation {
  self.controlsHidden = YES;
  
  if (animation) {
    [[UIApplication sharedApplication]
     setStatusBarHidden:YES
     withAnimation:UIStatusBarAnimationFade];
    [UIView animateWithDuration:FBFrickViewFadeInDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                       self.menuButton.alpha = 0.0;
                       self.dateRangeOverlay.alpha = 0.0;
                     }
                     completion:^(BOOL finished) { self.menuButton.enabled = NO; }];
  } else {
    [[UIApplication sharedApplication]
     setStatusBarHidden:YES
     withAnimation:UIStatusBarAnimationNone];
    self.menuButton.alpha = 0.0;
    self.menuButton.enabled = NO;
    self.dateRangeOverlay.alpha = 0.0;
  }
}

- (void)showFrickView {
  [FBAnimations animateView:self.waterOnlyMapView
                      alpha:1.0
                   duration:FBFrickViewFadeInDuration];
  [FBAnimations animateView:self.frickView
                      alpha:1.0
                   duration:FBFrickViewFadeInDuration];
}

- (void)hideFrickView {
  [FBAnimations animateView:self.waterOnlyMapView
                      alpha:0.0
                   duration:FBFrickViewFadeOutDuration];
  [FBAnimations animateView:self.frickView
                      alpha:0.0
                   duration:FBFrickViewFadeOutDuration];
}

@end
