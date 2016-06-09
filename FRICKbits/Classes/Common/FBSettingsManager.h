//
//  FBSettingsManager.h
//  FrickBits
//
//  Created by Matt McGlincy on 2/6/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

@interface FBSettingsManager : NSObject

@property (nonatomic) BOOL debug;

// RecipeFactory settings
@property (nonatomic) CGFloat minJiggle;
@property (nonatomic) CGFloat maxJiggle;
@property (nonatomic) CGFloat minBorderWidth;
@property (nonatomic) CGFloat maxBorderWidth;
@property (nonatomic) CGFloat minBorderAlpha;
@property (nonatomic) CGFloat maxBorderAlpha;
@property (nonatomic) CGFloat minBorderWhite;
@property (nonatomic) CGFloat maxBorderWhite;
@property (nonatomic) CGFloat minBitThickness;
@property (nonatomic) CGFloat maxBitThickness;
@property (nonatomic) NSString *textureImageFilename;
@property (nonatomic) NSInteger borderSmoothness;

+ (instancetype)sharedInstance;
- (void)reloadSettings;
- (void)setDefaults;
- (void)save;

@end
