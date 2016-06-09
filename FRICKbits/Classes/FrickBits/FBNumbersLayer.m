//
//  FBNumbersLayer.m
//  FrickBits
//
//  Created by Matt McGlincy on 2/26/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "FBNumbersLayer.h"
#import "FBUtils.h"

@interface FBNumbersLayer ()
@property(nonatomic) UIColor *strokeColor;
@property(nonatomic) CATextLayer *textLayer;
@property(nonatomic) CGSize textOffset;
@end

@implementation FBNumbersLayer

- (id)initWithFillColor:(UIColor *)fillColor {
  if (self = [super init]) {
    self.masksToBounds = YES;  // we want text to clip
    _textOffset = CGSizeMake(0.0f, 0.0f);
    _textLayer = [[CATextLayer alloc] init];
    _textLayer.fontSize = 10.0f;
    _textLayer.alignmentMode = kCAAlignmentCenter;
    _textLayer.contentsScale = [[UIScreen mainScreen] scale];
    self.strokeColor = UIColorFromHexString(@"#333333", 0.8f);
    [self setText:RandNumberString() color:fillColor];
    [self addSublayer:self.textLayer];
    
    // setNeedsDisplay seems to be necessary to force the textLayer to be visible
    dispatch_async(dispatch_get_main_queue(), ^{
      [_textLayer setNeedsDisplay];
    });
  }
  return self;
}

- (id)initWithFillColor:(UIColor *)fillColor andOffset:(CGSize)offset {
  if (self = [self initWithFillColor:fillColor]) {
    _textOffset = offset;
  }
  return self;
}

- (void)setFrame:(CGRect)frame {
  [super setFrame:frame];

  // offset text a bit
  if (0.0f == _textOffset.width || 0.0f == _textOffset.height) {
    _textOffset = CGSizeMake(-4.0f, -6.0f);
  }

  self.textLayer.frame =
      CGRectMake(_textOffset.width, _textOffset.height,
                 frame.size.width + 2 * abs(_textOffset.width),
                 self.frame.size.height + 2 * abs(_textOffset.height));
}

- (void)setText:(NSString *)text color:(UIColor *)color {
  CTFontRef fontRef =
      CTFontCreateWithName((CFStringRef) @"MARI&DAVID", 14.0f, NULL);
  NSDictionary *attributes = @{
    (NSString *)kCTFontAttributeName : (__bridge id)fontRef,
    (NSString *)kCTForegroundColorAttributeName : (id)color.CGColor,
    (NSString *)kCTStrokeColorAttributeName : (id)self.strokeColor.CGColor,
    (NSString *)kCTStrokeWidthAttributeName :
    (id)[NSNumber numberWithFloat : -3.0],
  };
  NSAttributedString *attrStr =
      [[NSAttributedString alloc] initWithString:text attributes:attributes];
  CFRelease(fontRef);
  _textLayer.string = attrStr;
}

NSString *RandNumberString() {
  NSInteger rand = arc4random_uniform(100);
  return [NSString stringWithFormat:@"%02ld", (long)rand];
}

@end
