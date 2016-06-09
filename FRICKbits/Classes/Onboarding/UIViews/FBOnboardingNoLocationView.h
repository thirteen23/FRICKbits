//
//  FBOnboardingNoLocationView.h
//  FRICKbits
//
//  Created by Michael Van Milligan on 6/30/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBOnboardingNoLocationView : UIView

- (void)doNoLocationErrorTransition;
- (void)doNoLocationErrorTransitionWithCompletion:(dispatch_block_t)completion;

@end
