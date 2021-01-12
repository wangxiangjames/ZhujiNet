//
//  ForumModel.m
//  ZhujiNet
//
//  Created by zhujiribao on 2017/8/2.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import "MenuModel.h"
#import "MJExtension.h"

@implementation MenuModel

MJExtensionCodingImplementation

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"fid"   :@"id",
    };
}


@end
