//
//  FBOnboardingFrickColumnLayer.h
//  FRICKbits
//
//  Created by Michael Van Milligan on 5/29/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface FBOnboardingFrickColumnLayer : CALayer

@property(nonatomic) NSInteger tag;
@property(nonatomic, readonly) NSUInteger numBits;

- (instancetype)initWithHeight:(CGFloat)height
                     withWidth:(CGFloat)width
                     withShift:(CGFloat)shift
              withMinThickness:(CGFloat)minThickness
                    withJiggle:(CGFloat)jiggle
              withDistribution:(CGFloat)distribution
                withBaseColors:(NSArray *)baseColors
                withCompColors:(NSArray *)compColors;

- (void)animateBitsIn;
- (void)animateBitsInWithCompletion:(dispatch_block_t)completion;
- (void)animateBitsOut;
- (void)animateBitsOutWithCompletion:(dispatch_block_t)completion;

- (void)removeAllBits;

@end
