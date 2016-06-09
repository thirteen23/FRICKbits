//
//  FBBoxesLayer.h
//  FrickBits
//
//  Created by Matt McGlincy on 2/25/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

@interface FBBoxesLayer : CALayer

@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, strong) UIColor *fillColor;

@property (nonatomic) CGFloat horizontalMargin;
@property (nonatomic) CGFloat verticalMargin;

@end
