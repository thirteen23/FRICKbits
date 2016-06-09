//
//  FBOnboardingColorScrollView.m
//  FRICKbits
//
//  Created by Michael Van Milligan on 5/20/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#include <tgmath.h>
#import <objc/runtime.h>
#import "FBOnboardingColorScrollView.h"
#import "FBOnboardingColorView.h"
#import "FBColorPaletteManager.h"
#import "T23AtomicBoolean.h"
#import "FBUtils.h"

@interface UIColor (FRICKbitsColorIndex)
@property(nonatomic, retain) id anAssociatedObject;
@end

@implementation UIColor (FRICKbitsColorIndex)
- (void)setAnAssociatedObject:(id)newAssociatedObject {
  objc_setAssociatedObject(self, @selector(anAssociatedObject),
                           newAssociatedObject,
                           OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id)anAssociatedObject {
  return objc_getAssociatedObject(self, @selector(anAssociatedObject));
}
@end

@interface FBOnboardingColorScrollView () <UIScrollViewDelegate,
                                           FBOnboardingColorViewDelegate,
                                           UIGestureRecognizerDelegate>

@property(nonatomic, strong) NSArray *colors;
@property(nonatomic, strong) NSMutableArray *visibleColorViews;
@property(nonatomic, strong) UIView *containerView;

@property(nonatomic, strong) UIPanGestureRecognizer *scrollInhibitor;

@property(nonatomic, strong) dispatch_group_t animationGroup;
@property(nonatomic, strong) dispatch_queue_t concurrentAnimationQ;

@property(nonatomic, strong) FBOnboardingColorView *currentColorView;

@property(nonatomic, strong) T23AtomicBoolean *firstLaunchCenterBits;
@property(nonatomic, strong) T23AtomicBoolean *firstLaunchTap;
@property(nonatomic, strong) T23AtomicBoolean *animatedIn;

@property(nonatomic, strong) T23AtomicBoolean *allowAnimation;

@property(nonatomic) CGFloat centerX;

@property(nonatomic) NSUInteger startingIndex;
@property(nonatomic) NSUInteger centerTileIndex;

@end

@implementation FBOnboardingColorScrollView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame {
  if ((self = [super initWithFrame:frame])) {
    self.translatesAutoresizingMaskIntoConstraints = NO;
  }
  return self;
}

- (id)init {
  if ((self = [super init])) {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self commonInit];
    _startingIndex = _centerTileIndex;
    [self resetColorOriginIndex];
  }
  return self;
}

- (instancetype)initWithStartingColorIndex:(NSUInteger)index {
  if (self = [super init]) {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    [self commonInit];
    _animatedIn.value = YES;
    _allowAnimation.value = YES;
    _startingIndex = index;
    [self resetColorOriginIndex];
  }
  return self;
}

- (void)commonInit {

  _animationGroup = dispatch_group_create();
  _concurrentAnimationQ = dispatch_queue_create(
      "com.FRICKbits.FBOnboardingFrickColumnLayer.concurrentAnimationQ",
      DISPATCH_QUEUE_CONCURRENT);

  self.backgroundColor = [UIColor clearColor];
  self.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
  self.contentSize = CGSizeMake(1000.0f, FBOnboardingColorViewHeight);
  self.showsHorizontalScrollIndicator = NO;
  self.decelerationRate = UIScrollViewDecelerationRateFast;
  self.delegate = self;

  _scrollInhibitor = [[UIPanGestureRecognizer alloc] init];
  _scrollInhibitor.delegate = self;
  [self addGestureRecognizer:_scrollInhibitor];

  [self.panGestureRecognizer requireGestureRecognizerToFail:_scrollInhibitor];

  _firstLaunchCenterBits = [[T23AtomicBoolean alloc] init];
  _firstLaunchCenterBits.value = YES;

  _firstLaunchTap = [[T23AtomicBoolean alloc] init];
  _firstLaunchTap.value = YES;

  _allowAnimation = [[T23AtomicBoolean alloc] init];
  _animatedIn = [[T23AtomicBoolean alloc] init];

  _colors = [[FBColorPaletteManager sharedInstance] getColorWheelFromPalettes];

  _visibleColorViews = [NSMutableArray array];
  _containerView = [[UIView alloc]
      initWithFrame:CGRectMake(0.0f, 0.0f, self.contentSize.width,
                               self.contentSize.height)];
  _containerView.translatesAutoresizingMaskIntoConstraints = NO;
  _containerView.backgroundColor = [UIColor clearColor];

  [self addSubview:_containerView];

  self.contentOffset =
      CGPointMake(self.contentOffset.x + (FBOnboardingColorViewWidth),
                  self.contentOffset.y);

  _centerX = ([[UIScreen mainScreen] bounds].size.width / 2.0f);
  _centerTileIndex =
      floor(((_centerX * 2.0f) / FBOnboardingColorViewWidth) / 2.0f);
}

