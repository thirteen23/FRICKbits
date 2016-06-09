//
//  FBLocation.h
//  FrickBits
//
//  Created by Matt McGlincy on 1/21/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

CLLocationCoordinate2D AverageCoordinateOfFBLocations(NSArray *locations);

@interface FBLocation : NSObject

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;
// UTC seconds
@property (nonatomic) double timestamp;

// generic id pointer for what cell/cluster/etc this location gets grouped into
@property (nonatomic, weak) id cell;

// convenience readonly coordinate
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithLatitude:(double)latitude longitude:(double)longitude;

@end
