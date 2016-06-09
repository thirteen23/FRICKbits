//
//  FBOnboardingBlobMaskView.h
//  FRICKbits
//
//  Created by Michael Van Milligan on 5/28/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBOnboardingBlobMaskView : UIView

- (instancetype)initWithFrame:(CGRect)frame andMask:(UIBezierPath *)path;
- (instancetype)initWithMask:(UIBezierPath *)path;

@end
