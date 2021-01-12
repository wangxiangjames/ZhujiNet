//
//  ThreadModel.h
//  ZhujiNet
//
//  Created by zhujiribao on 2018/5/17.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+MJKeyValue.h"

@interface ThreadModel : NSObject

@property (nonatomic,assign) NSInteger  tid;
@property (nonatomic,copy) NSString*    author;
@property (nonatomic,assign) NSInteger  authorid;
@property (nonatomic,copy) NSString*    title;
@property (nonatomic,copy) NSString*    dateline;
@property (nonatomic,copy) NSString*    forumname;
@property (nonatomic,copy) NSString*    videocover;
@property (nonatomic,copy) NSString*    videourl;
@property (strong, nonatomic) NSArray*  imglist;
@property (nonatomic,assign) NSInteger  imgnum;
@property (nonatomic,assign) NSInteger  hits;
@property (nonatomic,copy) NSString*    recommend_add;
@property (nonatomic,copy) NSString*    shareurl;

@end
