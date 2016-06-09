//
// Created by Matt McGlincy on 4/9/14.
// Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBMapViewController.h"

@interface FBMapViewController (DataDisplay)

- (void)loadDataWithFilename:(NSString *)filename;
- (void)updateDataDisplay;
- (void)zoomMapToFitDataset;

@end