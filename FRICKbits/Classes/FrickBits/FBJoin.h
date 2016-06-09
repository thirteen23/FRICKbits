//
//  FBJoin.h
//  FrickBits
//
//  Created by Matt McGlincy on 2/25/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

typedef NS_ENUM(NSInteger, FBJoinSide) {
    FBJoinSideTop,
    FBJoinSideRight,
    FBJoinSideBottom,
    FBJoinSideLeft
};

typedef struct {
    FBJoinSide side1;
    FBJoinSide side2;
} FBJoinSidePair;


