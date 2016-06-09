//
//  FBGridCellAnnotation.h
//  FrickBits
//
//  Created by Matthew McGlincy on 2/1/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "FBMapGridCell.h"

@interface FBGridCellAnnotation : NSObject<MKAnnotation>

@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;

@property (nonatomic, strong) FBMapGridCell *cell;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
