//
//  BbsForumModel.h
//  ZhujiNet
//
//  Created by zhujiribao on 2018/1/22.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+MJKeyValue.h"
#import "ForumSubModel.h"

@interface BbsForumModel : NSObject
@property (copy, nonatomic) NSString *fid;
@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *sublist;
@end
