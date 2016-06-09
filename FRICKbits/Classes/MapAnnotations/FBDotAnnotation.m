//
//  FBDotAnnotation.m
//  FrickBits
//
//  Created by Matt McGlincy on 1/31/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBDotAnnotation.h"

@implementation FBDotAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    self = [super init];
    if (self) {
        _coordinate = coordinate;
    }
    return self;
}

- (NSUInteger)hash {
  return (NSUInteger)(self.coordinate.latitude * 1000 * 17) ^ (NSUInteger)(self.coordinate.longitude * 1000);
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[FBDotAnnotation class]]) {
        return NO;
    }
    return [self isEqualToDotAnnotation:(FBDotAnnotation *)object];
}

- (BOOL)isEqualToDotAnnotation:(FBDotAnnotation *)object {
    if (self == object) {
        return YES;
    }
    return (self.coordinate.latitude == object.coordinate.latitude &&
            self.coordinate.longitude == object.coordinate.longitude);
}

@end
