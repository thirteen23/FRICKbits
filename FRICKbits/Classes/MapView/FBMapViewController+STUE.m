//
//  FBMapViewController+STUE.m
//  FRICKbits
//
//  Created by Matt McGlincy on 7/21/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBChrome.h"
#import "FBHeaderView.h"
#import "FBOnboardingPresentationView.h"
#import "FBMapViewController+STUE.h"

@implementation FBMapViewController (STUE)

static NSString *kDefaultsSTUEKey = @"FBUserHasSeenSTUE";

+ (BOOL)userCompletedSTUE {
  return [[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsSTUEKey];
}

+ (void)setUserCompletedSTUE:(BOOL)val {
  [[NSUserDefaults standardUserDefaults] setBool:val forKey:kDefaultsSTUEKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

static NSString *welcomeTitle = @"This is just the start!\n";
static NSString *welcomeText = @"Notice patterns in your travels. Pinch, compose, repaint. Tap anywhere for menu button. Keep moving.";
static NSString *welcomeButtonTitle = @"OK";

- (void)setupSTUEViews {
  [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];

  self.headerView = [[FBHeaderView alloc] init];
  [self.headerView addToView:self.view];
  
  // "Welcome back..." message overlay  
  NSMutableAttributedString *welcomeString = [[NSMutableAttributedString alloc]
                                              initWithAttributedString:[FBChrome attributedTextTitle:welcomeTitle]];
  [welcomeString appendAttributedString:[FBChrome attributedParagraph:welcomeText]];
  
  UIButton *welcomeButton = [FBChrome onboardingButtonWithTitle:welcomeButtonTitle];
  [welcomeButton addTarget:self action:@selector(welcomeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
  
  self.welcomeView =
  [[FBOnboardingPresentationView alloc] initWithHelpText:welcomeString andButton:welcomeButton andMargins:25.0f];
  [self.view addSubview:self.welcomeView];
  [self.welcomeView autoAlignAxisToSuperviewAxis:ALAxisVertical];
  [self.welcomeView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0];
  [self.welcomeView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0];
  [self.welcomeView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0];
  
  self.fullMapView.userInteractionEnabled = NO;
}

#pragma mark - button handlers

- (void)welcomeButtonPressed:(id)sender {
  [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:YES];
  [UIView animateWithDuration:1.0
                   animations:^{
                     self.headerView.alpha = 0.0;
                     self.welcomeView.alpha = 0.0;
                   }
                   completion:^(BOOL finished) {
                     [FBMapViewController setUserCompletedSTUE:YES];
                     [self.headerView removeFromSuperview];
                     [self.welcomeView removeFromSuperview];
                     self.headerView = nil;
                     self.welcomeView = nil;
                     self.fullMapView.userInteractionEnabled = YES;
                   }
   ];
}

@end
