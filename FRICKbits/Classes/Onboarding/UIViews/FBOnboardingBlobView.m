//
//  FBOnboardingBlobView.m
//  FRICKbits
//
//  Created by Michael Van Milligan on 5/28/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBOnboardingBlobView.h"
#import "FBOnboardingBlobMaskView.h"
#import "FBOnboardingFrickColumnLayer.h"
#import "FBOnboarding.h"
#import "FBColorPaletteManager.h"
#import "T23AtomicBoolean.h"
#import "FBUtils.h"

@interface FBOnboardingBlobView ()

/* debug */
@property(nonatomic, strong) CALayer *circleLayer;

@property(nonatomic, strong) dispatch_group_t animationGroup;
@property(nonatomic, strong) dispatch_queue_t concurrentAnimationQ;

@property(nonatomic, strong) FBOnboardingBlobMaskView *maskView;

@property(nonatomic, strong) NSMutableArray *bitColumns;
@property(nonatomic) NSUInteger numColumns;
@property(nonatomic, strong) NSMutableArray *upperLeftPoints;
@property(nonatomic, strong) NSMutableArray *lowerLeftPoints;
@property(nonatomic, strong) NSMutableArray *upperRightPoints;
@property(nonatomic, strong) NSMutableArray *lowerRightPoints;

@end

@implementation FBOnboardingBlobView

@synthesize bitColumns = _bitColumns;

- (NSMutableArray *)bitColumns {
  if (!_bitColumns) {
    _bitColumns = [[NSMutableArray alloc]
        initWithCapacity:(FBOnboardingBlobMaskViewFrickBlockLevels * 2) - 1];
  }
  return _bitColumns;
}

- (void)setBitColumns:(NSMutableArray *)bitColumns {
  [_bitColumns removeAllObjects];
  _bitColumns = nil;
  _bitColumns = bitColumns;
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self commonInit];
  }
  return self;
}

- (id)init {
  return [self initWithFrame:CGRectMake(0.0f, 0.0f, FBOnboardingBlobViewSize,
                                        FBOnboardingBlobViewSize)];
}

- (void)commonInit {

  _animationGroup = dispatch_group_create();
  _concurrentAnimationQ = dispatch_queue_create(
      "com.FRICKbits.FBOnboardingBlobView.concurrentAnimationQ",
      DISPATCH_QUEUE_CONCURRENT);

  self.translatesAutoresizingMaskIntoConstraints = NO;

  _upperLeftPoints = [[NSMutableArray alloc] init];
  _lowerLeftPoints = [[NSMutableArray alloc] init];
  _upperRightPoints = [[NSMutableArray alloc] init];
  _lowerRightPoints = [[NSMutableArray alloc] init];

  _numColumns = 0;
}

#pragma mark - Generating Blob

