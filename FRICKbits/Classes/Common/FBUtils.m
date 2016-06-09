//
//  FBUtils.m
//  FrickBits
//
//  Created by Matt McGlincy on 1/14/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <FXBlurView/FXBlurView.h>
#import "FBUtils.h"

UIColor *UIColorFromHexString(NSString *hexString, CGFloat alpha) {
  unsigned rgbValue = 0;
  NSScanner *scanner = [NSScanner scannerWithString:hexString];
  [scanner setScanLocation:1]; // bypass '#' character
  [scanner scanHexInt:&rgbValue];
  return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16) / 255.0
                         green:((rgbValue & 0xFF00) >> 8) / 255.0
                          blue:(rgbValue & 0xFF) / 255.0
                         alpha:alpha];
}

UIColor *UIColorInGrayscale(UIColor *color) {
  CGFloat r, g, b, a, gray;

  [color getRed:&r green:&g blue:&b alpha:&a];

  gray = ((r * 0.2126f) + (g * 0.7152f) + (b * 0.0722f));

  return [UIColor colorWithRed:gray green:gray blue:gray alpha:1.0f];
}

void CGContextFillCircle(CGContextRef context, CGPoint center, CGFloat radius,
                         UIColor *color) {
  CGContextSetFillColorWithColor(context, color.CGColor);
  CGContextAddEllipseInRect(context,
                            CGRectMake(center.x, center.y, radius, radius));
  CGContextDrawPath(context, kCGPathFill);
  CGContextStrokePath(context);
}

CGFloat TenthsRand(CGFloat min, CGFloat max) {
  return min + (arc4random_uniform(max * 10.0 - min * 10.0) / 10.0);
}

double MetersBetweenCoordinates(CLLocationCoordinate2D c1,
                                CLLocationCoordinate2D c2) {
  // Haversine distance
  // http://stackoverflow.com/questions/4102520/how-to-transform-a-distance-from-degrees-to-metres
  double R = 6371 * 1000; // meters
  double dLat = DEGREES_TO_RADIANS(c2.latitude - c1.latitude);
  double dLon = DEGREES_TO_RADIANS(c2.longitude - c1.longitude);
  double a = sin(dLat / 2) * sin(dLat / 2) +
             cos(DEGREES_TO_RADIANS(c1.latitude)) *
                 cos(DEGREES_TO_RADIANS(c2.latitude)) * sin(dLon / 2) *
                 sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  double d = R * c;
  return d;
}

CGFloat DistanceBetweenPoints(CGPoint p1, CGPoint p2) {
  // distance formula
  return sqrtf(powf(p2.x - p1.x, 2) + powf(p2.y - p1.y, 2));
}

CGFloat RadiansBetweenPoints(CGPoint p1, CGPoint p2) {
  CGFloat radians = atan2f(p2.y - p1.y, p2.x - p1.x);
  // atanf returns between -PI and PI,
  // and we want between 0 and 2*PI
  if (radians < 0) {
    radians += 2 * M_PI;
  }
  return radians;
}

CGFloat DegreesBetweenPoints(CGPoint p1, CGPoint p2) {
  return RADIANS_TO_DEGREES(RadiansBetweenPoints(p1, p2));
}

CGFloat RadiansBetweenLines(CGLine line1, CGLine line2) {

  CGPoint U = CGPointMake((line1.point1.x - line1.point2.x),
                          (line1.point2.y - line1.point1.y));
  CGPoint V = CGPointMake((line2.point2.x - line2.point1.x),
                          (line2.point1.y - line2.point2.y));

  CGFloat prod =
      ((U.x * V.x) + (U.y * V.y)) / (sqrtf((powf(U.x, 2.0) + powf(U.y, 2.0))) *
                                     sqrtf((powf(V.x, 2.0) + powf(V.y, 2.0))));

  CGFloat radians = acosf(prod);

  if (radians < 0) {
    radians += 2 * M_PI;
  }
  return radians;
}

CGFloat DegreesBetweenLines(CGLine line1, CGLine line2) {
  return RADIANS_TO_DEGREES(RadiansBetweenLines(line1, line2));
}

