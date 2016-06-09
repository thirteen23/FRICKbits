//
//  FBQuad.m
//  FrickBits
//
//  Created by Matt McGlincy on 2/13/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBQuad.h"
#import "FBUtils.h"
#import "MTGeometry.h"

FBQuad FBQuadMake(CGPoint upperLeft, CGPoint upperRight, CGPoint lowerRight,
                  CGPoint lowerLeft) {
  FBQuad q;
  q.upperLeft = upperLeft;
  q.upperRight = upperRight;
  q.lowerRight = lowerRight;
  q.lowerLeft = lowerLeft;
  return q;
}

FBQuad FBQuadMakeAroundPoints(CGPoint p1, CGPoint p2, CGFloat thickness) {
  //
  // Figure out the rectangle vertices surrounding p1 and p2.
  //
  // rectangle vertices solved as points on the circle whose center is the
  // endpoint,
  // radius is our desired rectangle thickness, and angle is +/- 90 degrees from
  // our
  // line segment angle to the horizontal.
  //
  CGFloat lineAngle = atan2((p2.y - p1.y), (p2.x - p1.x));
  CGFloat counterClockwiseAngle = lineAngle + (M_PI / 2.0);

  // to solve for point on a circle of radius r at angle theta, we use
  // x = r * cos(theta), y = r * sin(theta)
  CGFloat deltaX = thickness * cos(counterClockwiseAngle);
  CGFloat deltaY = thickness * sin(counterClockwiseAngle);

  // upper left and lower left are around p1; upper right and lower right are
  // around p2
  // This is CoreGraphics, so -y is up.
  CGPoint ul = CGPointMake(p1.x - deltaX, p1.y - deltaY);
  CGPoint ll = CGPointMake(p1.x + deltaX, p1.y + deltaY);
  CGPoint ur = CGPointMake(p2.x - deltaX, p2.y - deltaY);
  CGPoint lr = CGPointMake(p2.x + deltaX, p2.y + deltaY);

  return FBQuadMake(ul, ur, lr, ll);
}

CGFloat delta(CGFloat f1, CGFloat f2) {
  if (f1 == f2) {
    return 0;
  } else if (f2 > f1) {
    return 1;
  } else {
    return -1;
  }
}

FBQuad FBQuadInset(FBQuad quad, CGFloat inset) {
  // to, "inset" move each vertex toward its opposite corner
  CGFloat ulx = delta(quad.upperLeft.x, quad.lowerRight.x);
  CGFloat uly = delta(quad.upperLeft.y, quad.lowerRight.y);
  CGFloat urx = delta(quad.upperRight.x, quad.lowerLeft.x);
  CGFloat ury = delta(quad.upperRight.y, quad.lowerLeft.y);
  CGFloat lrx = -inset * ulx;
  CGFloat lry = -inset * uly;
  CGFloat llx = -inset * urx;
  CGFloat lly = -inset * ury;
  CGPoint ul = CGPointMake(quad.upperLeft.x + ulx, quad.upperLeft.y + uly);
  CGPoint ur = CGPointMake(quad.upperRight.x + urx, quad.upperRight.y + ury);
  CGPoint lr = CGPointMake(quad.lowerRight.x + lrx, quad.lowerRight.y + lry);
  CGPoint ll = CGPointMake(quad.lowerLeft.x + llx, quad.lowerLeft.y + lly);
  return FBQuadMake(ul, ur, lr, ll);
}

FBQuad FBQuadOffset(FBQuad quad, CGPoint offset) {
  return FBQuadMake(CGPointPlusPoint(quad.upperLeft, offset),
                    CGPointPlusPoint(quad.upperRight, offset),
                    CGPointPlusPoint(quad.lowerRight, offset),
                    CGPointPlusPoint(quad.lowerLeft, offset));
}

BOOL FBQuadIsTwisted(FBQuad quad) {
  // a quad is twisted if the top line and bottom line intersect,
  // or if the left line and right line intersect.
  return (LinesIntersect(quad.upperLeft, quad.upperRight, quad.lowerLeft,
                         quad.lowerRight) ||
          LinesIntersect(quad.upperLeft, quad.lowerLeft, quad.upperRight,
                         quad.lowerRight));
}

