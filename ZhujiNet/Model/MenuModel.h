//
//  ForumModel.h
//  ZhujiNet
//
//  Created by zhujiribao on 2017/8/2.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "NSObject+MJKeyValue.h"

@interface MenuModel : NSObject

@property (nonatomic,copy) NSString    *title;
@property (nonatomic,copy) NSString    *url;
@property (nonatomic,assign) NSInteger fid;
@property (nonatomic,assign) NSInteger dmode;
@property (nonatomic,assign) NSInteger ishide;
@property (nonatomic,assign) NSInteger istype;
@property (nonatomic,assign) NSInteger ispost;
@end
