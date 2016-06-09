//
//  FBColorPalette.h
//  FrickBits
//
//  Created by Matt McGlincy on 1/9/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <Foundation/Foundation.h>

//
// Color cycler.
//
@interface FBColorPalette : NSObject <NSCoding>

@property(nonatomic) NSUInteger index;
@property(nonatomic, readonly) UIColor *seedColor;

- (id)initWithSeedColorHex:(NSString *)seedColorHex
         primaryColorHexes:(NSArray *)primaryColorHexes
   complementaryColorHexes:(NSArray *)complementaryColorHexes;

- (instancetype)initWithSeedColor:(UIColor *)seed
                    primaryColors:(NSArray *)primarys
              complementaryColors:(NSArray *)complements;

- (UIColor *)nextPrimaryColor;
- (UIColor *)nextComplementaryColor;

@end
