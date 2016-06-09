//
//  TBUtils.h
//  FrickBits
//
//  Created by Matt McGlincy on 1/31/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "TBQuadTree.h"

TBBoundingBox TBBoundingBoxForMapRect(MKMapRect mapRect);
MKMapRect TBMapRectForBoundingBox(TBBoundingBox boundingBox);
NSInteger TBZoomScaleToZoomLevel(MKZoomScale scale);
float TBCellSizeForZoomScale(MKZoomScale zoomScale);
CGPoint TBRectCenter(CGRect rect);
CGRect TBCenterRect(CGRect rect, CGPoint center);
