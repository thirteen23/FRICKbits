//
//  FBFrickBitLayer.m
//  FrickBits
//
//  Created by Matt McGlincy on 1/30/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "FBColorPalette.h"
#import "FBBoxesLayer.h"
#import "FBFrickBitLayer.h"
#import "FBJoin.h"
#import "FBQuad.h"
#import "FBQuadPathLayer.h"
#import "FBSmoothQuadPath.h"
#import "FBNumbersLayer.h"
#import "FBUtils.h"
#import "MTGeometry.h"

static const CGFloat FBChanceOfDotsDetail = 10.0f;
static const CGFloat FBChanceOfInsetQuadDetail = 50.0;
static const CGFloat FBChanceOfNumberDetail = 10.0f;

@interface FBFrickBitLayer ()
@property(nonatomic, strong) FBSmoothQuadPath *quadPath;
@property(nonatomic) FBQuad insetQuad;
@property(nonatomic, strong) FBSmoothQuadPath *insetQuadPath;
@property(nonatomic, strong) FBNumbersLayer *numbersLayer;
@property(nonatomic, strong) FBBoxesLayer *boxesLayer;
@end

@implementation FBFrickBitLayer

- (id)initWithRecipe:(FBFrickBitRecipe *)recipe
    fromPointInParent:(CGPoint)fromPoint
      toPointInParent:(CGPoint)toPoint {
  self = [super init];
  if (self) {
    self.recipe = recipe;
    self.fromPointInParent = fromPoint;
    self.toPointInParent = toPoint;

    // instead of using from/to as-is,
    // we figure out the smallest box/rect that will contain them,
    // and make our layer that big.
    // Our actual from/to will be normalized within this newly-offset rect.
    CGRect boundingBox = CGRectSurroundingPoints(fromPoint, toPoint);

    // expand the bounding box to allow for bit thickness
    // TODO: insufficient padding / frame size can cause clipping of bit
    // coloring.
    // We should make a more-accurate calculation to correctly work with
    // various nested frickbit types, like splitbits.
    CGFloat padding = 10;
    boundingBox = CGRectInset(boundingBox, -2 * padding, -2 * padding);
    self.frame = boundingBox;

    self.fromPointInSelf = CGPointMinusPoint(self.fromPointInParent, self.frame.origin);
    self.toPointInSelf = CGPointMinusPoint(self.toPointInParent, self.frame.origin);
    self.quadInSelf = FBQuadMakeAroundPoints(self.fromPointInSelf, self.toPointInSelf, self.recipe.thickness);
    
    self.quadPath = [[FBSmoothQuadPath alloc] initWithRecipe:self.recipe.quadRecipe
                                                        quad:self.quadInSelf];

    [self updatePaths];

    [self addRandomDetail];
  }
  return self;
}

- (NSString *)description {
  return [NSString stringWithFormat:@"<%@: %p, %@ <==> %@>", [self class], self,
          NSStringFromCGPoint(self.fromPointInSelf),
          NSStringFromCGPoint(self.toPointInSelf)];
}

- (void)setFrame:(CGRect)frame {
  [super setFrame:frame];
  self.mask.frame = self.bounds;
  [self setNeedsDisplay];
}

- (void)updatePaths {
  // recalculate everything downstream from quadInSelf
  [self.quadPath recalculateWithQuad:self.quadInSelf];

  self.insetQuad = FBQuadInset(self.quadInSelf, 1.0);
  [self.insetQuadPath recalculateWithQuad:self.insetQuad];
  
  CAShapeLayer *maskLayer = (CAShapeLayer *)self.mask;
  maskLayer.path = [self fillPath].CGPath;
}

