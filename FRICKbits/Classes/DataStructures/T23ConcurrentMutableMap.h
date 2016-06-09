//
//  T23ConcurrentMutableMap.h
//  FRICKbits
//
//  Created by Matt McGlincy on 6/16/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface T23ConcurrentMutableMap : NSObject

- (id)objectForKey:(id)key;
- (void)setObject:(id)obj forKey:(id)key;
- (BOOL)setObject:(id)obj forKeyIfAbsent:(id)key;

- (void)removeAllObjects;
- (void)removeObjectForKey:(id)key;

@end