- (void)generateFrickBlocksWithPaletteIndex:(NSUInteger)idx {

  CGFloat yCoord = 0.0f, yDelta = 0.0f, yTopPoint = 0.0f, yBotPoint = 0.0f,
          curWidth = 0.0f, cursor = 0.0f;
  CGFloat originPoint = (self.frame.size.width / 2.0f);
  CGFloat yCenter = (self.frame.size.height / 2.0f);
  CGFloat distro = 0.0f;

  NSArray *baseColors =
      [[FBColorPaletteManager sharedInstance] getPrimaryPaletteForIndex:idx];
  NSArray *compColors =
      [[FBColorPaletteManager sharedInstance] getComplementPaletteForIndex:idx];

  //  if (!_circleLayer) {
  //    _circleLayer = [[CALayer alloc] init];
  //    _circleLayer.frame =
  //        CGRectMake(originPoint - FBOnboardingBlobMaskViewRadius,
  //                   yCenter - FBOnboardingBlobMaskViewRadius,
  //                   FBOnboardingBlobMaskViewRadius * 2.0f,
  //                   FBOnboardingBlobMaskViewRadius * 2.0f);
  //    _circleLayer.cornerRadius = FBOnboardingBlobMaskViewRadius;
  //    _circleLayer.backgroundColor = [UIColor clearColor].CGColor;
  //    _circleLayer.borderColor = [UIColor greenColor].CGColor;
  //    _circleLayer.borderWidth = 1.0f;
  //
  //    [self.layer addSublayer:_circleLayer];
  //  }

  for (size_t i = 0; i < FBOnboardingBlobMaskViewFrickBlockLevels; i++) {

    cursor += (0 == i || (FBOnboardingBlobMaskViewFrickBlockLevels - 1) == i)
                  ? FBOnboardingBlobMaskViewFrickBlockWidthHalf
                  : FBOnboardingBlobMaskViewFrickBlockWidth;
    yCoord =
        sqrtf(powf(FBOnboardingBlobMaskViewRadius, 2.0f) - powf(cursor, 2.0f));
    yDelta = (yCenter + yCoord) - (yCenter - yCoord);
    yTopPoint = yCenter - yCoord;
    yBotPoint = yTopPoint + yDelta;
    curWidth = (((FBOnboardingBlobMaskViewFrickBlockLevels - 1) > i)
                    ? FBOnboardingBlobMaskViewFrickBlockWidth
                    : FBOnboardingBlobMaskViewFrickBlockWidthHalf);

    if (0 == i) {
      distro += FBOnboardingBlobMaskViewFrickBlockDistro;
      originPoint -= FBOnboardingBlobMaskViewFrickBlockWidthHalf;
      [self addColumnOfFrickBlocksAt:CGPointMake(originPoint, yTopPoint)
                          withHeight:yDelta
                           withWidth:curWidth
                           withShift:FBOnboardingBlobMaskViewFrickBlockShift
                    withMinThickness:
                        FBOnboardingBlobMaskViewFrickBlockMinThickness
                          withJiggle:FBOnboardingBlobMaskViewFrickBlockJiggle
                    withDistribution:distro
                      withBaseColors:baseColors
                      withCompColors:compColors];

      if (!_maskView) {
        [_upperLeftPoints
            addObject:[NSValue valueWithCGPoint:CGPointMake(originPoint,
                                                            yTopPoint)]];
        [_lowerLeftPoints
            addObject:[NSValue valueWithCGPoint:CGPointMake(originPoint,
                                                            yBotPoint)]];

        [_upperRightPoints
            addObject:[NSValue
                          valueWithCGPoint:
                              CGPointMake(
                                  originPoint +
                                      FBOnboardingBlobMaskViewFrickBlockWidth,
                                  yTopPoint)]];
        [_lowerRightPoints
            addObject:[NSValue
                          valueWithCGPoint:
                              CGPointMake(
                                  originPoint +
                                      FBOnboardingBlobMaskViewFrickBlockWidth,
                                  yBotPoint)]];
      }

    } else {

      CGFloat drawRightPoint =
          originPoint + (FBOnboardingBlobMaskViewFrickBlockWidth * i);
      CGFloat drawLeftRightPoint =
          drawRightPoint - ((FBOnboardingBlobMaskViewFrickBlockLevels > i)
                                ? 0.0f
                                : FBOnboardingBlobMaskViewFrickBlockWidthHalf);
      CGFloat drawRightRightPoint =
          drawRightPoint + (((FBOnboardingBlobMaskViewFrickBlockLevels - 1) > i)
                                ? FBOnboardingBlobMaskViewFrickBlockWidth
                                : FBOnboardingBlobMaskViewFrickBlockWidthHalf);

      distro += ((FBOnboardingBlobMaskViewFrickBlockLevels - 1) > i)
                    ? 0.0f
                    : FBOnboardingBlobMaskViewFrickBlockDistro;

      [self addColumnOfFrickBlocksAt:CGPointMake(drawRightPoint, yTopPoint)
                          withHeight:yDelta
                           withWidth:curWidth
                           withShift:FBOnboardingBlobMaskViewFrickBlockShift
                    withMinThickness:
                        FBOnboardingBlobMaskViewFrickBlockMinThickness
                          withJiggle:FBOnboardingBlobMaskViewFrickBlockJiggle
                    withDistribution:distro
                      withBaseColors:baseColors
                      withCompColors:compColors];

      if (!_maskView) {
        [_upperRightPoints
            addObject:[NSValue valueWithCGPoint:CGPointMake(drawLeftRightPoint,
                                                            yTopPoint)]];
        [_upperRightPoints
            addObject:[NSValue valueWithCGPoint:CGPointMake(drawRightRightPoint,
                                                            yTopPoint)]];

        [_lowerRightPoints
            addObject:[NSValue valueWithCGPoint:CGPointMake(drawLeftRightPoint,
                                                            yBotPoint)]];
        [_lowerRightPoints
            addObject:[NSValue valueWithCGPoint:CGPointMake(drawRightRightPoint,
                                                            yBotPoint)]];
      }

      CGFloat drawLeftPoint =
          (((FBOnboardingBlobMaskViewFrickBlockLevels - 1) > i)
               ? (originPoint - (FBOnboardingBlobMaskViewFrickBlockWidth * i))
               : (originPoint - (FBOnboardingBlobMaskViewFrickBlockWidth * i)) +
                     FBOnboardingBlobMaskViewFrickBlockWidthHalf);
      CGFloat drawLeftLeftPoint =
          drawLeftPoint + (((FBOnboardingBlobMaskViewFrickBlockLevels - 1) > i)
                               ? FBOnboardingBlobMaskViewFrickBlockWidth
                               : FBOnboardingBlobMaskViewFrickBlockWidthHalf);
      CGFloat drawRightLeftPoint = drawLeftPoint;

      [self addColumnOfFrickBlocksAt:CGPointMake(drawLeftPoint, yTopPoint)
                          withHeight:yDelta
                           withWidth:curWidth
                           withShift:FBOnboardingBlobMaskViewFrickBlockShift
                    withMinThickness:
                        FBOnboardingBlobMaskViewFrickBlockMinThickness
                          withJiggle:FBOnboardingBlobMaskViewFrickBlockJiggle
                    withDistribution:distro
                      withBaseColors:baseColors
                      withCompColors:compColors];

      if (!_maskView) {
        [_upperLeftPoints
            addObject:[NSValue valueWithCGPoint:CGPointMake(drawLeftLeftPoint,
                                                            yTopPoint)]];
        [_upperLeftPoints
            addObject:[NSValue valueWithCGPoint:CGPointMake(drawRightLeftPoint,
                                                            yTopPoint)]];

        [_lowerLeftPoints
            addObject:[NSValue valueWithCGPoint:CGPointMake(drawLeftLeftPoint,
                                                            yBotPoint)]];
        [_lowerLeftPoints
            addObject:[NSValue valueWithCGPoint:CGPointMake(drawRightLeftPoint,
                                                            yBotPoint)]];
      }
    }
  }

  if (!_maskView) {
    UIBezierPath *maskPath = [self buildBezierPath];
    _maskView = [[FBOnboardingBlobMaskView alloc] initWithFrame:self.frame
                                                        andMask:maskPath];

    [self addSubview:_maskView];
  }

  [self bringSubviewToFront:_maskView];
}

