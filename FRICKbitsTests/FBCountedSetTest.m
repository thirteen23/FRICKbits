//
//  FBCountedSetTest.m
//  FrickBits
//
//  Created by Matt McGlincy on 3/9/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "T23CountedSet.h"

@interface FBCountedSetTest : XCTestCase

@end

@implementation FBCountedSetTest

- (void)testAddObject {
    T23CountedSet *set = [T23CountedSet set];
    NSString *foo = @"foo";

    XCTAssertEqual([set count], 0U, @"Wrong count");
    XCTAssertEqual([set countForObject:foo], 0U, @"Wrong count");

    [set addObject:foo];
    XCTAssertEqual([set count], 1U, @"Wrong count");
    XCTAssertEqual([set countForObject:foo], 1U, @"Wrong count");

    [set addObject:foo];
    XCTAssertEqual([set count], 1U, @"Wrong count");
    XCTAssertEqual([set countForObject:foo], 2U, @"Wrong count");
}

- (void)testRemoveObject {
    T23CountedSet *set = [T23CountedSet set];
    NSString *foo = @"foo";
    [set addObject:foo];
    [set addObject:foo];
    XCTAssertEqual([set count], 1U, @"Wrong count");
    XCTAssertEqual([set countForObject:foo], 2U, @"Wrong count");
    
    [set removeObject:foo];
    XCTAssertEqual([set count], 1U, @"Wrong count");
    XCTAssertEqual([set countForObject:foo], 1U, @"Wrong count");

    [set removeObject:foo];
    XCTAssertEqual([set count], 0U, @"Wrong count");
    XCTAssertEqual([set countForObject:foo], 0U, @"Wrong count");
}

- (void)testSetObjectCount {
    T23CountedSet *set = [T23CountedSet set];
    NSString *foo = @"foo";

    XCTAssertEqual([set count], 0U, @"Wrong count");
    XCTAssertEqual([set countForObject:foo], 0U, @"Wrong count");
    
    [set setObject:foo count:3];
    XCTAssertEqual([set count], 1U, @"Wrong count");
    XCTAssertEqual([set countForObject:foo], 3U, @"Wrong count");
}

@end
