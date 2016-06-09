//
//  T23ConcurrentMutableMap.m
//  FRICKbits
//
//  Created by Matt McGlincy on 6/16/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "T23ConcurrentMutableMap.h"

@interface T23ConcurrentMutableMap ()
@property(nonatomic, strong) NSMapTable *cache;
@property(nonatomic, strong) dispatch_queue_t queue;
@end

@implementation T23ConcurrentMutableMap

- (id)init {
  self = [super init];
  if (self) {
    _cache = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory
                                   valueOptions:NSMapTableStrongMemory];
    _queue = dispatch_queue_create("T23ConcurrentMutableMap",
                                   DISPATCH_QUEUE_CONCURRENT);
  }
  return self;
}

- (id)objectForKey:(id)key {
  __block id obj;
  dispatch_sync(_queue, ^{ obj = [_cache objectForKey:key]; });
  return obj;
}

- (void)removeAllObjects {
  dispatch_barrier_async(_queue, ^{ [_cache removeAllObjects]; });
}

- (void)removeObjectForKey:(id)key {
  dispatch_barrier_async(_queue, ^{ [_cache removeObjectForKey:key]; });
}

- (void)setObject:(id)obj forKey:(id)key {
  dispatch_barrier_async(_queue, ^{ [_cache setObject:obj forKey:key]; });
}

- (BOOL)setObject:(id)obj forKeyIfAbsent:(id)key {
  __block BOOL added = NO;
  dispatch_barrier_sync(_queue, ^{
    if (![_cache objectForKey:key]) {
      [_cache setObject:obj forKey:key];
      added = YES;
    }
  });
  return added;
}

/* alternate implementation >>>
- (id)setObject:(id)obj forKeyIfAbsent:(id)key {
  __block id retObj = NO;
  dispatch_barrier_sync(_queue, ^{
    retObj = [_cache objectForKey:key];
    if (!retObj) {
      [_cache setObject:obj forKey:key];
      retObj = obj;
    }
  });
  return retObj;
}
<<< */

@end
