//
//  FBBoxesLayer.m
//  FrickBits
//
//  Created by Matt McGlincy on 2/25/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBBoxesLayer.h"
#import "FBUtils.h"

@implementation FBBoxesLayer

- (id)init {
    self = [super init];
    if (self) {
        self.masksToBounds = YES;
        self.verticalMargin = 2.0;
        self.horizontalMargin = 2.0;
        self.fillColor = [UIColor clearColor];
        self.strokeColor = UIColorFromHexString(@"#111111", 0.9);
    }
    return self;
}

- (void)drawInContext:(CGContextRef)context {
    CGContextSaveGState(context);

    // TODO: this really only works for "upright" boxes
    // we need to decide how we want to handle rotation
    
    CGContextSetLineWidth(context, 0.5);
    CGContextSetFillColorWithColor(context, self.fillColor.CGColor);
    CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);

    CGFloat currentX = self.horizontalMargin;
    while (currentX < (self.frame.size.width - self.horizontalMargin)) {
        NSInteger dotWidth = 3 + arc4random_uniform(2);
        // TODO: currently restricting dots to be square
        //NSInteger dotHeight = bitHeight - (verticalMargin * 2) - arc4random_uniform(2);
        NSInteger dotHeight = dotWidth;
        CGRect dotRect = CGRectMake(currentX, self.verticalMargin, dotWidth, dotHeight);
        CGContextFillRect(context, dotRect);

        CGContextAddRect(context, dotRect);
        CGContextStrokePath(context);
        currentX += (dotWidth + self.horizontalMargin);
    }
    
    CGContextRestoreGState(context);
}


@end
