//
//  NSDate+MDF.m
//  Secoo-iPhone
//
//  Created by Hujianghong on 16/1/21.
//  Copyright © 2016年 secoo. All rights reserved.
//

#import "NSDate+YY.h"
#import "NSDateFormatter+YY.h"

static const unsigned componentFlags = (NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal);

@implementation NSDate (YY)

+ (instancetype)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
    NSDateComponents *comp = [[NSDateComponents alloc] init];
    [comp setMonth:month];
    [comp setDay:day];
    [comp setYear:year];
    NSCalendar *myCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [myCal dateFromComponents:comp];
}

+ (instancetype)getTimeFromSeveralYearAgo:(NSInteger)year {
    NSDate *today = [[NSDate alloc] init];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *addComponents = [[NSDateComponents alloc] init];
    addComponents.year = -year;
    return [calendar dateByAddingComponents:addComponents toDate:today options:0];
}

+ (NSDate *)dateWithString:(NSString *)dateString format:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [formatter dateFromString:dateString];
}

+ (NSString *)dateStrWithString:(NSString *)dateString foreFormat:(NSString *)foreFormat format:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:foreFormat];
    NSDate *d =  [formatter dateFromString:dateString];
    [formatter setDateFormat:format];
    return  [formatter stringFromDate:d];
}

+ (NSString *)mdf_convertDateIntervalToStringWith:(NSString *)aInterVal
{
    time_t statusCreateAt_t;
    NSString *timestamp = nil;
    time_t now;
    time(&now);
    
    statusCreateAt_t = (time_t)[aInterVal longLongValue];
    
    struct tm *nowtime;
    nowtime = localtime(&now);
    uint32_t thour = nowtime->tm_hour;
    
    localtime(&statusCreateAt_t);
    
    int distance = (int)difftime(now, statusCreateAt_t);
    if (distance < 0) {
        distance = 0;
    }
    
    if (distance < 30) {
        timestamp = @"刚刚";
    } else if (distance < 60) {
        timestamp = @"30秒前";
    } else if (distance < 60 * 60) {/* 小于1小时 */
        distance = distance / 60;
        if (distance == 0) {
            distance = 1;
        }
        timestamp = [NSString stringWithFormat:@"%d分钟前", distance];
    } else if (distance < (60 * 60 * (thour))) {/* 大于1小时，但是在今日 */
    
        timestamp = [NSString stringWithFormat:@"%d小时前", distance / 60 / 60];
    } else {
        NSDate *date_now = [NSDate dateWithTimeIntervalSince1970:now];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:statusCreateAt_t];
        NSInteger dateYear = [date year];
        NSInteger nowYear = [date_now year];
        
        if (dateYear == nowYear) {
            NSDateFormatter *dateFormatter = [NSDateFormatter mdf_dateFormatterWithFormat:@"MM-dd HH:mm"];
            timestamp = [dateFormatter stringFromDate:date];
        } else {
            NSDateFormatter *dateFormatter = [NSDateFormatter mdf_dateFormatterWithFormat:@"yyyy-MM-dd HH:mm"];
            timestamp = [dateFormatter stringFromDate:date];
        }
    }
    
    return timestamp;
}

+ (NSString *)mdf_convertDateIntervalToSimpleStringWith:(NSString *)aInterVal
{
    time_t statusCreateAt_t;
    NSString *timestamp = nil;
    time_t now;
    time(&now);
    
    statusCreateAt_t = (time_t)[aInterVal longLongValue];
    
    struct tm *nowtime;
    nowtime = localtime(&now);
    uint32_t thour = nowtime->tm_hour;
    
    localtime(&statusCreateAt_t);
    
    int distance = (int)difftime(now, statusCreateAt_t);
    if (distance < 0) {
        distance = 0;
    }
    
    if (distance < 60 * 60) {/* 小于1小时 */
        distance = distance / 60;
        if (distance == 0) {
            distance = 1;
        }
        timestamp = [NSString stringWithFormat:@"%d分钟前", distance];
    } else if (distance < (60 * 60 * (thour))) {/* 大于1小时，但是在今日 */
        distance = distance / (60 * 60);
        if (distance == 0) {
            distance = 1;
        }
        timestamp = [NSString stringWithFormat:@"%d小时前", distance];
    } else {
        NSDate *date_now = [NSDate dateWithTimeIntervalSince1970:now];
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:statusCreateAt_t];
        NSInteger dateYear = [date year];
        NSInteger nowYear = [date_now year];
        
        if (dateYear == nowYear) {
            NSDateFormatter *dateFormatter = [NSDateFormatter mdf_dateFormatterWithFormat:@"MM-dd"];
            timestamp = [dateFormatter stringFromDate:date];
        } else {
            NSDateFormatter *dateFormatter = [NSDateFormatter mdf_dateFormatterWithFormat:@"yyyy-MM-dd"];
            timestamp = [dateFormatter stringFromDate:date];
        }
    }
    
    return timestamp;
}

+ (NSCalendar *)mdf_currentCalendar
{
    static NSCalendar *sharedCalendar = nil;
    if (!sharedCalendar) {
        sharedCalendar = [NSCalendar autoupdatingCurrentCalendar];
    }
    
    return sharedCalendar;
}

+ (NSString *)mdf_convertDateIntervalToStringNow
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return [formatter stringFromDate:[NSDate date]];
}

+ (NSString *)mdf_stringLongDateTime:(NSTimeInterval)timeInterval
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval / 1000]];
}

+ (NSString *)mdf_stringShortDateTime:(NSTimeInterval)timeInterval
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    return [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeInterval / 1000]];
}

+ (NSString *)mdf_Timestamp
{
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSTimeInterval aTimeInterval = [zone secondsFromGMTForDate:date] * 1000;

    return [NSString stringWithFormat:@"%f", aTimeInterval];
}

