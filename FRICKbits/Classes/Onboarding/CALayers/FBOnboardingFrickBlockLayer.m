//
//  FBOnboardingFrickBlockLayer.m
//  FRICKbits
//
//  Created by Michael Van Milligan on 5/28/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "FBOnboardingFrickBlockLayer.h"
#import "FBOnboarding.h"
#import "FBRecipeFactory.h"
#import "FBSmoothPath.h"
#import "FBQuad.h"
#import "FBUtils.h"
#import "T23AtomicBoolean.h"

@interface FBOnboardingFrickBlockLayer ()

@property(nonatomic, copy) dispatch_block_t completion;

@property(nonatomic, strong) FBSmoothPath *topPath;
@property(nonatomic, strong) FBSmoothPath *rightPath;
@property(nonatomic, strong) FBSmoothPath *bottomPath;
@property(nonatomic, strong) FBSmoothPath *leftPath;

@property(nonatomic, strong) FBSmoothPath *topImperfectPath;
@property(nonatomic, strong) FBSmoothPath *rightImperfectPath;
@property(nonatomic, strong) FBSmoothPath *bottomImperfectPath;
@property(nonatomic, strong) FBSmoothPath *leftImperfectPath;

@property(nonatomic, strong) T23AtomicBoolean *animating;
@property(nonatomic, strong) T23AtomicBoolean *doImperfectQuad;

@end

@implementation FBOnboardingFrickBlockLayer

- (BOOL)doImperfections {
  return _doImperfectQuad.value;
}

- (void)setDoImperfections:(BOOL)doImperfections {
  _doImperfectQuad.value = doImperfections;
}

#pragma mark - Initialization

- (BOOL)isAnimating {
  return _animating.value;
}

- (id)init {
  if (self = [super init]) {
    self.masksToBounds = NO;
    self.borderColor = [UIColor lightGrayColor].CGColor;
    self.borderWidth = 0.0f;
    self.opaque = YES;

    _animating = [[T23AtomicBoolean alloc] init];
    _doImperfectQuad = [[T23AtomicBoolean alloc] init];
  }
  return self;
}

#pragma mark - Animations

- (void)animate {
  [self animateWithCompletion:nil];
}

- (void)animateWithCompletion:(dispatch_block_t)completion {
  [self animateWithDuration:-1.0f andCompletion:completion];
}

- (void)animateWithDuration:(CGFloat)duration
              andCompletion:(dispatch_block_t)completion {
  CGFloat animationTime =
      (NAN != duration && 0.0f < duration) ? duration : 0.3f;
  CGPoint currentPoint = self.position;
  CGPoint endPoint =
      CGPointMake(currentPoint.x + _shift.dx, currentPoint.y + _shift.dy);

  CABasicAnimation *dropDown =
      [CABasicAnimation animationWithKeyPath:@"position"];
  dropDown.fromValue = [NSValue valueWithCGPoint:currentPoint];
  dropDown.toValue = [NSValue valueWithCGPoint:endPoint];
  dropDown.duration = animationTime;

  // yay old school delegate methods
  dropDown.delegate = self;

  // squirrel this away
  self.completion = completion;

  [dropDown setValue:@"fall" forKey:@"drop"];
  [dropDown setValue:[NSNumber numberWithInteger:_tag] forKey:@"tag"];

  self.position = endPoint;

  _animating.value = YES;
  [self addAnimation:dropDown forKey:@"dropDown"];
}

- (void)animationDidStart:(CAAnimation *)anim {
  // Nothing?
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
  if (self.completion != nil && flag) {
    _animating.value = NO;
    self.completion();
    self.completion = nil;
  }
}

#pragma mark - Overrides

+ (BOOL)needsDisplayForKey:(NSString *)key {
  if ([key isEqualToString:@"bounds"]) {
    return YES;
  }
  return [super needsDisplayForKey:key];
}

#pragma mark - Drawing

