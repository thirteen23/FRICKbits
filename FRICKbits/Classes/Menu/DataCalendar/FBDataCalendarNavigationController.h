//
//  FBDataCalendarNavigationController.h
//  FRICKbits
//
//  Created by Michael Van Milligan on 8/25/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBTrackedNavigationController.h"

@class FBDataCalendarNavigationController;
@protocol FBDataCalendarNavigationControllerDelegate<NSObject>
- (void)dataCalendarNavigationController:
            (FBDataCalendarNavigationController *)nc
                      didSelectStartDate:(NSDate *)startDate
                                 endDate:(NSDate *)endDate;
- (void)dataCalendarNavigationControllerDidCancel:
        (FBDataCalendarNavigationController *)nc;
@end

@interface FBDataCalendarNavigationController : FBTrackedNavigationController

@property(nonatomic, weak)
    id<FBDataCalendarNavigationControllerDelegate> delegate;
@property(nonatomic, strong) NSDate *startDate;
@property(nonatomic, strong) NSDate *endDate;
@property(nonatomic, strong) NSDate *startFilterDate;
@property(nonatomic, strong) NSDate *endFilterDate;

- (instancetype)initWithStartDate:(NSDate *)startDate
                          endDate:(NSDate *)endDate
                  startFilterDate:(NSDate *)startFilterDate
                    endFilterDate:(NSDate *)endFilterDate;

@end
