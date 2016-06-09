//
// Created by Matt McGlincy on 4/15/14.
// Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "NSMutableArray+T23Queue.h"


@implementation NSMutableArray (T23Queue)

- (id)dequeue {
  if (self.count == 0) {
    return nil;
  }
  // remove from the front
  id obj = [self objectAtIndex:0];
  [self removeObjectAtIndex:0];
  return obj;
}

- (void)enqueue:(id)anObject {
  // add to the back
  [self addObject:anObject];
}

@end