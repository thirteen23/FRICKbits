//
//  FBGridCellAnnotationView.h
//  FrickBits
//
//  Created by Matthew McGlincy on 2/1/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface FBGridCellAnnotationView : MKAnnotationView

@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic) CGFloat lineWidth;

@end
