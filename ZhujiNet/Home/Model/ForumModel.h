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

@interface ForumModel : NSObject

@property (copy, nonatomic) NSString *attachlist;
@property (copy, nonatomic) NSString *follow;
@property (copy, nonatomic) NSString *tid;
@property (copy, nonatomic) NSString *fid;
@property (copy, nonatomic) NSString *adminid;
@property (copy, nonatomic) NSString *sharetimes;
@property (copy, nonatomic) NSString *subject;
@property (copy, nonatomic) NSString *views;
@property (copy, nonatomic) NSString *authorid;
@property (copy, nonatomic) NSString *sortid;
@property (copy, nonatomic) NSString *recommend_add;

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *lastpost;
@property (copy, nonatomic) NSArray* imagelist;

@property (copy, nonatomic) NSString *dateline;
@property (copy, nonatomic) NSString *message;
@property (copy, nonatomic) NSString *attachments;

@property (copy, nonatomic) NSString *avatar;
@property (copy, nonatomic) NSString *displayorder;
@property (copy, nonatomic) NSString *pid;

@property (copy, nonatomic) NSString *comment;
@property (copy, nonatomic) NSString *attachment;
@property (copy, nonatomic) NSString *author;
@property (copy, nonatomic) NSString *digest;

@property (nonatomic, assign) CGFloat cellHeight;

@end
