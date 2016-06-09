//
//  FBNumbersLayer.h
//  FrickBits
//
//  Created by Matt McGlincy on 2/26/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface FBNumbersLayer : CALayer

- (id)initWithFillColor:(UIColor *)fillColor;
- (id)initWithFillColor:(UIColor *)fillColor andOffset:(CGSize)offset;

@end
