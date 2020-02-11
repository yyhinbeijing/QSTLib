//
//  NSDateFormatter+YY.m
//  Secoo-iPhone
//
//  Created by yangyonghui on 18/2/16.
//  Copyright © 2018年 aicow. All rights reserved.
//

#import "NSDateFormatter+YY.h"
static NSMutableDictionary *formatters = nil;

@implementation NSDateFormatter (YY)

+ (NSDateFormatter *)mdf_dateFormatterWithFormat:(NSString *)formmat
{
    return [self mdf_dateFormatterWithKey:[NSString stringWithFormat:@"<%@>", formmat] configBlock: ^(NSDateFormatter *formatter) {
                if (formatter) {
                    [formatter setDateFormat:formmat];
                }
            }];
}

+ (NSDateFormatter *)mdf_dateFormatterWithKey:(NSString *)key configBlock:(MDFDateFormmaterConfigBlock)cofigBlock
{
    NSString *strKey = nil;
    if (!key) {
        strKey = @"defaultFormatter";
    } else {
        strKey = [key copy];
    }
    
    @synchronized(self) {
        NSDateFormatter *dateFormatter = [[self formatters] objectForKey:strKey];
        if (!dateFormatter) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
         [[self formatters] setObject:dateFormatter forKey:strKey];
            
            if (cofigBlock) {
                cofigBlock(dateFormatter); //配置它
            }
            return dateFormatter;
        }
        
        return dateFormatter;
    }
}

+ (NSMutableDictionary *)formatters
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!formatters) {
            formatters = [[NSMutableDictionary alloc] init];
        }
    });
    
    return formatters;
}

@end
