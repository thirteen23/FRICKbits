//
//  FBRecipeFactory.m
//  FrickBits
//
//  Created by Matt McGlincy on 1/10/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBRecipeFactory.h"
#import "FBSettingsManager.h"
#import "FBSmoothPath.h"
#import "FBUtils.h"
#import "UIBezierPath-Smoothing.h"

@interface FBRecipeFactory ()

@property(nonatomic, strong) UIImage *imageToMultiply;
@property(nonatomic, strong) UIImage *imageToScreen;

@end

@implementation FBRecipeFactory

- (id)init {
  self = [super init];
  if (self) {
    self.colorPalette = [[FBColorPalette alloc] init];
    self.imageToMultiply = [UIImage imageNamed:@"texture_multiply.jpg"];
    self.imageToScreen = [UIImage imageNamed:@"texture_screen.jpg"];
    [self updateFromSettings];
  }
  return self;
}

- (void)updateFromSettings {
  FBSettingsManager *settings = [FBSettingsManager sharedInstance];
  self.minBorderAlpha = settings.minBorderAlpha;
  self.maxBorderAlpha = settings.maxBorderAlpha;
  self.minBorderWhite = settings.minBorderWhite;
  self.maxBorderWhite = settings.maxBorderWhite;
  self.minBorderWidth = settings.minBorderWidth;
  self.maxBorderWidth = settings.maxBorderWidth;
  self.minJiggle = settings.minJiggle;
  self.maxJiggle = settings.maxJiggle;
  self.minBitThickness = settings.minBitThickness;
  self.maxBitThickness = settings.maxBitThickness;
  self.textureImage = [UIImage imageNamed:settings.textureImageFilename];
  self.borderSmoothness = settings.borderSmoothness;
}

- (FBFrickBitRecipe *)makeFrickBitRecipe {
  FBFrickBitRecipe *r = [[FBFrickBitRecipe alloc] init];
  r.quadRecipe = [self makeQuadRecipe];
  r.insetQuadRecipe = [self makeQuadRecipe];
  r.thickness = [self randBitThickness];
  r.textureImageMultiply = self.imageToMultiply;
  r.textureImageScreen = self.imageToScreen;
  r.fillColor = [self.colorPalette nextPrimaryColor];
  return r;
}

- (FBFrickBitRecipe *)makePerfectFrickBitRecipe {
  FBFrickBitRecipe *r = [[FBFrickBitRecipe alloc] init];
  r.quadRecipe = [self makePerfectQuadRecipe];
  r.insetQuadRecipe = [self makeQuadRecipe];
  r.thickness = [self randBitThickness];
  r.textureImageMultiply = self.imageToMultiply;
  r.textureImageScreen = self.imageToScreen;
  r.fillColor = [self.colorPalette nextPrimaryColor];
  return r;
}

- (FBFrickBitRecipe *)makeSkinnyFrickBitRecipe {
  FBFrickBitRecipe *r = [self makePerfectFrickBitRecipe];
  r.thickness = r.thickness / 2.0;
  return r;
}

- (FBQuadRecipe *)makeQuadRecipe {
  FBQuadRecipe *r = [[FBQuadRecipe alloc] init];
  r.pathRecipe1 = [self makePathRecipe];
  r.pathRecipe2 = [self makePathRecipe];
  r.pathRecipe3 = [self makePathRecipe];
  r.pathRecipe4 = [self makePathRecipe];
  return r;
}

- (FBQuadRecipe *)makePerfectQuadRecipe {
  FBQuadRecipe *r = [[FBQuadRecipe alloc] init];
  r.pathRecipe1 = [self makePerfectPathRecipe];
  r.pathRecipe2 = [self makePerfectPathRecipe];
  r.pathRecipe3 = [self makePerfectPathRecipe];
  r.pathRecipe4 = [self makePerfectPathRecipe];
  return r;
}

- (FBQuadRecipe *)makeInteriorQuadRecipe {
  FBQuadRecipe *r = [[FBQuadRecipe alloc] init];
  r.pathRecipe1 = [self makeInteriorPathRecipe];
  r.pathRecipe2 = [self makeInteriorPathRecipe];
  r.pathRecipe3 = [self makeInteriorPathRecipe];
  r.pathRecipe4 = [self makeInteriorPathRecipe];
  return r;
}

- (FBPathRecipe *)makePathRecipe {
  FBPathRecipe *r = [[FBPathRecipe alloc] init];
  r.lineWidth = [self randBorderWidth];
  r.color = [self randBorderColor];
  r.p1Jiggle = [self randJigglePoint];
  r.p2Jiggle = [self randJigglePoint];
  r.p3Jiggle = [self randJigglePoint];
  r.p4Jiggle = [self randJigglePoint];
  return r;
}

- (FBPathRecipe *)makePerfectPathRecipe {
  // a "perfect" path has no jiggle
  FBPathRecipe *r = [[FBPathRecipe alloc] init];
  r.lineWidth = [self randBorderWidth];
  r.color = [self randBorderColor];
  r.p1Jiggle = CGPointZero;
  r.p2Jiggle = CGPointZero;
  r.p3Jiggle = CGPointZero;
  r.p4Jiggle = CGPointZero;
  return r;
}

- (FBPathRecipe *)makeInteriorPathRecipe {
  FBPathRecipe *r = [[FBPathRecipe alloc] init];
  r.lineWidth = [self randBorderWidth];
  r.color = [self randBorderColor];
  r.p1Jiggle = [self randJigglePoint];
  r.p2Jiggle = [self randJigglePoint];
  r.p3Jiggle = [self randJigglePoint];
  r.p4Jiggle = [self randJigglePoint];
  return r;
}

- (CGFloat)randBitThickness {
  return TenthsRand(self.minBitThickness, self.maxBitThickness);
}

- (CGFloat)randBorderWidth {
  return TenthsRand(self.minBorderWidth, self.maxBorderWidth);
}

- (UIColor *)randBorderColor {
  CGFloat w = TenthsRand(self.minBorderWhite, self.maxBorderWhite);
  CGFloat a = TenthsRand(self.minBorderAlpha, self.maxBorderAlpha);
  return [UIColor colorWithWhite:w alpha:a];
}

- (CGPoint)randJigglePoint {
  return CGPointMake([self randJiggle], [self randJiggle]);
}

- (CGFloat)randJiggle {
  return TenthsRand(self.minJiggle, self.maxJiggle);
}

@end
