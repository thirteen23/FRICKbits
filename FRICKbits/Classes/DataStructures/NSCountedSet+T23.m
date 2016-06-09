//
//  NSCountedSet+T23.m
//  FRICKbits
//
//  Created by Matt McGlincy on 7/23/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "NSCountedSet+T23.h"

@implementation NSCountedSet (T23)

- (void)addObject:(id)anObject count:(NSUInteger)count {
  for (int i = 0; i < count; i++) {
    [self addObject:anObject];
  }
}

- (void)zeroObject:(id)anObject {
  NSUInteger count = [self countForObject:anObject];
  if (count > 0) {
    for (int i = 0; i < count; i++) {
      [self removeObject:anObject];
    }
  }
}

@end
