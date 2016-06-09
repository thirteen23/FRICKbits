//
//  FBMapViewController+STUE.h
//  FRICKbits
//
//  Created by Matt McGlincy on 7/21/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBMapViewController.h"

@interface FBMapViewController (STUE)

+ (BOOL)userCompletedSTUE;
+ (void)setUserCompletedSTUE:(BOOL)val;

- (void)setupSTUEViews;

- (void)welcomeButtonPressed:(id)sender;

@end