+ (NSString *)mdf_subTimestamp:(long long)endInterval
{
    NSDate *date = [NSDate date];
    NSTimeInterval aTimeInterval = [date timeIntervalSince1970] * 1000;
    
    long long aNowTimeInterval = [[NSString stringWithFormat:@"%f", aTimeInterval] longLongValue];
    
    return [NSString stringWithFormat:@"%lld", (endInterval - aNowTimeInterval) > 0 ? (endInterval - aNowTimeInterval) / 1000 : 0];
}

+ (NSInteger)mdf_subTimeInterval:(long long)endInterval
{
    NSDate *originDate = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)endInterval];
    originDate = [originDate dateByAddingTimeInterval:3600];
    
    return originDate.timeIntervalSinceNow;
}

- (NSString *)mdf_stringWithFormat:(NSString *)format
{
    NSDateFormatter *formatter = [NSDateFormatter mdf_dateFormatterWithFormat:format];
//    formatter.locale = [NSLocale currentLocale]; // Necessary?
    return [formatter stringFromDate:self];
}

+ (BOOL)mdf_isToadyInRange:(NSString *)beginDateString and:(NSString *)endDateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *todayDate = [NSDate date];
    NSDate *beginDate = [NSDate dateWithTimeIntervalSince1970:[beginDateString longLongValue]/1000];
    NSDate *endDate = [NSDate dateWithTimeIntervalSince1970:[endDateString longLongValue]/1000];
    
    if (!beginDate || !endDate) {
        return NO;
    }
    
    if ([[todayDate laterDate:beginDate] isEqualToDate:todayDate] && [[todayDate earlierDate:endDate] isEqualToDate:todayDate]) {
        return YES;
    }
    
    return NO;
}

- (NSString *)mdf_stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle
{
    NSDateFormatter *formatter = [NSDateFormatter mdf_dateFormatterWithFormat:@""];
    formatter.dateStyle = dateStyle;
    formatter.timeStyle = timeStyle;
//    formatter.locale = [NSLocale currentLocale]; // Necessary?
    return [formatter stringFromDate:self];
}

- (NSString *)shortString
{
    return [self mdf_stringWithDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
}

- (NSString *)shortTimeString
{
    return [self mdf_stringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
}

- (NSString *)shortDateString
{
    return [self mdf_stringWithDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
}

- (NSString *)mediumString
{
    return [self mdf_stringWithDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle ];
}

- (NSString *)mediumTimeString
{
    return [self mdf_stringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterMediumStyle ];
}

- (NSString *)mediumDateString
{
    return [self mdf_stringWithDateStyle:NSDateFormatterMediumStyle  timeStyle:NSDateFormatterNoStyle];
}

- (NSString *)longString
{
    return [self mdf_stringWithDateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterLongStyle ];
}

- (NSString *)longTimeString
{
    return [self mdf_stringWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterLongStyle ];
}

- (NSString *)longDateString
{
    return [self mdf_stringWithDateStyle:NSDateFormatterLongStyle  timeStyle:NSDateFormatterNoStyle];
}

- (NSInteger)nearestHour
{
    NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + kMDF_MINUTE * 30;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    NSDateComponents *components = [[NSDate mdf_currentCalendar] components:NSCalendarUnitHour fromDate:newDate];
    return components.hour;
}

- (NSInteger)hour
{
    NSDateComponents *components = [[NSDate mdf_currentCalendar] components:componentFlags fromDate:self];
    return components.hour;
}

- (NSInteger)minute
{
    NSDateComponents *components = [[NSDate mdf_currentCalendar] components:componentFlags fromDate:self];
    return components.minute;
}

- (NSInteger)seconds
{
    NSDateComponents *components = [[NSDate mdf_currentCalendar] components:componentFlags fromDate:self];
    return components.second;
}

- (NSInteger)day
{
    NSDateComponents *components = [[NSDate mdf_currentCalendar] components:componentFlags fromDate:self];
    return components.day;
}

- (NSInteger)month
{
    NSDateComponents *components = [[NSDate mdf_currentCalendar] components:componentFlags fromDate:self];
    return components.month;
}

- (NSInteger)weekOfMonth
{
    NSDateComponents *components = [[NSDate mdf_currentCalendar] components:componentFlags fromDate:self];
    return components.weekOfMonth;
}

- (NSInteger)weekOfYear
{
    NSDateComponents *components = [[NSDate mdf_currentCalendar] components:componentFlags fromDate:self];
    return components.weekOfYear;
}

- (NSInteger)weekday
{
    NSDateComponents *components = [[NSDate mdf_currentCalendar] components:componentFlags fromDate:self];
    return components.weekday;
}

- (NSInteger)nthWeekday // e.g. 2nd Tuesday of the month is 2
{
    NSDateComponents *components = [[NSDate mdf_currentCalendar] components:componentFlags fromDate:self];
    return components.weekdayOrdinal;
}

- (NSInteger)numbersOfDaysInThisMonth
{
    NSRange range = [[NSDate mdf_currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:[NSDate date]];
    return range.length;
}

- (NSInteger)year
{
    NSDateComponents *components = [[NSDate mdf_currentCalendar] components:componentFlags fromDate:self];
    return components.year;
}

- (NSInteger)mdf_getDifferenceDayByDate:(NSDate *)date {
    NSCalendar *gregorian = [NSDate mdf_currentCalendar];
    unsigned int unitFlags = NSCalendarUnitDay;
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:date toDate:self options:NSCalendarWrapComponents];
    return [comps day];
}

- (BOOL)mdf_isSameDay:(NSDate *)date {
    return (self.day == date.day && self.month == date.month && self.year == date.year);
}

@end
