//
//  FBOnboardingViewController.m
//  FrickBits
//
//  Created by Michael Van Milligan on 3/25/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBOnboardingViewController.h"
#import "FBOnboardingNavigationController.h"
#import "FBOnboardingVCAnimationDelegate.h"
#import "FBOnboardingBlobView.h"
#import "FBOnboardingColorScrollView.h"
#import "FBOnboardingColorView.h"
#import "FBOnboardingMapViewController.h"
#import "FBOnboardingPresentationView.h"
#import "FBOnboardingNoLocationView.h"
#import "FBOnboarding.h"
#import "FBColorPaletteManager.h"
#import "FBUtils.h"
#import "FBChrome.h"
#import "FBDialogView.h"
#import "FBHeaderView.h"
#import "FBDiaphanousView.h"
#import "FBFrickBitRecipe.h"

#import "T23AtomicBoolean.h"

#import "FBLocationManager.h"

static NSString *const colorPickerText =
    @"Choose a color. Find the palette that feels right for " @"you.";
static NSString *const locationAccessText =
    @"FRICKbits won't work without access to your location.";
static NSString *const nextOnboardingButtonText = @"NEXT";
static NSString *const backOnboardingButtonText = @"BACK";
static NSString *const cancelButtonText = @"CANCEL";
static NSString *const pickerButtonText = @"USE PALETTE";

typedef NS_ENUM(NSUInteger, FBOnboardingViewControllerState) {
  FBOnboardingViewControllerStateBeginning = 0,  // default
  FBOnboardingViewControllerStatePicker,
  FBOnboardingViewControllerStateLocationAccess,
  FBOnboardingViewControllerStateEnd = ~FBOnboardingViewControllerStateBeginning
};

@interface FBOnboardingViewController () <FBColorScrollViewDelegate>

/*
 * private
 */
@property(nonatomic, strong) FBHeaderView *titleView;

@property(nonatomic, strong) UIView *colorPickerView;
@property(nonatomic, strong) FBOnboardingColorScrollView *colorScrollView;
@property(nonatomic) NSUInteger colorScrollViewStartIndex;
@property(nonatomic, strong) UIView *blobViewFrame;
@property(nonatomic, strong) NSMutableArray *blobViewFrameConstraints;
@property(nonatomic, strong) UIView *blobViewContainer;
@property(nonatomic, strong) FBOnboardingBlobView *blobView;

@property(nonatomic, strong) FBOnboardingPresentationView *pickerInfoTextView;
@property(nonatomic, strong) NSMutableArray *pickerInfoTextViewConstraints;
@property(nonatomic, strong) UILabel *pickerInfoTextLabel;

@property(nonatomic, strong) FBOnboardingPresentationView *pickerView;
@property(nonatomic, strong) NSMutableArray *pickerViewConstraints;
@property(nonatomic, strong) UIView *pickerContainerView;
@property(nonatomic, strong) UIButton *cancelButton;
@property(nonatomic, strong) UIButton *pickerButton;
@property(nonatomic) BOOL shouldCancel;

@property(nonatomic, strong) FBOnboardingPresentationView *locationAccessView;
@property(nonatomic, strong) NSMutableArray *locationAccessViewConstraints;
@property(nonatomic, strong) UILabel *locationAccessTextLabel;
@property(nonatomic, strong) UIView *locationContainerView;
@property(nonatomic, strong) UIButton *locationNextButton;
@property(nonatomic, strong) UIButton *locationBackButton;

@property(nonatomic, strong) FBOnboardingNoLocationView *noLocationView;

@property(nonatomic, strong) UIView *greyScreen;

@property(nonatomic, strong) T23AtomicBoolean *firstAnimation;
@property(nonatomic, strong) T23AtomicBoolean *lastAnimation;
@property(nonatomic, strong) T23AtomicBoolean *inNoLocationErrorState;

@property(nonatomic) NSUInteger privPaletteIndex;

@property(nonatomic) NSUInteger initialState;

@property(nonatomic, strong) dispatch_group_t greyScreenAnimationGroup;

@end
@implementation FBOnboardingViewController

@synthesize privPaletteIndex = _privPaletteIndex;

- (NSUInteger)paletteIndex {
  return _privPaletteIndex;
}

- (BOOL)stuckInLocationPermissions {
  return _inNoLocationErrorState.value;
}

#pragma mark - Overrides
- (instancetype)init {
  if (self = [super init]) {
    _greyScreenAnimationGroup = dispatch_group_create();

    _initialState = FBOnboardingViewControllerStateBeginning;

    _presentedFromMenu = [[T23AtomicBoolean alloc] init];
    _firstAnimation = [[T23AtomicBoolean alloc] init];
    _firstAnimation.value = YES;
    _lastAnimation = [[T23AtomicBoolean alloc] init];
    _inNoLocationErrorState = [[T23AtomicBoolean alloc] init];

    _blobViewFrameConstraints = [[NSMutableArray alloc] init];
    _pickerInfoTextViewConstraints = [[NSMutableArray alloc] init];
    _pickerViewConstraints = [[NSMutableArray alloc] init];
    _locationAccessViewConstraints = [[NSMutableArray alloc] init];
  }
  return self;
}

