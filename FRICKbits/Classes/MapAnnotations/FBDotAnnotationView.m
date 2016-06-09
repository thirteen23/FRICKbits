//
//  FBDotAnnotationView.m
//  FrickBits
//
//  Created by Matt McGlincy on 1/31/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBDotAnnotationView.h"

@implementation FBDotAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation
         reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
  if (self) {
    self.backgroundColor = [UIColor clearColor];
    self.canShowCallout = NO;
    // set a frame so drawRect will be called
    self.frame = CGRectMake(0, 0, FBDotRadius * 2, FBDotRadius * 2);
  }
  return self;
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetAllowsAntialiasing(context, true);
  [self.dotColor setFill];
  CGContextFillEllipseInRect(context, rect);
}

@end