FBQuad FBQuadMakeUntwisted(FBQuad quad) {
  if (LinesIntersect(quad.upperLeft, quad.upperRight, quad.lowerLeft,
                     quad.lowerRight)) {
    // flip the lowerLeft and upperLeft
    return FBQuadMake(quad.lowerLeft, quad.upperRight, quad.lowerRight,
                      quad.upperLeft);
  } else if (LinesIntersect(quad.upperLeft, quad.lowerLeft, quad.upperRight,
                            quad.lowerRight)) {
    // flip the lowerRight and the upperRight
    return FBQuadMake(quad.upperLeft, quad.lowerRight, quad.upperRight,
                      quad.lowerLeft);
  } else {
    // unchanged
    return quad;
  }
}

CGPoint FBQuadCenterPoint(FBQuad quad) {
  CGLine l1 = CGLineMake(quad.upperLeft, quad.lowerRight);
  CGLine l2 = CGLineMake(quad.lowerLeft, quad.upperRight);
  return CGLinesIntersectAtPoint(l1, l2);
}

CGRect FBQuadBoundingRect(FBQuad quad) {
  // figure out a CGRect that encloses all our points
  CGFloat minX = MAXFLOAT;
  CGFloat maxX = -MAXFLOAT;
  CGFloat minY = MAXFLOAT;
  CGFloat maxY = -MAXFLOAT;

  if (quad.upperLeft.x < minX) {
    minX = quad.upperLeft.x;
  }
  if (quad.upperRight.x < minX) {
    minX = quad.upperRight.x;
  }
  if (quad.lowerRight.x < minX) {
    minX = quad.lowerRight.x;
  }
  if (quad.lowerLeft.x < minX) {
    minX = quad.lowerLeft.x;
  }

  if (quad.upperLeft.x > maxX) {
    maxX = quad.upperLeft.x;
  }
  if (quad.upperRight.x > maxX) {
    maxX = quad.upperRight.x;
  }
  if (quad.lowerRight.x > maxX) {
    maxX = quad.lowerRight.x;
  }
  if (quad.lowerLeft.x > maxX) {
    maxX = quad.lowerLeft.x;
  }

  if (quad.upperLeft.y < minY) {
    minY = quad.upperLeft.y;
  }
  if (quad.upperRight.y < minY) {
    minY = quad.upperRight.y;
  }
  if (quad.lowerRight.y < minY) {
    minY = quad.lowerRight.y;
  }
  if (quad.lowerLeft.y < minY) {
    minY = quad.lowerLeft.y;
  }

  if (quad.upperLeft.y > maxY) {
    maxY = quad.upperLeft.y;
  }
  if (quad.upperRight.y > maxY) {
    maxY = quad.upperRight.y;
  }
  if (quad.lowerRight.y > maxY) {
    maxY = quad.lowerRight.y;
  }
  if (quad.lowerLeft.y > maxY) {
    maxY = quad.lowerLeft.y;
  }

  return CGRectMake(minX, minY, maxX - minX, maxY - minY);
}

UIBezierPath *FBQuadBezierPath(FBQuad quad) {
  UIBezierPath *bp = [UIBezierPath bezierPath];
  [bp moveToPoint:quad.upperLeft];
  [bp addLineToPoint:quad.upperRight];
  [bp addLineToPoint:quad.lowerRight];
  [bp addLineToPoint:quad.lowerLeft];
  [bp addLineToPoint:quad.upperLeft];
  return bp;
}

NSString *NSStringFromFBQuad(FBQuad quad) {
  return [NSString stringWithFormat:@"[(%f,%f), (%f,%f), (%f,%f), (%f,%f)]",
                                    quad.upperLeft.x, quad.upperLeft.y,
                                    quad.upperRight.x, quad.upperRight.y,
                                    quad.lowerRight.x, quad.lowerRight.y,
                                    quad.lowerLeft.x, quad.lowerLeft.y];
}

BOOL FBQuadEqualToQuad(FBQuad q1, FBQuad q2) {
  return (CGPointEqualToPoint(q1.upperLeft, q2.upperLeft) &&
          CGPointEqualToPoint(q1.upperRight, q2.upperRight) &&
          CGPointEqualToPoint(q1.lowerRight, q2.lowerRight) &&
          CGPointEqualToPoint(q1.lowerLeft, q2.lowerLeft));
}

FBQuad FBQuadConvert(FBQuad q, CALayer *fromLayer, CALayer *toLayer) {
  return FBQuadMake([toLayer convertPoint:q.upperLeft fromLayer:fromLayer],
                    [toLayer convertPoint:q.upperRight fromLayer:fromLayer],
                    [toLayer convertPoint:q.lowerRight fromLayer:fromLayer],
                    [toLayer convertPoint:q.lowerLeft fromLayer:fromLayer]);
}