- (void)initializeQuadPaths {

  FBRecipeFactory *factory = [[FBRecipeFactory alloc] init];
  factory.minBorderWhite = FBOnboardingFrickBlockLayerMinBorderWhite;
  factory.maxBorderWhite = FBOnboardingFrickBlockLayerMaxBorderWhite;

  FBQuadRecipe *quadRecipe = [factory makePerfectQuadRecipe];

  CGPoint topLeftPoint = CGPointMake(0.0f, 0.0f);
  CGPoint topRightPoint = CGPointMake(self.bounds.size.width, 0.0f);
  CGPoint bottomLeftPoint = CGPointMake(0.0f, self.bounds.size.height);
  CGPoint bottomRightPoint =
      CGPointMake(self.bounds.size.width, self.bounds.size.height);

  FBQuad perfectQuad = FBQuadMake(topLeftPoint, topRightPoint, bottomRightPoint,
                                  bottomLeftPoint);

  _topPath = [[FBSmoothPath alloc] initWithRecipe:quadRecipe.pathRecipe1
                                               p1:perfectQuad.upperLeft
                                               p2:perfectQuad.upperRight];

  _rightPath = [[FBSmoothPath alloc] initWithRecipe:quadRecipe.pathRecipe2
                                                 p1:perfectQuad.upperRight
                                                 p2:perfectQuad.lowerRight];

  _bottomPath = [[FBSmoothPath alloc] initWithRecipe:quadRecipe.pathRecipe2
                                                  p1:perfectQuad.lowerRight
                                                  p2:perfectQuad.lowerLeft];

  _leftPath = [[FBSmoothPath alloc] initWithRecipe:quadRecipe.pathRecipe2
                                                p1:perfectQuad.lowerLeft
                                                p2:perfectQuad.upperLeft];

  if (_doImperfectQuad.value) {
    FBQuadRecipe *quadRecipe = [factory makeQuadRecipe];

    FBQuad insetQuad =
        FBQuadInset(FBQuadMake(topLeftPoint, topRightPoint, bottomRightPoint,
                               bottomLeftPoint),
                    1.0f + (CGFloat)arc4random_uniform(
                               FBOnboardingFrickBlockLayerJiggleRange));

    _topImperfectPath =
        [[FBSmoothPath alloc] initWithRecipe:quadRecipe.pathRecipe1
                                          p1:insetQuad.upperLeft
                                          p2:insetQuad.upperRight];

    _rightImperfectPath =
        [[FBSmoothPath alloc] initWithRecipe:quadRecipe.pathRecipe2
                                          p1:insetQuad.upperRight
                                          p2:insetQuad.lowerRight];

    _bottomImperfectPath =
        [[FBSmoothPath alloc] initWithRecipe:quadRecipe.pathRecipe2
                                          p1:insetQuad.lowerRight
                                          p2:insetQuad.lowerLeft];

    _leftImperfectPath =
        [[FBSmoothPath alloc] initWithRecipe:quadRecipe.pathRecipe2
                                          p1:insetQuad.lowerLeft
                                          p2:insetQuad.upperLeft];
  }
}