NSString *DocumentsFilePath(NSString *filename) {
  NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(
      NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
  NSString *filePath =
      [documentsDirectory stringByAppendingPathComponent:filename];
  //    NSLog(@"logging to file %@", fileName);
  return filePath;
}

BOOL RandChance(NSInteger percentChance) {
  NSInteger rand = arc4random_uniform(100) + 1;
  return (rand <= percentChance);
}

BOOL CoinFlip() {
  NSInteger rand = arc4random_uniform(100) + 1;
  return (rand <= 50);
}

NSInteger RandInt(NSInteger low, NSInteger high) {
  NSInteger diff = high - low;
  NSInteger rand = (NSInteger)arc4random_uniform(
      (u_int32_t)(diff + 1)); // between 0 and the diff, inclusive
  return low + rand;
}

CGPoint PointBetween(CGPoint p1, CGPoint p2, CGFloat distanceFromP1) {
  // http://stackoverflow.com/questions/1934210/finding-a-point-on-a-line

  // figure out the ratio of our needed distance to the total line length
  CGFloat xDiff = p2.x - p1.x;
  CGFloat yDiff = p2.y - p1.y;
  CGFloat lineLength = sqrtf(xDiff * xDiff + yDiff * yDiff);
  CGFloat segmentRatio = distanceFromP1 / lineLength;

  // find the point that divides the segment into the ratio (1-r):r
  CGFloat x3 = segmentRatio * p1.x + (1 - segmentRatio) * p2.x;
  CGFloat y3 = segmentRatio * p1.y + (1 - segmentRatio) * p2.y;

  return CGPointMake(x3, y3);
}

BOOL LinesIntersect(CGPoint l1p1, CGPoint l1p2, CGPoint l2p1, CGPoint l2p2) {
  CGLine l1 = CGLineMake(l1p1, l1p2);
  CGLine l2 = CGLineMake(l2p1, l2p2);
  CGPoint intersection = CGLinesIntersectAtPoint(l1, l2);
  return !CGPointEqualToPoint(intersection, NULL_POINT);
}

CGPoint MidpointBetween(CGPoint p1, CGPoint p2) {
  return CGPointMake((p1.x + p2.x) / 2, (p1.y + p2.y) / 2);
}

MKMapRect MKMapRectAroundCoordinates(CLLocationCoordinate2D c1,
                                     CLLocationCoordinate2D c2) {
  MKMapPoint p1 = MKMapPointForCoordinate(c1);
  MKMapPoint p2 = MKMapPointForCoordinate(c2);
  CGFloat minX = MIN(p1.x, p2.x);
  CGFloat minY = MIN(p1.y, p2.y);
  CGFloat maxX = MAX(p1.x, p2.x);
  CGFloat maxY = MAX(p1.y, p2.y);
  return MKMapRectMake(minX, minY, maxX - minX, maxY - minY);
}

NSInteger MKZoomScaleToZoomLevel(MKZoomScale scale) {
  double totalTilesAtMaxZoom = MKMapSizeWorld.width / 256.0;
  NSInteger zoomLevelAtMaxZoom = log2(totalTilesAtMaxZoom);
  NSInteger zoomLevel = MAX(0, zoomLevelAtMaxZoom + floor(log2f(scale) + 0.5));
  return zoomLevel;
}

MKZoomScale ZoomLevelToMKZoomScale(NSUInteger zoomLevel) {
  MKZoomScale zoomScale = pow(2, zoomLevel) / 1000000.0;
  return zoomScale;
}

NSString *NSStringFromMKMapRect(MKMapRect mapRect) {
  return [NSString stringWithFormat:@"{%f,%f,%f,%f}", mapRect.origin.x,
                                    mapRect.origin.y, mapRect.size.width,
                                    mapRect.size.height];
}

UIImage *UIImageWithView(UIView *view) {
  // This is for retina render check
  if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO,
                                           [UIScreen mainScreen].scale);
  } else {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIGraphicsBeginImageContext(keyWindow.bounds.size);
  }
  [view.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return image;
}

CGRect CGRectSurroundingPoints(CGPoint p1, CGPoint p2) {
  CGFloat minX = MIN(p1.x, p2.x);
  CGFloat minY = MIN(p1.y, p2.y);
  CGFloat maxX = MAX(p1.x, p2.x);
  CGFloat maxY = MAX(p1.y, p2.y);
  return CGRectMake(minX, minY, maxX - minX, maxY - minY);
}

UIColor *UIColorShifted(UIColor *color, CGFloat shift) {
  CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
  [color getRed:&red green:&green blue:&blue alpha:&alpha];
  return [UIColor colorWithRed:red + shift
                         green:green + shift
                          blue:blue + shift
                         alpha:alpha];
}

CGPoint CGPointPlusPoint(CGPoint p1, CGPoint p2) {
  return CGPointMake(p1.x + p2.x, p1.y + p2.y);
}

