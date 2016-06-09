//
//  T23ConcurrentMutableSet.m
//  FrickBits
//
//  Created by Matt McGlincy on 3/25/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "T23ConcurrentMutableSet.h"

@interface T23ConcurrentMutableSet ()
@property(nonatomic, strong) NSMutableSet *cache;
@property(nonatomic, strong) dispatch_queue_t queue;
@end

@implementation T23ConcurrentMutableSet

- (id)init {
  self = [super init];
  if (self) {
    _cache = [NSMutableSet set];
    _queue = dispatch_queue_create("T23ConcurrentMutableSet",
                                   DISPATCH_QUEUE_CONCURRENT);
  }
  return self;
}

- (NSUInteger)count {
  __block NSUInteger count;
  dispatch_sync(_queue, ^{ count = _cache.count; });
  return count;
}

- (BOOL)containsObject:(id)object {
  __block BOOL contains;
  dispatch_sync(_queue, ^{ contains = [_cache containsObject:object]; });
  return contains;
}

- (void)addObject:(id)object {
  dispatch_barrier_async(_queue, ^{ [_cache addObject:object]; });
}

- (void)addObjectsFromArray:(NSArray *)array {
  dispatch_barrier_async(_queue, ^{ [_cache addObjectsFromArray:array]; });
}

- (void)removeObject:(id)object {
  dispatch_barrier_async(_queue, ^{ [_cache removeObject:object]; });
}

- (void)removeAllObjects {
  dispatch_barrier_async(_queue, ^{ [_cache removeAllObjects]; });
}

- (id)popObject {
  __block id obj;
  dispatch_barrier_sync(_queue, ^{
      obj = [_cache anyObject];
      [_cache removeObject:obj];
  });
  return obj;
}

- (BOOL)addObjectIfAbsent:(id)object {
  __block BOOL added = NO;
  dispatch_barrier_sync(_queue, ^{
      if (![_cache containsObject:object]) {
        [_cache addObject:object];
        added = YES;
      }
  });
  return added;
}

@end