- (void)addColumnOfFrickBlocksAt:(CGPoint)p
                      withHeight:(CGFloat)height
                       withWidth:(CGFloat)width
                       withShift:(CGFloat)shift
                withMinThickness:(CGFloat)minThickness
                      withJiggle:(CGFloat)jiggle
                withDistribution:(CGFloat)distribution
                  withBaseColors:(NSArray *)baseColors
                  withCompColors:(NSArray *)compColors {

  FBOnboardingFrickColumnLayer *column =
      [[FBOnboardingFrickColumnLayer alloc] initWithHeight:height
                                                 withWidth:width
                                                 withShift:shift
                                          withMinThickness:minThickness
                                                withJiggle:jiggle
                                          withDistribution:distribution
                                            withBaseColors:baseColors
                                            withCompColors:compColors];

  column.frame =
      CGRectMake(p.x, p.y, column.frame.size.width, column.frame.size.height);
  column.tag = _numColumns;
  _numColumns++;

  _numBits += column.numBits;

  [self.bitColumns addObject:column];
  [self.layer addSublayer:column];
}

#pragma mark - Building Blob Mask

- (UIBezierPath *)buildBezierPath {

  UIBezierPath *path = [UIBezierPath bezierPath];

  [_upperLeftPoints
      enumerateObjectsWithOptions:NSEnumerationReverse
                       usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                           if (_ISA_(obj, NSValue)) {
                             NSValue *point = (NSValue *)obj;

                             if ([_upperLeftPoints count] - 1 == idx) {
                               [path moveToPoint:[point CGPointValue]];

                             } else {
                               [path addLineToPoint:[point CGPointValue]];
                             }
                           }
                       }];

  [_upperRightPoints
      enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
          if (_ISA_(obj, NSValue)) {
            NSValue *point = (NSValue *)obj;
            [path addLineToPoint:[point CGPointValue]];
          }
      }];

  [_lowerRightPoints
      enumerateObjectsWithOptions:NSEnumerationReverse
                       usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                           if (_ISA_(obj, NSValue)) {
                             NSValue *point = (NSValue *)obj;
                             [path addLineToPoint:[point CGPointValue]];
                           }
                       }];

  [_lowerLeftPoints
      enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
          if (_ISA_(obj, NSValue)) {
            NSValue *point = (NSValue *)obj;
            [path addLineToPoint:[point CGPointValue]];
          }
      }];

  [path closePath];

  return path;
}

