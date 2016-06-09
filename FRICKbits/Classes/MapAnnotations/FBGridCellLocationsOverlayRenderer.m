//
//  FBGridCellLocationsOverlayRenderer.m
//  FRICKbits
//
//  Created by Matt McGlincy on 7/22/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBChrome.h"
#import "FBLocation.h"
#import "FBGridCellLocationsOverlay.h"
#import "FBGridCellLocationsOverlayRenderer.h"
#import "FBUtils.h"

@implementation FBGridCellLocationsOverlayRenderer

static CGFloat dotRadius = 2.0;

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
  // outline, useful for debugging
//  CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
//  CGContextSetLineWidth(context, 1 / zoomScale);
//  CGRect boundingRect = [self rectForMapRect:self.overlay.boundingMapRect];
//  CGContextStrokeRect(context, boundingRect);

  CGFloat scaledRadius = dotRadius / zoomScale;

  // draw points for every location in the cell
  FBGridCellLocationsOverlay *overlay = (FBGridCellLocationsOverlay *)self.overlay;
  CGContextSetFillColorWithColor(context, [FBChrome perLocationPointColor].CGColor);
  for (FBLocation *location in overlay.cell.locations) {
    MKMapPoint mapPoint = MKMapPointForCoordinate(CLLocationCoordinate2DMake(location.latitude, location.longitude));
    CGPoint center = [self pointForMapPoint:mapPoint];
    CGRect rect = CGRectMake(center.x - scaledRadius,
                             center.y - scaledRadius,
                             scaledRadius * 2,
                             scaledRadius * 2);
    CGContextAddEllipseInRect(context, rect);
    CGContextDrawPath(context, kCGPathFill);
    CGContextStrokePath(context);
  }
}

@end
