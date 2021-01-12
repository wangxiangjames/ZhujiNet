//
//  CommonCell.h
//  ZhujiNet
//
//  Created by zhujiribao on 2018/3/7.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleModel.h"

@interface CircleDetailCell : UITableViewCell

@property (nonatomic, assign) CGFloat  height;
@property (nonatomic,copy) void(^blockTapImageViewAction)(UITapGestureRecognizer *gesture);
@property (nonatomic,copy) void(^blockFollowAction)(UIButton *sender);
@property (nonatomic,strong) UIButton   *btnFollow;

-(void)setData:(CircleModel *)model;

@end
