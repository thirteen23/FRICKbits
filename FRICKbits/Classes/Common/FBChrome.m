//
//  FBChrome.m
//  FrickBits
//
//  Created by Matt McGlincy on 2/7/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBChrome.h"
#import "FBUtils.h"

#define FBCHROME_FONT_SIZE 13.0f
#define FBCHROME_FONT_KERNING 1.5f
#define FBCHROME_LINE_SPACING 10.0f
#define FBCHROME_BACKGROUND_ALPHA 0.9f
#define FBCHROME_BLUR_ALPHA 0.2f
#define FBCHROME_TEXT_GRAY @"#4d4d4d"
#define FBCHROME_TEXT_DISABLED @"#e5e5e5"
#define FBCHROME_BLUR_OVERLAY @"#f7f7f7"
#define FBCHROME_HEADER_BACKGROUND @"#f7f7f7"
#define FBCHROME_LINE_OVERLAY @"#bbbcbf"
#define FBCHROME_BUTTON_GRAY @"#f3f3f3"
#define FBCHROME_PER_LOCATION_GRAY @"#bbbcbf"
#define FBCHROME_NAV_GRAY @"#f7f7f7"

@implementation FBChrome

+ (void)showOKAlertWithError:(NSError *)error {
  [self showOKAlertWithTitle:@"Error" message:error.localizedDescription];
}

+ (void)showOKAlertWithTitle:(NSString *)title message:(NSString *)message {
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                  message:message
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
  [alert show];
}

+ (UIColor *)blurOverlayColor {
  return UIColorFromHexString(FBCHROME_BLUR_OVERLAY, FBCHROME_BLUR_ALPHA);
}

+ (UIColor *)darkGrayColor {
  return [UIColor colorWithRed:0.33f green:0.33f blue:0.33f alpha:1.0f];
}

+ (UIColor *)textGrayColor {
  return UIColorFromHexString(FBCHROME_TEXT_GRAY, 1.0f);
}

+ (UIColor *)textDisabledColor {
  return UIColorFromHexString(FBCHROME_TEXT_DISABLED, 1.0f);
}

+ (UIColor *)headerBackgroundColor {
  return UIColorFromHexString(FBCHROME_HEADER_BACKGROUND,
                              FBCHROME_BACKGROUND_ALPHA);
}

+ (UIColor *)lineOverlayLineColor {
  return UIColorFromHexString(FBCHROME_LINE_OVERLAY, 1.0);
}

+ (UIColor *)buttonGrayColor {
  return UIColorFromHexString(FBCHROME_BUTTON_GRAY, 1.0f);
}

+ (UIColor *)perLocationPointColor {
  return UIColorFromHexString(FBCHROME_PER_LOCATION_GRAY, 1.0f);
}

+ (UIColor *)navigationBarColor {
  return UIColorFromHexString(FBCHROME_NAV_GRAY, 1.0f);
}

+ (UIFont *)buttonFont {
  return [UIFont fontWithName:@"Raleway-SemiBold" size:13.0f];
}

+ (UIFont *)barButtonItemFont {
  return [UIFont fontWithName:@"Raleway-SemiBold" size:13.0f];
}

+ (UIFont *)navigationBarFont {
  return [UIFont fontWithName:@"Raleway-Medium" size:16.0f];
}

+ (UIFont *)calendarMonthFont {
  return [UIFont fontWithName:@"Raleway-SemiBold" size:13.0f];
}

+ (UIFont *)calendarDayFont {
  return [UIFont fontWithName:@"Raleway-Medium" size:14.0f];
}

+ (UIButton *)onboardingButtonWithTitle:(NSString *)title {
  UIButton *button = [[UIButton alloc] init];
  button.translatesAutoresizingMaskIntoConstraints = NO;
  button.backgroundColor = [FBChrome buttonGrayColor];
  button.contentEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
  button.layer.borderColor = [UIColor whiteColor].CGColor;
  button.layer.borderWidth = 1.0f;
  [button setTitle:title forState:UIControlStateNormal];
  [button setTitleColor:[FBChrome textGrayColor] forState:UIControlStateNormal];
  button.titleLabel.font = [FBChrome buttonFont];
  return button;
}

+ (UIButton *)barButtonWithTitle:(NSString *)title {
  UIButton *button = [[UIButton alloc] init];
  button.frame = CGRectMake(0, 0, 74, 26);
  button.backgroundColor = [FBChrome buttonGrayColor];
  button.layer.borderColor = [[UIColor whiteColor] CGColor];
  button.layer.borderWidth = 1.0;
  [button setTitle:title forState:UIControlStateNormal];
  [button setTitleColor:[FBChrome textGrayColor] forState:UIControlStateNormal];
  button.titleLabel.font = [FBChrome barButtonItemFont];
  return button;
}

