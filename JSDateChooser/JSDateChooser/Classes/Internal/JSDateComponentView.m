//
//  JSDateComponentView.m
//  JSDateChooser
//
//  Created by sxq on 16/8/30.
//  Copyright © 2016年 sxq. All rights reserved.
//

#import "JSDateComponentView.h"
#import <EventKitUI/EventKitUI.h>

@interface JSDateComponentView ()<EKEventViewDelegate>

@property (strong, nonatomic) UILabel *textLabel;
@property (strong, nonatomic) CAShapeLayer *dotLayer;

@end

@implementation JSDateComponentView

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

- (void)commonInit {

    self.textLabel = [[UILabel alloc] init];
    self.textLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.textLabel];

    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:self.textLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    [self addConstraints:@[centerX, centerY]];

    self.dotLayer = [CAShapeLayer layer];
    self.dotLayer.hidden = YES;
    [self.layer addSublayer:self.dotLayer];

    UITapGestureRecognizer *tapRecongnizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidTap:)];
    [self addGestureRecognizer:tapRecongnizer];

    UILongPressGestureRecognizer *lpRecongnizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(viewDidLongPress:)];
    [self addGestureRecognizer:lpRecongnizer];

}

#pragma mark - Setter method

- (void)setContainingEvent:(EKEvent *)containingEvent {
    self->_containingEvent = containingEvent;

    if (containingEvent) {
        self.dotLayer.fillColor = containingEvent.calendar.CGColor;
        self.dotLayer.hidden = NO;
    }
    else {
        self.dotLayer.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        self.textLabel.textColor = self.highlightTextColor;
        self.dotLayer.fillColor = self.highlightTextColor.CGColor;
    }
    else {
        self.textLabel.textColor = self.textColor;
        self.dotLayer.fillColor = self.containingEvent.calendar.CGColor;
    }
}


#pragma mark - Setting

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.dotLayer.path = CGPathCreateWithEllipseInRect(CGRectMake(0.0f, 0.0f, 5.0f, 5.0f), nil);
    self.dotLayer.frame = CGRectMake((CGRectGetWidth(self.frame) - 5.0f) / 2.0f, CGRectGetMaxY(self.textLabel.frame), 5.0f, 5.0f);

}

#pragma mark - Actions

- (void)viewDidTap:(id)sender {
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLongPress:(id)sender {
    if (self.containingEvent) {
        [self becomeFirstResponder];

        UIMenuController *menu = [UIMenuController sharedMenuController];
        menu.menuItems = @[[[UIMenuItem alloc] initWithTitle:self.containingEvent.title action:@selector(showEvent)]];
        [menu setTargetRect:self.frame inView:self.superview];
        [menu setMenuVisible:YES];
    }
}

- (void)showEvent {
    UIResponder *next = self;
    while (next) {
        if ([next respondsToSelector:@selector(presentViewController:animated:completion:)]) {
            EKEventViewController *eventVC = [[EKEventViewController alloc] init];
            eventVC.event = self.containingEvent;
            eventVC.allowsEditing = YES;
            eventVC.allowsCalendarPreview = YES;
            eventVC.delegate = self;

            [((UIViewController *) next) presentViewController:[[UINavigationController alloc] initWithRootViewController:eventVC] animated:YES completion:nil];
            return;
        }
        else {
            next = [next nextResponder];
        }
    }
}

#pragma mark - Event view delegate

- (void)eventViewController:(EKEventViewController *)controller didCompleteWithAction:(EKEventViewAction)action {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

@end
