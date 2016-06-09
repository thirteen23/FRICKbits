//
//  FBMapViewController+Location.h
//  FRICKbits
//
//  Created by Matt McGlincy on 7/15/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBMapViewController.h"

@interface FBMapViewController (Location) <CLLocationManagerDelegate>

- (void)doInitialLocationAndLoad;

@end
