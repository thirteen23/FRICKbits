//
//  FBGridCellAnnotationView.m
//  FrickBits
//
//  Created by Matthew McGlincy on 2/1/14.
//  Copyright (c) 2014 Thirteen23. All rights reserved.
//

#import "FBGridCellAnnotation.h"
#import "FBGridCellAnnotationView.h"

@interface FBGridCellAnnotationView()
@property (nonatomic, strong) UILabel *rowColLabel;
@property (nonatomic, strong) UILabel *countLabel;
@end

@implementation FBGridCellAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.lineColor = [[UIColor alloc] initWithRed:1.0 green:0.5 blue:0.0 alpha:0.5];
        self.lineWidth = 1.0;

        self.rowColLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -16, 100, 50)];
        self.rowColLabel.textColor = [UIColor colorWithWhite:0.0 alpha:0.2];
        self.rowColLabel.font = [UIFont boldSystemFontOfSize:12.0];
        [self addSubview:self.rowColLabel];
        
        self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 32, 100, 50)];
        self.countLabel.textColor = [UIColor colorWithWhite:0.0 alpha:0.2];
        self.countLabel.font = [UIFont boldSystemFontOfSize:28.0];
        [self addSubview:self.countLabel];
    }
    return self;
}

- (void)setAnnotation:(id<MKAnnotation>)annotation {
    [super setAnnotation:annotation];
    if ([annotation isKindOfClass:[FBGridCellAnnotation class]]) {
        FBGridCellAnnotation *anno = (FBGridCellAnnotation *)annotation;
        
        self.rowColLabel.text = [NSString stringWithFormat:@"%ld,%ld", (long)anno.cell.row, (long)anno.cell.col];
        
        if (anno.cell.locations.count > 0) {
            self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1.0 alpha:0.1];
            self.countLabel.text = [NSString stringWithFormat:@"%ld", (long)anno.cell.locations.count];
        } else {
            self.backgroundColor = [UIColor clearColor];
            self.countLabel.text = @"";
        }
        [self.countLabel sizeToFit];
    }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextStrokeRect(context, rect);
}

@end
