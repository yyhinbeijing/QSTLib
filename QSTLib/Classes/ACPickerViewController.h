//
//  YYHPicker.h
//  secoo
//
//  Created by yangyonghui on 2018/8/31.
//  Copyright © 2018年 aicow. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PickerViewType) {
    PickerViewTypeOneComponent,    //一个组件
    PickerViewTypeTwoComponent,    // 两个组件
    PickerViewTypeThreeComponent,  //三个组件
    PickerViewTyeDateComponent     //时间组件
};

typedef void(^SurebuttonBlock)(NSArray *);
typedef void (^CancelButtonBlock)(void);

@interface ACPickerViewController : UIViewController
/**
 创建一个不同类型的picker
 pickerViewDataDic: picker展示的值，如果是一个组件，则传入格式{key:arr},两个组件，传入格式{key:[arr1,arr2]},三个组件，传入格式{key:[arr1,arr2,arr3]}，如果时间选择器，传nil，
 注意：一个组件传入的value是一维数组，二个组件或三个组件传入的value是二维数组
 */
- (instancetype)initpickerViewType:(PickerViewType)pickerViewType pickerViewData:(NSDictionary *)pickerViewDataDic  cancelBlock:(CancelButtonBlock)cancelBlock surebuttonBlock:(SurebuttonBlock)sureButtonBlock;

@end
