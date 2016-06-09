//
//  FBFrickBitRecipe.h
//  FrickBits
//
//  Created by Matt McGlincy on 1/15/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

// jiggle/randomization of a path
@interface FBPathRecipe : NSObject
@property (nonatomic) CGPoint p1Jiggle;
@property (nonatomic) CGPoint p2Jiggle;
@property (nonatomic) CGPoint p3Jiggle;
@property (nonatomic) CGPoint p4Jiggle;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) UIColor *color;
@property (nonatomic) NSInteger smoothness;
@end

// jiggle/randomization of a quad
@interface FBQuadRecipe : NSObject
@property (nonatomic, strong) FBPathRecipe *pathRecipe1;
@property (nonatomic, strong) FBPathRecipe *pathRecipe2;
@property (nonatomic, strong) FBPathRecipe *pathRecipe3;
@property (nonatomic, strong) FBPathRecipe *pathRecipe4;
@end

// jiggle/randomization of a frick bit
@interface FBFrickBitRecipe : NSObject
@property (nonatomic, strong) FBQuadRecipe *quadRecipe;
@property (nonatomic, strong) FBQuadRecipe *insetQuadRecipe;
@property (nonatomic) CGFloat thickness;
@property (nonatomic) UIColor *fillColor;
@property (nonatomic) UIImage *textureImageMultiply;
@property (nonatomic) UIImage *textureImageScreen;
@end
