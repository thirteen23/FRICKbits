//
//  FBOnboardingAnimationViewController.m
//  FRICKbits
//
//  Created by Michael Van Milligan on 9/5/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBOnboardingAnimationViewController.h"
#import "FBOnboardingNavigationController.h"
#import "FBOnboardingAnimationView.h"
#import "FBOnboardingPresentationView.h"
#import "FBHeaderView.h"
#import "FBChrome.h"
#import "FBUtils.h"
#import "FBDiaphanousView.h"
#import "PureLayout.h"
#import "T23AtomicBoolean.h"
#import "UIImage+BlurredFrame.h"

static NSString *const introText =
    @"Make Art.\nFRICKbits reveals the hidden pattern of your daily travels.";
static NSString *const nextOnboardingButtonText = @"NEXT";

// Dummy view hack
static NSString *const colorPickerText =
    @"Choose a color. Find the palette that feels right for " @"you.";

/*
 * Animation image files
 */

static const char *const animationImages[] = {
    /* 1st animation image */ "FRI_Onboarding_Slide3.png",
    /* 2nd animation image */ "FRI_Onboarding_Slide2.png",
    /* 3rd animation image */ "FRI_Onboarding_Slide1.png",
    /* 4th animation image */ "FRI_Onboarding_Slide0.png"};

@interface FBOnboardingAnimationViewController ()
@property(nonatomic, strong) dispatch_queue_t iVarQ;
@property(nonatomic, strong) dispatch_group_t animationActionGroup;
@property(nonatomic, strong) dispatch_group_t animationYieldGroup;
@property(nonatomic) BOOL animateOn;
@property(nonatomic, strong) NSArray *animationViews;
@property(nonatomic) NSUInteger imageCount;

@property(nonatomic, strong) FBHeaderView *titleView;
@property(nonatomic, strong) FBOnboardingPresentationView *introView;
@property(nonatomic, strong) NSMutableArray *introViewConstraints;
@property(nonatomic, strong) UIButton *introButton;
@property(nonatomic, strong) UILabel *introTextLabel;

// Dummy view hack
@property(nonatomic, strong) UILabel *dummyPickerInfoTextLabel;
@property(nonatomic, strong)
    FBOnboardingPresentationView *dummyPickerInfoTextView;
@property(nonatomic, strong) NSMutableArray *dummyPickerInfoTextViewConstraints;

// Rice paper
@property(nonatomic, strong) T23AtomicBoolean *didRicePapering;

@end

@implementation FBOnboardingAnimationViewController

@synthesize animateOn = _animateOn;

DEF_SAFE_GETSET_FOR_Q(BOOL, animateOn, setAnimateOn, _iVarQ);

