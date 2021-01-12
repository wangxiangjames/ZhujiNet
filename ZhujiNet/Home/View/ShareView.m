//
//  ShareView.m
//  ZhujiNet
//
//  Created by zhujiribao on 2017/8/8.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import "ShareView.h"
#import "Common.h"

@interface ShareView(){
    UILabel         *_like;
    UIButton        *_btnShangWord;
    UILabel         *_fenxiang;
    UIButton        *_bt0;
    UIButton        *_bt1;
    UIButton        *_bt2;
    UIButton        *_bt3;
    UIView          *_line0;
    UIView          *_line1;
}
@end

@implementation ShareView

- (instancetype)init
{
    self = [super init];
    if (self) {
        //self.userInteractionEnabled =YES;
        [self ininViews];
    }
    return self;
}

-(void)ininViews{
    CjwSkin* skin=[AppDelegate getApp].skin;
    
    UIImage *btBg=[UIImage imageWithColor:skin.colorMainLight size:CGSizeMake(1, 1)];
    _btShang=[UIButton new];
    [_btShang addTarget:self action:@selector(actionShang:) forControlEvents:UIControlEventTouchUpInside];
    [_btShang setTitle: @"赏" forState: UIControlStateNormal];
    _btShang.titleLabel.font=[UIFont systemFontOfSize:28];
    _btShang.backgroundColor=skin.colorMainLight;
    [_btShang setBackgroundImage:btBg forState:UIControlStateNormal];
    [_btShang setTitleColor:skin.colorButtonMainLight forState:UIControlStateNormal];
    _btShang.layer.cornerRadius=28;
    _btShang.clipsToBounds=YES;
    _btShang.alpha=skin.floatImgAlpha;
    [self addSubview:_btShang];

    _btnShangWord=[UIButton new];
    [_btnShangWord setTitle: @"打赏列表" forState: UIControlStateNormal];
    [_btnShangWord setTitleColor:skin.colorMainLight forState:UIControlStateNormal];
    [_btnShangWord addTarget:self action:@selector(actionShang:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_btnShangWord];
    
    _like=[UILabel new];
    _like.text=@"";
    _like.textColor=skin.colorMainDark;
    _like.alpha=skin.floatImgAlpha+skin.floatImgAlpha/2;
    _like.numberOfLines=0;
    _like.font=[UIFont systemFontOfSize:15];
    _like.textAlignment=NSTextAlignmentLeft;
    [self addSubview:_like];
    
    _fenxiang=[UILabel new];
    _fenxiang.text=@"分享";
    _fenxiang.backgroundColor=skin.colorCellBg;
    _fenxiang.textColor=skin.colorCellTitle;
    _fenxiang.textAlignment=NSTextAlignmentCenter;
    [self addSubview:_fenxiang];
    
    _bt0=[UIButton new];
    [_bt0 addTarget:self action:@selector(actionWeixin:) forControlEvents:UIControlEventTouchUpInside];
    [_bt0 setTitle: @"微信好友" forState: UIControlStateNormal];
    [_bt0 setTitleColor:[AppDelegate getApp].bInstall_weixin?skin.colorButton:[UIColor colorWithHexString:@"aaaaaa"] forState:UIControlStateNormal];
    [_bt0 setEnabled:[AppDelegate getApp].bInstall_weixin];
    _bt0.titleEdgeInsets=UIEdgeInsetsMake(70, -50, 0, 0);
    _bt0.titleLabel.font=[UIFont systemFontOfSize:14];
    [_bt0 setImage:[UIImage imageNamed:@"share_wechat"] forState:UIControlStateNormal];
    _bt0.imageEdgeInsets=UIEdgeInsetsMake(0, 10, 10, 0);
    _bt0.alpha=skin.floatImgAlpha;
    [self addSubview:_bt0];
    
    _bt1=[UIButton new];
    [_bt1 addTarget:self action:@selector(actionFriend:) forControlEvents:UIControlEventTouchUpInside];
    [_bt1 setTitle: @"微信朋友圈" forState: UIControlStateNormal];
    [_bt1 setTitleColor:[AppDelegate getApp].bInstall_weixin?skin.colorButton:[UIColor colorWithHexString:@"aaaaaa"]  forState:UIControlStateNormal];
    [_bt1 setEnabled:[AppDelegate getApp].bInstall_weixin];
    _bt1.titleEdgeInsets=UIEdgeInsetsMake(70, -50, 0, 0);
    _bt1.titleLabel.font=[UIFont systemFontOfSize:14];
    [_bt1 setImage:[UIImage imageNamed:@"share_wechattimeline"] forState:UIControlStateNormal];
    _bt1.imageEdgeInsets=UIEdgeInsetsMake(0, 10, 10, 0);
    _bt1.alpha=skin.floatImgAlpha;
    [self addSubview:_bt1];
    
    _bt2=[UIButton new];
    [_bt2 addTarget:self action:@selector(actionQQ:) forControlEvents:UIControlEventTouchUpInside];
    [_bt2 setTitle: @"腾讯QQ" forState: UIControlStateNormal];
    [_bt2 setTitleColor:[AppDelegate getApp].bInstall_tencent?skin.colorButton:[UIColor colorWithHexString:@"aaaaaa"]  forState:UIControlStateNormal];
    [_bt2 setEnabled:[AppDelegate getApp].bInstall_tencent];
    _bt2.titleEdgeInsets=UIEdgeInsetsMake(70, -50, 0, 0);
    _bt2.titleLabel.font=[UIFont systemFontOfSize:14];
    [_bt2 setImage:[UIImage imageNamed:@"share_qq"] forState:UIControlStateNormal];
    _bt2.imageEdgeInsets=UIEdgeInsetsMake(0, 10, 10, 0);
    _bt2.alpha=skin.floatImgAlpha;
    [self addSubview:_bt2];
    
    _bt3=[UIButton new];
    [_bt3 addTarget:self action:@selector(actionWeibo:) forControlEvents:UIControlEventTouchUpInside];
    [_bt3 setTitle: @"新浪微博" forState: UIControlStateNormal];
    [_bt3 setTitleColor:[AppDelegate getApp].bInstall_sinaweibo?skin.colorButton:[UIColor colorWithHexString:@"aaaaaa"] forState:UIControlStateNormal];
    [_bt3 setEnabled:[AppDelegate getApp].bInstall_sinaweibo];
    _bt3.titleEdgeInsets=UIEdgeInsetsMake(70, -50, 0, 0);
    _bt3.titleLabel.font=[UIFont systemFontOfSize:14];
    [_bt3 setImage:[UIImage imageNamed:@"share_sina"] forState:UIControlStateNormal];
    _bt3.imageEdgeInsets=UIEdgeInsetsMake(0, 10, 10, 0);
    _bt3.alpha=skin.floatImgAlpha;
    [self addSubview:_bt3];
    
    _line0=[UIView new];
    _line0.backgroundColor=skin.colorCellSeparator;
    [self addSubview:_line0];
    
    _line1=[UIView new];
    _line1.backgroundColor=skin.colorCellSeparator;
    [self addSubview:_line1];
}

- (CGFloat)height
{
    [_btShang mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(14);
        make.centerX.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(56, 56));
    }];
    
    [_btnShangWord mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_btShang.mas_bottom).offset(6);
        make.centerX.mas_equalTo(self);
    }];
    
    [_like mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_btnShangWord.mas_bottom).offset(14);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
    }];
    
    [_fenxiang mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_like.mas_bottom).offset(8);
        make.centerX.mas_equalTo(self);
    }];
    
    [_line0 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_fenxiang);
        make.left.mas_equalTo(self);
        make.right.mas_equalTo(_fenxiang.mas_left).offset(-20);
        make.height.mas_equalTo(1);
    }];
    
    [_line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_fenxiang);
        make.right.mas_equalTo(self);
        make.left.mas_equalTo(_fenxiang.mas_right).offset(20);
        make.height.mas_equalTo(1);
    }];
    
    NSArray *array=@[_bt0,_bt1,_bt2,_bt3];
    [array mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:70 leadSpacing:20 tailSpacing:20];
    [array mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_fenxiang.mas_bottom).offset(14);
        make.height.mas_equalTo(70);
    }];
    
    [self layoutIfNeeded];
    return _bt0.y+_bt0.height+30;
}

-(void)likeList:(NSString *)users{
    _like.text=users;
}

-(void)actionShang:(id)sender{
    if(self.blockShangAction){
        self.blockShangAction(sender);
    }
}

-(void)actionWeixin:(id)sender{
    if(self.blockWeixinAction){
        self.blockWeixinAction(sender);
    }
}

-(void)actionFriend:(id)sender{
    if(self.blockFriendAction){
        self.blockFriendAction(sender);
    }
}

-(void)actionQQ:(id)sender{
    if(self.blockQQAction){
        self.blockQQAction(sender);
    }
}

-(void)actionWeibo:(id)sender{
    if(self.blockWeiboAction){
        self.blockWeiboAction(sender);
    }
}

-(void)yiShangForBtn
{
    UIImage *btBg=[UIImage imageWithColor:[UIColor colorWithHexString:@"aaaaaa"] size:CGSizeMake(1, 1)];
    self.btShang.titleLabel.font=[UIFont systemFontOfSize:20];
    [self.btShang setTitle: @"已赏" forState: UIControlStateNormal];
    [self.btShang setBackgroundImage:btBg forState:UIControlStateNormal];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
