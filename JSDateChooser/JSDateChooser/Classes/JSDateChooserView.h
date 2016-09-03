//
//  JSDateChooserView.h
//  JSDateChooser
//
//  Created by sxq on 16/8/30.
//  Copyright © 2016年 sxq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@interface JSDateChooserView : UIControl

@property (copy, nonatomic) NSDate *selectedDate;
@property (copy, nonatomic) NSArray<NSString*> *localizedStringsOfWeekday;

/* Appearance Settings */
@property (copy, nonatomic) UIColor *weekdayHeaderTextColor;
@property (copy, nonatomic) UIColor *weekdayHeaderWeekendTextColor;
@property (copy, nonatomic) UIColor *componentTextColor;
@property (copy, nonatomic) UIColor *passDateTextColor;
@property (copy, nonatomic) UIColor *highlightedComponentTextColor;
@property (copy, nonatomic) UIColor *selectedIndicatorColor;
@property (copy, nonatomic) UIColor *todayIndicatorColor;
@property (assign, nonatomic) CGFloat indicatorRadius;
@property (assign, nonatomic) BOOL blodPrimaryComponentText;
@property (assign, nonatomic) BOOL sigleRowMode;

@property (assign, nonatomic) BOOL selectPassDateVisible;

/* Additional features */
@property (assign, nonatomic) BOOL showUserEvents;

- (void)reloadViewAnimated:(BOOL)animated;

- (void)jumpToNextMonth;

- (void)jumpToPreviousMonth;

- (void)jumpToMonth:(NSUInteger)month year:(NSUInteger)year;

@end