- (instancetype)initAtStartingPoint {
  if (self = [self init]) {
    /* No need for change as of now */
  }
  return self;
}

- (instancetype)initAtPickerPointWithColorIndex:(NSUInteger)index {
  if (self = [self init]) {
    _colorScrollViewStartIndex = index;
    _initialState = FBOnboardingViewControllerStatePicker;
    [_presentedFromMenu setValue:YES];
  }

  return self;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];

  self.view.backgroundColor = [UIColor whiteColor];

  [self setupPresentationOfView];
}

- (void)dealloc {
  [self deregisterForLocationUpdates];
}

#pragma mark - View Initialization

- (void)setupPresentationOfView {
  /*
   * Title message
   */
  _titleView = [[FBHeaderView alloc] init];
  [_titleView addToView:self.view];
  [self.view bringSubviewToFront:_titleView];

  if (FBOnboardingViewControllerStateLocationAccess >= _initialState) {
    [self setupLocationAccessView];
  }

  if (FBOnboardingViewControllerStatePicker >= _initialState) {
    [self setupPickerView];
  }
}

- (void)setupPickerView {
  // container view to hold side-by-side buttons
  _pickerContainerView = [[FBDiaphanousView alloc] init];
  _pickerContainerView.translatesAutoresizingMaskIntoConstraints = NO;
  _pickerContainerView.backgroundColor = [UIColor clearColor];
  _pickerContainerView.alpha = 0.0f;

  _pickerContainerView.userInteractionEnabled =
      ((FBOnboardingViewControllerStatePicker == _initialState)) ? YES : NO;

  /*
   * Picker button
   */
  _pickerButton = [FBChrome onboardingButtonWithTitle:pickerButtonText];
  [_pickerButton addTarget:self
                    action:@selector(handleButtonAction:)
          forControlEvents:UIControlEventTouchUpInside];

  if (_presentedFromMenu.value) {
    /*
     * Cancel button
     */
    _cancelButton = [FBChrome onboardingButtonWithTitle:cancelButtonText];
    [_cancelButton addTarget:self
                      action:@selector(handleButtonAction:)
            forControlEvents:UIControlEventTouchUpInside];

    [_pickerContainerView addSubview:_cancelButton];
    [_pickerContainerView addSubview:_pickerButton];

    [_cancelButton autoPinEdge:ALEdgeLeft
                        toEdge:ALEdgeLeft
                        ofView:_pickerContainerView];

    [_pickerButton autoPinEdge:ALEdgeRight
                        toEdge:ALEdgeRight
                        ofView:_pickerContainerView];

    [_cancelButton autoPinEdge:ALEdgeRight
                        toEdge:ALEdgeLeft
                        ofView:_pickerButton
                    withOffset:-5.0f
                      relation:NSLayoutRelationEqual];

    [_cancelButton autoMatchDimension:ALDimensionWidth
                          toDimension:ALDimensionWidth
                               ofView:_pickerButton];

    [_pickerButton autoAlignAxis:ALAxisHorizontal
                toSameAxisOfView:_pickerContainerView];
    [_cancelButton autoAlignAxis:ALAxisHorizontal
                toSameAxisOfView:_pickerContainerView];
  } else {
    [_pickerContainerView addSubview:_pickerButton];

    [_pickerButton autoPinEdge:ALEdgeRight
                        toEdge:ALEdgeRight
                        ofView:_pickerContainerView];

    [_pickerButton autoPinEdge:ALEdgeLeft
                        toEdge:ALEdgeLeft
                        ofView:_pickerContainerView];

    [_pickerButton autoAlignAxis:ALAxisHorizontal
                toSameAxisOfView:_pickerContainerView];
  }

  [_pickerContainerView autoMatchDimension:ALDimensionHeight
                               toDimension:ALDimensionHeight
                                    ofView:_pickerButton
                                withOffset:0.0f
                                  relation:NSLayoutRelationEqual];

  /*
   * Palette Info Text
   */
  NSAttributedString *paletteInfoText =
      [FBChrome attributedParagraphForOnboarding:colorPickerText];

  _pickerInfoTextLabel = [[UILabel alloc] init];
  _pickerInfoTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
  _pickerInfoTextLabel.backgroundColor = [UIColor clearColor];

  _pickerInfoTextLabel.attributedText = paletteInfoText;
  _pickerInfoTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
  _pickerInfoTextLabel.numberOfLines = 0;
  _pickerInfoTextLabel.alpha =
      (FBOnboardingViewControllerStatePicker == _initialState) ? 1.0f : 0.0f;
  [_pickerInfoTextLabel sizeToFit];

  /*
   * Palette Info View
   */
  _pickerInfoTextView = [[FBOnboardingPresentationView alloc]
      initWithViews:_pickerInfoTextLabel, nil];

  [self.view addSubview:_pickerInfoTextView];

  [_pickerInfoTextViewConstraints
      addObject:[_pickerInfoTextView
                    autoPinEdge:((FBOnboardingViewControllerStatePicker ==
                                  _initialState)
                                     ? ALEdgeTop
                                     : ALEdgeBottom)
                         toEdge:ALEdgeBottom
                         ofView:self.view]];

  [_pickerInfoTextViewConstraints
      addObject:[_pickerInfoTextView autoPinEdge:ALEdgeLeft
                                          toEdge:ALEdgeLeft
                                          ofView:self.view]];

  [_pickerInfoTextViewConstraints
      addObject:[_pickerInfoTextView autoPinEdge:ALEdgeRight
                                          toEdge:ALEdgeRight
                                          ofView:self.view]];

  _pickerInfoTextView.userInteractionEnabled = NO;

  /*
   * Palette Chooser View
   */
  _pickerView = [[FBOnboardingPresentationView alloc]
      initWithViews:_pickerContainerView, nil];

  _pickerView.userInteractionEnabled = NO;

  [self.view addSubview:_pickerView];

  [_pickerViewConstraints addObject:[_pickerView autoPinEdge:ALEdgeTop
                                                      toEdge:ALEdgeBottom
                                                      ofView:self.view]];

  [_pickerViewConstraints addObject:[_pickerView autoPinEdge:ALEdgeLeft
                                                      toEdge:ALEdgeLeft
                                                      ofView:self.view]];

  [_pickerViewConstraints addObject:[_pickerView autoPinEdge:ALEdgeRight
                                                      toEdge:ALEdgeRight
                                                      ofView:self.view]];

  /*
   * Color Picker View
   */
  _colorPickerView = [[FBDiaphanousView alloc] init];
  _colorPickerView.translatesAutoresizingMaskIntoConstraints = NO;
  _colorPickerView.backgroundColor = [UIColor clearColor];

  [self.view addSubview:_colorPickerView];
  [self.view sendSubviewToBack:_colorPickerView];

  [_colorPickerView autoPinEdge:ALEdgeTop
                         toEdge:ALEdgeBottom
                         ofView:_titleView];

  [_colorPickerView autoPinEdge:ALEdgeBottom
                         toEdge:ALEdgeBottom
                         ofView:self.view];

  [_colorPickerView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view];

  [_colorPickerView autoPinEdge:ALEdgeRight
                         toEdge:ALEdgeRight
                         ofView:self.view];

  /*
   * ScrollView
   */
  _colorScrollView =
      (FBOnboardingViewControllerStatePicker == _initialState)
          ? [[FBOnboardingColorScrollView alloc]
                initWithStartingColorIndex:_colorScrollViewStartIndex]
          : [[FBOnboardingColorScrollView alloc] init];

  _colorScrollView.colorDelegate = self;
  _colorScrollView.backgroundColor = [UIColor clearColor];

  _colorScrollView.userInteractionEnabled =
      (FBOnboardingViewControllerStatePicker == _initialState) ? YES : NO;

  [_colorPickerView addSubview:_colorScrollView];

  [_colorScrollView autoPinEdge:ALEdgeTop
                         toEdge:ALEdgeTop
                         ofView:_colorPickerView];

  [_colorScrollView autoPinEdge:ALEdgeLeft
                         toEdge:ALEdgeLeft
                         ofView:_colorPickerView];

  [_colorScrollView autoPinEdge:ALEdgeRight
                         toEdge:ALEdgeRight
                         ofView:_colorPickerView];

  [_colorScrollView autoSetDimension:ALDimensionHeight
                              toSize:FBOnboardingColorViewHeight];

  /*
   * Blob view frame; this view sits between the scroll and the presentation
   * views
   */
  _blobViewFrame = [[UIView alloc] init];
  _blobViewFrame.translatesAutoresizingMaskIntoConstraints = NO;
  _blobViewFrame.backgroundColor = [UIColor clearColor];

  [self.view addSubview:_blobViewFrame];
  [self.view sendSubviewToBack:_blobViewFrame];

  [_blobViewFrame autoPinEdge:ALEdgeLeft
                       toEdge:ALEdgeLeft
                       ofView:_colorPickerView];

  [_blobViewFrame autoPinEdge:ALEdgeRight
                       toEdge:ALEdgeRight
                       ofView:_colorPickerView];

  [_blobViewFrameConstraints
      addObject:[_blobViewFrame autoPinEdge:ALEdgeTop
                                     toEdge:ALEdgeBottom
                                     ofView:_colorScrollView]];

  [_blobViewFrameConstraints
      addObject:[_blobViewFrame autoPinEdge:ALEdgeBottom
                                     toEdge:ALEdgeTop
                                     ofView:_pickerView]];

  /*
   * Blob view container
   */
  _blobViewContainer = [[FBDiaphanousView alloc] init];
  _blobViewContainer.translatesAutoresizingMaskIntoConstraints = NO;
  _blobViewContainer.backgroundColor = [UIColor clearColor];

  [_blobViewFrame addSubview:_blobViewContainer];
  [_blobViewFrame sendSubviewToBack:_blobViewContainer];

  [_blobViewContainer autoSetDimension:ALDimensionHeight
                                toSize:FBOnboardingBlobViewSize];
  [_blobViewContainer autoSetDimension:ALDimensionWidth
                                toSize:FBOnboardingBlobViewSize];

  [_blobViewContainer autoCenterInSuperview];

  /*
   * Blob view
   */
  _blobView = [[FBOnboardingBlobView alloc] init];
  _blobView.backgroundColor = [UIColor clearColor];

  [_blobViewContainer addSubview:_blobView];
}

