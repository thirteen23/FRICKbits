//
//  FBOnboardingBlobView.h
//  FRICKbits
//
//  Created by Michael Van Milligan on 5/28/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBOnboardingBlobView : UIView
@property(nonatomic, readonly) NSUInteger numBits;

- (void)animateBitsInWithPaletteIndex:(NSUInteger)idx;
- (void)animateBitsInWithPaletteIndex:(NSUInteger)idx
                        andCompletion:(dispatch_block_t)completion;
- (void)animateBitsOut;
- (void)animateBitsOutWithCompletion:(dispatch_block_t)completion;

- (void)removeAllColumns;

@end