CGPoint CGPointMinusPoint(CGPoint p1, CGPoint p2) {
  return CGPointMake(p1.x - p2.x, p1.y - p2.y);
}

UIColor *RandomColor() {
  // see https://gist.github.com/kylefox/1689973
  CGFloat hue = (arc4random() % 256 / 256.0); //  0.0 to 1.0
  CGFloat saturation =
      (arc4random() % 128 / 256.0) + 0.5; //  0.5 to 1.0, away from white
  CGFloat brightness =
      (arc4random() % 128 / 256.0) + 0.5; //  0.5 to 1.0, away from black
  UIColor *color = [UIColor colorWithHue:hue
                              saturation:saturation
                              brightness:brightness
                                   alpha:1];
  return color;
}

MKCoordinateSpan DefaultZoomMapSpan() { return MKCoordinateSpanMake(0.2, 0.2); }

NSArray *SplitOneIntoFractions(NSUInteger fractionsDesired,
                               CGFloat minFraction) {
  NSMutableArray *fractions = [NSMutableArray array];
  NSInteger maxFractions = (NSInteger)(1.0 / minFraction);
  NSInteger fractionsToMake = MIN(fractionsDesired, maxFractions);

  CGFloat total = 0.0;
  for (int i = 0; i < fractionsToMake - 1; i++) {
    // pick a random value, up to +10% above our minimum fraction
    CGFloat randFraction = ((CGFloat)(arc4random_uniform(10) + 1)) / 100.0;
    CGFloat fraction = minFraction + randFraction;
    if (total + fraction > 1.0) {
      // don't overshoot 1.0
      break;
    }
    total += fraction;
    [fractions addObject:[NSNumber numberWithFloat:fraction]];
  }

  CGFloat remaining = 1.0 - total;
  if (remaining > 0) {
    NSNumber *finalFraction = [NSNumber numberWithFloat:remaining];
    [fractions addObject:finalFraction];
  }

  return fractions;
}

NSArray *SplitOneIntoEndWeightedFractions(NSUInteger fractionsDesired,
                                          CGFloat minFraction) {
  NSMutableArray *fractions = [NSMutableArray array];
  NSInteger maxFractions = (NSInteger)(1.0 / minFraction);
  NSInteger fractionsToMake = MIN(fractionsDesired, maxFractions);

  CGFloat total = 0.0;
  for (int i = 0; i < fractionsToMake - 1; i++) {
    // pick a random value, up to +10% above our minimum fraction
    CGFloat randFraction = ((CGFloat)(arc4random_uniform(10) + 1)) / 100.0;
    CGFloat fraction = minFraction + randFraction;
    total += fraction;
    if (total > 1.0) {
      // don't overshoot 1.0
      break;
    }
    [fractions addObject:[NSNumber numberWithFloat:fraction]];
  }

  CGFloat remaining = 1.0 - total;
  if (remaining > 0) {
    NSNumber *finalFraction = [NSNumber numberWithFloat:remaining];

    // sometimes add the remaining chunk to the front instead of the back
    if (RandChance(50)) {
      [fractions insertObject:finalFraction atIndex:0];
    } else {
      [fractions addObject:finalFraction];
    }
  }

  return fractions;
}

NSArray *GlomEndFractionsLessThan(NSArray *fractions, CGFloat minEndFraction) {
  if (fractions.count < 2) {
    return fractions;
  }

  NSMutableArray *newFract = [fractions mutableCopy];

  // keep glomming the beginning fractions until we've reduced to a single
  // fraction,
  // or our first fraction is sufficiently sized
  while (YES) {
    if (newFract.count < 2) {
      break;
    }

    NSNumber *firstFraction = newFract[0];
    if ([firstFraction floatValue] >= minEndFraction) {
      break;
    }

    NSNumber *secondFraction = newFract[1];
    NSNumber *combined =
        @([firstFraction floatValue] + [secondFraction floatValue]);
    [newFract removeObjectAtIndex:0];
    [newFract removeObjectAtIndex:0];
    [newFract insertObject:combined atIndex:0];
  }

  // keep glomming the end fractions until we've reduced to a single fraction,
  // or our last fraction is sufficiently sized
  while (YES) {
    if (newFract.count < 2) {
      break;
    }

    NSNumber *lastFraction = newFract[newFract.count - 1];
    if ([lastFraction floatValue] >= minEndFraction) {
      break;
    }

    NSNumber *nextToLastFraction = newFract[newFract.count - 2];
    NSNumber *combined =
        @([lastFraction floatValue] + [nextToLastFraction floatValue]);
    [newFract removeObjectAtIndex:newFract.count - 1];
    [newFract removeObjectAtIndex:newFract.count - 1];
    [newFract addObject:combined];
  }

  return newFract;
}

