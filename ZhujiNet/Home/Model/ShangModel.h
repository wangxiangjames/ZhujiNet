//
//  ShangModel.h
//  ZhujiNet
//
//  Created by zhujiribao on 2018/2/5.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+MJKeyValue.h"

@interface ShangModel : NSObject

@property (nonatomic,assign) NSInteger  uid;
@property (nonatomic,copy) NSString     *username;
@property (nonatomic,assign) NSInteger  credit;
@property (nonatomic,copy) NSString     *dateline;

@end
