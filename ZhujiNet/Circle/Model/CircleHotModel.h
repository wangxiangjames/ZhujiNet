//
//  CircleHotModel.h
//  ZhujiNet
//
//  Created by zhujiribao on 2018/1/27.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CircleHotModel : NSObject

@property (nonatomic,assign) NSInteger  tid;
@property (nonatomic,assign) NSInteger  likenum;
@property (nonatomic,copy) NSString     *title;
@property (nonatomic,copy) NSString     *author;
@property (nonatomic,copy) NSString     *image;
@property (nonatomic,copy) NSString     *forumname;
@property (nonatomic,assign) NSInteger  islike;
@end
