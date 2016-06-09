//
// Created by Matt McGlincy on 4/24/14.
// Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBColorPalette.h"
#import "FBColorPaletteManager.h"
#import "FBUtils.h"

NSString *const FBColorPaletteManagerPalettes = @"palettes";
NSString *const FBColorPaletteManagerHue = @"hue";
NSString *const FBColorPaletteManagerHero = @"hero";
NSString *const FBColorPaletteManagerPrimaryColors = @"base";
NSString *const FBColorPaletteManagerComplimentaryColors = @"comp";

static NSString *const kDefaultsColorPalette =
    @"FBColorPaletteManagerColorPalette";

@interface FBColorPaletteManager ()

@property(nonatomic, strong) dispatch_queue_t iVarQ;
@property(nonatomic, strong) NSArray *palettes;

@end

@implementation FBColorPaletteManager

@synthesize palettes = _palettes;

DEF_SAFE_GETSET_FOR_Q(NSArray *, palettes, setPalettes, _iVarQ);

+ (instancetype)sharedInstance {
  static id _sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^(void) { _sharedInstance = [[self alloc] init]; });
  return _sharedInstance;
}

- (id)init {
  if (self = [super init]) {

    _iVarQ = dispatch_queue_create("com.FRICKbits.FBColorPaletteManager.iVarQ",
                                   NULL);

    [self loadPalette];
  }
  return self;
}

- (void)loadPalette {
  NSData *data = [[NSUserDefaults standardUserDefaults]
      objectForKey:kDefaultsColorPalette];
  self.colorPalette = [NSKeyedUnarchiver unarchiveObjectWithData:data];

  // create a default palette if we don't already have one saved
  if (!self.colorPalette) {
    self.colorPalette = [[FBColorPalette alloc] init];
    [self savePalette];
  }
}

- (void)savePalette {
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.colorPalette];
  [[NSUserDefaults standardUserDefaults] setObject:data
                                            forKey:kDefaultsColorPalette];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSError *)getPalettesFromResources {
  NSError *error = nil;
  NSString *jsonPath =
      [[NSBundle mainBundle] pathForResource:@"palettes" ofType:@"json"];
  NSData *data = [NSData dataWithContentsOfFile:jsonPath];
  id json = [NSJSONSerialization JSONObjectWithData:data
                                            options:kNilOptions
                                              error:&error];
  if (_ISA_(json, NSDictionary)) {
    id potentialPalette = [json objectForKey:FBColorPaletteManagerPalettes];
    if (_ISA_(potentialPalette, NSArray)) {
      self.palettes = (NSArray *)potentialPalette;
    }
  }

  return error;
}

- (void)getPalettesFromResourcesWithCompletion:
            (void (^)(NSError *error))completion {

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                 ^(void) {

      NSError *error = [self getPalettesFromResources];

      if (completion) {
        dispatch_async(dispatch_get_main_queue(),
                       ^(void) { completion(error); });
      }
  });
}

- (NSArray *)getColorWheelFromPalettes {
  NSMutableArray *colorList = [[NSMutableArray alloc] init];

  dispatch_sync(_iVarQ, ^(void) {
      [_palettes
          enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
              if (_ISA_(obj, NSDictionary)) {
                NSDictionary *palette = (NSDictionary *)obj;
                id color = [palette objectForKey:FBColorPaletteManagerHero];
                if (_ISA_(color, NSString)) {
                  NSString *heroColor = (NSString *)color;
                  [colorList addObject:UIColorFromHexString(heroColor, 1.0f)];
                }
              }
          }];
  });

  return (0 != colorList.count) ? [NSArray arrayWithArray:colorList] : nil;
}

- (NSArray *)getPrimaryPaletteForIndex:(NSUInteger)index {
  __block NSArray *basePalette = nil;
  NSMutableArray *baseColors = [[NSMutableArray alloc] init];

  dispatch_sync(_iVarQ, ^(void) {
      id palette = [_palettes objectAtIndex:index];

      if (_ISA_(palette, NSDictionary)) {
        id base = [(NSDictionary *)palette
            objectForKey:FBColorPaletteManagerPrimaryColors];

        if (_ISA_(base, NSArray)) {
          basePalette = (NSArray *)base;
        }
      }
  });

  [basePalette
      enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
          if (_ISA_(obj, NSString)) {
            NSString *colorHexString = (NSString *)obj;
            [baseColors addObject:UIColorFromHexString(colorHexString, 1.0f)];
          }
      }];

  return (0 != baseColors.count) ? [NSArray arrayWithArray:baseColors] : nil;
}

- (NSArray *)getComplementPaletteForIndex:(NSUInteger)index {
  __block NSArray *compPalette = nil;
  NSMutableArray *compColors = [[NSMutableArray alloc] init];

  dispatch_sync(_iVarQ, ^(void) {
      id palette = [_palettes objectAtIndex:index];

      if (_ISA_(palette, NSDictionary)) {
        id comp = [(NSDictionary *)palette
            objectForKey:FBColorPaletteManagerComplimentaryColors];

        if (_ISA_(comp, NSArray)) {
          compPalette = (NSArray *)comp;
        }
      }
  });

  [compPalette
      enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
          if (_ISA_(obj, NSString)) {
            NSString *colorHexString = (NSString *)obj;
            [compColors addObject:UIColorFromHexString(colorHexString, 1.0f)];
          }
      }];

  return (0 != compColors.count) ? [NSArray arrayWithArray:compColors] : nil;
}

- (UIColor *)getHeroColorForIndex:(NSUInteger)index {
  __block UIColor *heroColor = nil;

  dispatch_sync(_iVarQ, ^(void) {
      id palette = [_palettes objectAtIndex:index];

      if (_ISA_(palette, NSDictionary)) {
        id colorHexString =
            [(NSDictionary *)palette objectForKey:FBColorPaletteManagerHero];

        if (_ISA_(colorHexString, NSString)) {
          heroColor = UIColorFromHexString((NSString *)colorHexString, 1.0f);
        }
      }
  });

  return heroColor;
}

- (NSNumber *)getHueValueForIndex:(NSUInteger)index {
  __block NSNumber *hueValue = nil;

  dispatch_sync(_iVarQ, ^(void) {
      id palette = [_palettes objectAtIndex:index];

      if (_ISA_(palette, NSDictionary)) {
        id hue =
            [(NSDictionary *)palette objectForKey:FBColorPaletteManagerHero];

        if (_ISA_(hue, NSNumber)) {
          hueValue =
              [NSNumber numberWithDouble:([(NSNumber *)hue doubleValue] /
                                          RADIANS_TO_DEGREES(M_PI * 2.0f))];
        }
      }
  });

  return hueValue;
}

@end