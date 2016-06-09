//
//  T23CountedSet.m
//  FrickBits
//
//  Created by Matt McGlincy on 3/7/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "T23CountedSet.h"

@interface T23CountedSet ()
@property(nonatomic, strong) NSMutableSet *objects;
// we use a maptable so we can use id keys, and not require id<NSCopying>
// object => NSNumber count
//@property(nonatomic, strong) NSMapTable *objectCounts;
@property(nonatomic, strong) NSMutableDictionary *objectCounts;
@end

@implementation T23CountedSet

+ (instancetype)set {
  return [[T23CountedSet alloc] init];
}

- (instancetype)init {
  self = [super init];
  if (self) {
    self.objects = [NSMutableSet set];
//    self.objectCounts = [NSMapTable strongToStrongObjectsMapTable];
    self.objectCounts = [NSMutableDictionary dictionary];
  }
  return self;
}

#pragma mark - NSSet required overrides

- (NSUInteger)count {
  return [self.objects count];
}

- (id)member:(id)object {
  return [self.objects member:object];
}

- (NSEnumerator *)objectEnumerator {
  return [self.objects objectEnumerator];
}

- (NSArray *)allObjects {
  return [self.objects allObjects];
}

#pragma mark - NSMutableSet required overrides

- (void)addObject:(id)object {
  NSNumber *count = [self.objectCounts objectForKey:object];
  NSNumber *newCount;
  if (!count) {
    newCount = @(1U);
  } else {
    newCount = @([count unsignedIntegerValue] + 1U);
  }
//  [self.objectCounts setObject:newCount forKey:object];
  // TODO
  [self.objectCounts setObject:newCount forKey:object];
  [self.objects addObject:object];
}

- (void)addObjectsFromArray:(NSArray *)array {
  for (id obj in array) {
    [self addObject:obj];
  }
}

- (void)addObject:(id)object count:(NSUInteger)count {
  NSUInteger currentCount = [self countForObject:object];
  [self setObject:object count:currentCount + count];
}

- (void)removeObject:(id)object {
  NSNumber *count = [self.objectCounts objectForKey:object];
  if (!count) {
    // we don't have this object
    return;
  }
  NSUInteger newVal = [count unsignedIntegerValue] - 1;
  if (newVal <= 0) {
    // all gone now
    [self.objectCounts removeObjectForKey:object];
    [self.objects removeObject:object];
  } else {
    NSNumber *newCount = @(newVal);
    [self.objectCounts setObject:newCount forKey:object];
  }
}

- (void)removeAllObjects {
  [self.objectCounts removeAllObjects];
  [self.objects removeAllObjects];
}

- (BOOL)containsObject:(id)object {
  return [self.objects containsObject:object];
}

#pragma mark - counter set methods

- (NSUInteger)countForObject:(id)object {
  NSNumber *count = [self.objectCounts objectForKey:object];
  return [count unsignedIntegerValue];
}

- (void)setObject:(id)object count:(NSUInteger)count {
  if (count == 0U) {
    [self.objects removeObject:object];
    [self.objectCounts removeObjectForKey:object];
  } else {
    [self.objects addObject:object];
    [self.objectCounts setObject:@(count) forKey:object];
  }
}

static long T23CountedSetRemoveAndZeroObjectCount = 0;

- (void)removeAndZeroObject:(id)object {
  T23CountedSetRemoveAndZeroObjectCount++;
  [self setObject:object count:0U];
}

+ (long)removeAndZeroObjectCount {
  return T23CountedSetRemoveAndZeroObjectCount;
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(__unsafe_unretained id *)stackbuf
                                    count:(NSUInteger)len {
  return [self.objects countByEnumeratingWithState:state
                                           objects:stackbuf
                                             count:len];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
  id copy = [[[self class] alloc] init];

  if (copy) {
    for (id<NSCopying> obj in self.objects) {
      NSNumber *count = [self.objectCounts objectForKey:obj];
      [copy setObject:obj count:[count unsignedIntegerValue]];
    }
  }

  return copy;
}

@end
