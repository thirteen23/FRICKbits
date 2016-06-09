//
//  FBDataset.h
//  FrickBits
//
//  Created by Matt McGlincy on 1/21/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

@interface FBDataset : NSObject

@property(nonatomic, readonly) NSString *filename;

// list of FBLocations
@property(nonatomic, strong) NSMutableArray *locations;

@property(nonatomic) double minLatitude;
@property(nonatomic) double maxLatitude;
@property(nonatomic) double minLongitude;
@property(nonatomic) double maxLongitude;

@property(nonatomic, strong) NSDate *earliestLoadedDate;
@property(nonatomic, strong) NSDate *startFilterDate;
@property(nonatomic, strong) NSDate *endFilterDate;

- (id)initWithFilename:(NSString *)filename;
- (id)initWithFilePath:(NSString *)filePath;
- (id)initWithFilename:(NSString *)filename
          maxLocations:(NSUInteger)maxLocations;
- (id)initWithFilePath:(NSString *)filePath
          maxLocations:(NSUInteger)maxLocations;

// load the default user location dataset
+ (FBDataset *)userLocationDataset;

// only keep the N most recent locations
- (void)trimDatasetToMaxLocations:(NSUInteger)maxLocations;

// filter the dateset based on a date range, inclusive.
- (void)filterDatasetWithStartDate:(NSDate *)startDate
                           endDate:(NSDate *)endDate;

// reload the dataset, with the original file path and maxLocations
- (void)reload;

// load the earliest date
- (NSDate *)earliestDate;

@end
