//
//  FBOnboardingPresentationView.m
//  FrickBits
//
//  Created by Michael Van Milligan on 3/25/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBOnboardingPresentationView.h"
#import "FBUtils.h"
#import "FBChrome.h"

@interface FBOnboardingPresentationView ()
@property(nonatomic, strong) UILabel *helpText;
@property(nonatomic, strong) UIView *whiteLine;
@property(nonatomic, strong) NSMutableArray *views;
@end

@implementation FBOnboardingPresentationView

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.userInteractionEnabled = NO;
  }
  return self;
}

- (instancetype)initWithHelpText:(NSAttributedString *)helpText
                      andMargins:(CGFloat)margins {
  if (self = [super init]) {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.userInteractionEnabled = NO;

    [self doInitializationWithHelpText:helpText andMargins:margins];
  }
  return self;
}

- (instancetype)initWithHelpText:(NSAttributedString *)helpText
                       andButton:(UIButton *)button
                      andMargins:(CGFloat)margins {
  if (self = [super init]) {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.userInteractionEnabled = YES;

    [self doInitializationWithHelpText:helpText
                             andButton:button
                            andMargins:margins];
  }
  return self;
}

- (void)doInitializationWithHelpText:(NSAttributedString *)helpText
                          andMargins:(CGFloat)margins {

  self.backgroundColor = [FBChrome headerBackgroundColor];

  /* Need to add particular font characteristics here but we're ignoring them
   * now */
  _helpText = [[UILabel alloc] init];
  _helpText.translatesAutoresizingMaskIntoConstraints = NO;
  _helpText.numberOfLines = 0;
  _helpText.lineBreakMode = NSLineBreakByWordWrapping;
  _helpText.attributedText = helpText;
  _helpText.backgroundColor = [UIColor clearColor];
  [_helpText sizeToFit];

  [self addSubview:_helpText];

  [self autoMatchDimension:ALDimensionHeight
               toDimension:ALDimensionHeight
                    ofView:_helpText
                withOffset:margins];

  [_helpText autoMatchDimension:ALDimensionWidth
                    toDimension:ALDimensionWidth
                         ofView:_helpText.superview
                     withOffset:-margins
                       relation:NSLayoutRelationLessThanOrEqual];

  [_helpText autoCenterInSuperview];

  _whiteLine = [[UIView alloc] init];
  _whiteLine.backgroundColor = [UIColor whiteColor];
  _whiteLine.translatesAutoresizingMaskIntoConstraints = NO;

  [self addSubview:_whiteLine];

  [_whiteLine autoSetDimension:ALDimensionHeight toSize:1.0f];
  [_whiteLine autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0f];
  [_whiteLine autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0f];
  [_whiteLine autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0f];
}

