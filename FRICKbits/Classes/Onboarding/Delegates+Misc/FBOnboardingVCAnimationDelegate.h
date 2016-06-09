//
//  FBOnboardingVCAnimationDelegate.h
//  FRICKbits
//
//  Created by Michael Van Milligan on 6/26/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBOnboardingVCAnimationDelegate
    : NSObject <UINavigationControllerDelegate,
                UIViewControllerTransitioningDelegate,
                UIViewControllerAnimatedTransitioning>

@property(nonatomic, copy) dispatch_block_t animationCompletionBlock;

@end