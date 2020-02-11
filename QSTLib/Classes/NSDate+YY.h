//
//  NSDate+MDF.h
//  Secoo-iPhone
//
//  Created by Hujianghong on 16/1/21.
//  Copyright © 2016年 secoo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kMDF_MINUTE     60
#define kMDF_HOUR		3600
#define kMDF_DAY		86400
#define kMDF_WEEK		604800
#define kMDF_YEAR		31556926

@interface NSDate (YY)

+ (instancetype)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;

+ (instancetype)getTimeFromSeveralYearAgo:(NSInteger)year;

+ (NSString *)mdf_convertDateIntervalToStringWith:(NSString *)aInterVal;
+ (NSString *)mdf_convertDateIntervalToSimpleStringWith:(NSString *)aInterVal;

+ (NSDate *)dateWithString:(NSString *)dateString format:(NSString *)format;

+ (NSString *)dateStrWithString:(NSString *)dateString foreFormat:(NSString *)foreFormat format:(NSString *)format;

+ (NSCalendar *)mdf_currentCalendar; // avoid bottlenecks

// 当前时间 yyyy-MM-dd hh:mm:ss
+ (NSString *)mdf_convertDateIntervalToStringNow;

// yyyy-MM-dd hh:mm:ss
+ (NSString *)mdf_stringLongDateTime:(NSTimeInterval)timeInterval;
// yyyy-MM-dd
+ (NSString *)mdf_stringShortDateTime:(NSTimeInterval)timeInterval;

// 时间戳
+ (NSString *)mdf_Timestamp;

// 获取两个时间戳的差值
+ (NSString *)mdf_subTimestamp:(long long)endInterval;

+ (NSInteger)mdf_subTimeInterval:(long long)endInterval;

- (NSString *)mdf_stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;
- (NSString *)mdf_stringWithFormat:(NSString *)format;

// 是否在有效显示时间内
+ (BOOL)mdf_isToadyInRange:(NSString *)beginDateString and:(NSString *)endDateString;

// 获取两天差了多少天
- (NSInteger)mdf_getDifferenceDayByDate:(NSDate *)date;

// 判断是不是同一天
- (BOOL)mdf_isSameDay:(NSDate *)date;

#pragma mark - Property
@property (nonatomic, readonly) NSString *shortString;
@property (nonatomic, readonly) NSString *shortDateString;
@property (nonatomic, readonly) NSString *shortTimeString;
@property (nonatomic, readonly) NSString *mediumString;
@property (nonatomic, readonly) NSString *mediumDateString;
@property (nonatomic, readonly) NSString *mediumTimeString;
@property (nonatomic, readonly) NSString *longString;
@property (nonatomic, readonly) NSString *longDateString;
@property (nonatomic, readonly) NSString *longTimeString;

@property (readonly) NSInteger nearestHour;
@property (readonly) NSInteger hour;
@property (readonly) NSInteger minute;
@property (readonly) NSInteger seconds;
@property (readonly) NSInteger day;
@property (readonly) NSInteger month;
@property (readonly) NSInteger weekOfMonth;
@property (readonly) NSInteger weekOfYear;
@property (readonly) NSInteger weekday;
@property (readonly) NSInteger nthWeekday; // e.g. 2nd Tuesday of the month == 2
@property (readonly) NSInteger year;
@property (readonly) NSInteger numbersOfDaysInThisMonth;

@end
