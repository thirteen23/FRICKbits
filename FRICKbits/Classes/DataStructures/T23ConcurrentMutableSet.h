//
//  T23ConcurrentMutableSet.h
//  FrickBits
//
//  Created by Matt McGlincy on 3/25/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <Foundation/Foundation.h>

//
// Partial implementation of a thread-safe mutable set.
//
// See https://mikeash.com/pyblog/friday-qa-2011-10-14-whats-new-in-gcd.html
//
@interface T23ConcurrentMutableSet : NSObject

- (NSUInteger)count;
- (void)addObject:(id)object;
- (void)addObjectsFromArray:(NSArray *)array;
- (void)removeObject:(id)object;
- (void)removeAllObjects;
- (BOOL)containsObject:(id)object;

// Remove and return any object from the set, as an atomic operation.
// Returns nil if set is empty.
- (id)popObject;

// Add an object to the set only if it doesn't already exist.
// Returns YES if the object was added, NO if the object already existed.
- (BOOL)addObjectIfAbsent:(id)object;

@end
