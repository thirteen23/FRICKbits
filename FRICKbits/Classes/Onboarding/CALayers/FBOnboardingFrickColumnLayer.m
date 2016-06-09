//
//  FBOnboardingFrickColumnLayer.m
//  FRICKbits
//
//  Created by Michael Van Milligan on 5/29/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBOnboardingFrickColumnLayer.h"
#import "FBOnboardingFrickBlockLayer.h"
#import "FBOnboarding.h"
#import "FBNumbersLayer.h"
#import "FBBoxesLayer.h"
#import "FBUtils.h"

@interface FBOnboardingFrickColumnLayer ()

@property(nonatomic, strong) dispatch_group_t animationGroup;
@property(nonatomic, strong) dispatch_queue_t concurrentAnimationQ;

@property(nonatomic, strong) NSMutableArray *bitBlocks;
@property(nonatomic) CGFloat height;
@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat shift;
@property(nonatomic) CGFloat minThickness;
@property(nonatomic) CGFloat jiggle;
@property(nonatomic) CGFloat distribution;
@property(nonatomic, strong) NSArray *baseColors;
@property(nonatomic, strong) NSArray *compColors;

@end

@implementation FBOnboardingFrickColumnLayer

@synthesize bitBlocks = _bitBlocks;

- (NSMutableArray *)bitBlocks {
  if (!_bitBlocks) {
    _bitBlocks = [[NSMutableArray alloc] init];
  }
  return _bitBlocks;
}

- (void)setBitBlocks:(NSMutableArray *)bitBlocks {
  [_bitBlocks removeAllObjects];
  _bitBlocks = nil;
  _bitBlocks = bitBlocks;
}

#pragma mark - Initialization

- (instancetype)initWithHeight:(CGFloat)height
                     withWidth:(CGFloat)width
                     withShift:(CGFloat)shift
              withMinThickness:(CGFloat)minThickness
                    withJiggle:(CGFloat)jiggle
              withDistribution:(CGFloat)distribution
                withBaseColors:(NSArray *)baseColors
                withCompColors:(NSArray *)compColors {
  if (self = [super init]) {

    _animationGroup = dispatch_group_create();
    _concurrentAnimationQ = dispatch_queue_create(
        "com.FRICKbits.FBOnboardingFrickColumnLayer.concurrentAnimationQ",
        DISPATCH_QUEUE_CONCURRENT);

    self.frame = CGRectMake(0.0f, 0.0f, width, height);
    self.opaque = YES;
    _height = height;
    _width = width;
    _shift = shift;
    _minThickness = minThickness;
    _jiggle = jiggle;
    _distribution = distribution;
    _baseColors = baseColors;
    _compColors = compColors;

    [self generateColumnWithDistro];

    self.backgroundColor =
        [[UIColor whiteColor] colorWithAlphaComponent:0.25f].CGColor;
  }
  return self;
}

#pragma mark - Overrides

- (void)addSublayer:(CALayer *)layer {
  if (_ISA_(layer, FBOnboardingFrickBlockLayer)) {
    [self.bitBlocks addObject:layer];
  }

  [super addSublayer:layer];
}

#pragma mark - Generating Column