- (instancetype)init {
  if (self = [super init]) {
    _iVarQ = dispatch_queue_create(
        "com.FRICKbits.FBOnboardingAnimationViewController.iVarQ", NULL);

    _animationActionGroup = dispatch_group_create();
    _animationYieldGroup = dispatch_group_create();
    _introViewConstraints = [[NSMutableArray alloc] init];
    _dummyPickerInfoTextViewConstraints = [[NSMutableArray alloc] init];
    _didRicePapering = [[T23AtomicBoolean alloc] init];

    _imageCount = (0 == sizeof(animationImages))
                      ? 0
                      : (sizeof(animationImages) / sizeof(animationImages[0]));

    NSAssert(1 < _imageCount,
             @"There needs to be at least two image animation files");
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = [UIColor whiteColor];

  [self setupIntroView];
  [self setupDummyPickerViewForTransition];
  [self initializeAnimationViews];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];

  /*
   * Autolayout has completed so this is where we have to calculate all the rice
   * papering... *grumble*
   */

  if (!_didRicePapering.value) {
    /*
     * viewDidLayoutSubviews gets called multiple times but we only really care
     * about the initial call during setup since we have static image animations
     */
    _didRicePapering.value = YES;

    [_animationViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx,
                                                  BOOL *stop) {

        if (!_ISA_(obj, FBOnboardingAnimationView)) {
          return;
        }

        FBOnboardingAnimationView *thisView = (FBOnboardingAnimationView *)obj;

        /*
         * Need to make sure the current view is visible so the blur effect can
         * be introduced appropriately
         */
        thisView.alpha = 1.0f;

        UIImage *stageOne = [thisView.backgroundView.image
              applyBlurWithRadius:3.0f
                        tintColor:[UIColor colorWithWhite:1.0f alpha:0.0f]
            saturationDeltaFactor:1.8f
                        maskImage:nil
                          atFrame:_titleView.frame];

        UIImage *stageTwo = [stageOne
              applyBlurWithRadius:3.0f
                        tintColor:[UIColor colorWithWhite:1.0f alpha:0.0f]
            saturationDeltaFactor:1.8f
                        maskImage:nil
                          atFrame:_introView.frame];

        thisView.backgroundView.image = stageTwo;

        /*
         * We revert back to being transparent unless it's the front view
         */
        thisView.alpha = (0 != idx) ? 0.0f : 1.0f;
    }];

    /*
     * We can now kick off the looped animation
     */
    [self startAnimation];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - View Initialization

- (void)setupIntroView {
  /*
   * Title message
   */
  _titleView = [[FBHeaderView alloc] init];
  [_titleView addToView:self.view];

  /*
   * Intro Button
   */
  _introButton = [FBChrome onboardingButtonWithTitle:nextOnboardingButtonText];
  [_introButton addTarget:self
                   action:@selector(handleButtonAction:)
         forControlEvents:UIControlEventTouchUpInside];

  /*
   * Intro Text
   */
  NSRange newline = [introText rangeOfString:@"\n"];
  NSString *makeArt = [NSString
      stringWithString:[introText substringToIndex:newline.location + 1]];

  NSMutableAttributedString *makeArtText =
      [[FBChrome attributedTextTitle:makeArt] mutableCopy];

  NSAttributedString *makeArtBody =
      [FBChrome attributedParagraphForOnboarding:
                    [introText substringFromIndex:newline.location + 1]];

  [makeArtText appendAttributedString:makeArtBody];

  _introTextLabel = [[UILabel alloc] init];
  _introTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
  _introTextLabel.backgroundColor = [UIColor clearColor];

  _introTextLabel.attributedText = makeArtText;
  _introTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
  _introTextLabel.numberOfLines = 0;
  [_introTextLabel sizeToFit];

  /*
   * Intro view
   */
  _introView = [[FBOnboardingPresentationView alloc]
      initWithViews:_introTextLabel, _introButton, nil];

  [self.view addSubview:_introView];

  [_introViewConstraints addObject:[_introView autoPinEdge:ALEdgeBottom
                                                    toEdge:ALEdgeBottom
                                                    ofView:self.view]];

  [_introViewConstraints addObject:[_introView autoPinEdge:ALEdgeLeft
                                                    toEdge:ALEdgeLeft
                                                    ofView:self.view]];

  [_introViewConstraints addObject:[_introView autoPinEdge:ALEdgeRight
                                                    toEdge:ALEdgeRight
                                                    ofView:self.view]];
}

- (void)setupDummyPickerViewForTransition {
  /*
   * This is an annoying hack to try and match the view controller animation
   * transition animation between this view controller and the onboarding
   * view controller.
   *
   * The presentation views are not setting their intrinsic height until after
   * the view controller animation delegate has finished its work. Therefore,
   * we have to recreate the same view so that we can animate properly.
   */

  /*
   * Palette Info Text
   */
  NSAttributedString *paletteInfoText =
      [FBChrome attributedParagraphForOnboarding:colorPickerText];

  _dummyPickerInfoTextLabel = [[UILabel alloc] init];
  _dummyPickerInfoTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
  _dummyPickerInfoTextLabel.backgroundColor = [UIColor clearColor];

  _dummyPickerInfoTextLabel.attributedText = paletteInfoText;
  _dummyPickerInfoTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
  _dummyPickerInfoTextLabel.numberOfLines = 0;
  _dummyPickerInfoTextLabel.alpha = 0.0f;
  [_dummyPickerInfoTextLabel sizeToFit];

  /*
   * Palette Info View
   */
  _dummyPickerInfoTextView = [[FBOnboardingPresentationView alloc]
      initWithViews:_dummyPickerInfoTextLabel, nil];

  [self.view addSubview:_dummyPickerInfoTextView];

  [_dummyPickerInfoTextViewConstraints
      addObject:[_dummyPickerInfoTextView autoPinEdge:ALEdgeTop
                                               toEdge:ALEdgeBottom
                                               ofView:self.view]];

  [_dummyPickerInfoTextViewConstraints
      addObject:[_dummyPickerInfoTextView autoPinEdge:ALEdgeLeft
                                               toEdge:ALEdgeLeft
                                               ofView:self.view]];

  [_dummyPickerInfoTextViewConstraints
      addObject:[_dummyPickerInfoTextView autoPinEdge:ALEdgeRight
                                               toEdge:ALEdgeRight
                                               ofView:self.view]];

  _dummyPickerInfoTextView.userInteractionEnabled = NO;
}

- (void)initializeAnimationViews {
  NSMutableArray *animationViewsAdd =
      [[NSMutableArray alloc] initWithCapacity:_imageCount];

  /*
   * Looping through all the image file names
   */
  for (size_t i = 0; i < _imageCount; i++) {
    UIImage *animationImage =
        (0 != strlen(animationImages[i]))
            ? [UIImage
                  imageNamed:[NSString stringWithCString:animationImages[i]
                                                encoding:NSUTF8StringEncoding]]
            : nil;

    FBOnboardingAnimationView *animationView =
        [[FBOnboardingAnimationView alloc]
            initWithBackgroundImage:animationImage];
    animationView.opaque = YES;
    animationView.backgroundColor = [UIColor clearColor];
    animationView.alpha = (_imageCount > (i + 1)) ? 0.0f : 1.0f;

    [self.view insertSubview:animationView atIndex:0];

    [animationView autoAlignAxisToSuperviewAxis:ALAxisVertical];
    [animationView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    //    [animationView autoPinEdge:ALEdgeBottom
    //                        toEdge:ALEdgeTop
    //                        ofView:_introView
    //                    withOffset:-20.0f];

    [animationViewsAdd insertObject:animationView atIndex:0];
  }

  _animationViews = [NSArray arrayWithArray:animationViewsAdd];
}

#pragma mark - Animations

- (void)startAnimation {
  self.animateOn = YES;

  /*
   * We have to grab the group here in order to halt threads waiting to yield to
   * this dispatch block completion
   */
  dispatch_group_enter(_animationYieldGroup);

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                 ^(void) {

      NSInteger direction = 1;
      NSUInteger cursor = 0, count = _animationViews.count;

      /*
       * Keep these around in case we have to do crazier animations in the
       * future
       */
      __block UIView *target = nil;

      while (self.animateOn) {
        /*
         * Enter the dispatch group and wait for the animation to complete
         */
        dispatch_group_enter(_animationActionGroup);

        /*
         * Have to pop onto the main thread/queue
         */
        dispatch_sync(dispatch_get_main_queue(), ^(void) {

            /*
             * Animate the unblurred portion
             */
            target = _animationViews[cursor + ((0 < direction) ? 1 : 0)];

            [UIView animateWithDuration:1.5f
                delay:(0 == cursor) ? 1.0f : 0.0f
                options:(UIViewAnimationOptionBeginFromCurrentState |
                         UIViewAnimationOptionCurveLinear)
                animations:^(void) {
                    target.alpha = (0 < direction) ? 1.0f : 0.0f;
                }
                completion:^(BOOL finished) {
                    if (finished) {
                      /*
                       * Signal the completion
                       */
                      dispatch_group_leave(_animationActionGroup);
                    }
                }];
        });

        /*
         * Wait till group is signalled before moving onto the next animation
         */
        dispatch_group_wait(_animationActionGroup, DISPATCH_TIME_FOREVER);

        /*
         * Since direction is init'd to 1 then we will end up counting up
         * to array.count - 1 and then counting back down to 0
         */
        cursor += direction;
        direction *= (0 == (cursor % (count - 1))) ? -1 : 1;
      }

      /*
       * Someone canceled the animation because we're transitioning
       */
      [_animationViews
          enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
              UIView *thisView = nil;
              if (_ISA_(obj, UIView)) {
                thisView = (UIView *)obj;
              }

              if (thisView && 0.0 < thisView.alpha) {
                dispatch_group_enter(_animationActionGroup);
                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    [UIView animateWithDuration:1.0f
                        delay:1.0f
                        options:(UIViewAnimationOptionBeginFromCurrentState)
                        animations:^(void) { thisView.alpha = 0.0; }
                        completion:^(BOOL finished) {
                            if (finished) {
                              /*
                               * Signal the completion
                               */
                              dispatch_group_leave(_animationActionGroup);
                              //                              NSLog(@"*
                              //                              Animation
                              //                              completed *");
                            }
                        }];
                });
              }
          }];

      dispatch_group_wait(_animationActionGroup, DISPATCH_TIME_FOREVER);
      dispatch_group_leave(_animationYieldGroup);

      //      dispatch_sync(dispatch_get_main_queue(),
      //                    ^(void) { NSLog(@"Done with all animations"); });
  });
}