- (void)setupLocationAccessView {
  /*
   * Back Button
   */
  _locationBackButton =
      [FBChrome onboardingButtonWithTitle:backOnboardingButtonText];
  [_locationBackButton addTarget:self
                          action:@selector(handleButtonAction:)
                forControlEvents:UIControlEventTouchUpInside];

  /*
   * Next Button
   */
  _locationNextButton =
      [FBChrome onboardingButtonWithTitle:nextOnboardingButtonText];
  [_locationNextButton addTarget:self
                          action:@selector(handleButtonAction:)
                forControlEvents:UIControlEventTouchUpInside];

  /*
   * Dummy container UIView
   */
  _locationContainerView = [[FBDiaphanousView alloc] init];
  _locationContainerView.translatesAutoresizingMaskIntoConstraints = NO;
  _locationContainerView.backgroundColor = [UIColor clearColor];
  _locationContainerView.alpha = 0.0f;

  [_locationContainerView addSubview:_locationBackButton];
  [_locationContainerView addSubview:_locationNextButton];

  [_locationBackButton autoPinEdge:ALEdgeLeft
                            toEdge:ALEdgeLeft
                            ofView:_locationContainerView];

  [_locationNextButton autoPinEdge:ALEdgeRight
                            toEdge:ALEdgeRight
                            ofView:_locationContainerView];

  [_locationBackButton autoPinEdge:ALEdgeRight
                            toEdge:ALEdgeLeft
                            ofView:_locationNextButton
                        withOffset:-5.0f
                          relation:NSLayoutRelationEqual];

  [_locationBackButton autoMatchDimension:ALDimensionWidth
                              toDimension:ALDimensionWidth
                                   ofView:_locationNextButton];

  [_locationNextButton autoAlignAxis:ALAxisHorizontal
                    toSameAxisOfView:_locationContainerView];
  [_locationBackButton autoAlignAxis:ALAxisHorizontal
                    toSameAxisOfView:_locationContainerView];

  [_locationContainerView autoMatchDimension:ALDimensionHeight
                                 toDimension:ALDimensionHeight
                                      ofView:_locationBackButton
                                  withOffset:0.0f
                                    relation:NSLayoutRelationEqual];

  /*
   * Location Access Text
   */
  NSAttributedString *accessText =
      [FBChrome attributedParagraphForOnboarding:locationAccessText];

  _locationAccessTextLabel = [[UILabel alloc] init];
  _locationAccessTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
  _locationAccessTextLabel.backgroundColor = [UIColor clearColor];

  _locationAccessTextLabel.attributedText = accessText;
  _locationAccessTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
  _locationAccessTextLabel.numberOfLines = 0;
  [_locationAccessTextLabel sizeToFit];
  _locationAccessTextLabel.alpha = 0.0f;

  /*
   * Location Access View
   */
  _locationAccessView = [[FBOnboardingPresentationView alloc]
      initWithViews:_locationAccessTextLabel, _locationContainerView, nil];

  [self.view addSubview:_locationAccessView];

  [_locationAccessViewConstraints
      addObject:[_locationAccessView autoPinEdge:ALEdgeTop
                                          toEdge:ALEdgeBottom
                                          ofView:self.view]];

  [_locationAccessViewConstraints
      addObject:[_locationAccessView autoPinEdge:ALEdgeLeft
                                          toEdge:ALEdgeLeft
                                          ofView:self.view]];

  [_locationAccessViewConstraints
      addObject:[_locationAccessView autoPinEdge:ALEdgeRight
                                          toEdge:ALEdgeRight
                                          ofView:self.view]];

  /*
   * Grey screen for map transition
   */
  _greyScreen = [[UIView alloc] init];
  _greyScreen.translatesAutoresizingMaskIntoConstraints = NO;

  _greyScreen.backgroundColor = [UIColor darkGrayColor];
  _greyScreen.alpha = 0.0f;

  [self.view addSubview:_greyScreen];

  [_greyScreen autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view];
  [_greyScreen autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.view];
  [_greyScreen autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view];
  [_greyScreen autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view];

  /*
   * No Location Error View
   */
  _noLocationView = [[FBOnboardingNoLocationView alloc] init];
  _noLocationView.alpha = 0.0f;

  [self.view addSubview:_noLocationView];

  [_noLocationView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.view];
  [_noLocationView autoPinEdge:ALEdgeBottom
                        toEdge:ALEdgeBottom
                        ofView:self.view];
  [_noLocationView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.view];
  [_noLocationView autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.view];
}