- (void)generateColumnWithDistro {
  _minThickness = (_minThickness < _height) ? _minThickness : _height;

  uint32_t bits = (uint32_t)floorf(_height / _minThickness);
  uint32_t packets = (uint32_t)floorf(bits * _distribution);
  uint32_t baseRand = 0, compRand = 0;
  CGFloat heightPos = 0.0;
  CGFloat bitHeight;
  FBOnboardingFrickBlockLayer *lastBit = nil;

  while (heightPos < _height) {

    uint32_t chosenBits =
        (arc4random_uniform((packets < bits) ? packets : bits) + 1);
    bitHeight = _minThickness * chosenBits;
    bitHeight += (powf(-1.0f, arc4random_uniform(chosenBits))) *
                 ((arc4random_uniform(_jiggle) / _jiggle) * _jiggle);

    bitHeight =
        ((bitHeight + heightPos) > _height) ? (_height - heightPos) : bitHeight;

    FBOnboardingFrickBlockLayer *block =
        [[FBOnboardingFrickBlockLayer alloc] init];

    baseRand = arc4random_uniform((u_int32_t)_baseColors.count);
    compRand = arc4random_uniform((u_int32_t)_compColors.count);

    UIColor *fillColor =
        (FBOnboardingFrickColumnLayerNumberUpperBoundHeight > bitHeight)
            ? (_compColors[(compRand == lastBit.colorIdx)
                               ? (compRand + 1) % _compColors.count
                               : compRand])
            : (_baseColors[(baseRand == lastBit.colorIdx)
                               ? (baseRand + 1) % _baseColors.count
                               : baseRand]);

    block.anchorPoint = CGPointMake(0.0f, 0.0f);
    block.bounds = CGRectMake(0.0f, 0.0f, _width, bitHeight);
    block.shift = CGVectorMake(0.0f, bitHeight + heightPos);
    block.position = CGPointMake(0.0f, -bitHeight);
    block.tag = _numBits;
    block.backgroundColor = [UIColor clearColor].CGColor;
    block.fillColor = fillColor;
    block.opaque = YES;
    block.drawsAsynchronously = YES;
    block.doImperfections = CoinFlip();

    if (FBOnboardingFrickColumnLayerNumberUpperBoundHeight > bitHeight &&
        FBOnboardingFrickColumnLayerNumberLowerBoundHeight < bitHeight &&
        RandChance(FBOnboardingFrickColumnLayerDetailProbability) &&
        FBOnboardingFrickColumnLayerNumberLowerBoundWidth < _width) {

      CGFloat randomWidthOffset =
          (block.frame.size.width - FBOnboardingFrickColumnLayerDetailWidth) -
          FBOnboardingFrickColumnLayerDetailOffset;

      randomWidthOffset *=
          1.0f /
          arc4random_uniform(FBOnboardingFrickColumnLayerDetailOffsetDistro);

      if (CoinFlip()) {
        FBNumbersLayer *numbersLayer = [[FBNumbersLayer alloc]
            initWithFillColor:_compColors[arc4random_uniform(
                                  (u_int32_t)_compColors.count)]];

        numbersLayer.frame = CGRectMake(
            FBOnboardingFrickColumnLayerDetailOffset + randomWidthOffset,
            FBOnboardingFrickColumnLayerDetailOffset,
            FBOnboardingFrickColumnLayerDetailWidth,
            bitHeight - (FBOnboardingFrickColumnLayerDetailOffset + 1.0f));

        numbersLayer.opaque = YES;

        [block addSublayer:numbersLayer];
      } else {
        FBBoxesLayer *box = [[FBBoxesLayer alloc] init];
        box.fillColor =
            _compColors[arc4random_uniform((u_int32_t)_compColors.count)];
        box.frame = CGRectMake(
            FBOnboardingFrickColumnLayerDetailOffset + randomWidthOffset,
            FBOnboardingFrickColumnLayerDetailOffset,
            FBOnboardingFrickColumnLayerDetailWidth,
            bitHeight - (FBOnboardingFrickColumnLayerDetailOffset + 1.0f));
        block.opaque = YES;

        [box setNeedsDisplay];
        [block addSublayer:box];
      }
    }

    [self addSublayer:block];
    [block setNeedsDisplay];

    lastBit = block;

    heightPos += bitHeight;
    _numBits++;
  }
}

#pragma mark - Animating Bits

- (void)animateBitsIn {
  [self animateBitsInWithCompletion:nil];
}

