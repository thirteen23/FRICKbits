//
//  FBOnboardingAnimationView.h
//  FRICKbits
//
//  Created by Michael Van Milligan on 9/5/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBOnboardingAnimationView : UIView

@property(nonatomic, readonly) UIImageView *backgroundView;

- (instancetype)initWithBackgroundImage:(UIImage *)backgroundImage;

@end
