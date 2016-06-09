//
//  FBUtils.h
//  FrickBits
//
//  Created by Matt McGlincy on 1/14/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import "MTGeometry.h"

#define FRICK_BITS_STATUS_BAR_HEIGHT                                           \
  ([UIApplication sharedApplication].statusBarFrame.size.height)

#define _ISA_(X, CLASS) ([X isKindOfClass:[CLASS class]])

#define DEF_SAFE_GETSET_FOR_Q(Type, Property, SetProperty, Q)                  \
  -(Type)Property {                                                            \
    __block Type retval;                                                       \
    dispatch_sync(Q, ^(void) { retval = _##Property; });                       \
    return retval;                                                             \
  }                                                                            \
  -(void)SetProperty : (Type)Property {                                        \
    dispatch_sync(Q, ^(void) { _##Property = Property; });                     \
  }

#define CLAMP(x, low, high)                                                    \
  (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))

#define DEGREES_TO_RADIANS(degrees) ((degrees) * (M_PI / 180.0))
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))

#define FLOOR_PI(DP)                                                           \
  (floor((10.0 * ((unsigned int)fabs(DP))) * M_PI) /                           \
   (10.0 * ((unsigned int)fabs(DP))))
#define FLOORF_PI(DP)                                                          \
  (floorf((10.0 * ((unsigned int)fabsf(DP))) * M_PI) /                         \
   (10.0 * ((unsigned int)fabsf(DP))))
#define CEIL_PI(DP)                                                            \
  (ceil((10.0 * ((unsigned int)fabs(DP))) * M_PI) /                            \
   (10.0 * ((unsigned int)fabs(DP))))
#define CEILF_PI(DP)                                                           \
  (ceilf((10.0 * ((unsigned int)fabsf(DP))) * M_PI) /                          \
   (10.0 * ((unsigned int)fabsf(DP))))

typedef struct {
  CGPoint p1;
  CGPoint p2;
} CGPointPair;
extern CGPointPair CGPointPairMake(CGPoint p1, CGPoint p2);

typedef struct {
  CGFloat f1;
  CGFloat f2;
} CGFloatPair;
extern CGFloatPair CGFloatPairMake(CGFloat f1, CGFloat f2);

/**
 * Create a UIColor from a hex string.
 * Assumes #RRGGBB input. E.g., @"#00FF00".
 */
extern UIColor *UIColorFromHexString(NSString *hexString, CGFloat alpha);

/**
 * Create a grayscale color from another color.
 * Uses the ITU-R recommendation (BT.709)
 */
extern UIColor *UIColorInGrayscale(UIColor *color);

/**
 * Draw a filled circle with the given center, radius, and color.
 */
extern void CGContextFillCircle(CGContextRef context, CGPoint center,
                                CGFloat radius, UIColor *color);

/**
 * Random float to the tenth. E.g., 2.4.
 */
extern CGFloat TenthsRand(CGFloat min, CGFloat max);

extern double MetersBetweenCoordinates(CLLocationCoordinate2D c1,
                                       CLLocationCoordinate2D c2);

extern CGFloat DistanceBetweenPoints(CGPoint p1, CGPoint p2);

extern CGFloat DegreesBetweenPoints(CGPoint p1, CGPoint p2);

extern CGFloat RadiansBetweenPoints(CGPoint p1, CGPoint p2);

extern CGFloat DegreesBetweenLines(CGLine line1, CGLine line2);

extern CGFloat RadiansBetweenLines(CGLine line1, CGLine line2);

/**
 * Full path for a file in the app Documents directory.
 */
extern NSString *DocumentsFilePath(NSString *filename);

/**
 * YES of a random given percent. E.g., 10 percent chance.
 */
extern BOOL RandChance(NSInteger percentChance);

extern NSInteger RandInt(NSInteger low, NSInteger high);

/**
 * Returns YES/NO  50% of the time
 */
extern BOOL CoinFlip(void);

/**
 * Find a point on the line between p1 and p2, at a given distance from p1.
 */
extern CGPoint PointBetween(CGPoint p1, CGPoint p2, CGFloat distanceFromP1);

extern BOOL LinesIntersect(CGPoint l1p1, CGPoint l1p2, CGPoint l2p1,
                           CGPoint l2p2);

extern CGPoint MidpointBetween(CGPoint p1, CGPoint p2);

extern MKMapRect MKMapRectAroundCoordinates(CLLocationCoordinate2D c1,
                                            CLLocationCoordinate2D c2);

extern NSInteger MKZoomScaleToZoomLevel(MKZoomScale scale);
extern MKZoomScale ZoomLevelToMKZoomScale(NSUInteger zoomLevel);

extern CGFloat MKCellSizeForZoomScale(MKZoomScale zoomScale);

extern NSString *NSStringFromMKMapRect(MKMapRect mapRect);

extern UIImage *UIImageWithView(UIView *view);

/**
 * Smallest CGRect that will surround the given points.
 */
extern CGRect CGRectSurroundingPoints(CGPoint p1, CGPoint p2);

/**
 * Create a new color by shifting another color's RGB values.
 */
extern UIColor *UIColorShifted(UIColor *color, CGFloat shift);

extern CGPoint CGPointPlusPoint(CGPoint p1, CGPoint p2);
extern CGPoint CGPointMinusPoint(CGPoint p1, CGPoint p2);

/**
 * Create a color with random RGB values.
 */
extern UIColor *RandomColor();

/**
 * Default "how much to zoom a map after loading".
 */
extern MKCoordinateSpan DefaultZoomMapSpan();

/**
 * Split 1.0 into some number of fractional pieces.
 */
extern NSArray *SplitOneIntoFractions(NSUInteger fractionsDesired,
                                      CGFloat minFraction);

/**
 * Split 1.0 into some number of randomized fractional NSNumber/float pieces,
 * with the "weighted" remainder at one end.
 */
extern NSArray *SplitOneIntoEndWeightedFractions(NSUInteger fractionsDesired,
                                                 CGFloat minFraction);

/**
 * Combine first or last fraction to the fraction before it, if less than the
 * given amount.
 */
extern NSArray *GlomEndFractionsLessThan(NSArray *fractions,
                                         CGFloat minEndFraction);

/**
 * Split 1.0 into some number of same-value fractional NSNumber/float pieces.
 */
extern NSArray *SplitOneIntoEqualFractions(NSUInteger fractionsDesired);

/**
 * Split 1.0 into some number of fractions, each fraction between the max and
 * min values.
 */
extern NSArray *SplitOneIntoRandomFractions(CGFloat minFraction,
                                            CGFloat maxFraction);

/**
 * CGPoint equality, with a float comparison tolerance.
 */
extern BOOL CGPointEqualToPointWithTolerance(CGPoint p1, CGPoint p2,
                                             CGFloat tolerance);

/**
 * Find the external/outside/farthest-apart points between two pairs of points.
 */
extern CGPointPair FarthestPoints(CGPointPair pp1, CGPointPair pp2);

/**
 * Size of the file at the given path.
 */
extern unsigned long long FileSize(NSString *path);

@interface FBUtils : NSObject

+ (void)takeRicePaperSnapshotOfView:(UIView *)view
                              frame:(CGRect)frame
                    completionBlock:
                        (void (^)(UIImage *snapshot))completionBlock;

+ (void)takeRicePaperSnapshotOfView:(UIView *)view
                              frame:(CGRect)frame
               updateAsynchronously:(BOOL)async
                    completionBlock:
                        (void (^)(UIImage *snapshot))completionBlock;

+ (void)doTransitionAnimationWithDuration:(CGFloat)duration
                               startDelay:(CGFloat)startDelay
                                 fromView:(UIView *)fromView
                          fromConstraints:(NSMutableArray *)fromConstraints
                                   toView:(UIView *)toView
                            toConstraints:(NSMutableArray *)toConstraints
                           withCompletion:(dispatch_block_t)completion;

+ (void)doTransitionAnimationWithDuration:(CGFloat)duration
                                  startDelay:(CGFloat)startDelay
                                    fromView:(UIView *)fromView
                             fromConstraints:(NSMutableArray *)fromConstraints
                                      toView:(UIView *)toView
                               toConstraints:(NSMutableArray *)toConstraints
    havingConcurrentAutoLayoutAnimationBlock:(dispatch_block_t)animationBlock
                              withCompletion:(dispatch_block_t)completion;

+ (void)animateView:(UIView *)view
          withAlpha:(CGFloat)alpha
     withCompletion:(dispatch_block_t)completion;

@end
