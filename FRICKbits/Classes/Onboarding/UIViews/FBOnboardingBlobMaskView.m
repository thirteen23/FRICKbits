//
//  FBOnboardingBlobMaskView.m
//  FRICKbits
//
//  Created by Michael Van Milligan on 5/28/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBOnboardingBlobMaskView.h"

@interface FBOnboardingBlobMaskView ()

@property(nonatomic, strong) UIBezierPath *mask;

@end

@implementation FBOnboardingBlobMaskView

- (instancetype)initWithFrame:(CGRect)frame andMask:(UIBezierPath *)path {
  if (self = [self initWithFrame:frame]) {
    _mask = path;
  }
  return self;
}

- (instancetype)initWithMask:(UIBezierPath *)path {
  if (self = [super init]) {
    self.backgroundColor = [UIColor clearColor];
    self.translatesAutoresizingMaskIntoConstraints = NO;
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.backgroundColor = [UIColor clearColor];
    self.translatesAutoresizingMaskIntoConstraints = NO;
  }
  return self;
}

- (void)drawRect:(CGRect)rect {
  UIBezierPath *bigMaskPath = [UIBezierPath bezierPathWithRect:rect];

  UIBezierPath *clipPath = [UIBezierPath bezierPathWithRect:CGRectInfinite];
  [clipPath appendPath:_mask];
  clipPath.usesEvenOddFillRule = YES;

  CGContextSaveGState(UIGraphicsGetCurrentContext());
  {
    [clipPath addClip];
    [[[UIColor whiteColor] colorWithAlphaComponent:1.0f] setFill];
    [bigMaskPath fill];
  }
  CGContextRestoreGState(UIGraphicsGetCurrentContext());
}

@end
