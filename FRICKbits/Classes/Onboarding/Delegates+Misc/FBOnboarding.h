//
// Created by Matt McGlincy on 4/24/14.
// Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBColorPalette.h"

// FBOnboardingFrickBlockLayer Constants
#define FBOnboardingFrickBlockLayerMinBorderWhite (0.4f)
#define FBOnboardingFrickBlockLayerMaxBorderWhite (0.4f)
#define FBOnboardingFrickBlockLayerQuadInset (1.0f)
#define FBOnboardingFrickBlockLayerGradientAlpha (0.2f)
#define FBOnboardingFrickBlockLayerImageAlpha (0.4f)
#define FBOnboardingFrickBlockLayerColorShift (0.1f)
#define FBOnboardingFrickBlockLayerJiggleRange (2)

// FBOnboardingFrickColumnLayer Constants
#define FBOnboardingFrickColumnLayerStepTime (90)
#define FBOnboardingFrickColumnLayerStartDuration (330)
#define FBOnboardingFrickColumnLayerStepDuration (30)
#define FBOnboardingFrickColumnLayerLowerBoundTime (150)
#define FBOnboardingFrickColumnLayerDetailProbability (60)
#define FBOnboardingFrickColumnLayerDetailWidth (15.0f)
#define FBOnboardingFrickColumnLayerDetailOffset (2.0f)
#define FBOnboardingFrickColumnLayerDetailOffsetDistro (20)
#define FBOnboardingFrickColumnLayerNumberUpperBoundHeight (10.0f)
#define FBOnboardingFrickColumnLayerNumberLowerBoundHeight (5.0f)
#define FBOnboardingFrickColumnLayerNumberLowerBoundWidth (10.0f)

// FBOnboardingBlobView Constants
#define FBOnboardingBlobViewRadius (85.0f)
#define FBOnboardingBlobViewSize ((FBOnboardingBlobViewRadius * 3.0f) + 10.0f)

// FBOnboardingBlobMaskView Constants
#define FBOnboardingBlobMaskViewFrickBlockLevels (5)
#define FBOnboardingBlobMaskViewFrickBlockMinThickness (5.0f)
#define FBOnboardingBlobMaskViewFrickBlockJiggle (7.0f)
#define FBOnboardingBlobMaskViewFrickBlockShift (180.0f)
#define FBOnboardingBlobMaskViewRadius FBOnboardingBlobViewRadius
#define FBOnboardingBlobMaskViewFrickBlockWidth (20.0f)
#define FBOnboardingBlobMaskViewFrickBlockWidthHalf                            \
  (FBOnboardingBlobMaskViewFrickBlockWidth / 2.0f)
#define FBOnboardingBlobMaskViewFrickBlockOffsetCenter (50.0f)
#define FBOnboardingBlobMaskViewFrickBlockDistro (0.25f)

// FBOnboardingColorScrollView Constants
#define FBOnboardingColorScrollViewAnimationDownIncrease (20.0f)
#define FBOnboardingColorScrollViewAnimationUpDecrease (1.0f)
#define FBOnboardingColorScrollViewAnimationDownDuration (0.09f)
#define FBOnboardingColorScrollViewAnimationFinishDelay (0.06f)
#define FBOnboardingColorScrollViewMiddleAnimationDelay (0.06f)
#define FBOnboardingColorScrollViewMiddleAnimationUpDuration (0.33f)
#define FBOnboardingColorScrollViewSideAnimationDelay (0.03f)
#define FBOnboardingColorScrollViewSideAnimationUpDuration (0.17f)

// FBOnboardingColorView
#define FBOnboardingColorViewWidth (20.0f)
#define FBOnboardingColorViewHeight (100.0f)
#define FBOnboardingColorViewSmallHeight (40.0f)
#define FBOnboardingColorViewMediumHeight (60.0f)
#define FBOnboardingColorViewLargeHeight (80.0f)
#define FBOnboardingColorViewExtraLargeHeight = FBOnboardingColorViewHeight;
#define FBOnboardingColorViewDefaultAnimateDuration (0.1f)

@interface FBOnboarding : NSObject

// has user completed onboarding?
+ (BOOL)onboardingCompleted;

// mark onboarding complete
+ (void)setOnboardingCompleted:(BOOL)completed;

// do all the "we're done onboarding now" logic, including saving the palette
+ (void)finishOnboardingWithColorPalette:(FBColorPalette *)colorPalette;

// Have we notified the user about having enough points of interest?
+ (BOOL)onboardingLocalNotificationCompleted;

// Mark that we've notified the user about having enough points of interest
+ (void)setOnboardingLocalNotificationCompleted:(BOOL)completed;

// Send local notification telling there are enough points of interest
+ (void)sendLocalNotification;

@end