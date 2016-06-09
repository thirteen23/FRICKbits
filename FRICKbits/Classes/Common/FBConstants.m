//
//  FBConstants.m
//  FrickBits
//
//  Created by Matt McGlincy on 1/24/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBConstants.h"

NSString *const FBAnnotationTypeCircle = @"FBAnnotationTypeCircle";
NSString *const FBAnnotationTypeDot = @"FBAnnotationTypeDot";
NSString *const FBAnnotationTypeFrickBit = @"FBAnnotationTypeFrickBit";
NSString *const FBAnnotationTypeFrickBitCluster =
    @"FBAnnotationTypeFrickBitCluster";
NSString *const FBAnnotationTypeGridCell = @"FBAnnotationTypeGridCell";

NSString *const FBLocationCSVFileName = @"location_history.csv";

NSUInteger const FBDatasetMaxLocations = 2000;

NSString *const FBLocationOverrideDatasetFileName = nil;
// NSString *const FBLocationOverrideDatasetFileName =
// @"openpaths_sarah_201407.csv";

CGFloat const FBMinimumBitLength = 2.0;
CGFloat const FBMinimumSegmentEndBitLength = 7.0;
CGFloat const FBDotRadius = 5.5;

NSString *const FBMapboxMapIDWaterOnly = @"t23developers.i1mgan7a";
NSString *const FBMapboxMapIDFull = @"t23developers.map-7ygvc38r";

CGFloat const FBLineOverlayLineWidth = 2.0;

NSUInteger const FBNotReadyUntilThisManyLocations = 10;

NSString *const FBLocalNotificationMessage =
    @"Go look, the very beginning of your FRICKbits are ready.";

NSUInteger const FBLocalNotificationMessageDelay = 5;

CLLocationDegrees const texasLatitude = 26.0;
CLLocationDegrees const texasLongitude = 96.0;

u_int32_t const texasLatitudeDelta = 10;
u_int32_t const texasLongitudeDelta = 12;
