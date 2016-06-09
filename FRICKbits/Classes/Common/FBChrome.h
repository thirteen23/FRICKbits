//
//  FBChrome.h
//  FrickBits
//
//  Created by Matt McGlincy on 2/7/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

@interface FBChrome : NSObject

+ (void)showOKAlertWithError:(NSError *)error;

+ (void)showOKAlertWithTitle:(NSString *)title message:(NSString *)message;

+ (UIColor *)blurOverlayColor;
+ (UIColor *)darkGrayColor;
+ (UIColor *)textGrayColor;
+ (UIColor *)textDisabledColor;
+ (UIColor *)headerBackgroundColor;
+ (UIColor *)lineOverlayLineColor;
+ (UIColor *)buttonGrayColor;
+ (UIColor *)perLocationPointColor;
+ (UIColor *)navigationBarColor;

+ (UIFont *)buttonFont;
+ (UIFont *)barButtonItemFont;
+ (UIFont *)navigationBarFont;
+ (UIFont *)calendarMonthFont;
+ (UIFont *)calendarDayFont;

+ (UIButton *)onboardingButtonWithTitle:(NSString *)title;
+ (UIButton *)barButtonWithTitle:(NSString *)title;

+ (NSAttributedString *)attributedString:(NSString *)string
                                    font:(UIFont *)font
                                   color:(UIColor *)color
                                 kerning:(CGFloat)kerning;

+ (NSAttributedString *)attributedButtonTitle:(NSString *)string;

+ (NSAttributedString *)attributedParagraph:(NSString *)string;

+ (NSAttributedString *)attributedParagraphForOnboarding:(NSString *)string;

+ (NSMutableParagraphStyle *)paragraphStyleWithAlignment:(NSTextAlignment)align;

+ (NSMutableParagraphStyle *)paragraphStyleWithAlignmentForOnboarding:
        (NSTextAlignment)align;

+ (NSAttributedString *)attributedTextTitle:(NSString *)string;

@end