#pragma mark - Animating Columns

- (void)animateBitsInWithPaletteIndex:(NSUInteger)idx {
  [self animateBitsInWithPaletteIndex:idx andCompletion:nil];
}

- (void)animateBitsInWithPaletteIndex:(NSUInteger)idx
                        andCompletion:(dispatch_block_t)completion {

  dispatch_barrier_async(_concurrentAnimationQ, ^(void) {

      dispatch_sync(dispatch_get_main_queue(), ^(void) {
          [self generateFrickBlocksWithPaletteIndex:idx];
      });

      dispatch_sync(dispatch_get_main_queue(), ^(void) {
          [self.bitColumns
              enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                  if (_ISA_(obj, FBOnboardingFrickColumnLayer)) {
                    FBOnboardingFrickColumnLayer *column =
                        (FBOnboardingFrickColumnLayer *)obj;

                    dispatch_group_enter(_animationGroup);
                    [column animateBitsInWithCompletion:^(void) {
                        dispatch_group_leave(_animationGroup);
                    }];
                  }
              }];
      });

      dispatch_group_wait(_animationGroup, DISPATCH_TIME_FOREVER);

      if (completion) {
        dispatch_sync(dispatch_get_main_queue(), completion);
      }
  });
}

- (void)animateBitsOut {
  [self animateBitsOutWithCompletion:nil];
}

- (void)animateBitsOutWithCompletion:(dispatch_block_t)completion {

  dispatch_barrier_async(_concurrentAnimationQ, ^(void) {

      dispatch_sync(dispatch_get_main_queue(), ^(void) {
          [self.bitColumns
              enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                  if (_ISA_(obj, FBOnboardingFrickColumnLayer)) {
                    FBOnboardingFrickColumnLayer *column =
                        (FBOnboardingFrickColumnLayer *)obj;

                    dispatch_group_enter(_animationGroup);
                    [column animateBitsOutWithCompletion:^(void) {
                        dispatch_group_leave(_animationGroup);
                    }];
                  }
              }];
      });

      dispatch_group_wait(_animationGroup, DISPATCH_TIME_FOREVER);

      dispatch_sync(dispatch_get_main_queue(), ^(void) {
          [self removeAllColumns];
          if (completion) {
            completion();
          }
      });
  });
}

#pragma mark - Resetting Columns

- (void)removeAllColumns {
  [self.bitColumns
      enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
          if (_ISA_(obj, FBOnboardingFrickColumnLayer)) {
            FBOnboardingFrickColumnLayer *thisColumn =
                (FBOnboardingFrickColumnLayer *)obj;
            [thisColumn removeAllBits];
            [thisColumn removeFromSuperlayer];
            _numColumns--;
          }
      }];

  self.bitColumns = nil;
}

@end
