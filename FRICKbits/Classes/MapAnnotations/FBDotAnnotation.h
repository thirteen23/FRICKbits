//
//  FBDotAnnotation.h
//  FrickBits
//
//  Created by Matt McGlincy on 1/31/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface FBDotAnnotation : NSObject<MKAnnotation>

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
