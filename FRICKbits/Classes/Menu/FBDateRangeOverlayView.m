//
//  FBDateRangeOverlayView.m
//  FRICKbits
//
//  Created by Matt McGlincy on 9/16/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBChrome.h"
#import "FBDateRangeOverlayView.h"

@interface FBDateRangeOverlayView()
@property (nonatomic, strong) UILabel *textLabel;
@end

@implementation FBDateRangeOverlayView

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    self.userInteractionEnabled = NO;
    
    UIView *background = [[UIView alloc] initWithFrame:self.bounds];
    background.backgroundColor = [UIColor whiteColor];
    background.alpha = 0.8;
    [self addSubview:background];

    self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 40)];
    self.textLabel.font = [FBChrome navigationBarFont];
    self.textLabel.textColor = [FBChrome textGrayColor];
    self.textLabel.textAlignment = NSTextAlignmentCenter;

    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, frame.size.width, 40)];
    [navView addSubview:self.textLabel];
    [self addSubview:navView];
  }
  return self;
}

- (void)setStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
  if (startDate && endDate) {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"MMM dd, yyyy";
    NSString *startString = [dateFormatter stringFromDate:startDate];
    NSString *endString = [dateFormatter stringFromDate:endDate];
    NSString *dateString = [NSString stringWithFormat:@"%@ - %@", startString, endString];
    self.textLabel.text = dateString;
  } else {
    self.textLabel.text = nil;
  }
}

- (BOOL)shouldShow {
  // show if non-blank
  return self.textLabel.text != nil;
}

@end
