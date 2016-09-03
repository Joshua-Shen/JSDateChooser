//
//  JSDateNavigationBar.m
//  JSDateChooser
//
//  Created by sxq on 16/8/30.
//  Copyright © 2016年 sxq. All rights reserved.
//

#import "JSDateNavigationBar.h"
#import "CustomImage.h"

@interface JSDateNavigationBar ()

@property (strong, nonatomic) UILabel *textLabel;
@property (strong, nonatomic) UIButton *prevButton;
@property (strong, nonatomic) UIButton *nextButton;

@property (readwrite, assign, nonatomic) JSDateNavigationBarCommand lastCommand;

@end

@implementation JSDateNavigationBar

#pragma mark - Initialized method

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void) commonInit {

    [self createTextLable];
    [self creatPrevButton];
    [self createNextButton];
}

#pragma mark - Custom Views

- (void)createTextLable {

    self.textLabel = [[UILabel alloc] init];
    self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.textLabel.textColor = [UIColor colorWithRed:0.29f green:0.29f blue:0.29f alpha:1];
    self.textLabel.font = [UIFont systemFontOfSize:16];
    [self addSubview:self.textLabel];

    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    [self addConstraints:@[centerX, centerY]];
}

- (void)creatPrevButton {

    self.prevButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.prevButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.prevButton.tintColor = [UIColor grayColor];
    [self.prevButton setBackgroundImage:[[CustomImage imageOfPrev] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.prevButton addTarget:self action:@selector(prevButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.prevButton];

    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self.prevButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0];
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:self.prevButton attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0f constant:15.0f];
    [self addConstraints:@[centerY, leading]];

    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.prevButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:30.0f];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.prevButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:30.0f];
    [self.prevButton addConstraints:@[width, height]];
}

- (void)createNextButton {
    self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.nextButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.nextButton.tintColor = [UIColor grayColor];
    [self.nextButton setBackgroundImage:[[CustomImage imageOfNext] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.nextButton addTarget:self action:@selector(nextButtonDidTap:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.nextButton];

    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self.nextButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0];
    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:self.nextButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-15.0f];
    [self addConstraints:@[centerY, trailing]];

    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:self.nextButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:30.0f];
    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:self.nextButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:30.0f];
    [self.nextButton addConstraints:@[width, height]];
}

#pragma mark - Actions

- (void)prevButtonDidTap:(id)sender {
    self.lastCommand = JSDateNavigationBarCommandPrevious;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)nextButtonDidTap:(id)sender {
    self.lastCommand = JSDateNavigationBarCommandNext;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
