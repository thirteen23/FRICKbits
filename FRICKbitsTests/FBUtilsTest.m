//
//  FBUtilsTest.m
//  FrickBits
//
//  Created by Matthew McGlincy on 2/21/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FBUtils.h"

@interface FBUtilsTest : XCTestCase

@end

@implementation FBUtilsTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

static inline CGPoint p(CGFloat x, CGFloat y) {
    return CGPointMake(x, y);
}

- (void)testDegreesBetweenPoints {
    XCTAssertEqualWithAccuracy(DegreesBetweenPoints(p(0, 0), p(0, 0)), 0.0, 0.0001, @"Wrong angle");
    XCTAssertEqualWithAccuracy(DegreesBetweenPoints(p(0, 0), p(1, 0)), 0.0, 0.0001, @"Wrong angle");
    XCTAssertEqualWithAccuracy(DegreesBetweenPoints(p(0, 0), p(1, 1)), 45.0, 0.0001, @"Wrong angle");
    XCTAssertEqualWithAccuracy(DegreesBetweenPoints(p(0, 0), p(0, 1)), 90.0, 0.0001, @"Wrong angle");
    XCTAssertEqualWithAccuracy(DegreesBetweenPoints(p(0, 0), p(-1, 1)), 135.0, 0.0001, @"Wrong angle");
    XCTAssertEqualWithAccuracy(DegreesBetweenPoints(p(0, 0), p(-1, 0)), 180.0, 0.0001, @"Wrong angle");
    XCTAssertEqualWithAccuracy(DegreesBetweenPoints(p(0, 0), p(-1, -1)), 225.0, 0.0001, @"Wrong angle");
    XCTAssertEqualWithAccuracy(DegreesBetweenPoints(p(0, 0), p(0, -1)), 270.0, 0.0001, @"Wrong angle");
    XCTAssertEqualWithAccuracy(DegreesBetweenPoints(p(0, 0), p(1, -1)), 315.0, 0.0001, @"Wrong angle");
}

- (void)testSplitOneIntoRandomFractions {
  // 1 piece
  NSArray *fractions =
      SplitOneIntoEndWeightedFractions(1, 0.1);
  XCTAssertEqual(fractions.count, 1, @"Wrong number of fractions");
  XCTAssertEqual([fractions[0] floatValue], 1.0, @"Wrong fraction");


  fractions = SplitOneIntoEndWeightedFractions(5, 0.1);
  CGFloat sum = 0.0;
  XCTAssertEqual(fractions.count, 5, @"Wrong number of fractions");
  for (NSNumber *fraction in fractions) {
    CGFloat f = [fraction floatValue];
    XCTAssert(f >= 0.1, @"Below min percent");
    sum += f;
  }
  XCTAssertEqualWithAccuracy(sum, 1.0, 0.0001, @"Fractions don't add up to 1"
      ".");
}

- (void)testFractionGlomming {

  // front/back within threshold, so no glomming
  // [0.5,0.5] -> [0.5,0.5]
  NSArray *fractions = @[@(0.5), @(0.5)];
  NSArray *glommed = GlomEndFractionsLessThan(fractions, 0.5);
  XCTAssertEqual(glommed.count, fractions.count);
  XCTAssertEqualWithAccuracy([glommed[0] floatValue], [fractions[0] floatValue], .0001);
  XCTAssertEqualWithAccuracy([glommed[0] floatValue], [fractions[0] floatValue], .0001);
  
  // outside of threshold, glomming into a single fraction
  // [0.5,0.5] -> [0.1]
  glommed = GlomEndFractionsLessThan(fractions, 0.6);
  XCTAssertEqual(glommed.count, 1);
  XCTAssertEqualWithAccuracy([glommed[0] floatValue], 1.0, .0001);
  
  // outside of threshold, glomming on both ends
  // [0.1,0.1,0.3,0.3,0.1,0.1] -> [0.5,0.5]
  fractions = @[@(0.1), @(0.1), @(0.3), @(0.3), @(0.1), @(0.1)];
  glommed = GlomEndFractionsLessThan(fractions, 0.3);
  XCTAssertEqual(glommed.count, 2);
  XCTAssertEqualWithAccuracy([glommed[0] floatValue], 0.5, .0001);
  XCTAssertEqualWithAccuracy([glommed[1] floatValue], 0.5, .0001);  
}

@end
