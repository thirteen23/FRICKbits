//
//  FBMapGridCellConnection2.h
//  FrickBits
//
//  Created by Matt McGlincy on 1/31/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBMapGridCell.h"

@interface FBMapGridCellConnection : NSObject<NSCopying>

@property(nonatomic, weak) FBMapGridCell *cell1;
@property(nonatomic, weak) FBMapGridCell *cell2;

+ (id)connectionWithCell1:(FBMapGridCell *)cell1 cell2:(FBMapGridCell *)cell2;

- (NSString *)stringKey;
- (CGFloat)angleDegrees;
- (CGFloat)positiveAngleDegrees;

- (BOOL)includesCell:(FBMapGridCell *)cell;

@end
