//
//  NSDate+FBDateCalculations.h
//  FRICKbits
//
//  Created by Michael Van Milligan on 9/9/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (FBDateCalculations)
- (NSString *)getTimeString;
- (NSDate *)dateBackToMidnight;
- (BOOL)foundByDayMonthYearInArray:(NSArray *)array;
- (BOOL)equalByDayMonthYear:(NSDate *)date;
- (NSArray *)datesBetweenDate:(NSDate *)date;
- (NSDate *)nextDate;
- (NSDate *)futureDateByDays:(NSInteger)days;
- (NSDate *)pastDateByDays:(NSInteger)days;
@end
