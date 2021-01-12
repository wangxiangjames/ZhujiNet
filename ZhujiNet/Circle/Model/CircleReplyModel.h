//
//  CircleReplyModel.h
//  ZhujiNet
//
//  Created by zhujiribao on 2018/1/29.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CircleReplyModel : NSObject

@property (nonatomic,assign) NSInteger  authorid;
@property (nonatomic,copy) NSString     *username;
@property (nonatomic,copy) NSString     *comment;

@end
