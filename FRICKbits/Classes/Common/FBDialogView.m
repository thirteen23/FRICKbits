//
//  FBDialogView.m
//  FrickBits
//
//  Created by Michael Van Milligan on 3/25/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBChrome.h"
#import "FBDialogView.h"
#import "FBUtils.h"

#define FBDIALOGVIEW_MARGINS (20.0f)
#define FBDIALOGVIEW_MIN_SZ (50.0f)
#define FBDIALOGVIEW_MULT_SZ (0.85f)
#define FBDIALOGVIEW_WHITE_HUE (1.0f)
#define FBDIALOGVIEW_OPACITY (0.5f)
#define FBDIALOGVIEW_BUTTON_OPACITY (0.5f)
#define FBDIALOGVIEW_BUTTON_HEIGHT (43.0f)

@interface FBDialogView ()<UIViewControllerTransitioningDelegate,
                           UIViewControllerAnimatedTransitioning>
@property(nonatomic, strong) NSAttributedString *message;
@property(nonatomic, strong) NSArray *buttonTitles;
@property(nonatomic, strong) UIViewController *presentingViewController;
@property(nonatomic, strong) UIImageView *backgroundImageView;
@end

@implementation FBDialogView

@synthesize buttonTitles = _buttonTitles;

+ (instancetype)dialogWithMessage:(NSString *)message
                         delegate:(id<FBDialogViewDelegate>)delegate
                cancelButtonTitle:(NSString *)cancelButtonTitle
                otherButtonTitles:(NSString *)otherButtonTitles, ... {

  NSAttributedString *messageAttr = [FBChrome attributedParagraph:message];
  NSAttributedString *cancelAttr =
      [FBChrome attributedButtonTitle:cancelButtonTitle];

  NSMutableArray *otherAttrs = [NSMutableArray array];
  va_list args;
  va_start(args, otherButtonTitles);
  for (NSString *arg = otherButtonTitles; arg != nil;
       arg = va_arg(args, NSString *)) {
    NSAttributedString *attr = [FBChrome attributedButtonTitle:arg];
    [otherAttrs addObject:attr];
  }
  va_end(args);

  return [[FBDialogView alloc] initWithMessage:messageAttr
                                      delegate:delegate
                             cancelButtonTitle:cancelAttr
                         otherButtonTitleArray:otherAttrs];
}

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
  }
  return self;
}

- (instancetype)initWithMessage:(NSAttributedString *)message
                       delegate:(id<FBDialogViewDelegate>)delegate
              cancelButtonTitle:(NSAttributedString *)cancelButtonTitle
              otherButtonTitles:(NSAttributedString *)otherButtonTitles, ... {

  NSMutableArray *otherTitles = [NSMutableArray array];
  va_list args;
  va_start(args, otherButtonTitles);
  for (NSAttributedString *arg = otherButtonTitles; arg != nil;
       arg = va_arg(args, NSAttributedString *)) {
    [otherTitles addObject:arg];
  }
  va_end(args);

  return [self initWithMessage:message
                      delegate:delegate
             cancelButtonTitle:cancelButtonTitle
         otherButtonTitleArray:otherTitles];
}

- (instancetype)initWithMessage:(NSAttributedString *)message
                       delegate:(id<FBDialogViewDelegate>)delegate
              cancelButtonTitle:(NSAttributedString *)cancelButtonTitle
          otherButtonTitleArray:(NSArray *)otherButtonTitles {
  if (self = [super init]) {
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.message = message;
    self.delegate = delegate;

    NSMutableArray *titles =
        [[NSMutableArray alloc] initWithCapacity:(1 + otherButtonTitles.count)];
    [titles addObject:cancelButtonTitle];
    [titles addObjectsFromArray:otherButtonTitles];
    self.buttonTitles = [NSArray arrayWithArray:titles];

    [self setup];
  }
  return self;
}