#pragma mark - Actions

- (void)handleButtonAction:(id)sender {
  if (sender == _cancelButton) {
    _shouldCancel = YES;
    [self doBackToMenuOrLocationTransition];
  } else if (sender == _pickerButton) {
    _shouldCancel = NO;
    [self doBackToMenuOrLocationTransition];
  } else if (sender == _locationNextButton) {
    [self doLocationDialogTransition];
  } else if (sender == _locationBackButton) {
    [self doBackToPickerTransition];
  } else {
    NSAssert(NO, @"No button for this transition intent");
  }
}

#pragma mark - Transitions

- (void)doInitialPickerTransition {
  [FBUtils doTransitionAnimationWithDuration:0.33f
                                  startDelay:0.0f
                                    fromView:nil
                             fromConstraints:nil
                                      toView:_pickerInfoTextView
                               toConstraints:_pickerInfoTextViewConstraints
                              withCompletion:^(void) {
                                  [FBUtils animateView:_pickerInfoTextLabel
                                             withAlpha:1.0f
                                        withCompletion:nil];

                                  [_colorScrollView
                                      animatePickerInWithCompletion:^(void) {
                                          _colorScrollView
                                              .userInteractionEnabled = YES;
                                      }];
                              }];
}

- (void)doPickerTransitionWithCompletion:(dispatch_block_t)completion {
  [FBUtils animateView:_pickerInfoTextLabel
             withAlpha:0.0f
        withCompletion:^(void) {
            dispatch_block_t additionalCompletion = ^void(void) {
                [FBUtils animateView:_pickerContainerView
                           withAlpha:1.0f
                      withCompletion:completion];
            };

            [FBUtils
                doTransitionAnimationWithDuration:0.33f
                                       startDelay:0.0f
                                         fromView:_pickerInfoTextView
                                  fromConstraints:_pickerInfoTextViewConstraints
                                           toView:_pickerView
                                    toConstraints:_pickerViewConstraints
                                   withCompletion:additionalCompletion];
        }];
}

