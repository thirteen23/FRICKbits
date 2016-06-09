//
// Created by Matt McGlincy on 4/9/14.
// Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <MessageUI/MFMailComposeViewController.h>
#import "FBDataCalendarNavigationController.h"
#import "FBDialogView.h"
#import "FBFaqViewController.h"
#import "FBOnboardingNavigationController.h"
#import "FBMapViewController.h"
#import "FBMenuViewController.h"

@interface FBMapViewController (
    Menu) <MFMailComposeViewControllerDelegate, FBMenuViewControllerDelegate,
           FBDialogViewDelegate, FBOnboardingNavigationControllerDelegate,
           UIActivityItemSource, FBDataCalendarNavigationControllerDelegate,
           FBFaqViewControllerDelegate>

- (NSArray *)menuItems;
- (void)menuButtonPressed:(id)sender;
- (void)showMenuView;
- (void)hideMenuView;

@end