//
//  FBDatasetTest.m
//  FrickBits
//
//  Created by Matt McGlincy on 4/18/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "FBDataset.h"
#import "FBLocation.h"

@interface FBDatasetTest : XCTestCase

@end

@implementation FBDatasetTest

- (void)assertLocation:(FBLocation *)location latitude:(double)latitude
    longitude:(double)longitude timestamp:(double)timestamp {
  XCTAssertEqualWithAccuracy(location.latitude, latitude, .00000001,
  @"Wrong latitude");
  XCTAssertEqualWithAccuracy(location.longitude, longitude, .00000001,
  @"Wrong longitude");
  XCTAssertEqualWithAccuracy(location.timestamp, timestamp, .00000001,
  @"Wrong timestamp");
}

- (void)testInitWithOpenPathsJSON {
  NSString *filePath = [[NSBundle bundleForClass:[self class]]
                                  pathForResource:@"test_openpaths_2points"
      ofType:@"json"];
  FBDataset *dataset = [[FBDataset alloc] initWithFilePath:filePath];

  XCTAssertEqual(dataset.locations.count, 2, @"Wrong count");
  [self assertLocation:dataset.locations[0] latitude:30.306242981
      longitude:-97.7453842163 timestamp:1389108864];
  [self assertLocation:dataset.locations[1] latitude:30.422830963134766
      longitude:-97.740875244140625 timestamp:1389658368];
}

- (void)testInitWithOpenPathsCSV {
  NSString *filePath = [[NSBundle bundleForClass:[self class]]
                                  pathForResource:@"test_openpaths_2points"
      ofType:@"csv"];
  FBDataset *dataset = [[FBDataset alloc] initWithFilePath:filePath];

  XCTAssertEqual(dataset.locations.count, 2, @"Wrong count");
  // timestamps are a bit different,
  // since our OpenPaths CSV dateFormatter doesn't include seconds or millis
  [self assertLocation:dataset.locations[0] latitude:30.306242981
      longitude:-97.7453842163 timestamp:1389735240];
  [self assertLocation:dataset.locations[1] latitude:30.422830963134766
      longitude:-97.740875244140625 timestamp:1404191520];
}

- (void)testInitWithLocationCSV {
  NSString *filePath = [[NSBundle bundleForClass:[self class]]
                                  pathForResource:@"test_location_2points"
      ofType:@"csv"];
  FBDataset *dataset = [[FBDataset alloc] initWithFilePath:filePath];

  XCTAssertEqual(dataset.locations.count, 2, @"Wrong count");
  [self assertLocation:dataset.locations[0] latitude:30.306242981
      longitude:-97.7453842163 timestamp:1389108864];
  [self assertLocation:dataset.locations[1] latitude:30.422830963134766
      longitude:-97.740875244140625 timestamp:1389658368];
}

- (void)assertDatasetMaxLocationsWithFilePath:(NSString *)filePath expectedLocations:(NSUInteger)expectedLocations {
  // maxLocations 0 = no limit
  FBDataset *dataset = [[FBDataset alloc] initWithFilePath:filePath maxLocations:0];
  XCTAssertEqual(dataset.locations.count, expectedLocations, @"Wrong count");
  
  dataset = [[FBDataset alloc] initWithFilePath:filePath maxLocations:(expectedLocations - 1)];
  XCTAssertEqual(dataset.locations.count, (expectedLocations - 1), @"Wrong count");
  
  dataset = [[FBDataset alloc] initWithFilePath:filePath maxLocations:expectedLocations];
  XCTAssertEqual(dataset.locations.count, expectedLocations, @"Wrong count");
  
  dataset = [[FBDataset alloc] initWithFilePath:filePath maxLocations:(expectedLocations + 1)];
  XCTAssertEqual(dataset.locations.count, expectedLocations, @"Wrong count");
}

