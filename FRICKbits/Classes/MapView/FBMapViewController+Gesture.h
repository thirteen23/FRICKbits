//
//  FBMapViewController+Gesture.h
//  FRICKbits
//
//  Created by Matt McGlincy on 7/15/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBMapViewController.h"

@interface FBMapViewController (Gesture) <UIGestureRecognizerDelegate>

- (void)handleTapGesture:(UITapGestureRecognizer *)recognizer;
- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)recognizer;
- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)recognizer;
- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer;
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer;

- (void)showControlsWithAnimation:(BOOL)animation;
- (void)hideControlsWithAnimation:(BOOL)animation;

- (void)showFrickView;
- (void)hideFrickView;

@end
