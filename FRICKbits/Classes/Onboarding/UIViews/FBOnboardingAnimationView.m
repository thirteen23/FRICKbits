//
//  FBOnboardingAnimationView.m
//  FRICKbits
//
//  Created by Michael Van Milligan on 9/5/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBOnboardingAnimationView.h"
#import "FBUtils.h"
#import "PureLayout.h"

@interface FBOnboardingAnimationView ()
@property(nonatomic, strong) UIImageView *backgroundView;
@end

@implementation FBOnboardingAnimationView

- (instancetype)initWithBackgroundImage:(UIImage *)backgroundImage {
  if (self = [super init]) {

    NSAssert(backgroundImage,
             @"In order to animate the image should be non-nil");

    self.translatesAutoresizingMaskIntoConstraints = NO;
    _backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
    _backgroundView.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:_backgroundView];

    [_backgroundView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [_backgroundView autoAlignAxisToSuperviewAxis:ALAxisVertical];

    [self autoMatchDimension:ALDimensionWidth
                 toDimension:ALDimensionWidth
                      ofView:_backgroundView];

    [self autoMatchDimension:ALDimensionHeight
                 toDimension:ALDimensionHeight
                      ofView:_backgroundView];
  }
  return self;
}

@end
