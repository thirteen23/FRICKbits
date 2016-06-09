//
// Created by Matt McGlincy on 4/15/14.
// Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <Foundation/Foundation.h>

// FIFO queue
@interface NSMutableArray (T23Queue)

- (id)dequeue;
- (void)enqueue:(id)obj;

@end