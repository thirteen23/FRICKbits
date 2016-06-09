//
// Created by Matt McGlincy on 4/16/14.
// Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "NSMutableArray+T23Stack.h"


@implementation NSMutableArray (T23Stack)

- (id)pop {
  if (self.count == 0) {
    return nil;
  }
  // remove from the front
  id obj = [self objectAtIndex:0];
  [self removeObjectAtIndex:0];
  return obj;
}

- (void)push:(id)obj {
  // add to the front
  [self insertObject:obj atIndex:0];
}

@end