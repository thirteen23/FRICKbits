//
//  NSDate+FBDateCalculations.m
//  FRICKbits
//
//  Created by Michael Van Milligan on 9/9/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "NSDate+FBDateCalculations.h"
#import "FBUtils.h"

@implementation NSDate (FBDateCalculations)

- (NSString *)getTimeString {
  NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
  timeFormatter.dateFormat = @"HH:mm:ss";

  return [timeFormatter stringFromDate:self];
}

- (NSDate *)dateBackToMidnight {
  unsigned int flags =
      NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
  NSDateComponents *components =
      [[NSCalendar currentCalendar] components:flags fromDate:self];

  return [[NSCalendar currentCalendar] dateFromComponents:components];
}

- (BOOL)foundByDayMonthYearInArray:(NSArray *)array {
  __block BOOL found = NO;

  [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      if (_ISA_(obj, NSDate)) {
        NSDate *comp = (NSDate *)obj;
        *stop = ((found = [self equalByDayMonthYear:comp]));
      }
  }];

  return found;
}

- (BOOL)equalByDayMonthYear:(NSDate *)date {
  return (NSOrderedSame ==
          [[self dateBackToMidnight] compare:[date dateBackToMidnight]]);
}

- (NSArray *)datesBetweenDate:(NSDate *)date {

  if ([self equalByDayMonthYear:date]) {
    return nil;
  }

  if (!date) {
    return @[ self ];
  }

  NSMutableArray *dateRange = [[NSMutableArray alloc] init];
  NSDate *cursor = [[self earlierDate:date] dateBackToMidnight];
  NSDate *end = [[self laterDate:date] dateBackToMidnight];

  [dateRange addObject:cursor];
  while (![end equalByDayMonthYear:cursor]) {
    NSDate *nextDate = [cursor nextDate];
    [dateRange addObject:nextDate];
    cursor = nextDate;
  }

  return (0 < dateRange.count) ? dateRange : nil;
}

- (NSDate *)nextDate {
  return [self futureDateByDays:1];
}

- (NSDate *)futureDateByDays:(NSInteger)days {
  NSDateComponents *comps = [[NSDateComponents alloc] init];
  comps.day = days;

  return [[NSCalendar currentCalendar] dateByAddingComponents:comps
                                                       toDate:self
                                                      options:0];
}

- (NSDate *)pastDateByDays:(NSInteger)days {
  NSDateComponents *comps = [[NSDateComponents alloc] init];
  comps.day = -days;

  return [[NSCalendar currentCalendar] dateByAddingComponents:comps
                                                       toDate:self
                                                      options:0];
}

@end
