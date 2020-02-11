//
//  UIDevice+YY.h
//  Aicow-iPhone
//
//  Created by yangyonghui on 16/2/14.
//  Copyright © 2016年 Aicow. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MDFNetworkType) {
    MDFNetworkTypeUnReachable,
    MDFNetworkTypeWifi,
    MDFNetworkTypeOther, //iOS7以下获取不到具体类型,移动网络统一归为'other'
    MDFNetworkType2G,
    MDFNetworkType3G,
    MDFNetworkType4G,
};

@interface UIDevice (YY)

- (NSString *)mdf_networkTypeString;

// 设备型号 iphone 7, 1
- (NSString *)mdf_platform;
- (NSString *)mdf_hwmodel;

- (MDFNetworkType)mdf_networkType;

// 获取UDID
- (NSString *)mdf_deviceUDID;

- (NSString *)mdf_macString;

// 获取idfa
- (NSString *)mdf_idfaString;

// 获取idfv
- (NSString *)mdf_idfvString;

// 获取token
- (NSString *)mdf_token;
// 保存token
- (void)mdf_saveToken:(NSString *)token;

+ (NSString *)createNewUUID;

@end
