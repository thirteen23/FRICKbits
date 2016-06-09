//
//  NSCountedSet+T23.h
//  FRICKbits
//
//  Created by Matt McGlincy on 7/23/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCountedSet (T23)

- (void)addObject:(id)anObject count:(NSUInteger)count;

// remove all occurrences of an object
- (void)zeroObject:(id)anObject;

@end
