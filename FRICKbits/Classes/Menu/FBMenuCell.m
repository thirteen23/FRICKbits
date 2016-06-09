//
// Created by Matt McGlincy on 4/3/14.
// Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBChrome.h"
#import "FBMenuCell.h"
#import "FBMenuItem.h"
#import "FBUtils.h"


@implementation FBMenuCell {

}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    self.backgroundColor =[FBChrome blurOverlayColor];
    self.selectionStyle = UITableViewCellSelectionStyleGray;

    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
        self.frame.size.width, 1)];
    topLine.backgroundColor = [UIColor whiteColor];
    [self addSubview:topLine];
    topLine.translatesAutoresizingMaskIntoConstraints = NO;
    [_titleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop
                                  withInset:0];
    [_titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft
                                  withInset:0];
    [_titleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight
                                  withInset:0];

    _iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40,
        40)];
    [self addSubview:_iconImageView];
    _iconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [_iconImageView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [_iconImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft
                                     withInset:10.0];

    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 31)];

    [self addSubview:_titleLabel];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_titleLabel autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    [_titleLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft
                                     withInset:50.0];

  }
  return self;
}

- (void)updateWithMenuItem:(FBMenuItem *)menuItem {
  self.iconImageView.image = menuItem.icon;

  UIFont *font = [UIFont fontWithName:@"Raleway-Medium"
                                     size:14.0];
  NSAttributedString *attributedString =
      [[NSAttributedString alloc]
          initWithString:menuItem.title
              attributes:
                  @{
                      NSFontAttributeName : font,
                      NSForegroundColorAttributeName : [FBChrome
                      darkGrayColor]                  ,
                      NSKernAttributeName : @(1.5f),
                  }
      ];
  self.titleLabel.attributedText = attributedString;
}

@end