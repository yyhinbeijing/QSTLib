//
//  NSDateFormatter+YY.h
//  Secoo-iPhone
//
//  Created by yangyonghui on 18/2/16.
//  Copyright © 2018年 secoo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^MDFDateFormmaterConfigBlock)(NSDateFormatter *dateFormmater);

@interface NSDateFormatter (YY)

+ (NSDateFormatter *)mdf_dateFormatterWithFormat:(NSString *)format;

// key 唯一标识
// block 配置formmater的格式
+ (NSDateFormatter *)mdf_dateFormatterWithKey:(NSString *)key configBlock:(MDFDateFormmaterConfigBlock)block;

@end
