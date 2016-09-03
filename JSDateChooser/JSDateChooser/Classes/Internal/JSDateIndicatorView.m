//
//  JSDateIndicatorView.m
//  JSDateChooser
//
//  Created by sxq on 16/8/30.
//  Copyright © 2016年 sxq. All rights reserved.
//

#import "JSDateIndicatorView.h"

@interface JSDateIndicatorView ()
@property (strong, nonatomic) CAShapeLayer *ellipseLayer;
@end

@implementation JSDateIndicatorView

- (void)didMoveToSuperview {
    [super didMoveToSuperview];

    self.ellipseLayer = [CAShapeLayer layer];
    self.ellipseLayer.fillColor = self.color.CGColor;
    [self.layer addSublayer:self.ellipseLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.ellipseLayer.path = CGPathCreateWithEllipseInRect(self.bounds, nil);
    self.ellipseLayer.frame = self.bounds;
}

- (void)setColor:(UIColor *)color {
    self->_color = color;
    self.ellipseLayer.fillColor = color.CGColor;
}

@end
