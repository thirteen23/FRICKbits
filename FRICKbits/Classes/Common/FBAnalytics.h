//
// Created by Matt McGlincy on 4/2/14.
// Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FBAnalytics : NSObject

+ (void)configure;
+ (void)sendView:(NSString *)screen;

@end