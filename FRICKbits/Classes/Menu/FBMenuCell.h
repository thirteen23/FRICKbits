//
// Created by Matt McGlincy on 4/3/14.
// Copyright (c) 2014 Thirteen23. All rights reserved.
//

@class FBMenuItem;

@interface FBMenuCell : UITableViewCell

@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UIImageView *iconImageView;

- (void)updateWithMenuItem:(FBMenuItem *)menuItem;

@end