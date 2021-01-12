//
//  NewsModel.h
//  ZhujiNet
//
//  Created by zhujiribao on 2017/8/5.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+MJKeyValue.h"

@interface NewsModel : NSObject

@property (copy, nonatomic) NSString *id;
@property (copy, nonatomic) NSString *category;
@property (copy, nonatomic) NSString *tid;
@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *imageurl;
@property (copy, nonatomic) NSString *dateline;
@property (copy, nonatomic) NSString *replies;
@property (copy, nonatomic) NSString *imagelink;
@property (copy, nonatomic) NSString *views;

@end