- (void)testMaxLocationsWithOpenPathsJSON {
  NSString *filePath = [[NSBundle bundleForClass:[self class]]
                        pathForResource:@"test_openpaths_2points"
                        ofType:@"json"];
  [self assertDatasetMaxLocationsWithFilePath:filePath expectedLocations:2];
}


- (void)testMaxLocationsWithOpenPathsCSV {
  NSString *filePath = [[NSBundle bundleForClass:[self class]]
                        pathForResource:@"test_openpaths_2points"
                        ofType:@"csv"];
  [self assertDatasetMaxLocationsWithFilePath:filePath expectedLocations:2];
}

- (void)testMaxLocationsWithLocationCSV {
  NSString *filePath = [[NSBundle bundleForClass:[self class]]
                        pathForResource:@"test_location_2points"
                        ofType:@"csv"];
  [self assertDatasetMaxLocationsWithFilePath:filePath expectedLocations:2];
}

- (void)testEarliestDate {
  FBDataset *dataset = [[FBDataset alloc] init];
  
  XCTAssertNil([dataset earliestDate]);
  
  FBLocation *l1 = [[FBLocation alloc] init];
  NSDate *d1 = [[NSDate alloc] init];
  l1.timestamp = [d1 timeIntervalSince1970];
  [dataset.locations addObject:l1];
  
  XCTAssertEqualWithAccuracy([[dataset earliestDate] timeIntervalSince1970], [d1 timeIntervalSince1970], .0001);
  
  FBLocation *l2 = [[FBLocation alloc] init];
  NSDate *d2 = [[NSDate alloc] init];
  l2.timestamp = [d2 timeIntervalSince1970];
  [dataset.locations addObject:l2];

  // should still be the first location
  XCTAssertEqualWithAccuracy([[dataset earliestDate] timeIntervalSince1970], [d1 timeIntervalSince1970], .0001);
}

- (void)testFilterWithDates {
  double daySeconds = 24 * 60 * 60;
  // set some daily dates, with a small bump so we're >24hrs apart
  NSDate *d0 = [[NSDate alloc] initWithTimeIntervalSince1970:0];
  NSDate *d1 = [[NSDate alloc] initWithTimeIntervalSince1970:1 * (daySeconds + 1)];
  NSDate *d2 = [[NSDate alloc] initWithTimeIntervalSince1970:2 * (daySeconds + 1)];
  NSDate *d3 = [[NSDate alloc] initWithTimeIntervalSince1970:3 * (daySeconds + 1)];
  NSDate *d4 = [[NSDate alloc] initWithTimeIntervalSince1970:4 * (daySeconds + 1)];
  
  FBDataset *dataset = [[FBDataset alloc] init];
  
  FBLocation *l1 = [[FBLocation alloc] init];
  l1.timestamp = [d1 timeIntervalSince1970];
  
  FBLocation *l2 = [[FBLocation alloc] init];
  l2.timestamp = [d2 timeIntervalSince1970];

  FBLocation *l3 = [[FBLocation alloc] init];
  l3.timestamp = [d3 timeIntervalSince1970];

  dataset.locations = [NSMutableArray arrayWithArray:@[l1, l2, l3]];
  
  XCTAssertEqual(dataset.locations.count, 3);
  
  [dataset filterDatasetWithStartDate:d0 endDate:d4];
  XCTAssertEqual(dataset.locations.count, 3);

  [dataset filterDatasetWithStartDate:d1 endDate:d3];
  XCTAssertEqual(dataset.locations.count, 3);

  [dataset filterDatasetWithStartDate:d2 endDate:d3];
  XCTAssertEqual(dataset.locations.count, 2);
  XCTAssertTrue([dataset.locations containsObject:l2]);
  XCTAssertTrue([dataset.locations containsObject:l3]);

  [dataset filterDatasetWithStartDate:d2 endDate:d2];
  XCTAssertEqual(dataset.locations.count, 1);
  XCTAssertTrue([dataset.locations containsObject:l2]);
}

@end
