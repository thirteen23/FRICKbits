//
//  FBSettingsManager.m
//  FrickBits
//
//  Created by Matt McGlincy on 2/6/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBSettingsManager.h"

@implementation FBSettingsManager

+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        [self reloadSettings];
    }
    return self;
}

- (void)setDefaults {
    self.debug = NO;
    self.minBorderAlpha = 0.6;
    self.maxBorderAlpha = 0.8;
    self.minBorderWhite = 0.2;
    self.maxBorderWhite = 0.2;
    self.minBorderWidth = 0.5;
    self.maxBorderWidth = 1.0;
    self.minJiggle = 0.0;
    self.maxJiggle = 1.0;
    self.minBitThickness = 7.0;
    self.maxBitThickness = 7.0;
    self.textureImageFilename = @"texture_dark.jpg";
    self.borderSmoothness = 4;
}

static NSString * const kSettingHasSetInitialDefaults = @"hassetinitialdefaults";
static NSString * const kSettingRestoreDefaults = @"restoredefaults_preference";
static NSString * const kSettingDebug = @"debug_preference";
static NSString * const kSettingMinBorderAlpha = @"minborderalpha_preference";
static NSString * const kSettingMaxBorderAlpha = @"maxborderalpha_preference";
static NSString * const kSettingMinBorderWhite = @"minborderwhite_preference";
static NSString * const kSettingMaxBorderWhite = @"maxborderwhite_preference";
static NSString * const kSettingMinBorderWidth = @"minborderwidth_preference";
static NSString * const kSettingMaxBorderWidth = @"maxborderwidth_preference";
static NSString * const kSettingMinJiggle = @"minjiggle_preference";
static NSString * const kSettingMaxJiggle = @"maxjiggle_preference";
static NSString * const kSettingMinBitThickness = @"minbitthickness_preference";
static NSString * const kSettingMaxBitThickness = @"maxbitthickness_preference";
static NSString * const kSettingBorderSmoothness = @"bordersmoothness_preference";
static NSString * const kSettingTextureImageFilename = @"textureimagefilename_preference";

- (void)maybeSetInitialDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasSetInitialDefaults = [defaults boolForKey:kSettingHasSetInitialDefaults];
    BOOL restoreDefaults = [defaults boolForKey:kSettingRestoreDefaults];
    if (!hasSetInitialDefaults || restoreDefaults) {
        [defaults setBool:YES forKey:kSettingHasSetInitialDefaults];
        [defaults setBool:NO forKey:kSettingRestoreDefaults];
        [self setDefaults];
        [self save];
    }
}

- (void)save {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:self.debug forKey:kSettingDebug];
    [defaults setFloat:self.minBorderAlpha forKey:kSettingMinBorderAlpha];
    [defaults setFloat:self.maxBorderAlpha forKey:kSettingMaxBorderAlpha];
    [defaults setFloat:self.minBorderWhite forKey:kSettingMinBorderWhite];
    [defaults setFloat:self.maxBorderWhite forKey:kSettingMaxBorderWhite];
    [defaults setFloat:self.minBorderWidth forKey:kSettingMinBorderWidth];
    [defaults setFloat:self.maxBorderWidth forKey:kSettingMaxBorderWidth];
    [defaults setFloat:self.minJiggle forKey:kSettingMinJiggle];
    [defaults setFloat:self.maxJiggle forKey:kSettingMaxJiggle];
    [defaults setFloat:self.minBitThickness forKey:kSettingMinBitThickness];
    [defaults setFloat:self.maxBitThickness forKey:kSettingMaxBitThickness];
    [defaults setInteger:self.borderSmoothness forKey:kSettingBorderSmoothness];
    [defaults setObject:self.textureImageFilename forKey:kSettingTextureImageFilename];
    [defaults synchronize];
}

- (void)reloadSettings {
    [self maybeSetInitialDefaults];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    CGFloat minBorderAlpha = [defaults floatForKey:kSettingMinBorderAlpha];
    CGFloat maxBorderAlpha = [defaults floatForKey:kSettingMaxBorderAlpha];
    CGFloat minBorderWhite = [defaults floatForKey:kSettingMinBorderWhite];
    CGFloat maxBorderWhite = [defaults floatForKey:kSettingMaxBorderWhite];
    CGFloat minBorderWidth = [defaults floatForKey:kSettingMinBorderWidth];
    CGFloat maxBorderWidth = [defaults floatForKey:kSettingMaxBorderWidth];
    CGFloat minJiggle = [defaults floatForKey:kSettingMinJiggle];
    CGFloat maxJiggle = [defaults floatForKey:kSettingMaxJiggle];
    CGFloat minBitThickness = [defaults floatForKey:kSettingMinBitThickness];
    CGFloat maxBitThickness = [defaults floatForKey:kSettingMaxBitThickness];

    // make sure our mins/maxes make sense
    self.minBorderAlpha = MIN(minBorderAlpha, maxBorderAlpha);
    self.maxBorderAlpha = MAX(minBorderAlpha, maxBorderAlpha);
    self.minBorderWhite = MIN(minBorderWhite, maxBorderWhite);
    self.maxBorderWhite = MAX(minBorderWhite, maxBorderWhite);
    self.minBorderWidth = MIN(minBorderWidth, maxBorderWidth);
    self.maxBorderWidth = MAX(minBorderWidth, maxBorderWidth);
    self.minJiggle = MIN(minJiggle, maxJiggle);
    self.maxJiggle = MAX(minJiggle, maxJiggle);
    self.minBitThickness = MIN(minBitThickness, maxBitThickness);
    self.maxBitThickness = MAX(minBitThickness, maxBitThickness);

    self.debug = [defaults boolForKey:kSettingDebug];
    self.borderSmoothness = [defaults integerForKey:kSettingBorderSmoothness];
    self.textureImageFilename = [defaults stringForKey:kSettingTextureImageFilename];
}

@end
