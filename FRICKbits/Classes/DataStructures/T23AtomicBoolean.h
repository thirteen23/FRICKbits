//
// Created by Matt McGlincy on 4/10/14.
// Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <Foundation/Foundation.h>

//
// A thread-safe atomic boolean.
//
// Inspired by java.util.concurrent.atomic.AtomicBoolean and
// http://stackoverflow.com/questions/2259956/is-bool-read-write-atomic-in-objective-c
//
@interface T23AtomicBoolean : NSObject

@property(nonatomic) BOOL value;

@end