- (void)drawInContext:(CGContextRef)context {
  CGContextSaveGState(context);

  [self initializeQuadPaths];

  CGPoint midPointTop =
      CGPointMake(0.0f + (self.bounds.size.width / 2.0f), 0.0f);

  CGPoint midPointBottom = CGPointMake(0.0f + (self.bounds.size.width / 2.0f),
                                       0.0f + self.bounds.size.height);

  CGImageRef textureImageToMultiply =
      [UIImage imageNamed:@"texture_multiply.jpg"].CGImage;
  CGImageRef textureImageToScreen =
      [UIImage imageNamed:@"texture_screen.jpg"].CGImage;

  CGMutablePathRef fillPath = CGPathCreateMutable();
  CGPathMoveToPoint(fillPath, NULL, 0.0f, 0.0f);
  CGPathAddLineToPoint(fillPath, NULL, 0.0f, self.bounds.size.height);
  CGPathAddLineToPoint(fillPath, NULL, self.bounds.size.width,
                       self.bounds.size.height);
  CGPathAddLineToPoint(fillPath, NULL, self.bounds.size.width, 0.0f);
  CGPathAddLineToPoint(fillPath, NULL, 0.0f, 0.0f);

  CGContextAddPath(context, fillPath);
  CGContextClip(context);

  CGContextSetBlendMode(context, kCGBlendModeNormal);
  CGContextAddPath(context, fillPath);
  CGContextSetFillColorWithColor(context, self.fillColor.CGColor);

  // Draw a color gradient from the center of the bit outward.
  // The center is darker, and the
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGFloat locations[] = {0.0f, 1.0f};
  NSArray *colors = @[
    (__bridge id)self.fillColor.CGColor,
    (__bridge id)UIColorShifted(self.fillColor,
                                FBOnboardingFrickBlockLayerColorShift).CGColor
  ];
  CGGradientRef gradient = CGGradientCreateWithColors(
      colorSpace, (__bridge CFArrayRef)colors, locations);
  CGPoint midPoint = MidpointBetween(midPointTop, midPointBottom);
  CGFloat gradientLength =
      MAX(DistanceBetweenPoints(midPointTop, midPointBottom),
          self.bounds.size.width);
  CGContextDrawRadialGradient(context, gradient, midPoint, 0.0f, midPoint,
                              gradientLength, kCGGradientDrawsAfterEndLocation);

  CGGradientRelease(gradient);
  CGColorSpaceRelease(colorSpace);

  CGContextSetBlendMode(context, kCGBlendModeMultiply);
  CGContextSetAlpha(context, FBOnboardingFrickBlockLayerGradientAlpha);
  CGContextDrawImage(
      context, CGRectMake(0.0f, 0.0f, CGImageGetWidth(textureImageToMultiply),
                          CGImageGetHeight(textureImageToMultiply)),
      textureImageToMultiply);

  CGContextSetBlendMode(context, kCGBlendModeScreen);
  CGContextSetAlpha(context, FBOnboardingFrickBlockLayerImageAlpha);
  CGContextDrawImage(
      context, CGRectMake(0.0f, 0.0f, CGImageGetWidth(textureImageToScreen),
                          CGImageGetHeight(textureImageToScreen)),
      textureImageToScreen);

  CGPathRelease(fillPath);
  CGContextRestoreGState(context);

  CGContextSaveGState(context);

  // Draw stroke
  CGContextAddPath(context, _topPath.CGPath);
  CGContextSetStrokeColorWithColor(context, _topPath.strokeColor.CGColor);
  CGContextSetLineWidth(context, _topPath.lineWidth);
  CGContextDrawPath(context, kCGPathStroke);

  CGContextAddPath(context, _rightPath.CGPath);
  CGContextSetStrokeColorWithColor(context, _rightPath.strokeColor.CGColor);
  CGContextSetLineWidth(context, _rightPath.lineWidth);
  CGContextDrawPath(context, kCGPathStroke);

  CGContextAddPath(context, _bottomPath.CGPath);
  CGContextSetStrokeColorWithColor(context, _bottomPath.strokeColor.CGColor);
  CGContextSetLineWidth(context, _bottomPath.lineWidth);
  CGContextDrawPath(context, kCGPathStroke);

  CGContextAddPath(context, _leftPath.CGPath);
  CGContextSetStrokeColorWithColor(context, _leftPath.strokeColor.CGColor);
  CGContextSetLineWidth(context, _leftPath.lineWidth);
  CGContextDrawPath(context, kCGPathStroke);

  if (_doImperfectQuad.value) {

    // Draw imperfect stroke
    CGContextAddPath(context, _topImperfectPath.CGPath);
    CGContextSetStrokeColorWithColor(context, _topPath.strokeColor.CGColor);
    CGContextSetLineWidth(context, _topPath.lineWidth);
    CGContextDrawPath(context, kCGPathStroke);

    CGContextAddPath(context, _rightImperfectPath.CGPath);
    CGContextSetStrokeColorWithColor(context, _rightPath.strokeColor.CGColor);
    CGContextSetLineWidth(context, _rightPath.lineWidth);
    CGContextDrawPath(context, kCGPathStroke);

    CGContextAddPath(context, _bottomImperfectPath.CGPath);
    CGContextSetStrokeColorWithColor(context, _bottomPath.strokeColor.CGColor);
    CGContextSetLineWidth(context, _bottomPath.lineWidth);
    CGContextDrawPath(context, kCGPathStroke);

    CGContextAddPath(context, _leftImperfectPath.CGPath);
    CGContextSetStrokeColorWithColor(context, _leftPath.strokeColor.CGColor);
    CGContextSetLineWidth(context, _leftPath.lineWidth);
    CGContextDrawPath(context, kCGPathStroke);
  }

  CGContextRestoreGState(context);
}

@end
