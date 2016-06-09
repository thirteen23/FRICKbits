//
//  FBTouchDownGestureRecognizer.m
//  FrickBits
//
//  Created by Matt McGlincy on 3/6/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <UIKit/UIGestureRecognizerSubclass.h>
#import "FBTouchGestureRecognizer.h"

@implementation FBTouchGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if (self.state == UIGestureRecognizerStatePossible) {
    self.state = UIGestureRecognizerStateBegan;
  }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  self.state = UIGestureRecognizerStateChanged;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  self.state = UIGestureRecognizerStateRecognized;
}

@end