- (void)doBackToMenuOrLocationTransition {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                 ^(void) {

      dispatch_group_t transitionAnimationGroup = dispatch_group_create();

      dispatch_sync(dispatch_get_main_queue(), ^(void) {

          dispatch_group_enter(transitionAnimationGroup);
          [_colorScrollView animatePickerOutWithCompletion:^(void) {
              dispatch_group_leave(transitionAnimationGroup);
          }];

          dispatch_group_enter(transitionAnimationGroup);
          [UIView animateWithDuration:0.17f
              delay:0.0f
              options:(UIViewAnimationOptionBeginFromCurrentState)
              animations:^(void) { _pickerContainerView.alpha = 0.0f; }
              completion:^(BOOL finished) {
                  if (finished) {
                    if (_presentedFromMenu.value) {
                      // Change Palette menu item
                      [self doBackToMenuTransitionWithCompletion:^(void) {
                          dispatch_group_leave(transitionAnimationGroup);
                      }];
                    } else {
                      // normal onboarding, prompts for location access
                      [self doLocationAccessTransitionWithCompletion:^(void) {
                          dispatch_group_leave(transitionAnimationGroup);
                      }];
                    }
                  }
              }];
      });

      dispatch_group_wait(transitionAnimationGroup, DISPATCH_TIME_FOREVER);

      dispatch_async(dispatch_get_main_queue(), ^(void) {
          if (_presentedFromMenu.value) {
            [self signalOnboardingNavigationControllerWithFailure:NO];
          }
      });
  });
}

- (void)doBackToMenuTransitionWithCompletion:(dispatch_block_t)completion {
  [UIView animateWithDuration:0.33f
      delay:0.0f
      options:(UIViewAnimationOptionBeginFromCurrentState)
      animations:^(void) {

          [_pickerView.superview removeConstraints:_pickerViewConstraints];
          [_pickerViewConstraints removeAllObjects];

          [_pickerViewConstraints
              addObject:[_pickerView autoPinEdge:ALEdgeBottom
                                          toEdge:ALEdgeBottom
                                          ofView:_pickerView.superview]];

          [_pickerViewConstraints
              addObject:[_pickerView autoPinEdge:ALEdgeLeft
                                          toEdge:ALEdgeLeft
                                          ofView:_pickerView.superview]];

          [_pickerViewConstraints
              addObject:[_pickerView autoPinEdge:ALEdgeRight
                                          toEdge:ALEdgeRight
                                          ofView:_pickerView.superview]];
          [_pickerView.superview layoutIfNeeded];
      }
      completion:^(BOOL finished) {
          if (completion) {
            completion();
          }
      }];
}

