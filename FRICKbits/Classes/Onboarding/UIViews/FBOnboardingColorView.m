//
//  FBOnboardingColorView.m
//  FRICKbits
//
//  Created by Michael Van Milligan on 5/20/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBOnboardingColorView.h"
#import "FBOnboardingFrickBlockLayer.h"
#import "FBUtils.h"
#import "T23AtomicBoolean.h"

@interface FBOnboardingColorView () <UIGestureRecognizerDelegate>

@property(nonatomic, strong) UIGestureRecognizer *touchRecognizer;
@property(nonatomic, strong) FBOnboardingFrickBlockLayer *block;

@property(nonatomic, readonly) T23AtomicBoolean *animating;
@property(nonatomic, copy) dispatch_block_t completion;
@property(nonatomic, strong) dispatch_queue_t iVarQ;

@property(nonatomic) CGFloat toHeight;

@end

@implementation FBOnboardingColorView

@synthesize iVarQ = _iVarQ, completion = _completion;

DEF_SAFE_GETSET_FOR_Q(dispatch_block_t, completion, setCompletion, _iVarQ);

#pragma mark - Initialization

- (BOOL)isAnimating {
  return _animating.value;
}

- (id)initWithSize:(CGSize)size
         withColor:(UIColor *)color
     andColorIndex:(NSInteger)colorIndex {
  if (self = [super
          initWithFrame:CGRectMake(0.0f, 0.0f, FBOnboardingColorViewWidth,
                                   FBOnboardingColorViewHeight)]) {

    self.translatesAutoresizingMaskIntoConstraints = NO;

    _iVarQ = dispatch_queue_create("com.FRICKbits.FBOnboardingColorView.iVarQ",
                                   NULL);

    _animating = [[T23AtomicBoolean alloc] init];

    _color = color;
    _colorIndex = colorIndex;

    _exposedView = [[UIView alloc] initWithFrame:CGRectZero];
    _exposedView.backgroundColor = [UIColor clearColor];
    _exposedView.frame = CGRectMake(0, 0, size.width, size.height);
    [self addSubview:_exposedView];

    _block = [[FBOnboardingFrickBlockLayer alloc] init];
    _block.anchorPoint = CGPointMake(0.0f, 0.0f);
    _block.bounds = CGRectMake(0.0f, 0.0f, _exposedView.frame.size.width,
                               _exposedView.frame.size.height);
    _block.position = CGPointMake(0.0f, 0.0f);
    _block.backgroundColor = [UIColor clearColor].CGColor;
    _block.fillColor = _color;
    _block.doImperfections = CoinFlip();

    [_exposedView.layer addSublayer:_block];
    [_block setNeedsDisplay];

    [self setupTouchEvents];
  }
  return self;
}

#pragma mark - Touch Events

- (void)setupTouchEvents {
  _touchRecognizer =
      [[UITapGestureRecognizer alloc] initWithTarget:self
                                              action:@selector(handleTap:)];
  _touchRecognizer.delegate = self;
  [self addGestureRecognizer:_touchRecognizer];
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer {
  if (_delegate &&
      [_delegate respondsToSelector:@selector(touchEventForColorView:)]) {
    [_delegate touchEventForColorView:self];
  }
}

#pragma mark UIGestureRecognizer Delegate Methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {

  BOOL shouldReceiveTouch = YES;

  if (_touchRecognizer == gestureRecognizer) {
    CGPoint touchLocation = [_touchRecognizer locationInView:self];

    if (touchLocation.y > _block.bounds.size.height) {
      shouldReceiveTouch = NO;
    }
  }

  return shouldReceiveTouch;
}

#pragma mark - Animations

- (void)animateToSize:(CGFloat)height {
  [self animateToSize:height
         withDuration:FBOnboardingColorViewDefaultAnimateDuration];
}

- (void)animateToSize:(CGFloat)height withDuration:(CGFloat)duration {
  [self animateToSize:height withDuration:duration andCompletion:nil];
}

- (void)animateToSize:(CGFloat)height
       withCompletion:(dispatch_block_t)completion {
  [self animateToSize:height
         withDuration:FBOnboardingColorViewDefaultAnimateDuration
        andCompletion:completion];
}

- (void)animateToSize:(CGFloat)height
         withDuration:(CGFloat)duration
        andCompletion:(dispatch_block_t)completion {

  CABasicAnimation *growDown =
      [CABasicAnimation animationWithKeyPath:@"bounds"];

  [growDown setValue:@"grow" forKey:@"down"];

  CGRect newBounds = CGRectMake(_block.bounds.origin.x, _block.bounds.origin.y,
                                _block.bounds.size.width, height);
  growDown.fromValue = [NSValue valueWithCGRect:_block.bounds];
  growDown.toValue = [NSValue valueWithCGRect:newBounds];
  growDown.duration = duration;

  // yay old school delegate methods
  growDown.delegate = self;

  // squirrel this away
  self.completion = completion;

  // squirrel this away as well
  _toHeight = height;

  _block.bounds = newBounds;

  _animating.value = YES;

  [_block addAnimation:growDown forKey:@"growDown"];

  _exposedView.frame =
      CGRectMake(_exposedView.frame.origin.x, _exposedView.frame.origin.y,
                 _exposedView.frame.size.width, height);

  self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                          self.frame.size.width, height);
}

- (void)animationDidStart:(CAAnimation *)anim {
  // Nothing?
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {

  if (flag) {
    dispatch_async(dispatch_get_main_queue(), ^(void) {

        _animating.value = NO;

        if (1.0f >= _toHeight) {
          _block.bounds =
              CGRectMake(_block.bounds.origin.x, _block.bounds.origin.y,
                         _block.bounds.size.width, 0.0f);
        }

        if (self.completion) {
          self.completion();
          self.completion = nil;
        }
    });
  }
}

@end