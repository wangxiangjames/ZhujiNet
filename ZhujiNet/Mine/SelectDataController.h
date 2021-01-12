//
//  SelectDataController.h
//  ZhujiNet
//
//  Created by zhujiribao on 2017/9/1.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

typedef NS_ENUM(NSInteger, select_data_type)
{
    //以下是枚举成员
    select_data_date = 0,                   //选择时间
    select_data_area = 1,                   //选择区域
    select_data_sex = 2,                    //选择性别
    select_data_sign = 3,                    //个性签名
    select_data_report = 4,            
};

@interface SelectDataController : UIViewController

@property (nonatomic,assign)select_data_type    type;
@property (nonatomic,copy) NSString             *inputData;
@property (nonatomic,copy) NSString             *szResult;

@property (nonatomic,copy) void(^blockResultAction)(NSString *szResult);

@end