- (void)doLocationAccessTransitionWithCompletion:(dispatch_block_t)completion {
  /*
   * We don't need to hold up that global dispatch queue anymore
   */
  completion();

  dispatch_block_t locationAnimationCompletion = ^void(void) {
      [FBUtils animateView:_locationContainerView
                 withAlpha:1.0f
            withCompletion:nil];
      [FBUtils animateView:_locationAccessTextLabel
                 withAlpha:1.0f
            withCompletion:nil];
  };

  dispatch_block_t animationBlock = ^void(void) {

      [_blobViewFrame.superview removeConstraints:_blobViewFrameConstraints];
      [_blobViewFrameConstraints removeAllObjects];

      [_blobViewFrameConstraints
          addObject:[_blobViewFrame autoPinEdge:ALEdgeTop
                                         toEdge:ALEdgeBottom
                                         ofView:_titleView]];

      [_blobViewFrameConstraints
          addObject:[_blobViewFrame autoPinEdge:ALEdgeBottom
                                         toEdge:ALEdgeTop
                                         ofView:_locationAccessView]];

      [_blobViewFrame.superview layoutIfNeeded];
  };

  [_blobViewFrame.superview layoutIfNeeded];
  [FBUtils doTransitionAnimationWithDuration:0.33f
                                    startDelay:0.5f
                                      fromView:_pickerView
                               fromConstraints:_pickerViewConstraints
                                        toView:_locationAccessView
                                 toConstraints:_locationAccessViewConstraints
      havingConcurrentAutoLayoutAnimationBlock:animationBlock
                                withCompletion:locationAnimationCompletion];
}

- (void)doBackToPickerTransition {
  // Need to reset this so that we transition properly
  _firstAnimation.value = YES;

  [UIView animateWithDuration:0.17f
      delay:0.0f
      options:(UIViewAnimationOptionBeginFromCurrentState)
      animations:^(void) {
          _locationAccessTextLabel.alpha = 0.0f;
          _locationContainerView.alpha = 0.0f;
      }
      completion:^(BOOL finished) {
          if (finished) {
            dispatch_block_t completion = ^void(void) {
                [FBUtils animateView:_pickerContainerView
                           withAlpha:1.0f
                      withCompletion:nil];
                [_colorScrollView animatePickerInFancyWithCompletion:^(void){}];
            };

            dispatch_block_t animationBlock = ^void(void) {

                [_blobViewFrame.superview
                    removeConstraints:_blobViewFrameConstraints];
                [_blobViewFrameConstraints removeAllObjects];

                [_blobViewFrameConstraints
                    addObject:[_blobViewFrame autoPinEdge:ALEdgeTop
                                                   toEdge:ALEdgeBottom
                                                   ofView:_colorScrollView]];

                [_blobViewFrameConstraints
                    addObject:[_blobViewFrame autoPinEdge:ALEdgeBottom
                                                   toEdge:ALEdgeTop
                                                   ofView:_pickerView]];

                [_blobViewFrame.superview layoutIfNeeded];
            };

            [_blobViewFrame.superview layoutIfNeeded];
            [FBUtils doTransitionAnimationWithDuration:0.33f
                                              startDelay:0.0f
                                                fromView:_locationAccessView
                                         fromConstraints:
                                             _locationAccessViewConstraints
                                                  toView:_pickerView
                                           toConstraints:_pickerViewConstraints
                havingConcurrentAutoLayoutAnimationBlock:animationBlock
                                          withCompletion:completion];
          }
      }];
}

