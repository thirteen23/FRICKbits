//
//  FBClusterAnnotation.m
//  TBAnnotationClustering
//
//  Created by Theodore Calmes on 10/8/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import "FBClusterCountAnnotation.h"

@implementation FBClusterCountAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate count:(NSInteger)count {
    self = [super init];
    if (self) {
        _coordinate = coordinate;
        _count = count;
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
    if (![object isKindOfClass:[FBClusterCountAnnotation class]]) {
        return NO;
    }
    return [self isEqualToClusterCountAnnotation:(FBClusterCountAnnotation *)object];
}

- (BOOL)isEqualToClusterCountAnnotation:(FBClusterCountAnnotation *)object {
    if (self == object) {
        return YES;
    }
    return (self.coordinate.latitude == object.coordinate.latitude &&
            self.coordinate.longitude == object.coordinate.longitude);
}


@end
