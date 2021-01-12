//
//  AppDelegate.m
//  ZhujiNet
//
//  Created by zhujiribao on 2017/7/18.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import "AppDelegate.h"
#import <UMCommon/UMCommon.h>
#import "WelcomeViewController.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import "ViewController.h"
#import "MapViewController.h"
#import <UMPush/UMessage.h>

@interface AppDelegate (){
     BMKMapManager* _mapManager;
}

@end

@implementation AppDelegate

/*
 初始化全局变量：皮肤设置 cjwSkin,网络访问cjwNet,资讯类菜单menu
 */
+ (AppDelegate *) getApp {
    AppDelegate *app=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(app.user==nil){
        app.user=[User shareInstance];
    }
    if(app.skin==nil){
        app.skin=[[CjwSkin alloc]init];
    }
    if(app.net==nil){
        app.net=[[CjwNet alloc] init];
    }
    if(app.menu==nil){
        app.menu = [NSMutableArray arrayWithObjects:@"推荐", nil];
    }
    if (app.domainLogin==nil) {
        app.domainLogin=[NSMutableArray arrayWithCapacity:5];
    }
    if(app.followUser==nil){
        app.followUser=[NSMutableArray arrayWithCapacity:10];
    }
    
    if(app.locationLike==nil){
        app.locationLike=[(NSDictionary *)[CjwFun getLocaionDict:kLocationLike] mutableCopy];
        if (app.locationLike==nil) {
            app.locationLike=[[NSMutableDictionary alloc] init];
        }
        //[app.locationLike removeAllObjects];
        //[CjwFun putLocaionDict:kLocationLike value:app.locationLike];
        NSLog(@"locationLike:%@",app.locationLike);
        
        NSInteger len=[app.locationLike count];
        NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
        [app.locationLike enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL * _Nonnull stop) {
            NSTimeInterval oldTime = [obj timeIntervalSince1970];
            double timeDiffence = currentTime - oldTime;
            int day=(int)(timeDiffence/3600/24);
            if (day>0) {
                [app.locationLike removeObjectForKey:key];
            }
        }];
        
        NSInteger len2=[app.locationLike count];
        if (len!=len2) {
            [CjwFun putLocaionDict:kLocationLike value:[app.locationLike copy]];
        }
        NSLog(@"locationLike2:%@",app.locationLike);
    }
    
    if(app.locationBlacklist==nil){
        app.locationBlacklist=[(NSDictionary *)[CjwFun getLocaionDict:kLocationBlanklist] mutableCopy];
        if (app.locationBlacklist==nil) {
            app.locationBlacklist=[[NSMutableDictionary alloc] init];
        }
        NSLog(@"locationBlacklist:%@",app.locationBlacklist);
    }
    
    if(app.locationUserData==nil){
        app.locationUserData=[(NSDictionary *)[CjwFun getLocaionDict:kLocationUserData] mutableCopy];
        if (app.locationUserData==nil) {
            app.locationUserData=[[NSMutableDictionary alloc] init];
        }
    }
    return app;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window.rootViewController =[[WelcomeViewController alloc] init];
    
    [CjwFun initShare];
    [self isAppInstall];
    //----------------------友盟统计---------------------------
    [UMConfigure initWithAppkey:@"5a141306f29d98061800017b" channel:@"App Store"];
    //----------------------友盟推送---------------------------
    // Push组件基本功能配置
    UMessageRegisterEntity * entity = [[UMessageRegisterEntity alloc] init];
    //type是对推送的几个参数的选择，可以选择一个或者多个。默认是三个全部打开，即：声音，弹窗，角标
    entity.types = UMessageAuthorizationOptionBadge|UMessageAuthorizationOptionSound|UMessageAuthorizationOptionAlert;
    [UNUserNotificationCenter currentNotificationCenter].delegate=self;
    [UMessage registerForRemoteNotificationsWithLaunchOptions:launchOptions Entity:entity     completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
        }else{
        }
    }];
    //iOS10必须加下面这段代码。
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate=self;
    UNAuthorizationOptions types10=UNAuthorizationOptionBadge|UNAuthorizationOptionAlert|UNAuthorizationOptionSound;
    [center requestAuthorizationWithOptions:types10  completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            //点击允许
        } else {
            //点击不允许
        }
    }];
    

    NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(userInfo){
        self.ymUserInfo = userInfo;
    }
    //---------------------------------------------------------
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定generalDelegate参数
    BOOL ret = [_mapManager start:@"o9SkSE0qQLC4jXj16N7luhrBxTSuwYhS"  generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
    return YES;
}

//iOS10以下使用这个方法接收通知
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //关闭U-Push自带的弹出框
    [UMessage setAutoAlert:NO];
    [UMessage didReceiveRemoteNotification:userInfo];
    
    //UIApplication *app = [UIApplication sharedApplication];
    //application.applicationIconBadgeNumber = 100;
}

//iOS10新增：处理前台收到通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于前台时的远程推送接受
        //关闭U-Push自带的弹出框
        [UMessage setAutoAlert:NO];
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        
    }else{
        //应用处于前台时的本地推送接受
    }
    //当应用处于前台时提示设置，需要哪个可以设置哪一个
    completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
}

//iOS10新增：处理后台点击通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler{
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于后台时的远程推送接受
        //必须加这句代码
        
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            //前台
            [[NSNotificationCenter defaultCenter]postNotificationName:@"userInfoNotification" object:userInfo];
            
        }else{
            //后台
            [[NSNotificationCenter defaultCenter]postNotificationName:@"userInfoNotification" object:userInfo];
        }
        [UMessage didReceiveRemoteNotification:userInfo];
        
    }else{
        //应用处于后台时的本地推送接受
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"deviceToken:%@",deviceToken);
    [UMessage registerDeviceToken:deviceToken];
    NSString * token = [[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]
                         stringByReplacingOccurrencesOfString: @">" withString: @""]
                        stringByReplacingOccurrencesOfString: @" " withString: @""];
    NSLog(@"device_token:%@",token);
}

// 支持所有iOS系统
//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
//{
//    //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
//    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
//    if (!result) {
//        // 其他如支付等SDK的回调
//    }
//    return result;
//}

//- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
//{
//    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
//    if (!result) {
//        // 其他如支付等SDK的回调
//    }
//    return result;
//}

-(void)isAppInstall{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"sinaweibo://"]])
    {
        self.bInstall_sinaweibo=YES;
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]])
    {
        self.bInstall_weixin=YES;
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]])
    {
        self.bInstall_tencent=YES;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskAll;
}

@end