- (void)drawInContext:(CGContextRef)context {
  CGContextSaveGState(context);

  CGContextAddPath(context, self.fillPath.CGPath);
  CGContextClip(context);

  CGContextSetBlendMode(context, kCGBlendModeNormal);
  CGContextAddPath(context, self.fillPath.CGPath);

  if (self.recipe.fillColor) {
    CGContextSetFillColorWithColor(context, self.recipe.fillColor.CGColor);

    // Draw a color gradient from the center of the bit outward.
    // The center is darker, and the
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = {0.0, 1.0};
    UIColor *shiftedColor = UIColorShifted(self.recipe.fillColor, 0.1);
    NSArray *colors = @[
                        (__bridge id)self.recipe.fillColor.CGColor,
                        (__bridge id)shiftedColor.CGColor
                        ];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
    CGPoint midPoint = MidpointBetween(self.fromPointInSelf, self.toPointInSelf);
    CGFloat gradientLength =
        MAX(DistanceBetweenPoints(midPoint, self.toPointInSelf),
            self.recipe.thickness);
    CGContextDrawRadialGradient(context, gradient, midPoint, 0, midPoint,
                                gradientLength, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
  }

  CGContextSetBlendMode(context, kCGBlendModeMultiply);
  CGContextSetAlpha(context, 0.2);
  CGContextDrawImage(
      context, CGRectMake(0, 0, self.recipe.textureImageMultiply.size.width,
                          self.recipe.textureImageMultiply.size.height),
      self.recipe.textureImageMultiply.CGImage);

  CGContextSetBlendMode(context, kCGBlendModeScreen);
  CGContextSetAlpha(context, 0.4);
  CGContextDrawImage(context,
                     CGRectMake(0, 0, self.recipe.textureImageScreen.size.width,
                                self.recipe.textureImageScreen.size.height),
                     self.recipe.textureImageScreen.CGImage);
  
  CGContextRestoreGState(context);

  // draw our quad paths on top
  [self.quadPath renderInContext:context];
  [self.insetQuadPath renderInContext:context];
}

#pragma mark - random detail

- (BOOL)isGoodSizeForNumbers {
  // square-ish, near-vertical bits
  return (self.bitWidth > 8 && self.bitLength > 6 && self.bitLength < 20 &&
          abs(abs(self.angle) - 90) < 20);
}

- (BOOL)isGoodSizeForDots {
  // square-ish, near-vertical bits
  return (self.bitWidth > 8 && self.bitLength > 6 && self.bitLength < 20 &&
          abs(abs(self.angle) - 90) < 20);
}

- (BOOL)isGoodSizeForInnerQuad {
  // need to be sufficient length
  return self.bitLength > 5;
}

- (void)addRandomDetail {
  // every bit has a chance of an inset quad,
  // which can coexist with other random detail
  if ([self isGoodSizeForInnerQuad] && RandChance(FBChanceOfInsetQuadDetail)) {
    self.insetQuadPath = [[FBSmoothQuadPath alloc] initWithRecipe:self.recipe.insetQuadRecipe quad:self.insetQuad];
  }
  
  // possibly add some mutually-exclusive random detail
  BOOL addedDetail = NO;

  if (!addedDetail && [self isGoodSizeForNumbers] &&
      RandChance(FBChanceOfNumberDetail)) {
    // TODO: where do we want colorPalette to come from?
    FBColorPalette *colorPalette = [[FBColorPalette alloc] init];
    self.numbersLayer = [[FBNumbersLayer alloc]
        initWithFillColor:[colorPalette nextComplementaryColor]];
    CGRect boundingBox = FBQuadBoundingRect(self.quadInSelf);
    // we position the number layer -90 degrees vs. our angle,
    // so vertical bits (like for joinery bits) get a right-side-up number.
    CGFloat radians = DEGREES_TO_RADIANS(self.angle - 90);
    self.numbersLayer.transform = CATransform3DMakeAffineTransform(
        CGAffineTransformMakeRotation(radians));
    self.numbersLayer.frame = CGRectMake(
        boundingBox.origin.x, boundingBox.origin.y, 14, self.bitLength);
    [self addSublayer:self.numbersLayer];
    addedDetail = YES;
  }

  if (!addedDetail && [self isGoodSizeForDots] &&
      RandChance(FBChanceOfDotsDetail)) {
    // TODO: where do we want colorPalette to come from?
    FBColorPalette *colorPalette = [[FBColorPalette alloc] init];
    self.boxesLayer = [[FBBoxesLayer alloc] init];
    self.boxesLayer.fillColor = [colorPalette nextComplementaryColor];
    CGRect boundingBox = FBQuadBoundingRect(self.quadInSelf);
    // we position the number layer -90 degrees vs. our angle,
    // so vertical bits (like for joinery bits) get a right-side-up number.
    CGFloat radians = DEGREES_TO_RADIANS(self.angle - 90);
    self.boxesLayer.transform = CATransform3DMakeAffineTransform(
        CGAffineTransformMakeRotation(radians));
    // swap length and width since we're going to be 90 degrees vs bit direction
    self.boxesLayer.frame =
        CGRectMake(boundingBox.origin.x, boundingBox.origin.y, self.bitWidth,
                   self.bitLength);
    [self.boxesLayer setNeedsDisplay];
    [self addSublayer:self.boxesLayer];
    addedDetail = YES;
  }
}

#pragma mark - FBAbstractBitLayer overrides

- (UIBezierPath *)fillPath {
//  return [self.quadPath makeFillPath];
  return [self.quadPath makeFillPath];
}

- (void)forceRedraw {
  [super forceRedraw];
  [self.numbersLayer setNeedsDisplay];
  [self.boxesLayer setNeedsDisplay];
}

- (void)hide {
  // TODO: can we just eliminate show/hide definitions on all bit types, and just use hidden on the top layer?
//  self.numbersLayer.hidden = YES;
//  self.boxesLayer.hidden = YES;
  self.hidden = YES;
}

- (void)show {
  // TODO: can we just eliminate show/hide definitions on all bit types, and just use hidden on the top layer?
//  self.numbersLayer.hidden = NO;
//  self.boxesLayer.hidden = NO;
  self.hidden = NO;
}

#pragma mark - joinery

- (void)endJoinToJoinNode:(CALayer<FBJoinNode> *)joinNode side:(FBJoinSide)side {
  // do all our calculations in our coordinate space
  CGPointPair joinPoints = [joinNode joinPointsInSelfForSide:side];
  CGPoint joinPoint1 = [self convertPoint:joinPoints.p1 fromLayer:joinNode];
  CGPoint joinPoint2 = [self convertPoint:joinPoints.p2 fromLayer:joinNode];
  
  // figure out which end of the bit to join to the joinPoints
  CGPoint endPointInSelf = [self endPointInSelfToJoinWithJoinNode:joinNode];
  
  if (CGPointEqualToPoint(endPointInSelf, self.toPointInSelf)) {
    // change toPoint (right) vertices
    self.quadInSelf =
    FBQuadMake(self.quadInSelf.upperLeft, joinPoint1, joinPoint2,
               self.quadInSelf.lowerLeft);
  } else {
    // change fromPoint (left) vertices
    self.quadInSelf = FBQuadMake(joinPoint1, self.quadInSelf.upperRight,
                                self.quadInSelf.lowerRight, joinPoint2);
  }
  
  // deal with "flag" quad shape
  //
  // 2--3
  // | /
  // 4
  // |
  // 1
  //
  // or
  //
  // 1-3-2
  // |/
  // 4
  //
  if (DistanceBetweenPoints(self.quadInSelf.lowerLeft, self.quadInSelf.upperRight) <
      DistanceBetweenPoints(self.quadInSelf.upperLeft, self.quadInSelf.upperRight)) {
    // flag 1: swap upperLeft and lowerLeft
    self.quadInSelf = FBQuadMake(self.quadInSelf.lowerLeft, self.quadInSelf.upperRight,
                                 self.quadInSelf.lowerRight, self.quadInSelf.upperLeft);
  } else if (DistanceBetweenPoints(self.quadInSelf.upperLeft, self.quadInSelf.lowerRight) <
             DistanceBetweenPoints(self.quadInSelf.upperLeft, self.quadInSelf.upperRight)) {
    // flag 2: swap upperRight and lowerRight
    self.quadInSelf = FBQuadMake(self.quadInSelf.upperLeft, self.quadInSelf.lowerRight,
                                 self.quadInSelf.upperRight, self.quadInSelf.lowerLeft);
  }
  
  if (FBQuadIsTwisted(self.quadInSelf)) {
    self.quadInSelf = FBQuadMakeUntwisted(self.quadInSelf);
  }
  [self updatePaths];
}

@end