NSArray *SplitOneIntoEqualFractions(NSUInteger fractionsDesired) {
  NSMutableArray *fractions = [NSMutableArray array];
  CGFloat fract = 1.0 / fractionsDesired;
  for (int i = 0; i < fractionsDesired; i++) {
    [fractions addObject:@(fract)];
  }
  return fractions;
}

NSArray *SplitOneIntoRandomFractions(CGFloat minFraction, CGFloat maxFraction) {
  CGFloat range = maxFraction - minFraction;
  NSMutableArray *fractions = [NSMutableArray array];
  CGFloat remaining = 1.0;

  while (remaining > 0 && remaining >= minFraction) {
    CGFloat randPercent = arc4random_uniform(100) + 1; // 0-100
    CGFloat delta = (randPercent / 100.0) * range;
    CGFloat num = minFraction + delta;
    // don't overshoot 1.0
    num = MIN(remaining, num);
    remaining -= num;
    [fractions addObject:@(num)];
  }

  // deal with a possible below-tolerance remainder
  // by adding the remainder to another num
  if (remaining > 0) {
    // TODO: use a while loop, break the remainder up, and keep all nums within
    // tolerance
    // we need some random-yet-guaranteed-to-terminate process to do this.
    // while (remaining > 0) {
    NSUInteger randIdx = arc4random_uniform((uint32_t)fractions.count);
    CGFloat num = [fractions[randIdx] floatValue];
    fractions[randIdx] = @(num + remaining);
  }

  return fractions;
}

BOOL CGPointEqualToPointWithTolerance(CGPoint p1, CGPoint p2,
                                      CGFloat tolerance) {
  return ((fabs(p1.x - p2.x) < tolerance) && (fabs(p1.y - p2.y) < tolerance));
}

CGPointPair FarthestPoints(CGPointPair pp1, CGPointPair pp2) {
  CGFloat maxDistance = -1;
  CGPointPair outside = {CGPointZero, CGPointZero};

  CGFloat distance = DistanceBetweenPoints(pp1.p1, pp2.p1);
  if (distance > maxDistance) {
    maxDistance = distance;
    outside = CGPointPairMake(pp1.p1, pp2.p1);
  }
  distance = DistanceBetweenPoints(pp1.p1, pp2.p2);
  if (distance > maxDistance) {
    maxDistance = distance;
    outside = CGPointPairMake(pp1.p1, pp2.p2);
  }
  distance = DistanceBetweenPoints(pp1.p2, pp2.p1);
  if (distance > maxDistance) {
    maxDistance = distance;
    outside = CGPointPairMake(pp1.p2, pp2.p1);
  }
  distance = DistanceBetweenPoints(pp1.p2, pp2.p2);
  if (distance > maxDistance) {
    maxDistance = distance;
    outside = CGPointPairMake(pp1.p2, pp2.p2);
  }

  return outside;
}

CGPointPair CGPointPairMake(CGPoint p1, CGPoint p2) {
  CGPointPair pp = {p1, p2};
  return pp;
}

CGFloatPair CGFloatPairMake(CGFloat f1, CGFloat f2) {
  CGFloatPair fp = {f1, f2};
  return fp;
}

@implementation FBUtils

+ (void)takeRicePaperSnapshotOfView:(UIView *)view
                              frame:(CGRect)frame
                    completionBlock:
                        (void (^)(UIImage *snapshot))completionBlock {
  [self takeRicePaperSnapshotOfView:view
                              frame:frame
               updateAsynchronously:YES
                    completionBlock:completionBlock];
}

+ (void)takeRicePaperSnapshotOfView:(UIView *)view
                              frame:(CGRect)frame
               updateAsynchronously:(BOOL)async
                    completionBlock:
                        (void (^)(UIImage *snapshot))completionBlock {
  FXBlurView *blurView = [[FXBlurView alloc] initWithFrame:frame];
  blurView.dynamic = NO;
  blurView.blurRadius = 15;
  // TODO: any tint color but clear causes the image to disappear???
  blurView.tintColor = [UIColor clearColor];
  blurView.alpha = 0.0;
  [view addSubview:blurView];
  // FXBlurView's completion block gets called on the main thread
  [blurView updateAsynchronously:async
                      completion:^(void) {
                          CGImageRef blurImageRef =
                              (__bridge CGImageRef)blurView.layer.contents;
                          UIImage *blurImage =
                              [[UIImage alloc] initWithCGImage:blurImageRef];
                          [blurView removeFromSuperview];
                          completionBlock(blurImage);
                      }];
}

