//
//  FBTrackedNavigationController.m
//  FRICKbits
//
//  Created by Michael Van Milligan on 8/25/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBAnalytics.h"
#import "FBTrackedNavigationController.h"

@implementation FBTrackedNavigationController {
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  if (self.screenName) {
    [FBAnalytics sendView:self.screenName];
  }
}

@end
