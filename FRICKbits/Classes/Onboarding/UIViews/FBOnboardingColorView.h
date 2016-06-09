//
//  FBOnboardingColorView.h
//  FRICKbits
//
//  Created by Michael Van Milligan on 5/20/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "FBOnboarding.h"

typedef NS_ENUM(NSInteger, FBOnboardingColorScrollViewBitDistance) {
  FBOnboardingColorScrollViewNear = (NSInteger)(FBOnboardingColorViewWidth / 2),
  FBOnboardingColorScrollViewClose = (NSInteger)(FBOnboardingColorViewWidth /
                                                 2) *
                                     3,
  FBOnboardingColorScrollViewFar = (NSInteger)(FBOnboardingColorViewWidth / 2) *
                                   5
};

@protocol FBOnboardingColorViewDelegate <NSObject>
- (void)touchEventForColorView:(id)colorView;
@end

@interface FBOnboardingColorView : UIView

@property(nonatomic, weak) id<FBOnboardingColorViewDelegate> delegate;

@property(nonatomic, strong) UIColor *color;
@property(nonatomic) NSInteger colorIndex;
@property(nonatomic, strong) UIView *exposedView;
@property(nonatomic, readonly) BOOL isAnimating;

- (id)initWithSize:(CGSize)size
         withColor:(UIColor *)color
     andColorIndex:(NSInteger)colorIndex;

- (void)animateToSize:(CGFloat)height;
- (void)animateToSize:(CGFloat)height withDuration:(CGFloat)duration;

- (void)animateToSize:(CGFloat)height
       withCompletion:(dispatch_block_t)completion;
- (void)animateToSize:(CGFloat)height
         withDuration:(CGFloat)duration
        andCompletion:(dispatch_block_t)completion;

@end
