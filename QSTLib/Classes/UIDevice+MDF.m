//
//  UIDevice+MDF.m
//  Aicow-iPhone
//
//  Created by yangyonghui on 16/2/14.
//  Copyright © 2016年 Aicow. All rights reserved.
//

#import "UIDevice+MDF.h"
#include <sys/sysctl.h>
//#import "AFNetworkReachabilityManager.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
//#import "SSKeychain.h"
#import <AdSupport/AdSupport.h>
#include <net/if.h>
#include <net/if_dl.h>
//#import "LVMDevLogManager.h"

//deviceId
static NSString * kMDFDeviceId = nil;

static NSString * const kMDFDeviceTokenKey = @"deviceToken";
static NSString * const kMDFKeychainUDIDService = @"com.Aicow.AicowApp";
static NSString * const kMDFKeychainUDIDAccount = @"udid";
static NSString * const kMDFUserDefaultUDIDKey = @"COM.Aicow.DEVICEID";
static NSString * const kMDFKeychainHasUDIDKey = @"kMDFKeychainHasUDIDKey";// 用于标示，keyChain中是否有UDID

@implementation UIDevice (MDF)

- (NSString *)mdf_networkTypeString
{
    MDFNetworkType type = [[UIDevice currentDevice] mdf_networkType];
    static NSDictionary *netTypes = nil;
    if (!netTypes) {
        netTypes = @{@(MDFNetworkTypeUnReachable):@"1",
                     @(MDFNetworkTypeWifi):@"5",
                     @(MDFNetworkTypeOther):@"6",
                     @(MDFNetworkType2G):@"2",
                     @(MDFNetworkType3G):@"3",
                     @(MDFNetworkType4G):@"4"};
    }
    
    return netTypes[@(type)];
}

- (NSString *) mdf_platform
{
    return [self mdf_getSysInfoByName:"hw.machine"];
}

// Thanks, Tom Harrington (Atomicbird)
- (NSString *) mdf_hwmodel
{
    return [self mdf_getSysInfoByName:"hw.model"];
}

- (NSString *) mdf_getSysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    
    free(answer);
    return results;
}

- (MDFNetworkType)mdf_networkType
{
//    AFNetworkReachabilityStatus status = [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus];
//    switch (status) {
//        case AFNetworkReachabilityStatusUnknown: {
            return MDFNetworkTypeOther;
//            break;
//        }
//        case AFNetworkReachabilityStatusNotReachable: {
//            return MDFNetworkTypeUnReachable;
//            break;
//        }
//        case AFNetworkReachabilityStatusReachableViaWWAN: {
//            CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
//            if ([networkInfo respondsToSelector:@selector(currentRadioAccessTechnology)]) {
//                NSString *currRadioAccessTech = networkInfo.currentRadioAccessTechnology;
//                if ([currRadioAccessTech isEqualToString:CTRadioAccessTechnologyGPRS] ||
//                    [currRadioAccessTech isEqualToString:CTRadioAccessTechnologyEdge]) {
//                    return MDFNetworkType2G;
//                } else if ([currRadioAccessTech isEqualToString:CTRadioAccessTechnologyWCDMA] ||
//                          [currRadioAccessTech isEqualToString:CTRadioAccessTechnologyHSDPA] ||
//                          [currRadioAccessTech isEqualToString:CTRadioAccessTechnologyHSUPA] ||
//                          [currRadioAccessTech isEqualToString:CTRadioAccessTechnologyCDMA1x] ||
//                          [currRadioAccessTech isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] ||
//                          [currRadioAccessTech isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] ||
//                          [currRadioAccessTech isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB] ||
//                          [currRadioAccessTech isEqualToString:CTRadioAccessTechnologyeHRPD]) {
//                    return MDFNetworkType3G;
//                } else if ([currRadioAccessTech isEqualToString:CTRadioAccessTechnologyLTE]) {
//                    return MDFNetworkType4G;
//                } else {
//                    return MDFNetworkType4G;
//                }
//            }
//            return MDFNetworkTypeOther;
//            break;
//        }
//        case AFNetworkReachabilityStatusReachableViaWiFi: {
//            return MDFNetworkTypeWifi;
//            break;
//        }
//    }
}

#pragma mark - deviceId -

