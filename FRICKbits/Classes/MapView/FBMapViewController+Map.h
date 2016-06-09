//
// Created by Matt McGlincy on 4/17/14.
// Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBMapViewController.h"

@interface FBMapViewController (Map) <MKMapViewDelegate>

+ (NSInteger)snappedZoomLevel:(NSInteger)zoomLevel;

- (CGFloat)currentZoomScale;
- (NSInteger)currentZoomLevel;
- (BOOL)mapIsGreaterThanMaxZoom;

- (void)recolorDots;

@end