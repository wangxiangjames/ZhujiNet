//
//  ReplyModel.h
//  ZhujiNet
//
//  Created by zhujiribao on 2017/8/5.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+MJKeyValue.h"

@interface ReplyModel : NSObject

@property (nonatomic,copy) NSString     *pid;
@property (nonatomic,copy) NSString     *author;
@property (nonatomic,copy) NSString     *authorid;
@property (nonatomic,copy) NSString     *avatar;
@property (nonatomic,copy) NSString     *dateline;
@property (nonatomic,copy) NSString     *message;
@property (nonatomic,copy) NSString     *area;
@property (nonatomic,assign) NSInteger  support;
@property (nonatomic,assign) NSInteger  level;
@property (nonatomic,copy) NSString     *quote;
@property (nonatomic,assign) NSInteger  islike;

@property (nonatomic,copy) NSArray*     imglist;

@end
