//
//  FBDiaphanousView.m
//  FRICKbits
//
//  Created by Michael Van Milligan on 7/24/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBDiaphanousView.h"

@implementation FBDiaphanousView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
  __block BOOL pointInside = NO;

  [self.subviews
      enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
          UIView *subview = (UIView *)obj;
          CGPoint convertedPoint = [subview convertPoint:point fromView:self];
          if ([subview pointInside:convertedPoint withEvent:event]) {
            pointInside = YES;
            *stop = YES;
          }
      }];

  return pointInside;
}

@end
