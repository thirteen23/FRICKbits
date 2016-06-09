//
//  FBFillerBitLayer.h
//  FRICKbits
//
//  Created by Matt McGlincy on 6/25/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBAbstractBitLayer.h"
#import "FBFrickBitLayer.h"
#import "FBQuadPathLayer.h"
#import "FBRecipeFactory.h"
#import "FBQuad.h"


@interface FBFillerBitLayer : FBFrickBitLayer

@property(nonatomic, strong) FBQuadPathLayer *quadPath;
@property(nonatomic, strong) NSMutableArray *frickBitLayers;
@property(nonatomic) NSUInteger numberOfSegments;

- (id)initWithFactory:(FBRecipeFactory *)factory
    fromPointInParent:(CGPoint)fromPointInParent
      toPointInParent:(CGPoint)toPointInParent
     numberOfSegments:(NSUInteger)numberOfSegments;

@end
