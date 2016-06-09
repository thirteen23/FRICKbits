//
// Created by Matt McGlincy on 4/10/14.
// Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "T23AtomicBoolean.h"
#import <libkern/OSAtomic.h>

@implementation T23AtomicBoolean {
  volatile uint32_t _internal;
}

@dynamic value;

- (id)init {
  if (self = [super init]) {
    OSAtomicAnd32Barrier(0, &_internal);
  }
  return self;
}

- (BOOL)value {
  return _internal != 0;
}

- (void)setValue:(BOOL)value {
  if (value) {
    // Atomic bitwise OR of two 32-bit values with barrier
    OSAtomicOr32Barrier(1, &_internal);
  } else {
    // Atomic bitwise AND of two 32-bit values with barrier.
    OSAtomicAnd32Barrier(0, &_internal);
  }
}

@end