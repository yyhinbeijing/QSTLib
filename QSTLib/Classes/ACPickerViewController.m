//
//  ACPickerViewController.h
//  secoo
//
//  Created by yangyonghui on 2018/8/31.
//  Copyright © 2018年 aicow. All rights reserved.
//

#import "ACPickerViewController.h"
#import "Configure.h"
#import "NSDate+MDF.h"

#define MAXYEAR 2050
#define MINYEAR 1900

static const CGFloat viewHeight = 325;
static const CGFloat pickViewHeight = 330;
static const CGFloat bottomViewHeight = 330;

@interface ACPickerViewController () <UIPickerViewDataSource,UIPickerViewDelegate,UIViewControllerTransitioningDelegate>{
    //日期存储数组
    NSMutableArray *_yearArray;
    NSMutableArray *_monthArray;
    NSMutableArray *_dayArray;
    //记录位置
    NSInteger _yearIndex;
    NSInteger _monthIndex;
    NSInteger _dayIndex;
    //选择的值
    NSString *selectOneCompomentValue;
    NSString *selectTwoCompomentValue;
    NSString *selectThreeComomentValue;
    
    //处理数组
    NSMutableArray *_dealArr;
}

@property (strong ,nonatomic)  UIPickerView* pickerView;
@property (strong, nonatomic)  NSDictionary *pickerViewDataDic;
@property (assign, nonatomic)  PickerViewType pickerViewType;
@property (copy, nonatomic)    NSArray *selectValueArr;
@property (copy, nonatomic)    CancelButtonBlock cancelBlock;
@property (copy, nonatomic)    SurebuttonBlock sureBlock;
@property (strong, nonatomic)  UIView *botomView;

@end

@implementation ACPickerViewController

#pragma mark --初始化方法
- (instancetype)initpickerViewType:(PickerViewType)pickerViewType pickerViewData:(NSDictionary *)pickerViewDataDic cancelBlock:(CancelButtonBlock)cancelBlock surebuttonBlock:(SurebuttonBlock)sureButtonBlock{
    if (self == [super init]) {
        self.pickerViewType = pickerViewType;
        self.pickerViewDataDic = pickerViewDataDic;
        self.cancelBlock = cancelBlock;
        self.sureBlock = sureButtonBlock;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
    
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.preferredContentSize = CGSizeMake(kYYScreenWidth, viewHeight);
    self.view.backgroundColor = RGBColor(0xffffff);
    [self.view addSubview:self.botomView];
    [self initArrAndsetDefaultData];
    CGFloat pickerLeftPadding = 16;
    CGFloat pickerRightPadding = 15;
    CGFloat pickTopPadding = 15;
    UIPickerView *pickView = [[UIPickerView alloc] initWithFrame:CGRectMake(pickerLeftPadding, pickTopPadding,kYYScreenWidth - pickerLeftPadding - pickerRightPadding ,pickViewHeight + 5)];
    pickView.delegate = self;
    pickView.dataSource = self;
    pickView.backgroundColor = RGBColor(0xffffff);
    [self.botomView addSubview:pickView];
    self.pickerView = pickView;
    
    //滚动到默认的位置(即今天的时间)
    if (self.pickerViewType == PickerViewTyeDateComponent) {
        NSArray *indexArray = @[@(_yearIndex - 1),@(_monthIndex - 1),@(_dayIndex - 1)];
        if ([[indexArray objectAtIndex:0] integerValue] < 0 || [[indexArray objectAtIndex:1] integerValue] < 0 || [[indexArray objectAtIndex:2] integerValue] < 0) {
            NSDate *date = [NSDate date];
            _yearIndex = date.year-MINYEAR + 1;
             [self.pickerView selectRow:(_yearIndex - 1) > 0?(_yearIndex - 1):0 inComponent:0 animated:YES];
             [self.pickerView selectRow:date.month - 1 inComponent:1 animated:YES];
             [self.pickerView selectRow:date.day - 1 inComponent:2 animated:YES];
        }else{
            for (int i=0; i<indexArray.count; i++) {
                [self.pickerView selectRow:[[indexArray objectAtIndex:i] integerValue] inComponent:i animated:YES];
            }
        }
    }
    
// 取消按钮
    CGFloat cancelButtonWidth  = 64;
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setBackgroundColor:[UIColor clearColor]];
    [cancelBtn setTitleColor:RGBColor(0x1c1717) forState:UIControlStateNormal];
    [cancelBtn setTitleColor:RGBColor(0x8d8b8b) forState:UIControlStateHighlighted];
    cancelBtn.frame = CGRectMake(0, 0, cancelButtonWidth, 55);
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    cancelBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.botomView addSubview:cancelBtn];
    [cancelBtn addTarget:self action:@selector(_cancelAction) forControlEvents:UIControlEventTouchUpInside];
    
    //确认按钮
    CGFloat sureButtonWidth = 64;
    UIButton *sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
   [sureButton setBackgroundColor:[UIColor clearColor]];
   [sureButton setTitleColor:RGBColor(0x1c1717) forState:UIControlStateNormal];
   [sureButton setTitleColor:RGBColor(0x8d8b8b) forState:UIControlStateHighlighted];
    
    [self.botomView addSubview:sureButton];
    sureButton.frame = CGRectMake(kYYScreenWidth - sureButtonWidth , 0, sureButtonWidth, 55);
    [sureButton setTitle:@"确认" forState:UIControlStateNormal];
    sureButton.titleLabel.font = [UIFont systemFontOfSize:17];
    sureButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self.botomView addSubview:sureButton];
    [sureButton addTarget:self action:@selector(_sureButtonAction) forControlEvents:UIControlEventTouchUpInside];
}


