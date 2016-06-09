//
//  FBRecipeFactory.h
//  FrickBits
//
//  Created by Matt McGlincy on 1/10/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBColorPalette.h"
#import "FBFrickBitRecipe.h"

//
// Makes FrickBits.
//
@interface FBRecipeFactory : NSObject

@property(nonatomic, strong) FBColorPalette *colorPalette;

// border vertex x/y jiggle
@property(nonatomic) CGFloat minJiggle;
@property(nonatomic) CGFloat maxJiggle;

@property(nonatomic) CGFloat minBorderWidth;
@property(nonatomic) CGFloat maxBorderWidth;

// borders are some shade of gray
@property(nonatomic) CGFloat minBorderAlpha;
@property(nonatomic) CGFloat maxBorderAlpha;
@property(nonatomic) CGFloat minBorderWhite;
@property(nonatomic) CGFloat maxBorderWhite;

@property(nonatomic) CGFloat minBitThickness;
@property(nonatomic) CGFloat maxBitThickness;

@property(nonatomic) UIImage *textureImage;

// how granular the border lines are; effectively how many subcurves it gets
// split into. Higher is smoother.
@property(nonatomic) NSInteger borderSmoothness;

- (FBFrickBitRecipe *)makeFrickBitRecipe;
// a "perfect" frickbit has at least one non-jiggled quad
- (FBFrickBitRecipe *)makePerfectFrickBitRecipe;

- (FBFrickBitRecipe *)makeSkinnyFrickBitRecipe;

- (FBQuadRecipe *)makeQuadRecipe;
- (FBQuadRecipe *)makePerfectQuadRecipe;
- (FBQuadRecipe *)makeInteriorQuadRecipe;

- (FBPathRecipe *)makePathRecipe;
- (FBPathRecipe *)makePerfectPathRecipe;
- (FBPathRecipe *)makeInteriorPathRecipe;

// use saved settings to twiddle our various knobs
- (void)updateFromSettings;

@end
