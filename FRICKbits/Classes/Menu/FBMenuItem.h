//
// Created by Matt McGlincy on 4/2/14.
// Copyright (c) 2014 Thirteen23. All rights reserved.
//

@interface FBMenuItem : NSObject

@property (nonatomic) NSInteger tag;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIImage *icon;

+ (FBMenuItem *)menuItemWithTag:(NSInteger)tag title:(NSString *)title icon:
    (UIImage *)icon;

@end