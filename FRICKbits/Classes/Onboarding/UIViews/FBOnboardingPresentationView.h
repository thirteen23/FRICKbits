//
//  FBOnboardingPresentationView.h
//  FrickBits
//
//  Created by Michael Van Milligan on 3/25/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBOnboardingPresentationView : UIView

- (instancetype)initWithHelpText:(NSAttributedString *)helpText
                      andMargins:(CGFloat)margins;

- (instancetype)initWithHelpText:(NSAttributedString *)helpText
                       andButton:(UIButton *)button
                      andMargins:(CGFloat)margins;

- (instancetype)initWithViews:(UIView *)views, ... NS_REQUIRES_NIL_TERMINATION;
- (void)addView:(UIView *)view;

@end