- (void)resetColorOriginIndex {
  NSMutableArray *tempColors = [NSMutableArray arrayWithCapacity:_colors.count];
  NSUInteger startIndex =
      (0 <= ((NSInteger)_startingIndex - (NSInteger)_centerTileIndex))
          ? _startingIndex - _centerTileIndex
          : ((NSInteger)_startingIndex - (NSInteger)_centerTileIndex) +
                _colors.count;

  _startingIndex = (_startingIndex > (_colors.count - 1)) ? (_colors.count - 1)
                                                          : _startingIndex;

  if (_colors) {
    for (size_t idx = 0; idx < _colors.count; idx++) {
      UIColor *cursor = _colors[((startIndex + idx) % _colors.count)];
      cursor.anAssociatedObject = [NSNumber
          numberWithUnsignedInteger:((startIndex + idx) % _colors.count)];
      tempColors[idx] = cursor;
    }
    _colors = tempColors;
  }
}

#pragma mark - UIPanGestureRecognizer delegates

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
  if (gestureRecognizer == _scrollInhibitor) {
    CGPoint locationInView = [gestureRecognizer locationInView:self];
    for (FBOnboardingColorView *colorView in _visibleColorViews) {
      if (CGRectContainsPoint(colorView.frame, locationInView)) {
        return NO;
      }
    }
  }
  return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
    shouldRecognizeSimultaneouslyWithGestureRecognizer:
        (UIGestureRecognizer *)otherGestureRecognizer {
  return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {

  if (gestureRecognizer == _scrollInhibitor) {
    CGPoint locationInView = [touch locationInView:self];
    for (FBOnboardingColorView *colorView in _visibleColorViews) {
      if (CGRectContainsPoint(colorView.frame, locationInView)) {
        return NO;
      }
    }
  }
  return YES;
}

#pragma mark - Scroll View Management

- (void)recenterIfNecessary {
  CGPoint currentOffset = self.contentOffset;
  CGFloat contentWidth = self.contentSize.width;
  CGFloat centerOffsetX = (contentWidth - self.bounds.size.width) / 2.0f;
  CGFloat distanceFromCenter = (currentOffset.x >= centerOffsetX)
                                   ? currentOffset.x - centerOffsetX
                                   : centerOffsetX - currentOffset.x;

  if (distanceFromCenter > (contentWidth / 4.0f)) {
    self.contentOffset = CGPointMake(centerOffsetX, currentOffset.y);

    // move content by the same amount so it appears to stay still
    for (FBOnboardingColorView *colorView in _visibleColorViews) {
      CGFloat xDelta = centerOffsetX - currentOffset.x;
      colorView.frame = CGRectMake(
          colorView.frame.origin.x + xDelta, colorView.frame.origin.y,
          colorView.frame.size.width, colorView.frame.size.height);
    }
  }
}

- (void)layoutSubviews {
  [super layoutSubviews];

  [self recenterIfNecessary];

  // tile content in visible bounds
  CGRect visibleBounds = self.bounds;
  CGFloat minVisibleX = CGRectGetMinX(visibleBounds);
  CGFloat maxVisibleX = CGRectGetMaxX(visibleBounds);
  [self tileFromMinX:minVisibleX toMaxX:maxVisibleX];

  if (_allowAnimation.value) {
    [self resizeBits];
  }

  if (_firstLaunchCenterBits.value) {
    _firstLaunchCenterBits.value = NO;
    [self centerBits];
  }
}

- (void)resizeBits {
  CGPoint currentOffset = self.contentOffset;
  CGFloat centerX = currentOffset.x + self.frame.size.width / 2.0;
  BOOL setCenter = NO;

  for (FBOnboardingColorView *colorView in _visibleColorViews) {

    CGFloat viewOrigin =
        (colorView.frame.origin.x + (FBOnboardingColorViewWidth / 2.0f));
    CGFloat distanceToCenter =
        (viewOrigin >= centerX) ? viewOrigin - centerX : centerX - viewOrigin;

    if (FBOnboardingColorViewMediumHeight >= distanceToCenter) {

      if (FBOnboardingColorScrollViewNear >= distanceToCenter && !setCenter) {
        setCenter = YES;
        [colorView animateToSize:FBOnboardingColorViewHeight
                  withCompletion:nil];
      } else {
        [colorView animateToSize:FBOnboardingColorViewSmallHeight +
                                 (FBOnboardingColorViewMediumHeight *
                                  (1.0f - (distanceToCenter /
                                           FBOnboardingColorViewMediumHeight)))
                  withCompletion:nil];
      }
    } else {
      if (FBOnboardingColorViewSmallHeight < colorView.frame.size.height) {
        [colorView animateToSize:FBOnboardingColorViewSmallHeight
                  withCompletion:nil];
      }
    }
  }
}

- (void)tileFromMinX:(CGFloat)minX toMaxX:(CGFloat)maxX {
  // make sure there's at least one color
  if (_visibleColorViews.count == 0) {
    [self placeNewColorOnRightEdge:minX nextToColorView:nil];
  }

  // add colors that are missing on the right side
  FBOnboardingColorView *lastColorView = [_visibleColorViews lastObject];
  CGFloat rightEdge = CGRectGetMaxX(lastColorView.frame);
  while (rightEdge < maxX) {
    rightEdge =
        [self placeNewColorOnRightEdge:rightEdge nextToColorView:lastColorView];
    lastColorView = [_visibleColorViews lastObject];
  }

  // add colors that are missing on the left side
  FBOnboardingColorView *firstColorView = [_visibleColorViews firstObject];
  CGFloat leftEdge = firstColorView.frame.origin.x;
  while (leftEdge > minX) {
    leftEdge =
        [self placeNewColorOnLeftEdge:leftEdge nextToColorView:firstColorView];
    firstColorView = [_visibleColorViews firstObject];
  }

  // remove colors that have fallen off the right edge
  lastColorView = [_visibleColorViews lastObject];
  while (lastColorView.frame.origin.x > maxX) {
    [lastColorView removeFromSuperview];
    [_visibleColorViews removeObjectAtIndex:(_visibleColorViews.count - 1)];
    lastColorView = [_visibleColorViews lastObject];
  }

  // remove colors that have fallen off the left edge
  firstColorView = [_visibleColorViews firstObject];
  while (CGRectGetMaxX(firstColorView.frame) < minX) {
    [firstColorView removeFromSuperview];
    [_visibleColorViews removeObjectAtIndex:0];
    firstColorView = [_visibleColorViews firstObject];
  }
}

- (NSInteger)nextColorIndex:(NSInteger)fromIndex {
  NSInteger nextIdx = fromIndex + 1;
  NSInteger endIdx = _colors.count - 1;
  if (nextIdx <= endIdx) {
    return nextIdx;
  } else {
    // wrap to beginning
    return 0;
  }
}

- (NSInteger)previousColorIndex:(NSInteger)fromIndex {
  NSInteger prevIdx = fromIndex - 1;
  if (prevIdx >= 0) {
    return prevIdx;
  } else {
    // wrap to end
    return _colors.count - 1;
  }
}

- (CGFloat)placeNewColorOnRightEdge:(CGFloat)rightEdge
                    nextToColorView:(FBOnboardingColorView *)nextToColorView {
  // grab the next color
  NSInteger colorIndex = 0;
  if (nextToColorView) {
    colorIndex = [self nextColorIndex:nextToColorView.colorIndex];
  }
  UIColor *color = _colors[colorIndex];

  CGFloat height =
      (!_animatedIn.value) ? 0.0f : FBOnboardingColorViewSmallHeight;

  FBOnboardingColorView *colorView = [[FBOnboardingColorView alloc]
       initWithSize:CGSizeMake(FBOnboardingColorViewWidth, height)
          withColor:color
      andColorIndex:colorIndex];
  colorView.delegate = self;
  [_containerView addSubview:colorView];
  [_visibleColorViews addObject:colorView];

  CGRect frame = colorView.frame;
  frame.origin.x = rightEdge;
  frame.origin.y = _containerView.bounds.size.height - frame.size.height;
  colorView.frame = frame;

  return CGRectGetMaxX(frame);
}

- (CGFloat)placeNewColorOnLeftEdge:(CGFloat)leftEdge
                   nextToColorView:(FBOnboardingColorView *)nextToColorView {
  // grab the previous color
  NSInteger colorIndex = 0;
  if (nextToColorView) {
    colorIndex = [self previousColorIndex:nextToColorView.colorIndex];
  }
  UIColor *color = _colors[colorIndex];

  CGFloat height =
      (!_animatedIn.value) ? 0.0f : FBOnboardingColorViewSmallHeight;

  FBOnboardingColorView *colorView = [[FBOnboardingColorView alloc]
       initWithSize:CGSizeMake(FBOnboardingColorViewWidth, height)
          withColor:color
      andColorIndex:colorIndex];
  colorView.delegate = self;
  [_containerView addSubview:colorView];

  [_visibleColorViews insertObject:colorView atIndex:0];

  CGRect frame = colorView.frame;
  frame.origin.x = leftEdge - frame.size.width;
  frame.origin.y = _containerView.bounds.size.height - frame.size.height;
  colorView.frame = frame;

  return frame.origin.x;
}

- (void)centerBits {
  for (FBOnboardingColorView *colorView in _visibleColorViews) {
    CGFloat viewOrigin =
        (colorView.frame.origin.x + (FBOnboardingColorViewWidth / 2.0f));
    CGFloat distanceToOffset = (viewOrigin >= self.contentOffset.x)
                                   ? viewOrigin - self.contentOffset.x
                                   : self.contentOffset.x - viewOrigin;

    if (FBOnboardingColorScrollViewNear >= distanceToOffset) {
      [self setContentOffset:CGPointMake(viewOrigin, self.contentOffset.y)
                    animated:YES];

      NSUInteger centerColorViewIndex = (_visibleColorViews.count - 1) / 2;
      FBOnboardingColorView *centerBit =
          (FBOnboardingColorView *)_visibleColorViews[centerColorViewIndex];

      _currentColorView = centerBit;
    }
  }
}

#pragma mark - Animations

- (void)animatePickerOut {
  [self animatePickerOutWithCompletion:nil];
}

- (void)animatePickerOutWithCompletion:(dispatch_block_t)completion {

  self.userInteractionEnabled = NO;

  dispatch_barrier_async(_concurrentAnimationQ, ^(void) {

      dispatch_sync(dispatch_get_main_queue(), ^(void) {
          FBOnboardingColorView *cursor = nil;
          CGFloat timeAccum = 0.0f;

          NSUInteger sideCount = (_visibleColorViews.count - 1) / 2;

          for (NSUInteger idx = 0; idx <= sideCount; idx++) {

            dispatch_block_t completion = nil;

            CGFloat duration =
                (3 > idx) ? FBOnboardingColorScrollViewMiddleAnimationUpDuration
                          : FBOnboardingColorScrollViewSideAnimationUpDuration;

            timeAccum += (3 > idx)
                             ? FBOnboardingColorScrollViewMiddleAnimationDelay
                             : FBOnboardingColorScrollViewSideAnimationDelay;

            if (0 == idx) {
              cursor = _visibleColorViews[sideCount];

              completion = ^void(void) {
                dispatch_after(
                    dispatch_time(
                        DISPATCH_TIME_NOW,
                        (int64_t)(
                            FBOnboardingColorScrollViewAnimationFinishDelay *
                            NSEC_PER_SEC)),
                    dispatch_get_main_queue(), ^(void) {
                        [cursor
                            animateToSize:
                                FBOnboardingColorScrollViewAnimationUpDecrease
                             withDuration:duration
                            andCompletion:^(void) {
                                dispatch_group_leave(_animationGroup);
                            }];
                    });
              };

              dispatch_group_enter(_animationGroup);
              [cursor
                  animateToSize:cursor.frame.size.height +
                                FBOnboardingColorScrollViewAnimationDownIncrease
                   withDuration:FBOnboardingColorScrollViewAnimationDownDuration
                  andCompletion:completion];

            } else {
              cursor = _visibleColorViews[sideCount - idx];

              completion = ^void(void) {
                [cursor
                    animateToSize:
                        cursor.frame.size.height +
                        FBOnboardingColorScrollViewAnimationDownIncrease
                     withDuration:
                         FBOnboardingColorScrollViewAnimationDownDuration
                    andCompletion:^(void) {
                        dispatch_after(
                            dispatch_time(
                                DISPATCH_TIME_NOW,
                                (int64_t)(
                                    FBOnboardingColorScrollViewAnimationFinishDelay *
                                    NSEC_PER_SEC)),
                            dispatch_get_main_queue(), ^(void) {
                                [cursor
                                    animateToSize:
                                        FBOnboardingColorScrollViewAnimationUpDecrease
                                     withDuration:duration
                                    andCompletion:^(void) {
                                        dispatch_group_leave(_animationGroup);
                                    }];
                            });
                    }];
              };

              dispatch_group_enter(_animationGroup);
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                           (int64_t)(timeAccum * NSEC_PER_SEC)),
                             dispatch_get_main_queue(), completion);

              cursor = _visibleColorViews[sideCount + idx];

              completion = ^void(void) {
                [cursor
                    animateToSize:
                        cursor.frame.size.height +
                        FBOnboardingColorScrollViewAnimationDownIncrease
                     withDuration:
                         FBOnboardingColorScrollViewAnimationDownDuration
                    andCompletion:^(void) {
                        dispatch_after(
                            dispatch_time(
                                DISPATCH_TIME_NOW,
                                (int64_t)(
                                    FBOnboardingColorScrollViewAnimationFinishDelay *
                                    NSEC_PER_SEC)),
                            dispatch_get_main_queue(), ^(void) {
                                [cursor
                                    animateToSize:
                                        FBOnboardingColorScrollViewAnimationUpDecrease
                                     withDuration:duration
                                    andCompletion:^(void) {
                                        dispatch_group_leave(_animationGroup);
                                    }];
                            });
                    }];
              };

              dispatch_group_enter(_animationGroup);
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                           (int64_t)(timeAccum * NSEC_PER_SEC)),
                             dispatch_get_main_queue(), completion);
            }
          }
      });

      dispatch_group_wait(_animationGroup, DISPATCH_TIME_FOREVER);

      dispatch_sync(dispatch_get_main_queue(), ^(void) {
          _animatedIn.value = NO;
          if (completion) {
            completion();
          }
      });
  });
}

