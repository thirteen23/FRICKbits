//
//  FBFrickBitLayer.h
//  FrickBits
//
//  Created by Matt McGlincy on 1/30/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBAbstractBitLayer.h"
#import "FBJoin.h"
#import "FBJoinNode.h"
#import "FBQuad.h"
#import "FBQuadPathLayer.h"

@interface FBFrickBitLayer : FBAbstractBitLayer

- (id)initWithRecipe:(FBFrickBitRecipe *)recipe
    fromPointInParent:(CGPoint)fromPoint
      toPointInParent:(CGPoint)toPoint;

// update paths and mask based on current quad
- (void)updatePaths;

@end
