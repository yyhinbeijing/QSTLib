//
//  Configure.h
//  Pods
//
//  Created by secoo_yonghui on 2020/2/11.
//

#ifndef Configure_h
#define Configure_h

// color
#define RGBColor(rgb)                 RGBColorAndAlpha(rgb, 1.0)
#define RGBColorAndAlpha(rgb, a)      [UIColor colorWithRed:((float)((rgb & 0xFF0000) >> 16)) / 255.0 \
                                                      green:((float)((rgb & 0xFF00) >> 8)) / 255.0  \
                                                       blue:((float)(rgb & 0xFF)) / 255.0  \
                                                      alpha:a]
#define kYYScreenWidth                     ([UIScreen mainScreen].bounds.size.width)
#define kYYStatusBarHeight                 [UIApplication sharedApplication].statusBarFrame.size.height
#define kYYNavigationBarHeight             (44.f)
#define kYYTabBarHeight                    (49.f)
#define kYYNavigationAndStatusBarHeight    (kYYStatusBarHeight + kYYNavigationBarHeight)

#endif /* Configure_h */
