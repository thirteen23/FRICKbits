//
// Created by Matt McGlincy on 4/24/14.
// Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const FBColorPaletteManagerPalettes;
extern NSString *const FBColorPaletteManagerHue;
extern NSString *const FBColorPaletteManagerHero;
extern NSString *const FBColorPaletteManagerPrimaryColors;
extern NSString *const FBColorPaletteManagerComplimentaryColors;

@class FBColorPalette;

@interface FBColorPaletteManager : NSObject

@property(nonatomic, strong) FBColorPalette *colorPalette;

+ (instancetype)sharedInstance;

- (void)loadPalette;
- (void)savePalette;

// acquire the palettes via json resource file synchronously
- (NSError *)getPalettesFromResources;

// acquire the palettes via json resource file asynchronously
- (void)getPalettesFromResourcesWithCompletion:
        (void (^)(NSError *error))completion;

// acquire NSArray of hero UIColors from the palette list
- (NSArray *)getColorWheelFromPalettes;

// acquire NSArray base palette of UIColors for index
- (NSArray *)getPrimaryPaletteForIndex:(NSUInteger)index;

// acquire NSArray complement palette for index
- (NSArray *)getComplementPaletteForIndex:(NSUInteger)index;

// acquire hero UIColor for index
- (UIColor *)getHeroColorForIndex:(NSUInteger)index;

// acquire hue value for index in percent
- (NSNumber *)getHueValueForIndex:(NSUInteger)index;

@end