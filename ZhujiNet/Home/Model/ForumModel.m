//
//  ForumModel.m
//  ZhujiNet
//
//  Created by zhujiribao on 2017/8/2.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import "ForumModel.h"
#import "MJExtension.h"

@implementation ForumModel

MJExtensionCodingImplementation

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"name"        :@"forumname",
             @"imagelist"   :@"imglist",
             @"subject"     :@"title"
    };
}

@end
