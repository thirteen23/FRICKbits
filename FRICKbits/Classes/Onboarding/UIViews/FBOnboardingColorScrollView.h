//
//  FBOnboardingColorScrollView.h
//  FRICKbits
//
//  Created by Michael Van Milligan on 5/20/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FBOnboardingColorScrollView;

@protocol FBColorScrollViewDelegate <NSObject>

- (void)colorScrollViewDidSelectPaletteAtIndex:(NSUInteger)idx;
- (void)colorScrollViewIsAnimating:
        (FBOnboardingColorScrollView *)colorScrollView;
- (void)colorScrollViewAnimationHalted:
        (FBOnboardingColorScrollView *)colorScrollView;

@end

@interface FBOnboardingColorScrollView : UIScrollView

@property(nonatomic, weak) id<FBColorScrollViewDelegate> colorDelegate;

- (instancetype)initWithStartingColorIndex:(NSUInteger)index;

- (void)animatePickerOut;
- (void)animatePickerOutWithCompletion:(dispatch_block_t)completion;

- (void)animatePickerIn;
- (void)animatePickerInWithCompletion:(dispatch_block_t)completion;

/* REMOVE THIS WHEN DONE */
- (void)animatePickerInFancyWithCompletion:(dispatch_block_t)completion;

@end