- (void)doLocationDialogTransition {
  [UIView animateWithDuration:0.17f
      delay:0.0f
      options:(UIViewAnimationOptionBeginFromCurrentState)
      animations:^(void) {
          _locationAccessTextLabel.alpha = 0.0f;
          _locationContainerView.alpha = 0.0f;
      }
      completion:^(BOOL finished) {
          if (finished) {
            [_blobViewFrame.superview layoutIfNeeded];
            [_locationAccessView.superview layoutIfNeeded];
            [UIView animateWithDuration:0.17f
                delay:0.0f
                options:(UIViewAnimationOptionBeginFromCurrentState)
                animations:^(void) {

                    [_locationAccessView.superview
                        removeConstraints:_locationAccessViewConstraints];
                    [_locationAccessViewConstraints removeAllObjects];

                    [_locationAccessViewConstraints
                        addObject:[_locationAccessView
                                      autoPinEdge:ALEdgeTop
                                           toEdge:ALEdgeBottom
                                           ofView:_locationAccessView
                                                      .superview]];

                    [_locationAccessViewConstraints
                        addObject:[_locationAccessView
                                      autoPinEdge:ALEdgeLeft
                                           toEdge:ALEdgeLeft
                                           ofView:_locationAccessView
                                                      .superview]];

                    [_locationAccessViewConstraints
                        addObject:[_locationAccessView
                                      autoPinEdge:ALEdgeRight
                                           toEdge:ALEdgeRight
                                           ofView:_locationAccessView
                                                      .superview]];

                    [_locationAccessView.superview layoutIfNeeded];

                    [_blobViewFrame.superview
                        removeConstraints:_blobViewFrameConstraints];
                    [_blobViewFrameConstraints removeAllObjects];

                    [_blobViewFrameConstraints
                        addObject:[_blobViewFrame autoPinEdge:ALEdgeTop
                                                       toEdge:ALEdgeTop
                                                       ofView:self.view]];

                    [_blobViewFrameConstraints
                        addObject:[_blobViewFrame autoPinEdge:ALEdgeBottom
                                                       toEdge:ALEdgeBottom
                                                       ofView:self.view]];

                    [_blobViewFrame.superview layoutIfNeeded];
                }
                completion:^(BOOL finished) {

                    if (finished) {
                      /*
                       * It's possible that after invoking the location manager
                       * that it could immediately call the delegate and then
                       * our animations would be messed up. So we use a group to
                       * sync on. Then we leave the group to let the animation
                       * complete. However, this shouldn't ever get tripped but
                       * you never know what bit rot faster processors can do to
                       * your flow!
                       */
                      dispatch_group_enter(_greyScreenAnimationGroup);

                      [self registerForLocationUpdates];

                      FBLocationManager *lm =
                          [FBLocationManager sharedInstance];

                      CLAuthorizationStatus authStatus = lm.authorizationStatus;
                      UIBackgroundRefreshStatus bgStatus =
                          lm.locationBackgroundRefreshStatus;

                      // NSLog(@"authStatus: %d, bgStatus: %d", authStatus,
                      // bgStatus);

                      if (kCLAuthorizationStatusAuthorized == authStatus &&
                          UIBackgroundRefreshStatusAvailable == bgStatus) {
                        /*
                         * User already went through and OK'd the app
                         * to use location services and allows for
                         * background updates.
                         */

                        [self doLastViewTransition];
                        dispatch_group_leave(_greyScreenAnimationGroup);
                      } else if (kCLAuthorizationStatusAuthorized !=
                                     authStatus &&
                                 kCLAuthorizationStatusNotDetermined !=
                                     authStatus) {
                        /*
                         * User explicitly turned off location services
                         * and therefore application won't work.
                         */

                        [self doNoLocationErrorTransition];
                        dispatch_group_leave(_greyScreenAnimationGroup);
                      } else if (UIBackgroundRefreshStatusAvailable !=
                                 bgStatus) {
                        /*
                         * User explicitly turned off background
                         * updates and therefore application won't work.
                         */

                        [self doNoLocationErrorTransition];
                        dispatch_group_leave(_greyScreenAnimationGroup);
                      } else {
                        /*
                         * User hasn't been prompted yet for location
                         * services authorization.
                         */

                        [lm requestAuthorization];

                        [FBUtils animateView:_greyScreen
                                   withAlpha:0.75f
                              withCompletion:^(void) {
                                  dispatch_group_leave(
                                      _greyScreenAnimationGroup);
                              }];
                      }
                    }
                }];
          }
      }];
}

- (void)doNoLocationErrorTransition {
  if (!(_lastAnimation.value)) {
    /*
     * This is to stop double animating when the location manager calls back
     * even if the authorization is already set as being authorized. We'll be
     * getting called back twice.
     */
    _lastAnimation.value = YES;
    _inNoLocationErrorState.value = YES;

    [UIView animateWithDuration:0.17f
        delay:0.0f
        options:(UIViewAnimationOptionBeginFromCurrentState)
        animations:^(void) {
            _greyScreen.alpha = 0.0f;
            _blobView.alpha = 0.0f;
            _noLocationView.alpha = 1.0f;
        }
        completion:^(BOOL finished) {
            if (finished) {
              [_noLocationView doNoLocationErrorTransitionWithCompletion:nil];
            }
        }];
  }
}

- (void)doLastViewTransition {
  if (!(_lastAnimation.value)) {
    /*
     * This is to stop double animating when the location manager calls back
     * even if the authorization is already set as being authorized. We'll be
     * getting called back twice.
     */
    _lastAnimation.value = YES;

    if (FBOnboardingViewControllerStateBeginning == _initialState) {
      [UIView animateWithDuration:0.17f
          delay:0.0f
          options:(UIViewAnimationOptionBeginFromCurrentState)
          animations:^(void) { _greyScreen.alpha = 0.0f; }
          completion:^(BOOL finished) {
              if (finished) {
                [UIView animateWithDuration:1.0f
                    delay:0.0f
                    options:(UIViewAnimationOptionBeginFromCurrentState |
                             UIViewAnimationOptionCurveLinear)
                    animations:^(void) {
                        _blobView.transform = CGAffineTransformScale(
                            CGAffineTransformIdentity, 0.01f, 0.01f);
                    }
                    completion:^(BOOL finished) {
                        if (finished) {
                          _blobView.alpha = 0.0f;
                          [self signalOnboardingNavigationControllerWithFailure:
                                    NO];
                        }
                    }];
              }
          }];
    } else {
      /* We're coming into this already completing color picking so no need
       * for showing the map view transition or blob transform */
      [self signalOnboardingNavigationControllerWithFailure:NO];
    }
  }
}

