//
//  FBConstants.h
//  FrickBits
//
//  Created by Matt McGlincy on 1/24/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

// define our various possible DEV_USERNAME values,
// so we can do things like #if DEV_USERNAME == mattmcglincy
#define gilligan 1
#define mattmcglincy 2

extern NSString *const FBAnnotationTypeCircle;
extern NSString *const FBAnnotationTypeDot;
extern NSString *const FBAnnotationTypeFrickBit;
extern NSString *const FBAnnotationTypeFrickBitCluster;
extern NSString *const FBAnnotationTypeGridCell;

// CSV file for our location data
extern NSString *const FBLocationCSVFileName;

// keep only the N most recent locations when loading a dataset. 0 = no limit.
extern NSUInteger const FBDatasetMaxLocations;

// optional possible override location dataset, for testing
extern NSString *const FBLocationOverrideDatasetFileName;

/// Don't allow bits shorter than this
extern CGFloat const FBMinimumBitLength;

// Dont' allow the first/last bits within a segment to be shorter than this.
// This helps with certain joinery visual foobars caused by too-short end bits.
extern CGFloat const FBMinimumSegmentEndBitLength;

extern CGFloat const FBDotRadius;

extern NSString *const FBMapboxMapIDFull;
extern NSString *const FBMapboxMapIDWaterOnly;

extern CGFloat const FBLineOverlayLineWidth;

extern NSUInteger const FBNotReadyUntilThisManyLocations;

extern NSString *const FBLocalNotificationMessage;

extern NSUInteger const FBLocalNotificationMessageDelay;

extern CLLocationDegrees const texasLatitude;

extern CLLocationDegrees const texasLongitude;

extern u_int32_t const texasLatitudeDelta;

extern u_int32_t const texasLongitudeDelta;
