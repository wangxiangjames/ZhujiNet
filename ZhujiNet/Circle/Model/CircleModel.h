//
//  CircleModel.h
//  ZhujiNet
//
//  Created by zhujiribao on 2018/1/29.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface CircleModel : NSObject

@property (nonatomic,copy) NSString     *avatar;
@property (nonatomic,copy) NSString     *author;
@property (nonatomic,assign) NSInteger  authorid;
@property (nonatomic,assign) NSInteger  level;
@property (nonatomic,copy) NSString     *forumname;
@property (nonatomic,copy) NSString     *title;
@property (nonatomic,copy) NSString     *dateline;
@property (nonatomic,copy) NSString     *videocover;
@property (nonatomic,copy) NSString     *videourl;
@property (nonatomic,assign) NSInteger  hits;
@property (nonatomic,assign) NSInteger  likenum;
@property (nonatomic,assign) NSInteger  tid;
@property (nonatomic,copy) NSString     *shareurl;
@property (nonatomic,assign) NSInteger  img_width;
@property (nonatomic,assign) NSInteger  img_height;
@property (nonatomic,assign) NSInteger  imgnum;
@property (nonatomic,strong) NSArray    *imglist;
@property (nonatomic,assign) NSInteger  postnum;
@property (nonatomic,strong) NSArray    *postlist;
@property (nonatomic,strong) NSArray    *likelist;

@property (nonatomic, assign) CGFloat   cellHeight;
@property (nonatomic, assign) BOOL      isVideoHeight;      //由于视频图片服务器没有提供高度和宽度，需要下载后读取宽度后高度 有sd_setImageWithURL读取

@end
