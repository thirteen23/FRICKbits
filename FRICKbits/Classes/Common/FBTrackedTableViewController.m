//
// Created by Matt McGlincy on 4/2/14.
// Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBTrackedTableViewController.h"

#import "FBAnalytics.h"


@implementation FBTrackedTableViewController {

}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  if (self.screenName) {
    [FBAnalytics sendView:self.screenName];
  }
}

@end