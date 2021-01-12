//
//  CicleHeaderCell.h
//  ZhujiNet
//
//  Created by zhujiribao on 2017/7/31.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PicScroll.h"
#import "CircleModel.h"

@interface CircleCell : UITableViewCell

@property (nonatomic, assign) CGFloat           height;
@property (nonatomic,copy) void(^blockTapImageViewAction)(UITapGestureRecognizer *gesture);
@property (nonatomic,copy) void(^blockLikeAction)(UIButton *sender);
@property (nonatomic,copy) void(^blockShareAction)(UIButton *sender);
@property (nonatomic,copy) void(^blockReplyAction)(UIButton *sender);
@property (nonatomic,copy) void(^blockLookAllAction)(UIButton *sender);
@property (nonatomic,copy) void(^blockMoreAction)(UIButton *sender);

-(void)setCircleModel:(CircleModel *)circle;
@end
