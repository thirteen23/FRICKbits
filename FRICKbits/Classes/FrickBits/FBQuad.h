//
//  FBQuad.h
//  FrickBits
//
//  Created by Matt McGlincy on 2/13/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

typedef struct FBQuad {
  CGPoint upperLeft;
  CGPoint upperRight;
  CGPoint lowerRight;
  CGPoint lowerLeft;
} FBQuad;

extern FBQuad FBQuadMake(CGPoint upperLeft, CGPoint upperRight,
                         CGPoint lowerRight, CGPoint lowerLeft);
extern FBQuad FBQuadMakeAroundPoints(CGPoint p1, CGPoint p2, CGFloat thickness);
extern FBQuad FBQuadInset(FBQuad quad, CGFloat inset);
extern FBQuad FBQuadOffset(FBQuad quad, CGPoint offset);
extern BOOL FBQuadIsTwisted(FBQuad quad);
extern FBQuad FBQuadMakeUntwisted(FBQuad quad);
extern CGPoint FBQuadCenterPoint(FBQuad quad);
extern CGRect FBQuadBoundingRect(FBQuad quad);
extern UIBezierPath *FBQuadBezierPath(FBQuad quad);
extern NSString *NSStringFromFBQuad(FBQuad quad);
extern BOOL FBQuadEqualToQuad(FBQuad q1, FBQuad q2);

// convert a quad from one layer's coordinate system to another
extern FBQuad FBQuadConvert(FBQuad q, CALayer *fromLayer, CALayer *toLayer);
