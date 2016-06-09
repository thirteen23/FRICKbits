//
//  FBMenuViewController.h
//  FrickBits
//
//  Created by Matt McGlincy on 4/2/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

@class FBMenuItem;
@class FBMenuViewController;

@protocol FBMenuViewControllerDelegate
- (void)menuViewControllerDidCancel:(FBMenuViewController *)vc;
- (void)menuViewController:(FBMenuViewController *)vc didSelectMenuItem:
    (FBMenuItem *)menuItem;
@end

@interface FBMenuViewController : UIViewController

// callback delegate.
@property(nonatomic, weak) id <FBMenuViewControllerDelegate> delegate;

// pixel height of each menuItem. Defaults to 48.0.
@property(nonatomic) CGFloat menuItemHeight;

// pixel height of the menu. Defaults to menuItems.count * menuItemHeight.
@property(nonatomic) CGFloat menuHeight;

// FBMenuItems to show.
@property(nonatomic, strong) NSArray *menuItems;

// image behind the menu.
@property(nonatomic, strong) UIImageView *backgroundImageView;

// designated initializer.
- (id)initWithMenuItems:(NSArray *)menuItems;

@end
