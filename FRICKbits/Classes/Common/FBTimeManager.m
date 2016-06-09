//
//  FBTimeManager.m
//  FRICKbits
//
//  Created by Matt McGlincy on 7/9/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBTimeManager.h"

@implementation FBTimeManager

+ (instancetype)sharedInstance {
  static id _sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{ _sharedInstance = [[self alloc] init]; });
  return _sharedInstance;
}

- (void)printTimes {
  NSLog(@"=====");
  NSLog(@"updateDataDisplay started 0");
  NSLog(@"update op started %f", [self.updateOpStartTime timeIntervalSinceDate:self.updateDataDisplayStartTime]);
  NSLog(@"calcs finished %f", [self.updateCalcFinishedTime timeIntervalSinceDate:self.updateDataDisplayStartTime]);
  NSLog(@"first bit op %f", [self.firstBitOpTime timeIntervalSinceDate:self.updateDataDisplayStartTime]);
}

@end
