//
//  JSDateUntils.m
//  JSDateChooser
//
//  Created by sxq on 16/8/30.
//  Copyright © 2016年 sxq. All rights reserved.
//

#import "JSDateUntils.h"

@implementation JSDateUntils

+ (NSCalendar *)localCalendar {
    static NSCalendar *Instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Instance =[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    });
    return Instance;
}

+ (NSDate *)dateWithMonth:(NSUInteger)month year:(NSUInteger)year {
    return [self dateWithMonth:month day:1 year:year];
}

+ (NSDate *)dateWithMonth:(NSUInteger)month day:(NSUInteger)day year:(NSUInteger)year {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    comps.month = month;
    comps.day = day;
    comps.year = year;
    return [self dateFromDateComponents:comps];
}

+ (NSDate *)dateFromDateComponents:(NSDateComponents *)components {
    return [[self localCalendar] dateFromComponents:components];
}

+ (NSUInteger)daysInMonth:(NSUInteger)month ofYear:(NSUInteger)year {
    NSDate *date = [self dateWithMonth:month year:year];
    return [[self localCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;
}

+ (NSUInteger)firstWeekdayInMonth:(NSUInteger)month ofYear:(NSUInteger)year {
    NSDate *date = [self dateWithMonth:month year:year];
    return [[self localCalendar] component:NSCalendarUnitWeekday fromDate:date];
}

+ (NSString *)stringOfWeekdayInEnglish:(NSUInteger)weekday {
    NSAssert(weekday >= 1 && weekday <= 7, @"Invalid weekday:%lu", weekday);
    static NSArray *Strings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Strings = @[@"Sun", @"Mon", @"Tues", @"Wed", @"Thur", @"Fri", @"Sat"];
    });
    return Strings[weekday - 1];
}

+ (NSString *)stringOfMonthInEnglish:(NSUInteger)month {
    NSAssert(month >= 1 && month <= 12, @"Invalid month:%lu", month);
    static NSArray *Strings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Strings = @[@"Jan.", @"Feb.", @"Mar.", @"Apr.", @"May.", @"Jun.", @"Jul.", @"Aug.", @"Sept.", @"Oct.", @"Nov.", @"Dec."];
    });
    return Strings[month - 1];
}


+ (NSString *)stringOfWeekdayInChinese:(NSUInteger)weekday {
    NSAssert(weekday >= 1 && weekday <= 7, @"Invalid weekday:%lu", weekday);
    static NSArray *Strings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Strings = @[@"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六"];
    });
    return Strings[weekday - 1];
}

+ (NSString *)stringOfMonthInChinese:(NSUInteger)month {
    NSAssert(month >= 1 && month <= 12, @"Invalid month:%lu", month);
    static NSArray *Strings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Strings = @[@"一月", @"二月", @"三月", @"四月", @"五月", @"六月", @"七月", @"八月", @"九月", @"十月", @"十一月", @"十二月"];
    });
    return Strings[month - 1];
}

+ (NSDateComponents *)dateComponentsFromDate:(NSDate *)date {
    return [[self localCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
}

+ (BOOL)isDateTodayWithDateComponents:(NSDateComponents *)dateComponents {
    NSDateComponents *todayComponents = [self dateComponentsFromDate:[NSDate date]];
    return todayComponents.year == dateComponents.year && todayComponents.month == dateComponents.month && todayComponents.day == dateComponents.day;
}

+ (BOOL)isDatePassWithDateComponents:(NSDateComponents *)dateComponents {
    NSDateComponents *todayComponents = [self dateComponentsFromDate:[NSDate date]];
    return todayComponents.year > dateComponents.year || (todayComponents.year == dateComponents.year && todayComponents.month > dateComponents.month) || (todayComponents.year == dateComponents.year && todayComponents.month == dateComponents.month && todayComponents.day > dateComponents.day);
}

@end
