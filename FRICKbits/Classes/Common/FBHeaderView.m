//
// Created by Matt McGlincy on 4/23/14.
// Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBHeaderView.h"
#import "FBUtils.h"
#import "FBChrome.h"

@interface FBHeaderView ()
@property(nonatomic, strong) UIImageView *headerImageView;
@property(nonatomic, strong) UIView *whiteLine;
@property(nonatomic) CGFloat height;
@end

@implementation FBHeaderView

- (id)init {
  if (self = [super init]) {
    [self commonInit];
  }
  return self;
}

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self commonInit];
  }
  return self;
}

- (void)addToView:(UIView *)view {
  [view addSubview:self];
  [self autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0.0];
  [self autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
  [self autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];
}

- (void)commonInit {
  self.translatesAutoresizingMaskIntoConstraints = NO;

  self.backgroundColor = [FBChrome headerBackgroundColor];

  UIImage *titleImage = [UIImage imageNamed:@"header_small_bits.png"];
  _height = titleImage.size.height;

  _headerImageView = [[UIImageView alloc] initWithImage:titleImage];

  [self addSubview:_headerImageView];

  _headerImageView.translatesAutoresizingMaskIntoConstraints = NO;
  [_headerImageView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];

  _whiteLine = [[UIView alloc] init];
  _whiteLine.translatesAutoresizingMaskIntoConstraints = NO;
  _whiteLine.backgroundColor = [UIColor whiteColor];
  [self addSubview:_whiteLine];

  [_whiteLine autoSetDimension:ALDimensionHeight toSize:1.0f];
  [_whiteLine autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self];
  [_whiteLine autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self];
  [_whiteLine autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self];

  [self autoSetDimension:ALDimensionHeight
                  toSize:_height + FRICK_BITS_STATUS_BAR_HEIGHT];
}

+ (CGFloat)heightOfHeaderView {
  return [UIImage imageNamed:@"header_small_bits.png"].size.height +
         FRICK_BITS_STATUS_BAR_HEIGHT + 1.0f;
}

@end