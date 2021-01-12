//
//  CicleHeaderCell.h
//  ZhujiNet
//
//  Created by zhujiribao on 2017/7/31.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReplyModel.h"

@interface ReplyCell : UITableViewCell

@property (nonatomic, assign) CGFloat       height;
@property (nonatomic, strong)UIButton*      btnLike;        //点赞按钮
@property (nonatomic,copy) void(^blockTapImageViewAction)(UITapGestureRecognizer *gesture);
@property (nonatomic,copy) void(^blockLikeAction)(UIButton *sender);
@property (nonatomic,copy) void(^blockReplyAction)(UIButton *sender);

-(void)setReplyModel:(ReplyModel *)reply;

@end