- (void)_cancelAction {
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

- (void)_sureButtonAction {
    [self getSelectArrValue];
    if (self.sureBlock) {
        self.sureBlock(self.selectValueArr);
    }
}
- (UIView *)botomView {
    if (_botomView) {
        return _botomView;
    }else{
        if (!self.navigationController) {
           _botomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kYYScreenWidth, bottomViewHeight)];
        }else{
            _botomView = [[UIView alloc] initWithFrame:CGRectMake(0, kYYNavigationAndStatusBarHeight, kYYScreenWidth, bottomViewHeight)];
        }
        return _botomView;
    }
}

- (void)initArrAndsetDefaultData {
    _dealArr = [NSMutableArray array];
    if (self.pickerViewType == PickerViewTyeDateComponent) {
        _dayArray = [NSMutableArray array];
        _monthArray = [NSMutableArray array];
        _yearArray = [NSMutableArray array];
        [self getDatePickDefaultValue];
    }
}

#pragma mark pickview的代理
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    switch (self.pickerViewType) {
        case PickerViewTypeOneComponent:{
            return 1;
            break;
        }
        case PickerViewTypeTwoComponent:
            return 2;
            break;
        case PickerViewTypeThreeComponent:
            return 3;
            break;
        case PickerViewTyeDateComponent:
            return 3;
            break;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (self.pickerViewType) {
        case PickerViewTypeOneComponent:{
            NSArray *componentArr = [[self.pickerViewDataDic allValues] objectAtIndex:0];
            selectOneCompomentValue = [componentArr objectAtIndex:0];
            return [componentArr count];
            break;
        }
        case PickerViewTypeTwoComponent:{
            NSArray *componentArr = [[self.pickerViewDataDic allValues] objectAtIndex:0];
             NSArray *dataArr = [componentArr objectAtIndex:component];
            if (component == 0) {
               selectOneCompomentValue = [dataArr objectAtIndex:0];
            }else{
               selectTwoCompomentValue = [dataArr objectAtIndex:0];
            }
            return [dataArr count];
            break;
        }
        case PickerViewTypeThreeComponent:{
            NSArray *componentArr = [[self.pickerViewDataDic allValues] objectAtIndex:0];
             NSArray *dataArr = [componentArr objectAtIndex:component];
            if (component == 0) {
                selectOneCompomentValue = [dataArr objectAtIndex:0];
            }else if (component == 1){
                selectTwoCompomentValue = [dataArr objectAtIndex:0];
            }else{
                selectThreeComomentValue = [dataArr objectAtIndex:0];
            }
            return [dataArr count];
            break;
        }
        case PickerViewTyeDateComponent:{
            if (component == 0) {
                return _yearArray.count;
            }else if (component == 1){
                return _monthArray.count;
            }else{
                if (_yearIndex > 0 && _monthIndex > 0) {
                     [self daysfromYear:[self getYear] andMonth:_monthIndex];
                }else{
                    NSDate *date = [NSDate date];
                    [self daysfromYear:date.year andMonth:date.month];
                }
                return _dayArray.count;
            }
            break;
        }
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view

{
    
    //设置分割线的颜色
    for(UIView *singleLine in pickerView.subviews)
    {
        if (singleLine.frame.size.height < 1)
        {
            singleLine.backgroundColor = RGBColor(0xe1e1e1);
        }
    }
    
    UILabel *customLabel = (UILabel *)view;
    if (!customLabel) {
        customLabel = [[UILabel alloc] init];
        customLabel.textAlignment = NSTextAlignmentCenter;
        customLabel.font = [UIFont systemFontOfSize:19];
        customLabel.textColor = [UIColor blackColor];
    }
    //设置文字的属
    customLabel.text = [self getComponentTitleInRow:row inCompoment:component];
    return customLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (self.pickerViewType) {
        case PickerViewTypeOneComponent:{
            NSArray *componentArr = [[self.pickerViewDataDic allValues] objectAtIndex:0];
            selectOneCompomentValue =  [componentArr objectAtIndex:row];
            break;
        }
        case PickerViewTypeTwoComponent:
            if (component == 0) {
                selectOneCompomentValue = [self getComponentTitleInRow:row inCompoment:component];
            }else{
                selectTwoCompomentValue = [self getComponentTitleInRow:row inCompoment:component];
            }
            break;
        case PickerViewTypeThreeComponent:
            if (component == 0) {
                selectOneCompomentValue = [self getComponentTitleInRow:row inCompoment:component];
            }else if (component == 1){
                selectTwoCompomentValue = [self getComponentTitleInRow:row inCompoment:component];
            }else{
                selectThreeComomentValue = [self getComponentTitleInRow:row inCompoment:component];
            }
            break;
        case PickerViewTyeDateComponent:{
            if (component == 0) {
                _yearIndex = row + 1;
                [self daysfromYear:[self getYear] andMonth:_monthIndex];
                [self.pickerView reloadAllComponents];
                 selectOneCompomentValue = [self getComponentTitleInRow:row inCompoment:component];
            }else if (component == 1){
                _monthIndex = row + 1;
                [self daysfromYear:[self getYear] andMonth:_monthIndex];
                [self.pickerView reloadAllComponents];
                 selectTwoCompomentValue = [self getComponentTitleInRow:row inCompoment:component];
            }else{
                 selectThreeComomentValue = [self getComponentTitleInRow:row inCompoment:component];
            }
            break;
        }
    }
    [self getSelectArrValue];
}

- (NSInteger)getYear {
    return _yearIndex + MINYEAR - 1;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 50;
}

#pragma mark -- 下面是一些私有方法
- (NSString *)getComponentTitleInRow:(NSInteger)row inCompoment:(NSInteger)compoment{
    switch (self.pickerViewType) {
        case PickerViewTypeOneComponent:{
            NSArray *componentArr = [[self.pickerViewDataDic allValues] objectAtIndex:0];
            return [componentArr objectAtIndex:row];
            break;
        }
        case PickerViewTypeTwoComponent:{
            NSArray *componentArr = [[self.pickerViewDataDic allValues] objectAtIndex:0];
            NSArray *compementInfoArr = [componentArr objectAtIndex:compoment];
            return [compementInfoArr objectAtIndex:row];
             break;
        }
        case PickerViewTypeThreeComponent:{
            NSArray *componentArr = [[self.pickerViewDataDic allValues] objectAtIndex:0];
            NSArray *compementInfoArr = [componentArr objectAtIndex:compoment];
            return [compementInfoArr objectAtIndex:row];
            break;
        }
        case PickerViewTyeDateComponent:{
            if (compoment == 0) {
                return [_yearArray objectAtIndex:row];
            }else if (compoment == 1){
                return [_monthArray objectAtIndex:row];
            }else{
                [self daysfromYear:[self getYear] andMonth:_monthIndex];
                return [_dayArray objectAtIndex:row];
            }
            break;
        }
    }
}

//记录选择的值，用一个数组装着
- (void)getSelectArrValue {
    [_dealArr removeAllObjects];
    if (selectOneCompomentValue) {
        [_dealArr addObject:selectOneCompomentValue];
    }
    if (selectTwoCompomentValue) {
        [_dealArr addObject:selectTwoCompomentValue];
    }
    if (selectThreeComomentValue) {
        [_dealArr addObject:selectThreeComomentValue];
    }
    self.selectValueArr = [NSArray arrayWithArray:_dealArr];
}

//获取时间选择器的初始滚轮位置的数据(今天的数据)
- (void)getDatePickDefaultValue {
    for (int i = 1; i < 13; i++) {
        NSString *monStr = [NSString stringWithFormat:@"%02d月",i];
        [_monthArray addObject:monStr];
    }
    
    for (NSInteger i = MINYEAR ; i < MAXYEAR + 1; i++) {
        NSString *yearStr = [NSString stringWithFormat:@"%04ld年",i];
        [_yearArray addObject:yearStr];
    }
    
    NSDate *date = [NSDate date];
    [self daysfromYear:date.year andMonth:date.month];
    _yearIndex = date.year-MINYEAR + 1;
    _monthIndex = date.month;
    _dayIndex = date.day;
    selectOneCompomentValue = [NSString stringWithFormat:@"%04ld年",date.year];
    selectTwoCompomentValue = [NSString stringWithFormat:@"%02ld月",date.month];
    selectThreeComomentValue = [NSString stringWithFormat:@"%02ld日",date.day];
}

//计算每月的天数
-(NSInteger)daysfromYear:(NSInteger)year andMonth:(NSInteger)month{
    NSInteger num_year  = year;
    NSInteger num_month = month;
    
    BOOL isrunNian = num_year%4==0 ? (num_year%100==0? (num_year%400==0?YES:NO):YES):NO;
    switch (num_month) {
        case 1:case 3:case 5:case 7:case 8:case 10:case 12:{
            [self setdayArray:31];
            return 31;
        }
        case 4:case 6:case 9:case 11:{
            [self setdayArray:30];
            return 30;
        }
        case 2:{
            if (isrunNian) {
                [self setdayArray:29];
                return 29;
            }else{
                [self setdayArray:28];
                return 28;
            }
        }
        default:
            break;
    }
    return 0;
}

//设置每月的天数数组
-(void)setdayArray:(NSInteger)num{
    [_dayArray removeAllObjects];
    for (int i=1; i<=num; i++) {
        [_dayArray addObject:[NSString stringWithFormat:@"%02d日",i]];
    }
}

#pragma mark - UIViewControllerTransitioningDelegate

//- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
//    LVMProductDetailPresentationController *vc = [[LVMProductDetailPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
//    return vc;
//}
//
//- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
//    LVMProductDetailTransition *transition = [[LVMProductDetailTransition alloc] initWithTransitionType:LVMAlertTransitionTypePresent];
//    return transition;
//}
//
//- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
//    LVMProductDetailTransition *transition = [[LVMProductDetailTransition alloc] initWithTransitionType:LVMAlertTransitionTypeDismiss];
//    return transition;
//}

@end