- (void)signalOnboardingNavigationControllerWithFailure:(BOOL)failure {
  if (_shouldCancel) {
    [(FBOnboardingNavigationController *)self.navigationController cancel];
  } else {
    FBColorPalette *selectedPalette = [[FBColorPalette alloc]
          initWithSeedColor:[[FBColorPaletteManager sharedInstance]
                                getHeroColorForIndex:_privPaletteIndex]
              primaryColors:[[FBColorPaletteManager sharedInstance]
                                getPrimaryPaletteForIndex:_privPaletteIndex]
        complementaryColors:
            [[FBColorPaletteManager sharedInstance]
                getComplementPaletteForIndex:_privPaletteIndex]];
    selectedPalette.index = _privPaletteIndex;

    // persist the chosen palette
    [FBColorPaletteManager sharedInstance].colorPalette = selectedPalette;
    [[FBColorPaletteManager sharedInstance] savePalette];

    if (!failure) {
      [(FBOnboardingNavigationController *)self.navigationController
          transitionToMapViewControllerWithColorPalette:selectedPalette];
    } else {
      [(FBOnboardingNavigationController *)self.navigationController
          didTransitionToNoLocationViewWithColorPalette:selectedPalette];
    }
  }
}

#pragma mark - FBColorScrollViewDelegate

- (void)colorScrollViewIsAnimating:
            (FBOnboardingColorScrollView *)colorScrollView {
  if ([_colorScrollView isEqual:colorScrollView]) {
    _pickerView.userInteractionEnabled = NO;
  }
}

- (void)colorScrollViewAnimationHalted:
            (FBOnboardingColorScrollView *)colorScrollView {
  if ([_colorScrollView isEqual:colorScrollView]) {
    _pickerView.userInteractionEnabled = YES;
  }
}

- (void)colorScrollViewDidSelectPaletteAtIndex:(NSUInteger)idx {
  _pickerView.userInteractionEnabled = NO;

  dispatch_async(dispatch_get_main_queue(), ^(void) {

      _privPaletteIndex = idx;
      if (_colorScrollView.userInteractionEnabled) {
        _colorScrollView.userInteractionEnabled = NO;
        if (!_firstAnimation.value) {
          [_blobView animateBitsOutWithCompletion:^(void) {
              [_blobView
                  animateBitsInWithPaletteIndex:idx
                                  andCompletion:^(void) {
                                      _colorScrollView.userInteractionEnabled =
                                          YES;
                                      _pickerView.userInteractionEnabled = YES;
                                  }];
          }];
        } else {
          [self doPickerTransitionWithCompletion:^(void) {
              [_blobView animateBitsOutWithCompletion:^(void) {
                  [_blobView
                      animateBitsInWithPaletteIndex:idx
                                      andCompletion:^(void) {
                                          _colorScrollView
                                              .userInteractionEnabled = YES;
                                          _pickerView.userInteractionEnabled =
                                              YES;
                                      }];
              }];
          }];
          _firstAnimation.value = NO;
        }
      }
  });
}

#pragma mark -

- (void)registerForLocationUpdates {
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(handleFBLocationManagerAuthChange:)
             name:kFBLocationManagerAuthorizationChangedNotification
           object:nil];

  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(handleFBLocationManagerError:)
             name:kFBLocationManagerDidFailWithErrorNotification
           object:nil];
}

- (void)deregisterForLocationUpdates {
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:kFBLocationManagerAuthorizationChangedNotification
              object:nil];

  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:kFBLocationManagerDidFailWithErrorNotification
              object:nil];
}

#pragma mark - FBLocationManager Notification Handlers

- (void)handleFBLocationManagerAuthChange:(NSNotification *)notification {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                           0x0),
                 ^(void) {

      dispatch_group_wait(_greyScreenAnimationGroup, DISPATCH_TIME_FOREVER);

      dispatch_async(dispatch_get_main_queue(), ^(void) {

          id note = [notification object];

          NSAssert(
              _ISA_(note, NSNumber),
              @"FBLocationManager protocol contract broken, not a NSNumber");

          NSNumber *authChange = (NSNumber *)note;
          NSUInteger authorizationValue = 0;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
          authorizationValue = kCLAuthorizationStatusAuthorizedAlways;
#else
                                        authorizationValue =
                                            kCLAuthorizationStatusAuthorized;
#endif
          if (authorizationValue == [authChange integerValue] &&
              UIBackgroundRefreshStatusAvailable ==
                  [FBLocationManager sharedInstance]
                      .locationBackgroundRefreshStatus) {
            [self doLastViewTransition];
          } else if (kCLAuthorizationStatusNotDetermined !=
                     [authChange integerValue]) {
            [self doNoLocationErrorTransition];
          }
      });
  });
}

- (void)handleFBLocationManagerError:(NSNotification *)notification {
  dispatch_async(
      dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0x0), ^(void) {

          dispatch_group_wait(_greyScreenAnimationGroup, DISPATCH_TIME_FOREVER);

          dispatch_async(dispatch_get_main_queue(), ^(void) {

              id note = [notification object];

              NSAssert(
                  _ISA_(note, NSError),
                  @"FBLocationManager protocol contract broken, not a NSError");

              NSError *error = (NSError *)note;

              if (error) {
                [self doNoLocationErrorTransition];
              }
          });
      });
}

@end
