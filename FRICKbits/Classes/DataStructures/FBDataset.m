//
//  FBDataset.m
//  FrickBits
//
//  Created by Matt McGlincy on 1/21/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "CHCSVParser.h"
#import "FBChrome.h"
#import "FBDataset.h"
#import "FBLocation.h"
#import "FBUtils.h"
#import "NSDate+FBDateCalculations.h"

@interface FBDataset ()
@property(nonatomic, strong) NSString *filename;
@property(nonatomic, strong) NSString *filePath;
@property(nonatomic) NSUInteger maxLocations;
@end

@implementation FBDataset

+ (FBDataset *)userLocationDataset {
  return [[FBDataset alloc] initWithFilename:FBLocationCSVFileName
                                maxLocations:FBDatasetMaxLocations];
}

- (id)init {
  self = [super init];
  if (self) {
    self.locations = [NSMutableArray array];
  }
  return self;
}

- (id)initWithFilename:(NSString *)filename {
  return [self initWithFilename:filename maxLocations:0];
}

- (id)initWithFilePath:(NSString *)filePath {
  return [self initWithFilePath:filePath maxLocations:0];
}

- (id)initWithFilename:(NSString *)filename
          maxLocations:(NSUInteger)maxLocations {
  // our location_history.csv lives in Documents, but other files may live
  // in the bundle
  NSString *filePath = DocumentsFilePath(filename);
  if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    filePath = [bundle pathForResource:filename ofType:nil];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
      NSLog(@"Couldn't find dataset file %@", filename);
    }
  }
  self = [self initWithFilePath:filePath maxLocations:maxLocations];
  _filename = filename;
  return self;
}

- (id)initWithFilePath:(NSString *)filePath
          maxLocations:(NSUInteger)maxLocations {
  self = [super init];
  if (self) {
    _filePath = filePath;
    _maxLocations = maxLocations;
    [self loadWithFilePath:filePath maxLocations:maxLocations];
  }
  return self;
}

- (void)reload {
  [self loadWithFilePath:_filePath maxLocations:_maxLocations];
}

- (void)loadWithFilePath:(NSString *)filePath
            maxLocations:(NSUInteger)maxLocations {
  if ([filePath hasSuffix:@".csv"]) {
    NSString *csvString =
        [NSString stringWithContentsOfFile:filePath
                                  encoding:NSUTF8StringEncoding
                                     error:nil];
    [self parseCSVString:csvString];
  } else if ([filePath hasSuffix:@".json"]) {
    NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
    [self parseOpenPathsJSONData:jsonData];
  } else {
    NSLog(@"Don't know how to parse file %@", filePath);
  }
  NSLog(@"Loaded FBDataset from %@ with %ld locations", filePath,
        (long)self.locations.count);
  if (maxLocations > 0) {
    [self trimDatasetToMaxLocations:maxLocations];
    NSLog(@"Trimmed FBDataset to %ld locations", (long)self.locations.count);
  }

  if (self.locations.count > 0) {
    FBLocation *location = [self.locations firstObject];
    self.earliestLoadedDate =
        [NSDate dateWithTimeIntervalSince1970:location.timestamp];
  }
}

