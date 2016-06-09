//
//  FBDateRangeOverlayView.h
//  FRICKbits
//
//  Created by Matt McGlincy on 9/16/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBDateRangeOverlayView : UIView

- (BOOL)shouldShow;

- (void)setStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

@end
