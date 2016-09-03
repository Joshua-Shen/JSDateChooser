//
//  JSDateUntils.h
//  JSDateChooser
//
//  Created by sxq on 16/8/30.
//  Copyright © 2016年 sxq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSDateUntils : NSObject

+ (NSCalendar *)localCalendar;

+ (NSDate *)dateWithMonth:(NSUInteger)month year:(NSUInteger)year;

+ (NSDate *)dateWithMonth:(NSUInteger)month day:(NSUInteger)day year:(NSUInteger)year;

+ (NSDate *)dateFromDateComponents:(NSDateComponents *)components;

+ (NSUInteger)daysInMonth:(NSUInteger)month ofYear:(NSUInteger)year;

+ (NSUInteger)firstWeekdayInMonth:(NSUInteger)month ofYear:(NSUInteger)year;

+ (NSString *)stringOfWeekdayInEnglish:(NSUInteger)weekday;

+ (NSString *)stringOfMonthInEnglish:(NSUInteger)month;

+ (NSString *)stringOfWeekdayInChinese:(NSUInteger)weekday;

+ (NSString *)stringOfMonthInChinese:(NSUInteger)month;

+ (NSDateComponents *)dateComponentsFromDate:(NSDate *)date;

+ (BOOL)isDateTodayWithDateComponents:(NSDateComponents *)dateComponents;

+ (BOOL)isDatePassWithDateComponents:(NSDateComponents *)dateComponents;

@end
