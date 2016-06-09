//
//  FBGridCellAnnotation.m
//  FrickBits
//
//  Created by Matthew McGlincy on 2/1/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBGridCellAnnotation.h"

@implementation FBGridCellAnnotation

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
    if (![object isKindOfClass:[FBGridCellAnnotation class]]) {
        return NO;
    }
    
    return [self isEqualToGridCellAnnotation:(FBGridCellAnnotation *)object];
}

- (BOOL)isEqualToGridCellAnnotation:(FBGridCellAnnotation *)object {
    if (!object) {
        return NO;
    }
    return (self.coordinate.latitude == object.coordinate.latitude &&
            self.coordinate.longitude == object.coordinate.longitude);
}

@end
