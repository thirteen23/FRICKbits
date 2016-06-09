//
//  FBDialogView.h
//  FrickBits
//
//  Created by Michael Van Milligan on 3/25/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FBDialogView;

@protocol FBDialogViewDelegate<NSObject>

@optional
- (void)dialogView:(FBDialogView *)dialogView
    clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface FBDialogView : UIView

@property(nonatomic, assign) id<FBDialogViewDelegate> delegate;

+ (instancetype)dialogWithMessage:(NSString *)message
                         delegate:(id<FBDialogViewDelegate>)delegate
                cancelButtonTitle:(NSString *)cancelButtonTitle
                otherButtonTitles:(NSString *)otherButtonTitles, ...;

- (instancetype)initWithMessage:(NSAttributedString *)message
                       delegate:(id<FBDialogViewDelegate>)delegate
              cancelButtonTitle:(NSAttributedString *)cancelButtonTitle
              otherButtonTitles:(NSAttributedString *)otherButtonTitles,
                                ... NS_REQUIRES_NIL_TERMINATION;

- (instancetype)initWithMessage:(NSAttributedString *)message
                       delegate:(id<FBDialogViewDelegate>)delegate
              cancelButtonTitle:(NSAttributedString *)cancelButtonTitle
          otherButtonTitleArray:(NSArray *)otherButtonTitles;

- (void)showOnView:(UIView *)view;

@end
