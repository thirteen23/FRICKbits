//
//  FBGridCellLocationsOverlay.h
//  FRICKbits
//
//  Created by Matt McGlincy on 7/22/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "FBMapGridCell.h"

@interface FBGridCellLocationsOverlay : NSObject <MKOverlay>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) MKMapRect boundingMapRect;

@property (nonatomic, readonly) FBMapGridCell *cell;

- (id)initWithMapGridCell:(FBMapGridCell *)cell;

@end
