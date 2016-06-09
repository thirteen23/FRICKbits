//
//  FBColorPalette.m
//  FrickBits
//
//  Created by Matt McGlincy on 1/9/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBColorPalette.h"
#import "FBUtils.h"

@interface FBColorPalette ()

@property(nonatomic, strong) dispatch_queue_t iVarQ;

@property(nonatomic, strong) NSArray *primaryColors;
@property(nonatomic, strong) NSArray *complementaryColors;

@end

@implementation FBColorPalette

@synthesize iVarQ = _iVarQ, primaryColors = _primaryColors,
            complementaryColors = _complementaryColors,
            seedColor = _seedColor;

DEF_SAFE_GETSET_FOR_Q(UIColor *, seedColor, setSeedColor, _iVarQ);
DEF_SAFE_GETSET_FOR_Q(NSArray *, primaryColors, setPrimaryColors, _iVarQ);
DEF_SAFE_GETSET_FOR_Q(NSArray *, complementaryColors, setComplementaryColors,
                      _iVarQ);

- (id)init {
  NSArray *primaryColorHexes = @[
    @"#e16b50",
    @"#d66a81",
    @"#f06e7f",
    @"#f1866d",
    @"#f58b54",
    @"#f79f84",
    @"#f4a66b",
    @"#fac075",
    @"#f8ac8f",
    @"#fbd171",
    @"#fbbb92",
    @"#fcc8a1",
    @"#f9c8d6",
    @"#fecd94",
    @"#fede6e",
    @"#ffe780",
    @"#fedcbf",
    @"#fbee7a",
    @"#fbf2a5",
    @"#fcf5b7",
  ];
  NSArray *complementaryColorHexes = @[
    @"#88617b",
    @"#966175",
    @"#6b8bbf",
    @"#5f958c",
    @"#918ea8",
    @"#b9b24f",
    @"#dda0aa",
    @"#c088b7",
    @"#939bca",
    @"#be9fba",
    @"#81bfe7",
    @"#c7a8ca",
    @"#83c2a1",
    @"#a5cd9b",
    @"#8fd0e2",
    @"#cfda8c",
    @"#a6c7d2",
    @"#d0bcda",
    @"#dad7d3",
    @"#f4ddeb",
  ];
  return [self initWithSeedColorHex:primaryColorHexes[0]
                  primaryColorHexes:primaryColorHexes
            complementaryColorHexes:complementaryColorHexes];
}

- (id)initWithSeedColorHex:(NSString *)seedColorHex
         primaryColorHexes:(NSArray *)primaryColorHexes
        complementaryColorHexes:(NSArray *)complementaryColorHexes {
  UIColor *seedColor = UIColorFromHexString(seedColorHex, 1.0);
  NSArray *primaryColors = [FBColorPalette colorsWithColorHexes:primaryColorHexes];
  NSArray *complementaryColors = [FBColorPalette colorsWithColorHexes:complementaryColorHexes];
  
  return [self initWithSeedColor:seedColor primaryColors:primaryColors complementaryColors:complementaryColors];
}

// @return an NSArray of UIColors from the given array of #ffffff hex-string colors
+ (NSArray *)colorsWithColorHexes:(NSArray *)colorHexes {
  NSMutableArray *colors = [NSMutableArray arrayWithCapacity:colorHexes.count];
  for (NSString *hex in colorHexes) {
    UIColor *color = UIColorFromHexString(hex, 1.0);
    [colors addObject:color];
  }
  return [NSArray arrayWithArray:colors];
}

- (instancetype)initWithSeedColor:(UIColor *)seed
                    primaryColors:(NSArray *)primarys
              complementaryColors:(NSArray *)complements {
  if (self = [super init]) {
    [self commonInit];
    self.seedColor = seed;
    self.primaryColors = primarys;
    self.complementaryColors = complements;
  }
  return self;
}

- (void)commonInit {
  self.iVarQ =
      dispatch_queue_create("com.FRICKbits.FBColorPalette.iVarQ", NULL);
}

- (UIColor *)nextPrimaryColor {
  NSUInteger rand = arc4random_uniform((uint32_t)_primaryColors.count);
  return _primaryColors[rand];
}

- (UIColor *)nextComplementaryColor {
  NSUInteger rand = arc4random_uniform((uint32_t)_complementaryColors.count);
  return _complementaryColors[rand];
}

#pragma mark - NSCoding

static NSString *const kPrimaryColors = @"primaryColors";
static NSString *const kComplementaryColors = @"complementaryColors";
static NSString *const kSeedColor = @"seedColor";
static NSString *const kIndex = @"index";

- (id)initWithCoder:(NSCoder *)decoder {
  if (self = [super init]) {
    [self commonInit];
    self.index = [decoder decodeIntegerForKey:kIndex];
    self.seedColor = [decoder decodeObjectForKey:kSeedColor];
    self.primaryColors = [decoder decodeObjectForKey:kPrimaryColors];
    self.complementaryColors = [decoder decodeObjectForKey:kComplementaryColors];
  }
  return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
  [encoder encodeInteger:self.index forKey:kIndex];
  [encoder encodeObject:self.seedColor forKey:kSeedColor];
  [encoder encodeObject:self.primaryColors forKey:kPrimaryColors];
  [encoder encodeObject:self.complementaryColors forKey:kComplementaryColors];
}

@end