- (void)animateOutBeforePoppingWithCompletion:(dispatch_block_t)completion {
  /*
   * First we animate the opacity of the button and text view out. Then we move
   * to stopping the animation and waiting for the stop to complete before we
   * move to transition to the other view controller being loaded after this.
   */
  [UIView animateWithDuration:0.17f
      delay:0.0f
      options:(UIViewAnimationOptionBeginFromCurrentState)
      animations:^(void) {
          _introTextLabel.alpha = 0.0f;
          _introButton.alpha = 0.0f;
      }
      completion:^(BOOL finished) {
          if (finished) {
            dispatch_async(dispatch_get_global_queue(
                               DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                           ^(void) {

                self.animateOn = NO;

                //                dispatch_sync(dispatch_get_main_queue(),
                //                              ^(void) { NSLog(@"Waiting
                //                              patiently"); });
                /*
                 * Since we've been having trouble with this cross-thread wait
                 * we'll safe gaurd this with a "lucky" soft timeout
                 */
                dispatch_time_t waitTimeout = dispatch_time(
                    DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC));
                if (0 !=
                    dispatch_group_wait(_animationYieldGroup, waitTimeout)) {
                  /*
                   * If we got here it's because the group leave was never
                   * called.
                   * We have to clean up otherwise weird errors abound...
                   */
                  dispatch_group_leave(_animationYieldGroup);
                }

                //                dispatch_sync(dispatch_get_main_queue(),
                //                              ^(void) { NSLog(@"Done
                //                              waiting"); });

                dispatch_sync(dispatch_get_main_queue(), ^(void) {
                    [FBUtils
                        doTransitionAnimationWithDuration:0.33f
                                               startDelay:0.0f
                                                 fromView:_introView
                                          fromConstraints:_introViewConstraints
                                                   toView:
                                                       _dummyPickerInfoTextView
                                            toConstraints:
                                                _dummyPickerInfoTextViewConstraints
                                           withCompletion:^(void) {
                                               if (completion) {
                                                 completion();
                                               }
                                           }];
                });
            });
          }
      }];
}

#pragma mark - Actions

- (void)handleButtonAction:(id)sender {
  if (sender == _introButton) {
    /*
     * Should probably turn off the button...
     */
    _introView.userInteractionEnabled = NO;

    [self animateOutBeforePoppingWithCompletion:^(void) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            /*
             * Kick our navigation controller to transition to the next view
             * controller
             */
            [(FBOnboardingNavigationController *)self
                    .navigationController transitionToOnboardingViewController];
        });
    }];

  } else {
    NSAssert(NO, @"No button for this transition intent");
  }
}

@end