+ (void)doTransitionAnimationWithDuration:(CGFloat)duration
                               startDelay:(CGFloat)startDelay
                                 fromView:(UIView *)fromView
                          fromConstraints:(NSMutableArray *)fromConstraints
                                   toView:(UIView *)toView
                            toConstraints:(NSMutableArray *)toConstraints
                           withCompletion:(dispatch_block_t)completion {

  [FBUtils doTransitionAnimationWithDuration:duration
                                    startDelay:startDelay
                                      fromView:fromView
                               fromConstraints:fromConstraints
                                        toView:toView
                                 toConstraints:toConstraints
      havingConcurrentAutoLayoutAnimationBlock:nil
                                withCompletion:completion];
}

+ (void)doTransitionAnimationWithDuration:(CGFloat)duration
                                  startDelay:(CGFloat)startDelay
                                    fromView:(UIView *)fromView
                             fromConstraints:(NSMutableArray *)fromConstraints
                                      toView:(UIView *)toView
                               toConstraints:(NSMutableArray *)toConstraints
    havingConcurrentAutoLayoutAnimationBlock:(dispatch_block_t)animationBlock
                              withCompletion:(dispatch_block_t)completion {
  CGFloat splitDuration =
      (fromConstraints && fromView) ? duration / 2.0f : duration;

  if (toView && toConstraints) {

    [toView.superview layoutIfNeeded];
    [UIView animateWithDuration:splitDuration
        delay:startDelay
        options:(UIViewAnimationOptionBeginFromCurrentState)
        animations:^(void) {

            [toView.superview removeConstraints:toConstraints];
            [toConstraints removeAllObjects];

            [toConstraints addObject:[toView autoPinEdge:ALEdgeBottom
                                                  toEdge:ALEdgeBottom
                                                  ofView:toView.superview]];

            [toConstraints addObject:[toView autoPinEdge:ALEdgeLeft
                                                  toEdge:ALEdgeLeft
                                                  ofView:toView.superview]];

            [toConstraints addObject:[toView autoPinEdge:ALEdgeRight
                                                  toEdge:ALEdgeRight
                                                  ofView:toView.superview]];
            [toView.superview layoutIfNeeded];

            if (animationBlock) {
              animationBlock();
            }
        }
        completion:^(BOOL finished) {

            if (finished) {

              if (fromConstraints && fromView) {

                [fromView.superview layoutIfNeeded];
                [UIView animateWithDuration:splitDuration
                    delay:0.0f
                    options:(UIViewAnimationOptionBeginFromCurrentState)
                    animations:^(void) {

                        [fromView.superview removeConstraints:fromConstraints];
                        [fromConstraints removeAllObjects];

                        [fromConstraints
                            addObject:[fromView
                                          autoPinEdge:ALEdgeTop
                                               toEdge:ALEdgeBottom
                                               ofView:fromView.superview]];

                        [fromConstraints
                            addObject:[fromView
                                          autoPinEdge:ALEdgeLeft
                                               toEdge:ALEdgeLeft
                                               ofView:fromView.superview]];

                        [fromConstraints
                            addObject:[fromView
                                          autoPinEdge:ALEdgeRight
                                               toEdge:ALEdgeRight
                                               ofView:fromView.superview]];
                        [fromView.superview layoutIfNeeded];
                    }
                    completion:^(BOOL finished) {
                        if (finished) {
                          if (completion) {
                            completion();
                          }
                        }
                    }];
              } else {
                if (completion) {
                  completion();
                }
              }
            }
        }];
  }
}

+ (void)animateView:(UIView *)view
          withAlpha:(CGFloat)alpha
     withCompletion:(dispatch_block_t)completion {

  if (0.0f >= alpha) {
    view.userInteractionEnabled = NO;
  }

  [UIView animateWithDuration:0.17f
      delay:0.0f
      options:(UIViewAnimationOptionBeginFromCurrentState)
      animations:^(void) { view.alpha = alpha; }
      completion:^(BOOL finished) {
          if (finished) {
            if (0.0f < alpha) {
              view.userInteractionEnabled = YES;
            }

            if (completion) {
              completion();
            }
          }
      }];
}

unsigned long long FileSize(NSString *path) {
  return [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil]
      .fileSize;
}

@end