- (void)parseCSVString:(NSString *)csvString {
  NSArray *lines = [csvString componentsSeparatedByString:@"\n"];

  self.minLatitude = DBL_MAX;
  self.maxLatitude = -DBL_MAX;
  self.minLongitude = DBL_MAX;
  self.maxLongitude = -DBL_MAX;
  self.locations = [NSMutableArray arrayWithCapacity:lines.count];
  BOOL isOpenPathsCSV =
      [lines[0] hasPrefix:@"lat,lon,alt,date,device,os,version"];

  // OpenPaths date format: 2013-08-29 17:04:00
  NSDateFormatter *openPathsDateFormatter = [[NSDateFormatter alloc] init];
  openPathsDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";

  FBLocation *prevLocation;
  for (NSString *line in lines) {
    // make sure we properly handle CSV-escaping
    // and take [0] because CHCSVParser is handing back [[...],[]]
    NSArray *components = [line CSVComponents][0];

    double latitude;
    double longitude;
    NSTimeInterval timeInterval;

    if (isOpenPathsCSV) {
      // lat,lon,alt,date,device,os,version
      if (components.count < 5 || [components[0] isEqualToString:@"lat"]) {
        // skip malformed/insufficient or header lines
        continue;
      }
      latitude = [components[0] doubleValue];
      longitude = [components[1] doubleValue];
      NSDate *date = [openPathsDateFormatter dateFromString:components[3]];
      timeInterval = [date timeIntervalSince1970];
    } else {
      // lat,lon,timestamp
      if (components.count != 3) {
        // skip malformed lines
        // TODO: we could use a CSV parser or a regex to check lines
        continue;
      }
      latitude = [components[0] doubleValue];
      longitude = [components[1] doubleValue];
      timeInterval = [components[2] doubleValue];
    }

    FBLocation *location = [[FBLocation alloc] init];
    location.latitude = latitude;
    location.longitude = longitude;
    location.timestamp = timeInterval;
    [self.locations addObject:location];
    prevLocation = location;

    // keep track of min/max lat/lng
    if (latitude < self.minLatitude) {
      self.minLatitude = latitude;
    }
    if (latitude > self.maxLatitude) {
      self.maxLatitude = latitude;
    }
    if (longitude < self.minLongitude) {
      self.minLongitude = longitude;
    }
    if (longitude > self.maxLongitude) {
      self.maxLongitude = longitude;
    }
  }
}

- (void)parseOpenPathsJSONData:(NSData *)data {
  NSError *error;
  NSArray *jsonLocations = [NSJSONSerialization JSONObjectWithData:data
                                                           options:kNilOptions
                                                             error:&error];
  if (error) {
    // TODO: push error handling higher, to consumer
    NSLog(@"error parsing JSON file: %@", error);
    return;
  }

  self.minLatitude = DBL_MAX;
  self.maxLatitude = -DBL_MAX;
  self.minLongitude = DBL_MAX;
  self.maxLongitude = -DBL_MAX;

  self.locations = [NSMutableArray arrayWithCapacity:jsonLocations.count];

  FBLocation *prevLocation;
  for (NSDictionary *dict in jsonLocations) {
    // OpenPaths JSON fields
    double latitude = [[dict objectForKey:@"lat"] doubleValue];
    double longitude = [[dict objectForKey:@"lon"] doubleValue];
    NSTimeInterval timeInterval = [[dict objectForKey:@"t"] doubleValue];

    FBLocation *location = [[FBLocation alloc] init];
    location.latitude = latitude;
    location.longitude = longitude;
    location.timestamp = timeInterval;
    [self.locations addObject:location];
    prevLocation = location;

    // keep track of min/max lat/lng
    if (latitude < self.minLatitude) {
      self.minLatitude = latitude;
    }
    if (latitude > self.maxLatitude) {
      self.maxLatitude = latitude;
    }
    if (longitude < self.minLongitude) {
      self.minLongitude = longitude;
    }
    if (longitude > self.maxLongitude) {
      self.maxLongitude = longitude;
    }
  }
}

// TODO: this still has us loading *all* the locations before trimming down
- (void)trimDatasetToMaxLocations:(NSUInteger)maxLocations {
  NSInteger tooMany = self.locations.count - maxLocations;
  if (tooMany > 0) {
    [self.locations removeObjectsInRange:NSMakeRange(0, tooMany)];
  }
}

- (void)filterDatasetWithStartDate:(NSDate *)startDate
                           endDate:(NSDate *)endDate {
  NSMutableArray *toRemove = [NSMutableArray array];

  /*
   * We have to bump the date otherwise we won't include any points
   * that would be inclusive to that date.
   */
  double endTimestamp = [[endDate nextDate] timeIntervalSince1970];

  double startTimestamp = [startDate timeIntervalSince1970];

  for (FBLocation *location in self.locations) {
    if (location.timestamp < startTimestamp ||
        location.timestamp > endTimestamp) {
      [toRemove addObject:location];
    }
  }
  [self.locations removeObjectsInArray:toRemove];
}

- (NSDate *)earliestDate {
  // assume locations are in time-sorted order
  FBLocation *location = [self.locations firstObject];
  if (!location) {
    return nil;
  }
  return [NSDate dateWithTimeIntervalSince1970:location.timestamp];
}

@end
