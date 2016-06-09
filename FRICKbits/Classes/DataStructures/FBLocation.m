//
//  FBLocationDatum.m
//  FrickBits
//
//  Created by Matt McGlincy on 1/21/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBLocation.h"

CLLocationCoordinate2D AverageCoordinateOfFBLocations(NSArray *locations) {
    double sumLat = 0;
    double sumLon = 0;
    for (FBLocation *location in locations) {
        sumLat += location.latitude;
        sumLon += location.longitude;
    }
    return CLLocationCoordinate2DMake(sumLat / locations.count, sumLon / locations.count);
}

@implementation FBLocation

@dynamic coordinate;

- (id)initWithLatitude:(double)latitude longitude:(double)longitude {
    self = [super init];
    if (self) {
        self.latitude = latitude;
        self.longitude = longitude;
        self.timestamp = [[NSDate date] timeIntervalSince1970];
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

@end