- (NSString *)mdf_deviceUDID
{
    NSError *error = nil;
    if (kMDFDeviceId) {
        [self readUUIDFromKeyChain:&error];
        return kMDFDeviceId;
    }

    NSString *deviceId = [[NSUserDefaults standardUserDefaults] stringForKey:kMDFUserDefaultUDIDKey];
    if (deviceId.length) {
        kMDFDeviceId = deviceId;
        [self saveDeviceIdToKeychain:deviceId];
        return deviceId;
    }

    error = nil;
    deviceId = [self readUUIDFromKeyChain:&error];
    if ([deviceId length] < 1) {
        deviceId = [self makeDeviceId];
    }

    [self cacheDeviceId:deviceId];
    
    return @"";
}

- (NSString *)makeDeviceId {
    NSString *deviceId = [UIDevice createNewUUID];
    if (!deviceId) {
        NSString *errMsg = [NSString stringWithFormat:@"device creat error!\n"];
//        [[LVMDevLogManager sharedInstance] logInfoQuickWhenEnterBackground:errMsg];
        return @"";
    }
    return deviceId;
}

- (void)cacheDeviceId:(NSString *)deviceId {
    if ([deviceId length] < 1) {
        return;
    }
    
    kMDFDeviceId = deviceId;
//    [[MDFUserDefaults sharedInstance] setObject:deviceId forKey:kMDFUserDefaultUDIDKey];
    [self saveDeviceIdToKeychain:deviceId];
}

- (void)saveDeviceIdToKeychain:(NSString *)deviceId {
//    BOOL hasKeychaniUDID = [[MDFUserDefaults sharedInstance] boolForKey:kMDFKeychainHasUDIDKey];
//    if (hasKeychaniUDID) {
//        return;
//    }
//
//    NSError *error = nil;
//    [SSKeychain setPassword:deviceId forService:kMDFKeychainUDIDService account:kMDFKeychainUDIDAccount error:&error];
//    if (error) {
//        NSString *errMsg = [NSString stringWithFormat:@"device save error:%@", error.description];
//        [[LVMDevLogManager sharedInstance] logInfoQuickWhenEnterBackground:errMsg];
//    } else {
//        [[MDFUserDefaults sharedInstance] setBool:YES forKey:kMDFKeychainHasUDIDKey];
//    }
    
}

- (NSString *)readUUIDFromKeyChain:(NSError **)error {
//    [SSKeychain setAccessibilityType:kSecAttrAccessibleAlways];
//    NSString *deviceId = [SSKeychain passwordForService:kMDFKeychainUDIDService
//                                      account:kMDFKeychainUDIDAccount
//                                        error:error];
//    if (*error != nil) {
//        NSString *errMsg = [NSString stringWithFormat:@"device get error:%@\n", (*error).description];
//        [[LVMDevLogManager sharedInstance] logInfoQuickWhenEnterBackground:errMsg];
//        return nil;
//    }
    return @"";
}

#pragma mark - End of deviceId -

- (NSString * )mdf_macString
{
    int mib[6];
    size_t len;
    char *buf;
    unsigned char *ptr;
    struct if_msghdr *ifm;
    struct sockaddr_dl *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *macString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return macString;
}

- (NSString *)mdf_idfaString
{
    NSBundle *adSupportBundle = [NSBundle bundleWithPath:@"/System/Library/Frameworks/AdSupport.framework"];
    [adSupportBundle load];
    if (adSupportBundle == nil) {
        return @"";
    } else {
        Class asIdentifierMClass = NSClassFromString(@"ASIdentifierManager");
        if(asIdentifierMClass == nil) {
            return @"";
        } else {
            ASIdentifierManager *asIM = [[asIdentifierMClass alloc] init];
            if (asIM == nil) {
                return @"";
            } else {
                if(asIM.advertisingTrackingEnabled) {
                    return [asIM.advertisingIdentifier UUIDString];
                } else {
                    return [asIM.advertisingIdentifier UUIDString];
                }
            }
        }
    }
}

- (NSString *)mdf_idfvString
{
    if([[UIDevice currentDevice] respondsToSelector:@selector(identifierForVendor)]) {
        return [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    return @"";
}

//- (NSString *)mdf_token {
//  return [[MDFUserDefaults sharedInstance] stringForKey:kMDFDeviceTokenKey] ?: @"";
//}
//
//- (void)mdf_saveToken:(NSString *)token {
//  [[MDFUserDefaults sharedInstance] setString:token forKey:kMDFDeviceTokenKey];
//}

#pragma mark - Others

+ (NSString *)createNewUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    NSString *str = (__bridge NSString *)string;
    CFRelease(string);
    return  str;
}

@end
