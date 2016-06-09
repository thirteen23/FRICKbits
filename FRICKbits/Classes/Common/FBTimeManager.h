//
//  FBTimeManager.h
//  FRICKbits
//
//  Created by Matt McGlincy on 7/9/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBTimeManager : NSObject

@property (nonatomic, strong) NSDate *updateDataDisplayStartTime;
@property (nonatomic, strong) NSDate *updateOpStartTime;
@property (nonatomic, strong) NSDate *updateWithMapViewStartTime;
@property (nonatomic, strong) NSDate *updateCalcFinishedTime;
@property (nonatomic, strong) NSDate *firstBitOpTime;

+ (instancetype)sharedInstance;

- (void)printTimes;

@end
