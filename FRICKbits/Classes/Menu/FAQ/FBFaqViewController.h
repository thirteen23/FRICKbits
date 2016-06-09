//
//  FBFaqViewController.h
//  FRICKbits
//
//  Created by Michael Van Milligan on 8/25/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBTrackedViewController.h"

@class FBFaqViewController;
@protocol FBFaqViewControllerDelegate <NSObject>
- (void)faqViewControllerDidCancel:(FBFaqViewController *)vc;
@end

@interface FBFaqViewController : FBTrackedViewController

@property(nonatomic, weak) id<FBFaqViewControllerDelegate> delegate;

@end
