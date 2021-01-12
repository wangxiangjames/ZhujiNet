//
//  AppDelegate.h
//  ZhujiNet
//
//  Created by zhujiribao on 2017/7/18.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "Common.h"

typedef NS_ENUM(NSInteger, enum_login_status)
{
    login_status_out = 0,       //未登录
    login_status_in = 1,        //已登录
    login_status_reout = 2,     //重新退出
    login_status_relogin = 3,   //重新登录
};

@interface AppDelegate : UIResponder <UIApplicationDelegate,UNUserNotificationCenterDelegate>

@property (strong, nonatomic) UIWindow              *window;
@property (strong, nonatomic) UITabBarController    *tabController;
@property (strong, nonatomic) User                  *user;
@property (strong, nonatomic) CjwSkin               *skin;
@property (strong, nonatomic) CjwNet                *net;
@property (strong, nonatomic) NSMutableArray        *menu;
@property (strong, nonatomic) NSMutableArray        *forumMenu;
@property (strong, nonatomic) NSMutableArray        *circleMenu;
@property (strong, nonatomic) NSMutableArray        *shopMenu;
@property (strong, nonatomic) NSMutableArray        *domainLogout;      //多域名退出
@property (strong, nonatomic) NSMutableArray        *domainLogin;
@property (strong, nonatomic) NSMutableArray        *followUser;        //关注用户
@property (strong, nonatomic) NSDictionary          *ymUserInfo;
@property (copy, nonatomic)   NSString              *launchWebUrl;
@property (assign, nonatomic) enum_login_status     userLoginStatus;       //登陆状态
@property (assign, nonatomic) BOOL                  bInstall_sinaweibo;
@property (assign, nonatomic) BOOL                  bInstall_weixin;
@property (assign, nonatomic) BOOL                  bInstall_tencent;
@property (strong, nonatomic) NSMutableDictionary   *locationLike;          //保存本地点赞
@property (strong, nonatomic) NSMutableDictionary   *locationBlacklist;     //保存黑名单列表
@property (strong, nonatomic) NSMutableDictionary   *locationUserData;      //用户本地保存数据
+ (AppDelegate *) getApp;

@end


//cn.tengw.ZhujiOnLine

/*
 NSDictionary *dict=@{@"1":@"t1",@"2":@"t2"};
 [CjwFun putLocaionDict:kLocationLike value:dict];
 
 NSDictionary * dict2=[CjwFun getLocaionDict:kLocationLike];
 NSLog(@"loactionlike:%@",dict2);
 */