- (void)animateBitsInWithCompletion:(dispatch_block_t)completion {

  dispatch_barrier_async(_concurrentAnimationQ, ^(void) {

      dispatch_sync(dispatch_get_main_queue(), ^(void) {

          NSUInteger subCount = [self.bitBlocks count] - 1;

          /* Begin enumeration block */
          void (^enumerationBlock)(id, NSUInteger, BOOL *) =
              ^(id obj, NSUInteger idx, BOOL *stop) {
              if (_ISA_(obj, FBOnboardingFrickBlockLayer)) {
                FBOnboardingFrickBlockLayer *thisBlock =
                    (FBOnboardingFrickBlockLayer *)obj;

                int64_t time =
                    FBOnboardingFrickColumnLayerStepTime * (subCount - idx);

                NSUInteger step = ((subCount - idx) *
                                   FBOnboardingFrickColumnLayerStepDuration);

                step = (FBOnboardingFrickColumnLayerStartDuration > step)
                           ? FBOnboardingFrickColumnLayerStartDuration - step
                           : 0;

                CFTimeInterval duration =
                    (FBOnboardingFrickColumnLayerLowerBoundTime < step)
                        ? step
                        : FBOnboardingFrickColumnLayerLowerBoundTime;

                duration /= 1000.0f;

                dispatch_group_enter(_animationGroup);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                             (int64_t)(time * NSEC_PER_MSEC)),
                               dispatch_get_main_queue(), ^(void) {

                    [thisBlock animateWithDuration:duration
                                     andCompletion:^(void) {
                                         dispatch_group_leave(_animationGroup);
                                     }];
                });
              }
          }; /* End enumeration block */

          [self.bitBlocks enumerateObjectsWithOptions:NSEnumerationReverse
                                           usingBlock:enumerationBlock];
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

          NSUInteger subCount = [self.bitBlocks count] - 1;

          /* Begin enumeration block */
          void (^enumerationBlock)(id, NSUInteger, BOOL *) =
              ^(id obj, NSUInteger idx, BOOL *stop) {
              if (_ISA_(obj, FBOnboardingFrickBlockLayer)) {
                FBOnboardingFrickBlockLayer *thisBlock =
                    (FBOnboardingFrickBlockLayer *)obj;

                int64_t time =
                    FBOnboardingFrickColumnLayerStepTime * (subCount - idx);

                NSUInteger step = ((subCount - idx) *
                                   FBOnboardingFrickColumnLayerStepDuration);

                step = (FBOnboardingFrickColumnLayerStartDuration > step)
                           ? FBOnboardingFrickColumnLayerStartDuration - step
                           : 0;

                CFTimeInterval duration =
                    (FBOnboardingFrickColumnLayerLowerBoundTime < step)
                        ? step
                        : FBOnboardingFrickColumnLayerLowerBoundTime;

                duration /= 1000.0f;

                dispatch_group_enter(_animationGroup);

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                             (int64_t)(time * NSEC_PER_MSEC)),
                               dispatch_get_main_queue(), ^(void) {

                    CGFloat dropDistance = _height - thisBlock.position.y;
                    thisBlock.shift = CGVectorMake(0.0f, dropDistance + 1.0f);

                    [thisBlock animateWithDuration:duration
                                     andCompletion:^(void) {
                                         dispatch_group_leave(_animationGroup);
                                     }];
                });
              }
          }; /* End enumeration block */

          [self.bitBlocks enumerateObjectsWithOptions:NSEnumerationReverse
                                           usingBlock:enumerationBlock];
      });

      dispatch_group_wait(_animationGroup, DISPATCH_TIME_FOREVER);

      if (completion) {
        dispatch_sync(dispatch_get_main_queue(), completion);
      }
  });
}

#pragma mark - Resetting Bits

- (void)removeAllBits {
  [self.bitBlocks
      enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
          if (_ISA_(obj, FBOnboardingFrickBlockLayer)) {
            FBOnboardingFrickBlockLayer *thisBlock =
                (FBOnboardingFrickBlockLayer *)obj;
            [thisBlock removeFromSuperlayer];
          }
      }];

  self.bitBlocks = nil;
}

@end
