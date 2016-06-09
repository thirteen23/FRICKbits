//
//  FBGridCellLocationsOverlay.m
//  FRICKbits
//
//  Created by Matt McGlincy on 7/22/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBGridCellLocationsOverlay.h"

@interface FBGridCellLocationsOverlay()
@property (nonatomic, strong) FBMapGridCell *cell;
@end

@implementation FBGridCellLocationsOverlay

- (id)initWithMapGridCell:(FBMapGridCell *)cell {
  self = [super init];
  if (self) {
    _cell = cell;
  }
  return self;
}

- (CLLocationCoordinate2D)coordinate {
  return MKCoordinateForMapPoint(_cell.mapRect.origin);
}

- (MKMapRect)boundingMapRect {
  return _cell.mapRect;
}

@end