+ (NSAttributedString *)attributedString:(NSString *)string
                                    font:(UIFont *)font
                                   color:(UIColor *)color
                                 kerning:(CGFloat)kerning {
  return [[NSAttributedString alloc]
      initWithString:string
          attributes:@{
                       NSFontAttributeName : font,
                       NSForegroundColorAttributeName : color,
                       NSKernAttributeName : @(kerning),
                     }];
}

+ (NSAttributedString *)attributedButtonTitle:(NSString *)string {
  return [FBChrome attributedString:string
                               font:[UIFont fontWithName:@"Raleway-Medium"
                                                    size:FBCHROME_FONT_SIZE]
                              color:[FBChrome textGrayColor]
                            kerning:FBCHROME_FONT_KERNING];
}

+ (NSAttributedString *)attributedParagraph:(NSString *)string {
  NSMutableAttributedString *attributedString =
      [[NSMutableAttributedString alloc] initWithString:string];
  NSRange entireStringRange = NSMakeRange(0, [string length]);
  NSMutableParagraphStyle *paragraphStyle =
      [FBChrome paragraphStyleWithAlignment:NSTextAlignmentLeft];

  [attributedString addAttribute:NSParagraphStyleAttributeName
                           value:paragraphStyle
                           range:entireStringRange];
  [attributedString addAttribute:NSFontAttributeName
                           value:[UIFont fontWithName:@"Raleway-Medium"
                                                 size:FBCHROME_FONT_SIZE]
                           range:entireStringRange];

  [attributedString addAttribute:NSForegroundColorAttributeName
                           value:[FBChrome textGrayColor]
                           range:entireStringRange];

  [attributedString addAttribute:NSKernAttributeName
                           value:@(FBCHROME_FONT_KERNING)
                           range:entireStringRange];

  return attributedString;
}

+ (NSAttributedString *)attributedParagraphForOnboarding:(NSString *)string {
  NSMutableAttributedString *attributedString =
      [[NSMutableAttributedString alloc] initWithString:string];
  NSRange entireStringRange = NSMakeRange(0, [string length]);
  NSMutableParagraphStyle *paragraphStyle =
      [FBChrome paragraphStyleWithAlignmentForOnboarding:NSTextAlignmentLeft];

  [attributedString addAttribute:NSParagraphStyleAttributeName
                           value:paragraphStyle
                           range:entireStringRange];
  [attributedString addAttribute:NSFontAttributeName
                           value:[UIFont fontWithName:@"Raleway-Regular"
                                                 size:FBCHROME_FONT_SIZE]
                           range:entireStringRange];

  [attributedString addAttribute:NSForegroundColorAttributeName
                           value:[FBChrome textGrayColor]
                           range:entireStringRange];

  return attributedString;
}

+ (NSMutableParagraphStyle *)paragraphStyleWithAlignment:
                                 (NSTextAlignment)align {
  NSMutableParagraphStyle *paragraphStyle =
      [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.alignment = align;
  paragraphStyle.lineSpacing = FBCHROME_LINE_SPACING;
  paragraphStyle.minimumLineHeight = FBCHROME_LINE_SPACING;
  paragraphStyle.maximumLineHeight = 0.0f;

  return paragraphStyle;
}

+ (NSMutableParagraphStyle *)paragraphStyleWithAlignmentForOnboarding:
                                 (NSTextAlignment)align {
  NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
  paragraph.alignment = align;
  paragraph.lineSpacing = FBCHROME_LINE_SPACING;
  paragraph.lineBreakMode = NSLineBreakByWordWrapping;

  return paragraph;
}

+ (NSAttributedString *)attributedTextTitle:(NSString *)string {
  NSMutableAttributedString *titleString = nil;

  NSRange entireStringRange = NSMakeRange(0, [string length]);
  NSMutableParagraphStyle *paragraphStyle =
      [FBChrome paragraphStyleWithAlignment:NSTextAlignmentCenter];
  titleString =
      [[NSMutableAttributedString alloc] initWithString:(NSString *)string];

  [titleString addAttribute:NSParagraphStyleAttributeName
                      value:paragraphStyle
                      range:entireStringRange];

  [titleString addAttribute:NSFontAttributeName
                      value:[UIFont fontWithName:@"Raleway-SemiBold"
                                            size:FBCHROME_FONT_SIZE]
                      range:entireStringRange];

  [titleString addAttribute:NSForegroundColorAttributeName
                      value:[FBChrome textGrayColor]
                      range:entireStringRange];

  [titleString addAttribute:NSKernAttributeName
                      value:@(FBCHROME_FONT_KERNING)
                      range:entireStringRange];

  return titleString;
}

@end