- (void)setup {
  self.hidden = YES;
  self.backgroundColor = [UIColor colorWithWhite:FBDIALOGVIEW_WHITE_HUE
                                           alpha:FBDIALOGVIEW_OPACITY];
  self.layer.borderColor = [UIColor whiteColor].CGColor;
  self.layer.borderWidth = 1.0;
  self.layer.cornerRadius = 5.0;
  // clip contained buttons at our rounded bounds/border
  self.clipsToBounds = YES;

  _backgroundImageView =
      [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
  _backgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
  [self addSubview:_backgroundImageView];
  [_backgroundImageView autoCenterInSuperview];
  [_backgroundImageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
  [_backgroundImageView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
  [_backgroundImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
  [_backgroundImageView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];

  UIView *colorOverlay =
      [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
  colorOverlay.backgroundColor = [FBChrome blurOverlayColor];
  colorOverlay.translatesAutoresizingMaskIntoConstraints = NO;
  [self addSubview:colorOverlay];
  [colorOverlay autoCenterInSuperview];
  [colorOverlay autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:0];
  [colorOverlay autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:0];
  [colorOverlay autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:0];
  [colorOverlay autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:0];

  UILabel *messageLabel = [[UILabel alloc] init];
  messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
  messageLabel.attributedText = self.message;
  messageLabel.backgroundColor = [UIColor clearColor];
  messageLabel.numberOfLines = 0;
  messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
  messageLabel.preferredMaxLayoutWidth = 250.0;
  [self addSubview:messageLabel];
  [messageLabel autoAlignAxis:ALAxisVertical toSameAxisOfView:self];
  [messageLabel autoPinEdgeToSuperviewEdge:ALEdgeTop
                                 withInset:FBDIALOGVIEW_MARGINS];
  [messageLabel autoPinEdgeToSuperviewEdge:ALEdgeLeft
                                 withInset:FBDIALOGVIEW_MARGINS];
  [messageLabel autoPinEdgeToSuperviewEdge:ALEdgeRight
                                 withInset:FBDIALOGVIEW_MARGINS];

  NSMutableArray *buttons = [[NSMutableArray alloc] init];
  [self.buttonTitles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx,
                                                  BOOL *stop) {
      if (_ISA_(obj, NSAttributedString)) {
        NSAttributedString *buttonString = (NSAttributedString *)obj;

        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.tag = idx;
        button.backgroundColor = [UIColor clearColor];
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.layer.borderWidth = 1.0;
        button.translatesAutoresizingMaskIntoConstraints = NO;

        [button setAttributedTitle:buttonString forState:UIControlStateNormal];
        button.titleLabel.numberOfLines = 0;
        button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [button addTarget:self
                      action:@selector(buttonWasSelected:)
            forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];

        [button autoSetDimension:ALDimensionHeight
                          toSize:FBDIALOGVIEW_BUTTON_HEIGHT
                        relation:NSLayoutRelationEqual];
        [button autoConstrainAttribute:ALEdgeTop
                           toAttribute:ALEdgeBottom
                                ofView:messageLabel
                            withOffset:FBDIALOGVIEW_MARGINS
                              relation:NSLayoutRelationGreaterThanOrEqual];
        [button autoConstrainAttribute:ALEdgeBottom
                           toAttribute:ALEdgeBottom
                                ofView:self
                            withOffset:0
                              relation:NSLayoutRelationLessThanOrEqual];

        [buttons addObject:button];
      }
  }];

  if (buttons.count == 1) {
    UIButton *button = buttons[0];
    [button autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self];
    [button autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self];
    [button autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self];
  } else {
    [buttons autoDistributeViewsAlongAxis:ALAxisHorizontal
                         withFixedSpacing:-1
                                alignment:NSLayoutFormatAlignAllCenterY];
  }
}

- (UIButton *)getSubviewButtonWithIndex:(NSUInteger)index {

  __block UIButton *prevButton = nil;

  [self.subviews
      enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
          if (_ISA_(obj, UIButton)) {
            if (index == ((UIButton *)obj).tag) {
              prevButton = (UIButton *)obj;
              *stop = YES;
            }
          }
      }];

  return prevButton;
}

- (void)presentDialogView {

  NSAssert(nil != self.superview,
           @"This needs to be added to a view before it can be presented");

  [self autoSetDimension:ALDimensionHeight
                  toSize:FBDIALOGVIEW_MIN_SZ
                relation:NSLayoutRelationGreaterThanOrEqual];

  [self autoMatchDimension:ALDimensionWidth
               toDimension:ALDimensionWidth
                    ofView:self.superview
            withMultiplier:FBDIALOGVIEW_MULT_SZ
                  relation:NSLayoutRelationEqual];

  [self autoCenterInSuperview];

  self.hidden = NO;

  [self layoutIfNeeded];
  [self.superview layoutIfNeeded];

  [self setNeedsDisplay];
}

- (void)buttonWasSelected:(id)sender {

  if (_ISA_(sender, UIButton)) {
    UIButton *senderButton = (UIButton *)sender;
    if ([self.delegate
            respondsToSelector:@selector(dialogView:clickedButtonAtIndex:)]) {
      [self.delegate dialogView:self clickedButtonAtIndex:senderButton.tag];
    }
  }

  [self dismiss];
}

- (void)dismiss {
  // just use normal, non-custom dismissal transition
  _presentingViewController.modalPresentationStyle =
      UIModalPresentationFullScreen;
  _presentingViewController.transitioningDelegate = nil;
  [_presentingViewController.presentingViewController
      dismissViewControllerAnimated:YES
                         completion:^{
                             // break any retain cycle
                             [self removeFromSuperview];
                             self.presentingViewController = nil;
                         }];
}

- (void)showOnView:(UIView *)view {
  _presentingViewController = [[UIViewController alloc] init];
  [_presentingViewController.view addSubview:self];
  _presentingViewController.view.backgroundColor = [UIColor clearColor];
  _presentingViewController.transitioningDelegate = self;
  _presentingViewController.modalPresentationStyle = UIModalPresentationCustom;

  // apply layout, and figure out our frame
  [self presentDialogView];

  [FBUtils takeRicePaperSnapshotOfView:view
                                 frame:self.frame
                       completionBlock:^(UIImage *snapshot) {
                           self.backgroundImageView.image = snapshot;
                           [view.window.rootViewController
                               presentViewController:_presentingViewController
                                            animated:YES
                                          completion:^{}];
                       }];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)
    animationControllerForPresentedController:(UIViewController *)presented
                         presentingController:(UIViewController *)presenting
                             sourceController:(UIViewController *)source {
  return self;
}

- (id<UIViewControllerAnimatedTransitioning>)
    animationControllerForDismissedController:(UIViewController *)dismissed {
  return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)
    interactionControllerForPresentation:
        (id<UIViewControllerAnimatedTransitioning>)animator {
  return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)
    interactionControllerForDismissal:
        (id<UIViewControllerAnimatedTransitioning>)animator {
  return nil;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)
                  transitionContext {
  return 0.25f;
}

- (void)animateTransition:
            (id<UIViewControllerContextTransitioning>)transitionContext {
  UIViewController *toVC = [transitionContext
      viewControllerForKey:UITransitionContextToViewControllerKey];
  UIViewController *fromVC = [transitionContext
      viewControllerForKey:UITransitionContextFromViewControllerKey];

  [[transitionContext containerView] addSubview:toVC.view];

  CGRect screenRect = [[UIScreen mainScreen] bounds];
  [toVC.view setFrame:CGRectMake(0, screenRect.size.height,
                                 fromVC.view.frame.size.width,
                                 fromVC.view.frame.size.height)];

  [UIView animateWithDuration:0.25f
      animations:^{
          [toVC.view setFrame:CGRectMake(0, 0, fromVC.view.frame.size.width,
                                         fromVC.view.frame.size.height)];
      }
      completion:^(BOOL finished) {
          [transitionContext completeTransition:YES];
      }];
}

@end
