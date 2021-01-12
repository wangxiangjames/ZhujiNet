//
//  CircleModel.m
//  ZhujiNet
//
//  Created by zhujiribao on 2018/1/29.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//

#import "CircleModel.h"

@implementation CircleModel

+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"postlist" : @"CircleReplyModel",
             @"likelist" : @"LikeModel"
    };
}

@end