- (void)animatePickerIn {
  [self animatePickerInWithCompletion:nil];
}

- (void)animatePickerInWithCompletion:(dispatch_block_t)completion {
  self.userInteractionEnabled = NO;

  dispatch_barrier_async(_concurrentAnimationQ, ^(void) {

      dispatch_sync(dispatch_get_main_queue(), ^(void) {

          for (id cursor in _visibleColorViews) {
            if (_ISA_(cursor, FBOnboardingColorView)) {
              dispatch_group_enter(_animationGroup);
              [cursor animateToSize:FBOnboardingColorViewSmallHeight
                       withDuration:0.33f
                      andCompletion:^(void) {
                          dispatch_group_leave(_animationGroup);
                      }];
            }
          }
      });

      dispatch_group_wait(_animationGroup, DISPATCH_TIME_FOREVER);

      dispatch_sync(dispatch_get_main_queue(), ^(void) {
          self.userInteractionEnabled = YES;
          _animatedIn.value = YES;
          if (completion) {
            completion();
          }
      });
  });
}

- (void)animatePickerInFancyWithCompletion:(dispatch_block_t)completion {

  CGPoint currentOffset = self.contentOffset;
  CGFloat centerX = currentOffset.x + self.frame.size.width / 2.0;

  self.userInteractionEnabled = NO;

  dispatch_barrier_async(_concurrentAnimationQ, ^(void) {

      dispatch_sync(dispatch_get_main_queue(), ^(void) {
          FBOnboardingColorView *cursor = nil;
          CGFloat timeAccum = 0.0f;

          NSUInteger sideCount = (_visibleColorViews.count - 1) / 2;

          for (NSUInteger idx = 0; idx <= sideCount; idx++) {

            dispatch_block_t completion = nil;

            CGFloat duration =
                (3 > (sideCount - idx))
                    ? FBOnboardingColorScrollViewMiddleAnimationUpDuration
                    : FBOnboardingColorScrollViewSideAnimationUpDuration;

            if (sideCount == idx) {
              cursor = _visibleColorViews[sideCount];

              completion = ^void(void) {
                [cursor
                    animateToSize:
                        FBOnboardingColorViewHeight +
                        FBOnboardingColorScrollViewAnimationDownIncrease
                     withDuration:
                         FBOnboardingColorScrollViewAnimationDownDuration
                    andCompletion:^(void) {
                        dispatch_after(
                            dispatch_time(
                                DISPATCH_TIME_NOW,
                                (int64_t)(
                                    FBOnboardingColorScrollViewAnimationFinishDelay *
                                    NSEC_PER_SEC)),
                            dispatch_get_main_queue(), ^(void) {
                                [cursor
                                    animateToSize:FBOnboardingColorViewHeight
                                     withDuration:duration
                                    andCompletion:^(void) {
                                        dispatch_group_leave(_animationGroup);
                                    }];
                            });
                    }];
              };

              dispatch_group_enter(_animationGroup);
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                           (int64_t)(timeAccum * NSEC_PER_SEC)),
                             dispatch_get_main_queue(), completion);

            } else {
              cursor = _visibleColorViews[idx];

              CGFloat viewOrigin =
                  (cursor.frame.origin.x + (FBOnboardingColorViewWidth / 2.0f));
              CGFloat distanceToCenter = (viewOrigin >= centerX)
                                             ? viewOrigin - centerX
                                             : centerX - viewOrigin;

              CGFloat animationHeight =
                  (FBOnboardingColorViewMediumHeight >= distanceToCenter)
                      ? FBOnboardingColorViewSmallHeight +
                            (FBOnboardingColorViewMediumHeight *
                             (1.0f - (distanceToCenter /
                                      FBOnboardingColorViewMediumHeight)))
                      : FBOnboardingColorViewSmallHeight;

              completion = ^void(void) {
                [cursor
                    animateToSize:
                        animationHeight +
                        FBOnboardingColorScrollViewAnimationDownIncrease
                     withDuration:
                         FBOnboardingColorScrollViewAnimationDownDuration
                    andCompletion:^(void) {
                        dispatch_after(
                            dispatch_time(
                                DISPATCH_TIME_NOW,
                                (int64_t)(
                                    FBOnboardingColorScrollViewAnimationFinishDelay *
                                    NSEC_PER_SEC)),
                            dispatch_get_main_queue(), ^(void) {
                                [cursor animateToSize:animationHeight
                                         withDuration:duration
                                        andCompletion:^(void) {
                                            dispatch_group_leave(
                                                _animationGroup);
                                        }];
                            });
                    }];
              };

              dispatch_group_enter(_animationGroup);
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                           (int64_t)(timeAccum * NSEC_PER_SEC)),
                             dispatch_get_main_queue(), completion);

              cursor = _visibleColorViews[(_visibleColorViews.count - 1) - idx];

              viewOrigin =
                  (cursor.frame.origin.x + (FBOnboardingColorViewWidth / 2.0f));
              distanceToCenter = (viewOrigin >= centerX) ? viewOrigin - centerX
                                                         : centerX - viewOrigin;

              animationHeight =
                  (FBOnboardingColorViewMediumHeight >= distanceToCenter)
                      ? FBOnboardingColorViewSmallHeight +
                            (FBOnboardingColorViewMediumHeight *
                             (1.0f - (distanceToCenter /
                                      FBOnboardingColorViewMediumHeight)))
                      : FBOnboardingColorViewSmallHeight;

              completion = ^void(void) {
                [cursor
                    animateToSize:
                        animationHeight +
                        FBOnboardingColorScrollViewAnimationDownIncrease
                     withDuration:
                         FBOnboardingColorScrollViewAnimationDownDuration
                    andCompletion:^(void) {
                        dispatch_after(
                            dispatch_time(
                                DISPATCH_TIME_NOW,
                                (int64_t)(
                                    FBOnboardingColorScrollViewAnimationFinishDelay *
                                    NSEC_PER_SEC)),
                            dispatch_get_main_queue(), ^(void) {
                                [cursor animateToSize:animationHeight
                                         withDuration:duration
                                        andCompletion:^(void) {
                                            dispatch_group_leave(
                                                _animationGroup);
                                        }];
                            });
                    }];
              };

              dispatch_group_enter(_animationGroup);
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                           (int64_t)(timeAccum * NSEC_PER_SEC)),
                             dispatch_get_main_queue(), completion);
            }

            timeAccum += (3 > (sideCount - idx))
                             ? FBOnboardingColorScrollViewMiddleAnimationDelay
                             : FBOnboardingColorScrollViewSideAnimationDelay;
          }
      });

      dispatch_group_wait(_animationGroup, DISPATCH_TIME_FOREVER);

      dispatch_sync(dispatch_get_main_queue(), ^(void) {
          self.userInteractionEnabled = YES;
          _animatedIn.value = YES;
          if (completion) {
            completion();
          }
      });
  });
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
  _allowAnimation.value = YES;
  [self signalDelegateIsAnimating];
  [self resizeBits];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset {
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate {
  if (!self.dragging) {
    [self centerBits];
    [self signalDelegateDidSelectPaletteAtIndex];
  }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
  if (_allowAnimation.value) {
    [self resizeBits];

    if (_firstLaunchTap.value) {
      _firstLaunchTap.value = NO;
      [self signalDelegateDidSelectPaletteAtIndex];
    }
  }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
  if (_allowAnimation.value) {
    [self centerBits];
    [self signalDelegateDidSelectPaletteAtIndex];
  }
}

#pragma mark - FBOnboardingColorViewDelegate

- (void)signalDelegateDidSelectPaletteAtIndex {
  if (_colorDelegate &&
      [_colorDelegate
          respondsToSelector:@selector(
                                 colorScrollViewDidSelectPaletteAtIndex:)]) {
    [_colorDelegate colorScrollViewDidSelectPaletteAtIndex:
                        [(NSNumber *)_currentColorView.color
                                .anAssociatedObject unsignedIntegerValue]];
  }
}

- (void)signalDelegateIsAnimating {
  if (_colorDelegate &&
      [_colorDelegate
          respondsToSelector:@selector(colorScrollViewIsAnimating:)]) {
    [_colorDelegate colorScrollViewIsAnimating:self];
  }
}

- (void)signalDelegateAnimationHalted {
  if (_colorDelegate &&
      [_colorDelegate
          respondsToSelector:@selector(colorScrollViewAnimationHalted:)]) {
    [_colorDelegate colorScrollViewAnimationHalted:self];
  }
}

- (void)touchEventForColorView:(id)colorView {

  if (!self.dragging) {

    FBOnboardingColorView *thisColorView =
        (_ISA_(colorView, FBOnboardingColorView))
            ? (FBOnboardingColorView *)colorView
            : nil;

    if (thisColorView) {

      _currentColorView = thisColorView;

      CGFloat viewOrigin = (_currentColorView.frame.origin.x +
                            (FBOnboardingColorViewWidth / 2.0f));
      CGFloat bookEnd = self.contentOffset.x + (self.bounds.size.width / 2.0f);
      CGFloat distanceToOffset = viewOrigin - bookEnd;
      CGPoint newOffset = CGPointMake(distanceToOffset + self.contentOffset.x,
                                      self.contentOffset.y);

      if (0.0f > distanceToOffset || 0.0f < distanceToOffset) {

        if (!_allowAnimation.value) {
          /*
           * Animation handling for first launch animation where the user
           * selects anything BUT the middle bit
           */
          _allowAnimation.value = YES;
          [self setContentOffset:newOffset animated:YES];
        } else {

          /*
           * Animation handling for all subsequent animations
           */
          [self setContentOffset:newOffset animated:YES];
          [self signalDelegateDidSelectPaletteAtIndex];
        }

      } else {
        /*
         * Animation handling for first launch animation where the user selects
         * the middle bit
         */
        if (!_allowAnimation.value) {
          _allowAnimation.value = YES;

          [self resizeBits];
          [self signalDelegateDidSelectPaletteAtIndex];
        }
      }
    }
  }
}

@end
