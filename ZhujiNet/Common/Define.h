//
//  Define.h
//  ZhujiNet
//
//  Created by zhujiribao on 2017/7/22.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#ifndef Define_h
#define Define_h

//---------------通用——--------------------
#define kImgHolder                      @"default"                                                              //默认占位图片
#define kUserToken                      @"token"                                                                //获取

#define kHomeTopMenu                    @"homeTopMenu"                                                          //首页顶部导航菜单
#define kBbsForumMenu                   @"bbsForumMenu"                                                         //论坛版块菜单
#define kLocationLike                   @"kLocationLike"                                                        //本地点赞保存
#define kLocationBlanklist              @"kLocationBlanklist"                                                        //本地黑名单保存
#define kLocationBadge                  @"kLocationBadge"                                                       //本地角标保存
#define kLocationUserData               @"kLocationUserData"                                                     //本地用户数据保存
//----------home-------------------------
#define URL_launch                      @"http://app.zhuji.net/index/json/launch"
#define URL_channel                     @"http://app.zhuji.net/index/json/channel"
#define URL_thread                      @"http://app.zhuji.net/index/json/thread"
#define URL_slider                      @"http://app.zhuji.net/index/json/slider"
#define URL_web_detail                  @"http://app.zhuji.net/content/news/%@.html?header=no"
#define URL_replay                      @"http://app.zhuji.net/index/json/replay"
#define URL_newpost                     @"http://bbs.zhuji.net/zjapp/json/newpost"
#define URL_vod_signature               @"http://bbs.zhuji.net/zjapp/json/vod_signature"
#define URL_video_circle                @"http://bbs.zhuji.net/zjapp/json/video_circle"
#define URL_search                      @"http://app.zhuji.net/index/json/search"
#define URL_pagecount                   @"http://app.zhuji.net/index/json/pagecount"
//----------bbs-------------------------
#define URL_bbs_forum                   @"http://app.zhuji.net/index/json/bbs_forum"
#define URL_bbs_thread                  @"http://app.zhuji.net/index/json/bbs_thread"

//----------circle-------------------------
#define URL_circle_hot                  @"http://app.zhuji.net/index/json/circle_hot/"                          //诸暨圈
#define URL_circle                      @"http://app.zhuji.net/index/json/circle_post/"                         //诸暨圈
#define URL_circle_nav                  @"http://app.zhuji.net/index/json/circle_nav/"                          //诸暨圈分类导航
#define URL_circle_forum                @"http://app.zhuji.net/index/json/circle_forum/"                        //诸暨圈话题
#define URL_follow_post                 @"http://app.zhuji.net/index/json/follow_post"

//----------shop-------------------------
#define URL_shop_forum                  @"http://app.zhuji.net/index/json/shop_forum/"                          //社区店版块
#define URL_shop_post                   @"http://app.zhuji.net/index/json/shop_post/"                           //社区店

//----------mine-------------------------
#define URL_agree                       @"http://app.zhuji.net/user/bbs/agree"
#define URL_login                       @"http://bbs.zhuji.net/zjapp/json/login"                                //登录
#define URL_userinfo                    @"http://bbs.zhuji.net/zjapp/json/userinfo"                             //我的信息
#define URL_userinfo_update             @"http://bbs.zhuji.net/zjapp/json/userinfo_update"                      //更新用户信息
#define URL_sms                         @"http://bbs.zhuji.net/zjapp/json/sms"                                  //获取验证码
#define URL_imgcode                     @"http://bbs.zhuji.net/zjapp/json/imgcode"                              //图形验证码
#define URL_sms                         @"http://bbs.zhuji.net/zjapp/json/sms"                                  //发送短信
#define URL_lostpasswd                  @"http://bbs.zhuji.net/zjapp/json/lostpasswd"                           //设置密码
#define URL_checkregverifycode          @"http://bbs.zhuji.net/zjapp/json/checkregverifycode"                   //验证短信码
#define URL_edit_mobile                 @"http://bbs.zhuji.net/zjapp/json/edit_mobile"                          //更新手机号
#define URL_bind_mobile                 @"http://bbs.zhuji.net/zjapp/json/bind_mobile"                          //绑定手机号
#define URL_register                    @"http://bbs.zhuji.net/zjapp/json/register"                             //注册
#define URL_sysinfo_list                @"http://app.zhuji.net/index/json/sysinfo_list"                         //系统信息
#define URL_mythread                    @"http://bbs.zhuji.net/zjapp/json/mythread"                             //我的帖子
#define URL_recommend_add               @"http://bbs.zhuji.net/zjapp/json/recommend_add"                        //点赞
#define URL_replay_recommend            @"http://app.zhuji.net/index/json/replay_recommend"                     //赞列表
#define replay_recommend_post           @"http://app.zhuji.net/index/json/replay_recommend_post"                //回复点赞
#define URL_reward_list                 @"http://app.zhuji.net/index/json/reward_list"                          //赏列表
#define URL_reward_add                  @"http://bbs.zhuji.net/zjapp/json/reward_add"                           //打赏
#define URL_follow_add                  @"http://bbs.zhuji.net/zjapp/json/follow_add"                           //关注
#define URL_follow_user                 @"http://bbs.zhuji.net/zjapp/json/follow_user"                           //关注列表
#define URL_follow_del                  @"http://bbs.zhuji.net/zjapp/json/follow_del"
#define URL_otherthread                 @"http://bbs.zhuji.net/zjapp/json/otherthread"
//----------其他---------------------------
#define URL_government                  @"http://life.zhuji.net:8080/governmentAffairsApp/main.html"
#define URL_service                     @"http://life.zhuji.net:8080/life/LifeMain.html"                         //服务
#define URL_weather                     @"http://weatherapi.zhuji.net:8080/WeatherReport"                       //天气json
#define URL_weatherContent              @"http://weatherapi.zhuji.net:8080/WeatherReport/WeatherContent.jsp"    //天气内容页
#define URL_domain_inout                @"http://app.zhuji.net/index/json/domain_inout"

#define URL_report_add                  @"http://dk.zhuji.net/index/json/addReport"
#define URL_invitecode_add              @"http://app.zhuji.net/index/json/add_invitecode"                       //添加邀请码

//----------system-------------------------
#define SCREEN_WIDTH                    ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT                   ([[UIScreen mainScreen] bounds].size.height)
#define BarButton(TITLE,SELECTOR)       [[UIBarButtonItem alloc] initWithTitle:TITLE style:UIBarButtonItemStylePlain target:self action:SELECTOR]
#define ImageNamed(_name)               [UIImage imageNamed:_name]
#define NSString(NSInteger)             [NSString stringWithFormat:@"%ld",NSInteger]

#define WeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o;
#define StrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

// 判断是否是iPhone X
//#define iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhoneX (UIApplication.sharedApplication.statusBarFrame.size.height>=44 ? YES:NO)

// 状态栏高度
#define Height_StatusBar                (iPhoneX ? 44.f : 20.f)
// 导航栏高度
#define Height_NavBar                   (iPhoneX ? 88.f : 64.f)
// tabBar高度
#define Height_TabBar                   (iPhoneX ? (49.f+34.f) : 49.f)
// home indicator
#define Height_HomeIndicator            (iPhoneX ? 34.f : 0.f)

#define Height_NavBar_HomeIndicator     (iPhoneX ? 88.f+34.f : 64.f)
//-----------------------------------------
#endif /* Define_h */
