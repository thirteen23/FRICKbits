//
//  T23CountedSet.h
//  FrickBits
//
//  Created by Matt McGlincy on 3/7/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

@interface T23CountedSet : NSObject<NSFastEnumeration, NSCopying>

+ (instancetype)set;

// NSSet methods
- (NSUInteger)count;
- (id)member:(id)object;
- (NSEnumerator *)objectEnumerator;
- (NSArray *)allObjects;

// NSMutableSet methods

// Add an object and increment count of that object.
- (void)addObject:(id)object;

// all an array of objects. Equivalent to calling addObject: for each.
- (void)addObjectsFromArray:(NSArray *)array;

// add a given object N times, incrementing any existing count.
- (void)addObject:(id)object count:(NSUInteger)count;

// Decrement count of an object. If count is brought to zero, also removes that object.
- (void)removeObject:(id)object;

- (void)removeAllObjects;

- (BOOL)containsObject:(id)object;

// counted set methods

// Set the count for the given object. If zero, remove the object.
- (void)setObject:(id)object count:(NSUInteger)count;

// Remove an object and zero its count.
// Equivalent to [self setObject:object count:0]
- (void)removeAndZeroObject:(id)object;

// Count for the given object.
- (NSUInteger)countForObject:(id)object;

+ (long)removeAndZeroObjectCount;

@end
