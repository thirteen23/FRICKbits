//
//  FBOnboardingViewController.h
//  FrickBits
//
//  Created by Michael Van Milligan on 3/25/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBTrackedViewController.h"

@class T23AtomicBoolean;

@interface FBOnboardingViewController
    : FBTrackedViewController<UINavigationControllerDelegate>

@property(nonatomic, readonly) T23AtomicBoolean *presentedFromMenu;
@property(nonatomic, readonly) NSUInteger paletteIndex;
@property(nonatomic, readonly) BOOL stuckInLocationPermissions;

- (instancetype)initAtStartingPoint;
- (instancetype)initAtPickerPointWithColorIndex:(NSUInteger)index;
- (void)doInitialPickerTransition;

@end
