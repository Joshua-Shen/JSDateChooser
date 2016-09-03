//
//  JSDateComponentView.h
//  JSDateChooser
//
//  Created by sxq on 16/8/30.
//  Copyright © 2016年 sxq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@interface JSDateComponentView : UIControl

@property (readonly) UILabel *textLabel;
@property (copy, nonatomic) UIColor *textColor;
@property (copy, nonatomic) UIColor *highlightTextColor;
@property (strong, nonatomic) EKEvent *containingEvent;
@property (strong, nonatomic) id representedObject;
@end