- (void)doInitializationWithHelpText:(NSAttributedString *)helpText
                           andButton:(UIButton *)button
                          andMargins:(CGFloat)margins {

  CGRect screenRect = [[UIScreen mainScreen] bounds];
  CGFloat selfHeight = 0.0f;

  self.backgroundColor = [FBChrome headerBackgroundColor];

  /* Need to add particular font characteristics here but we're ignoring them
   * now */
  _helpText = [[UILabel alloc] init];
  _helpText.translatesAutoresizingMaskIntoConstraints = NO;
  _helpText.numberOfLines = 0;
  _helpText.lineBreakMode = NSLineBreakByWordWrapping;
  _helpText.attributedText = helpText;
  _helpText.backgroundColor = [UIColor clearColor];
  [_helpText sizeToFit];

  CGRect expectedLabelSize =
      [helpText boundingRectWithSize:CGSizeMake(screenRect.size.width, 10000.0f)
                             options:NSStringDrawingUsesLineFragmentOrigin |
                                     NSStringDrawingUsesFontLeading
                             context:nil];

  selfHeight += expectedLabelSize.size.height;

  [self addSubview:_helpText];

  [_helpText autoMatchDimension:ALDimensionWidth
                    toDimension:ALDimensionWidth
                         ofView:_helpText.superview
                     withOffset:-margins
                       relation:NSLayoutRelationLessThanOrEqual];

  [_helpText autoAlignAxisToSuperviewAxis:ALAxisVertical];

  [_helpText autoPinEdge:ALEdgeTop
                  toEdge:ALEdgeTop
                  ofView:self
              withOffset:15.0f];

  selfHeight += (25.0f * 2.0f);

  [self addSubview:button];

  [button autoPinEdge:ALEdgeTop
               toEdge:ALEdgeBottom
               ofView:_helpText
           withOffset:15.0f
             relation:NSLayoutRelationGreaterThanOrEqual];
  selfHeight += 15.0f;

  [button autoSetDimension:ALDimensionHeight toSize:44.0];
  [button autoAlignAxisToSuperviewAxis:ALAxisVertical];
  [button autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:20.0];
  [button autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:20.0];
  [button autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:20.0];

  selfHeight += button.frame.size.height;
  selfHeight += 20.0f;

  _whiteLine = [[UIView alloc] init];
  _whiteLine.backgroundColor = [UIColor whiteColor];
  _whiteLine.translatesAutoresizingMaskIntoConstraints = NO;

  [self addSubview:_whiteLine];

  [_whiteLine autoSetDimension:ALDimensionHeight toSize:1.0f];
  [_whiteLine autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0.0f];
  [_whiteLine autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0.0f];
  [_whiteLine autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0.0f];

  [self autoSetDimension:ALDimensionHeight
                  toSize:selfHeight
                relation:NSLayoutRelationGreaterThanOrEqual];
}

- (instancetype)initWithViews:(UIView *)views, ... NS_REQUIRES_NIL_TERMINATION {

  if (self = [super init]) {

    _views = [[NSMutableArray alloc] init];

    if (views) {
      va_list args;
      va_start(args, views);

      UIView *vw = views;
      do {
        [_views addObject:vw];
      } while ((vw = va_arg(args, UIView *)));
      va_end(args);
    }

    self.userInteractionEnabled = YES;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.backgroundColor = [FBChrome headerBackgroundColor];

    [self positionViews];
  }
  return self;
}

- (void)addView:(UIView *)view {
}

- (void)positionViews {
  __block UIView *lastView = nil;

  [_views enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      if (_ISA_(obj, UIView)) {
        UIView *thisView = (UIView *)obj;

        [self addSubview:thisView];

        [thisView autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [thisView autoPinEdge:ALEdgeRight
                       toEdge:ALEdgeRight
                       ofView:self
                   withOffset:-40.0f];
        [thisView autoPinEdge:ALEdgeLeft
                       toEdge:ALEdgeLeft
                       ofView:self
                   withOffset:40.0f];

        if (idx >= _views.count - 1) {
          NSLayoutConstraint *constraint = [thisView autoPinEdge:ALEdgeBottom
                                                          toEdge:ALEdgeBottom
                                                          ofView:self
                                                      withOffset:-15.0f];
          constraint.priority = UILayoutPriorityDefaultHigh;
        }

        if (!lastView) {

          NSLayoutConstraint *constraint = [thisView autoPinEdge:ALEdgeTop
                                                          toEdge:ALEdgeTop
                                                          ofView:self
                                                      withOffset:15.0f];
          constraint.priority = UILayoutPriorityDefaultHigh;

          [self autoMatchDimension:ALDimensionHeight
                       toDimension:ALDimensionHeight
                            ofView:thisView
                        withOffset:0.0f
                          relation:NSLayoutRelationGreaterThanOrEqual];

        } else {
          NSLayoutConstraint *constraint = [thisView autoPinEdge:ALEdgeTop
                                                          toEdge:ALEdgeBottom
                                                          ofView:lastView
                                                      withOffset:15.0f];
          constraint.priority = UILayoutPriorityDefaultHigh;
        }

        lastView = thisView;
      }
  }];
}

@end
