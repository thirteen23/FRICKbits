//
//  FBSplitBit.h
//  FrickBits
//
//  Created by Matt McGlincy on 2/24/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBAbstractBitLayer.h"
#import "FBRecipeFactory.h"
#import "FBFrickBitLayer.h"

@interface FBSplitBitLayer : FBAbstractBitLayer

@property(nonatomic, strong) FBFrickBitLayer *bit1;
@property(nonatomic, strong) FBFrickBitLayer *bit2;

- (id)initWithFactory:(FBRecipeFactory *)factory
    fromPointInParent:(CGPoint)fromPointInParent
      toPointInParent:(CGPoint)toPointInParent;

- (BOOL)isTwisted;

// untwist any "twisted" or crossing children bits.
// callers should subsquently call updateQuad / updatePaths.
- (void)untwist;

// update quad to enclose all children bits.
- (void)updateQuad;

// update paths and mask to reflect current quad.
- (void)updatePaths;

@end
