//
//  UIDevice+YY.m
//  Aicow-iPhone
//
//  Created by yangyonghui on 16/2/14.
//  Copyright © 2016年 Aicow. All rights reserved.
//

#import "UIDevice+YY.h"
#include <sys/sysctl.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <AdSupport/AdSupport.h>
#include <net/if.h>
#include <net/if_dl.h>

static NSString * kMDFDeviceId = nil;

static NSString * const kMDFDeviceTokenKey = @"deviceToken";
static NSString * const kMDFKeychainUDIDService = @"com.Aicow.AicowApp";
static NSString * const kMDFKeychainUDIDAccount = @"udid";
static NSString * const kMDFUserDefaultUDIDKey = @"COM.Aicow.DEVICEID";
static NSString * const kMDFKeychainHasUDIDKey = @"kMDFKeychainHasUDIDKey";// 用于标示，keyChain中是否有UDID

@implementation UIDevice (YY)

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
    return MDFNetworkTypeOther;
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
        return @"";
    }
    return deviceId;
}

- (void)cacheDeviceId:(NSString *)deviceId {
    if ([deviceId length] < 1) {
        return;
    }
    kMDFDeviceId = deviceId;
    [self saveDeviceIdToKeychain:deviceId];
}

- (void)saveDeviceIdToKeychain:(NSString *)deviceId {
}

- (NSString *)readUUIDFromKeyChain:(NSError **)error {
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

- (NSString *)mdf_token {
  return [[NSUserDefaults standardUserDefaults] stringForKey:kMDFDeviceTokenKey] ?: @"";
}

- (void)mdf_saveToken:(NSString *)token {
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:kMDFDeviceTokenKey];
}

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
