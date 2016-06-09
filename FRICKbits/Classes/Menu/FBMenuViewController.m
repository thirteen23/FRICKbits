//
//  FBMenuViewController.m
//  FrickBits
//
//  Created by Matt McGlincy on 4/2/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBMenuCell.h"
#import "FBMenuItem.h"
#import "FBMenuViewController.h"

@interface FBMenuViewController () <UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, strong) UITableView *tableView;
@end

@implementation FBMenuViewController

- (id)initWithMenuItems:(NSArray *)menuItems {
  self = [super init];
  if (self) {
    _menuItems = [menuItems copy];
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  _menuItemHeight = 48.0;
  _menuHeight = _menuItemHeight * _menuItems.count;

  UIView *nonTableArea = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
      self.view.frame.size.width, self.view.frame.size.height - _menuHeight)];
  [self.view addSubview:nonTableArea];

  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                                          initWithTarget:self
      action:@selector(handleTapGesture:)];
  [nonTableArea addGestureRecognizer:tapGestureRecognizer];

  _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
      self.view.frame.size.height - _menuHeight, self.view.frame.size.width,
      _menuHeight)];
  [self.view addSubview:_backgroundImageView];

  _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,
      self.view.frame.size.height - _menuHeight, self.view.frame.size.width,
      _menuHeight)];
  _tableView.dataSource = self;
  _tableView.delegate = self;
  _tableView.scrollEnabled = NO;
  _tableView.backgroundColor = [UIColor clearColor];
  // cells provide their own top line
  _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  [self.view addSubview:_tableView];

  [_tableView reloadData];
}

- (void)handleTapGesture:(id)handleTapGesture {
  [_delegate menuViewControllerDidCancel:self];
}

#pragma UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"FBMenuCell";
  FBMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (!cell) {
    cell = [[FBMenuCell alloc] initWithStyle:UITableViewCellStyleDefault
        reuseIdentifier:CellIdentifier];
  }
  FBMenuItem *menuItem = _menuItems[(NSUInteger) indexPath.row];
  [cell updateWithMenuItem:menuItem];
  return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return self.menuItemHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [_tableView deselectRowAtIndexPath:indexPath animated:YES];
  FBMenuItem *menuItem = _menuItems[(NSUInteger) indexPath.row];
  [_delegate menuViewController:self didSelectMenuItem:menuItem];
}

@end
