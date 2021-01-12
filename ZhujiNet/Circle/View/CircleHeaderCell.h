//
//  CicleHeaderCell.h
//  ZhujiNet
//
//  Created by zhujiribao on 2017/7/31.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PicScroll.h"

@interface CircleHeaderCell : UITableViewCell

@property (nonatomic, assign) CGFloat       height;
@property (nonatomic, strong) PicScroll*    hotPicScroll;
@property (nonatomic, strong) PicScroll*    menuPicScroll;
@property (nonatomic,copy) void(^blockWalkAction)(UIButton *sender);

@end
