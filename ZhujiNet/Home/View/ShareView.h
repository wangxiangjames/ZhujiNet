//
//  ShareView.h
//  ZhujiNet
//
//  Created by zhujiribao on 2017/8/8.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareView : UIView

@property (nonatomic,assign) CGFloat  height;
@property (nonatomic,strong) UIButton *btShang;
@property (nonatomic,copy) void(^blockShangAction)(UIButton *sender);
@property (nonatomic,copy) void(^blockWeixinAction)(UIButton *sender);
@property (nonatomic,copy) void(^blockFriendAction)(UIButton *sender);
@property (nonatomic,copy) void(^blockQQAction)(UIButton *sender);
@property (nonatomic,copy) void(^blockWeiboAction)(UIButton *sender);

-(void)likeList:(NSString *)users;
-(void)yiShangForBtn;

@end
