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

@interface SliderModel : NSObject

@property (assign, nonatomic) NSInteger tid;
@property (assign, nonatomic) NSInteger dmode;
@property (assign, nonatomic) NSInteger contmode;
@property (copy, nonatomic) NSString    *title;
@property (copy, nonatomic) NSString    *url;
@property (copy, nonatomic) NSString    *image;
@property (assign, nonatomic) NSInteger jumpchannel;
@end
