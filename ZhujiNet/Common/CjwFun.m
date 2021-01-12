//
//  CjwFun.m
//  CjwSchool
//
//  Created by chenjinwei on 16/4/11.
//  Copyright © 2016年 chenjinwei. All rights reserved.
//

#import "CjwFun.h"
//#import <SDWebImageManager.h>
#import "AppDelegate.h"
#import "BbsForumModel.h"
#import "BBSMenuViewController.h"
#import "AFHTTPSessionManager+Synchronous.h"


@implementation CjwFun

+(void) showAlertMessage:(NSString *) message currViewController:(UIViewController*)viewController{
    //创建提示框指针
    UIAlertController *alertMessage;
    //用参数myMessage初始化提示框
    alertMessage = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    //添加按钮
    [alertMessage addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    //display the message on screen  显示在屏幕上
    [viewController presentViewController:alertMessage animated:YES completion:nil];
}

//获取当前时间戳
+(NSString *)currentTimeStr{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval time=[date timeIntervalSince1970]*1000;// *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}

#pragma 正则匹配手机号
+ (BOOL)checkTelNumber:(NSString *) telNumber
{
    NSString *pattern = @"^1+[34578]+\\d{9}";
    //    NSString *pattern = @"^(0|86|17951)?(13[0-9]|15[012356789]|17[678]|18[0-9]|14[57])[0-9]{8}$/)";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:telNumber];
    return isMatch;
}

#pragma 正则匹配手机号
+ (BOOL)isNumber:(NSString *)number
{
    NSString *pattern = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:number];
    return isMatch;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"

+(CGSize)sizeForText:(UILabel*)label width:(CGFloat)width font:(UIFont*)font  lineSapce:(CGFloat)space{
    CGSize maxSize = CGSizeMake(width, CGFLOAT_MAX);
    
    CGSize textSize = CGSizeZero;
    // iOS7以后使用boundingRectWithSize，之前使用sizeWithFont
    if ([label.text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:label.text];
        NSMutableParagraphStyle *pstyle = [[NSMutableParagraphStyle alloc] init];
        [pstyle setLineSpacing:space];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:pstyle range:NSMakeRange(0, [label.text length])];
        label.attributedText = attributedString;
        label.font=font;
        [label sizeToFit];
        
        NSStringDrawingOptions opts = NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading;
        NSDictionary *attributes = @{ NSFontAttributeName:font, NSParagraphStyleAttributeName:pstyle };
        CGRect rect = [label.text boundingRectWithSize:maxSize
                                               options:opts
                                            attributes:attributes
                                               context:nil];
        
        textSize = rect.size;
    }
    else{
        textSize = [label.text sizeWithFont:font constrainedToSize:maxSize lineBreakMode:NSLineBreakByCharWrapping];
    }
    return textSize;
}

+(CGSize)sizeForText:(NSString*)text font:(UIFont*)font{
    CGRect screen = [UIScreen mainScreen].bounds;
    CGFloat maxWidth = screen.size.width;
    CGSize maxSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
    
    CGSize textSize = CGSizeZero;
    // iOS7以后使用boundingRectWithSize，之前使用sizeWithFont
    if ([text respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        // 多行必需使用NSStringDrawingUsesLineFragmentOrigin
        NSStringDrawingOptions opts = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setLineBreakMode:NSLineBreakByCharWrapping];
        NSDictionary *attributes = @{ NSFontAttributeName : font, NSParagraphStyleAttributeName : style };
        CGRect rect = [text boundingRectWithSize:maxSize
                                         options:opts
                                      attributes:attributes
                                         context:nil];
        textSize = rect.size;
    } else{
        textSize = [text sizeWithFont:font constrainedToSize:maxSize lineBreakMode:NSLineBreakByCharWrapping];
    }
    return textSize;
}

#pragma clang diagnostic pop

+(void) putLocaionDict:(NSString*)key value:(NSObject *)obj{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:obj forKey:key];
    [defaults synchronize];
}

+(NSObject *) getLocaionDict:(NSString*)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:key];
}

//----------------------友盟分享---------------------------

+ (void)initShare{
    /* 打开调试日志 */
//    [[UMSocialManager defaultManager] openLog:YES];
    /* 设置友盟appkey */
    [CjwFun confitUShareSettings];
    [CjwFun configUSharePlatforms];
}

+ (void)confitUShareSettings
{
    /*
     * 打开图片水印
     */
    //[UMSocialGlobal shareInstance].isUsingWaterMark = YES;
    
    /*
     * 关闭强制验证https，可允许http图片分享，但需要在info.plist设置安全域名
     <key>NSAppTransportSecurity</key>
     <dict>
     <key>NSAllowsArbitraryLoads</key>
     <true/>
     </dict>
     */
    //[UMSocialGlobal shareInstance].isUsingHttpsWhenShareContent = NO;
    
    //配置微信平台的Universal Links
//微信和QQ完整版会校验合法的universalLink，不设置会在初始化平台失败
//[UMSocialGlobal shareInstance].universalLinkDic = @{@(UMSocialPlatformType_WechatSession):@"https://bbs.zhuji.net/",
//                                                    @(UMSocialPlatformType_QQ):@"https://bbs.zhuji.net/qq_conn/101830139"
//                                                    };
    
}

+ (void)configUSharePlatforms
{
   
    [ShareSDK registPlatforms:^(SSDKRegister *platformsRegister) {
                               //QQ
                               [platformsRegister setupQQWithAppId:@"1106621918" appkey:@"Lz4iHyE2fe89eaI3" enableUniversalLink:YES universalLink:@"https://ov1id.share2dlink.com/qq_conn/1106621918"];

                                 //更新到4.3.3或者以上版本，微信初始化需要使用以下初始化
                               [platformsRegister setupWeChatWithAppId:@"wxf981d3ef24ad122b" appSecret:@"c02296be041ee5a48876f109bc6624c1" universalLink:@"https://ov1id.share2dlink.com/"];

        
                               //新浪
                              [platformsRegister setupSinaWeiboWithAppkey:@"1921636818" appSecret:@"dca4506635044b1258568431d67566b9" redirectUrl:@"https://sns.whalecloud.com/sina2/callback"];

              }];
    /*
     设置微信的appKey和appSecret
     [微信平台从U-Share 4/5升级说明]http://dev.umeng.com/social/ios/%E8%BF%9B%E9%98%B6%E6%96%87%E6%A1%A3#1_1
     */
//    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:@"wxf981d3ef24ad122b" appSecret:@"c02296be041ee5a48876f109bc6624c1" redirectURL:nil];
    /*
     * 移除相应平台的分享，如微信收藏
     */
    //[[UMSocialManager defaultManager] removePlatformProviderWithPlatformTypes:@[@(UMSocialPlatformType_WechatFavorite)]];
    
    /* 设置分享到QQ互联的appID
     * U-Share SDK为了兼容大部分平台命名，统一用appKey和appSecret进行参数设置，而QQ平台仅需将appID作为U-Share的appKey参数传进即可。
     100424468.no permission of union id
     [QQ/QZone平台集成说明]http://dev.umeng.com/social/ios/%E8%BF%9B%E9%98%B6%E6%96%87%E6%A1%A3#1_3
     */
//    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"1106907992"/*设置QQ平台的appID*/  appSecret:nil redirectURL:@"http://mobile.umeng.com/social"];
//    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"1101253351"/*设置QQ平台的appID*/  appSecret:nil redirectURL:@"http://mobile.umeng.com/social"];
    /*
     设置新浪的appKey和appSecret
     [新浪微博集成说明]http://dev.umeng.com/social/ios/%E8%BF%9B%E9%98%B6%E6%96%87%E6%A1%A3#1_2
     */
//    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:@"1921636818"  appSecret:@"dca4506635044b1258568431d67566b9" redirectURL:@"https://sns.whalecloud.com/sina2/callback"];
    
    
}
+ (void)shareWebPageToPlatformType:(SSDKPlatformType)platformType currentViewController:(id)viewController  shareCont:(ShareModel*)share{
    if ([share.thumbUrl length]>0) {
        NSURL *url = [NSURL URLWithString:share.thumbUrl];
        //NSData *data = [NSData dataWithContentsOfURL:url];
        //share.thumbImg=[UIImage imageWithData:data];
        
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager cachedImageExistsForURL:url completion:^(BOOL isInCache) {
            NSLog(@"是否有缓存%ld",(unsigned long)isInCache);
            if (isInCache) {
                share.thumbImg= [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:share.thumbUrl];
                [self shareWebPageToPlatformType2:platformType currentViewController:viewController shareCont:share];
            }
            else{
                [manager loadImageWithURL:url options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                    NSLog(@"显示当前进度");
                } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                    share.thumbImg=image;
                    [self shareWebPageToPlatformType2:platformType currentViewController:viewController shareCont:share];
                }];
            }
        }];
    }
    else{
        share.thumbImg=[UIImage imageNamed:@"zhuji"];
        [self shareWebPageToPlatformType2:platformType currentViewController:viewController shareCont:share];
    }
}

+ (void)shareWebPageToPlatformType2:(SSDKPlatformType)platformType currentViewController:(id)viewController  shareCont:(ShareModel*)share
{
    if (share==nil) {
        NSLog(@"分享内容不能为空！");
        return;
    }
    //创建分享消息对象
//    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
//    //创建网页内容对象
//    //UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:share.title descr:share.descr thumImage:share.thumbUrl];
//    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:share.title descr:share.descr thumImage:share.thumbImg==nil?share.thumbUrl:share.thumbImg];
//
//    //设置网页地址
//
//    shareObject.webpageUrl = share.webpageUrl;
//    //分享消息对象设置分享内容对象
//    messageObject.shareObject = shareObject;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];

    [params SSDKSetupShareParamsByText:share.descr
                                                          images:share.thumbImg==nil?share.thumbUrl:share.thumbImg
                                                                  url:[NSURL URLWithString:share.webpageUrl]
                                                                title:share.title
                                                               type:SSDKContentTypeAuto];
    
    [ShareSDK share:platformType parameters:params onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        }else {
            switch (state) {
                        case SSDKResponseStateSuccess:
                                 NSLog(@"成功");//成功
                                 break;
                        case SSDKResponseStateFail:
                           {
                                  NSLog(@"--%@",error.description);
                                  //失败
                                  break;
                            }
                        case SSDKResponseStateCancel:
                                  //取消
                                  break;

                        default:
                            break;
                    }
        }
    }];
    //调用分享接口
//    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:viewController completion:^(id data, NSError *error) {
//        if (error) {
//            UMSocialLogInfo(@"************Share fail with error %@*********",error);
//        }else{
//            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
//                UMSocialShareResponse *resp = data;
//                //分享结果消息
//                UMSocialLogInfo(@"response message is %@",resp.message);
//                //第三方原始返回的数据
//                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
//
//            }else{
//                UMSocialLogInfo(@"response data is %@",data);
//            }
//        }
//        NSLog(@"%@",error);
//    }];
}

+(void)domainForLogin{
    AppDelegate* _app = [AppDelegate getApp];
    [_app.net request:URL_domain_inout param:nil withMethod:@"POST"
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSDictionary *dict = (NSDictionary *)responseObject;
                  if([dict[@"code"] integerValue]==0){
                      _app.domainLogin=[dict[@"data"] mutableCopy];
                      //NSLog(@"app.domainLogin:%@",_app.domainLogin);
                  }
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              }];
    

    //同步
    
    /*NSString *url = URL_domain_inout;
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:@"POST" URLString:url parameters:nil error:nil];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    AFHTTPResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
    [requestOperation setResponseSerializer:responseSerializer];
    [requestOperation start];
    [requestOperation waitUntilFinished];
    NSDictionary *dict = (NSDictionary *)requestOperation.responseObject;
    if([dict[@"code"] integerValue]==0){
        AppDelegate* _app = [AppDelegate getApp];
        [_app.domainLogin removeAllObjects];
        _app.domainLogin=[dict[@"data"] mutableCopy];
    }*/
}

+(void)domainForLogout{
    AppDelegate* _app = [AppDelegate getApp];
    NSDictionary *param=@{ @"type":@"1" };
    [_app.net request:URL_domain_inout param:param withMethod:@"POST"
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSDictionary *dict = (NSDictionary *)responseObject;
                  if([dict[@"code"] integerValue]==0){
                      _app.domainLogout=[dict[@"data"] mutableCopy];
                  }
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              }];
}

//加载关注
+(void)loadFollow{
    AppDelegate* _app = [AppDelegate getApp];
    if(_app.user.uid>0){
        NSString *url = URL_follow_user;
        AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
        NSMutableURLRequest *request = [requestSerializer requestWithMethod:@"POST" URLString:url parameters:nil error:nil];
        //---------------------
        NSString *userAgent = [NSString stringWithFormat:@"iOS/%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
        //如果token存在
        NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:kUserToken];
        if (token) {
            [request setValue:token forHTTPHeaderField:kUserToken];
        }
        [request setTimeoutInterval:30];
        //---------------------
        /*AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        AFHTTPResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializer];
        [requestOperation setResponseSerializer:responseSerializer];
        [requestOperation start];
        [requestOperation waitUntilFinished];
        NSDictionary *dict = (NSDictionary *)requestOperation.responseObject;
        NSLog(@"chch:%@",requestOperation.responseObject);
        if([dict[@"code"] integerValue]==0){
            NSDictionary *digest=dict[@"data"];
            for(id item in digest){
                CjwItem *cjwItem=[[CjwItem alloc]init];
                cjwItem.title=item[@"fusername"];
                cjwItem.dateline=item[@"dateline"];
                cjwItem.authorid=item[@"followuid"];
                [_app.followUser addObject:cjwItem];
            }
        }*/
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        NSURLSessionUploadTask *uploadTask;
        uploadTask = [manager
                      uploadTaskWithStreamedRequest:request
                      progress:nil
                      completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                          if (error) {
      
                          } else {
                              //NSLog(@"%@ %@", response, responseObject);
                              NSDictionary *dict = (NSDictionary *)responseObject;
                              if([dict[@"code"] integerValue]==0){
                                  NSDictionary *digest=dict[@"data"];
                                  for(id item in digest){
                                      CjwItem *cjwItem=[[CjwItem alloc]init];
                                      cjwItem.title=item[@"fusername"];
                                      cjwItem.dateline=item[@"dateline"];
                                      cjwItem.authorid=item[@"followuid"];
                                      [_app.followUser addObject:cjwItem];
                                  }
                              }
                          }
                      }];
        
        [uploadTask resume];
        
    }
}

//-----------------------------------------------------------------

+(void)selectImgCont:(ImagePicket_type)imgPicketType
                 fid:(NSInteger) selectFid
            topTitle:(NSString *) selectForumTitle
        withTextCont:(NSString *) textCont
      viewController:(UIViewController*)viewController
         resultAcion:(void (^)(NSInteger fid,NSString *title,NSString *contnet,NSMutableArray *photos,NSString *videoUrl,NSInteger videoNum,UIImage* coverImg))acionBlock{
    
    AppDelegate* _app = [AppDelegate getApp];
    ImagePicketViewController *imagePicket = [[ImagePicketViewController alloc] init];
    imagePicket.type=imgPicketType;
    imagePicket.allowCrop=YES;
    imagePicket.showSheet=YES;
    imagePicket.showTakePhotoBtn=YES;
    if(imgPicketType==ImagePicket_reply){
        imagePicket.maxImagesCount=3;
        imagePicket.allowPickingVideo=NO;
    }
    else{
        imagePicket.allowPickingVideo=YES;
        imagePicket.maxImagesCount=9;
    }
        
    imagePicket.modalPresentationStyle = UIModalPresentationOverFullScreen;
    imagePicket.textCont=textCont;
    
    //-------------设置标题及版块---------------
    NSString *forumTitle=@"";
    NSInteger forumFid=0;
    
    if (imgPicketType==ImagePicket_bbs) {
        for (BbsForumModel* item in _app.forumMenu) {
            NSLog(@"cccc:%@",item.name);
            if ([selectForumTitle isEqualToString:item.name]){
                if([item.sublist count]>0){
                    ForumSubModel* sub=[item.sublist objectAtIndex:0];
                    forumTitle=sub.name;
                    forumFid=[sub.fid intValue];
                    break;
                }
            }
            
            for (NSInteger i=0; i<item.sublist.count; i++) {
                ForumSubModel* sub=[item.sublist objectAtIndex:i];
                if ([sub.fid intValue]==selectFid) {
                    forumTitle=sub.name;
                    forumFid=[sub.fid intValue];
                    break;
                }
            }
            if ([forumTitle isEqualToString:@""]) {
                for (NSInteger i=0; i<item.sublist.count; i++) {
                    ForumSubModel* sub=[item.sublist objectAtIndex:i];
                    if ([selectForumTitle isEqualToString:sub.name]) {
                        forumTitle=sub.name;
                        forumFid=[sub.fid intValue];
                        break;
                    }
                }
            }
        }
        
        if ([forumTitle isEqualToString:@""]) {
            for (BbsForumModel* item in _app.forumMenu) {
                if ([item.name isEqualToString:@"固定"]) {
                    if([item.sublist count]>0){
                        ForumSubModel* sub=[item.sublist objectAtIndex:0];
                        forumTitle=sub.name;
                        forumFid=[sub.fid intValue];
                        break;
                    }
                }
            }
        }
        
        imagePicket.navMenuItemTitle=forumTitle;
        imagePicket.fid=forumFid;
    }
    
    if (imgPicketType==ImagePicket_shop) {
        if (_app.shopMenu) {
            if (!imagePicket.menuArray) {
                imagePicket.menuArray=[NSMutableArray arrayWithCapacity:20];
            }
            else{
                [imagePicket.menuArray removeAllObjects];
            }
            for (ForumSubModel *item in _app.shopMenu) {
                [imagePicket.menuArray addObject:item.name];
            }
            if ([_app.shopMenu count]>0) {
                for (NSInteger i=0; i<_app.shopMenu.count; i++) {
                    ForumSubModel *item=_app.shopMenu[i];
                    if ([item.fid intValue]==selectFid) {
                        imagePicket.fid=[item.fid intValue];
                        imagePicket.nSelectMenuItem=i;
                    }
                }
                
                if (imagePicket.nSelectMenuItem<=0) {
                    ForumSubModel *item=_app.shopMenu[0];
                    imagePicket.fid=[item.fid intValue];
                }
            }
        }
    }
    if (imgPicketType==ImagePicket_circle) {
        if (_app.circleMenu) {
            if (!imagePicket.menuArray) {
                imagePicket.menuArray=[NSMutableArray arrayWithCapacity:20];
            }
            else{
                [imagePicket.menuArray removeAllObjects];
            }
            for (ForumSubModel *item in _app.circleMenu) {
                [imagePicket.menuArray addObject:item.name];
            }
            if ([_app.circleMenu count]>0) {
                for (NSInteger i=0; i<_app.circleMenu.count; i++) {
                    ForumSubModel *item=_app.circleMenu[i];
                    if ([item.fid intValue]==selectFid) {
                        imagePicket.fid=[item.fid intValue];
                        imagePicket.nSelectMenuItem=i;
                    }
                }
                
                if (imagePicket.nSelectMenuItem<=0) {
                    ForumSubModel *item=_app.circleMenu[0];
                    imagePicket.fid=[item.fid intValue];
                }
            }
            //imagePicket.menuArray=[[NSMutableArray alloc] initWithArray:@[@"推荐",@"热点",@"杭州",@"社会",@"娱乐",@"科技",@"段子",@"趣图",@"美女",@"健康",@"教育",@"特卖",@"彩票",@"辟谣"]];
        }
    }
    
    //-------------响应点击菜单---------------
    __weak __typeof(&*imagePicket)weakSelf = imagePicket;
    [imagePicket setBlockMenuItemClickAction:^(UIButton *button){
        long index=(long)button.tag;
        
        if (imgPicketType==ImagePicket_bbs) {
            BBSMenuViewController *bbsmenu=[[BBSMenuViewController alloc]init];
            bbsmenu.isHaveAddButton=YES;
            bbsmenu.navTitle=@"全部版块";
            bbsmenu.pushController=weakSelf;
            bbsmenu.isHaveAddButton=NO;
            bbsmenu.arrayBbsForum=_app.forumMenu;
            [weakSelf.navigationController pushViewController:bbsmenu animated:TRUE];
        }
        
        if (imgPicketType==ImagePicket_shop) {
            if ([_app.shopMenu count]>index) {
                ForumSubModel *item=_app.shopMenu[index];
                weakSelf.fid=[item.fid intValue];
                NSLog(@"fid:%@,name:%@",item.fid,item.name);
            }
        }
        
        if (imgPicketType==ImagePicket_circle) {
            if ([_app.circleMenu count]>index) {
                ForumSubModel *item=_app.circleMenu[index];
                weakSelf.fid=[item.fid intValue];
                NSLog(@"fid:%@,name:%@",item.fid,item.name);
            }
        }
    }];
    //------------------------------------
    if (imgPicketType==ImagePicket_circle){
        //_needCloseController=imagePicket;
        [viewController presentViewController:imagePicket animated:NO completion:^{ [imagePicket showSelectMenu];}];
    }
    else{
        [viewController.navigationController pushViewController:imagePicket animated:TRUE];
    }
    
    //---------------点击发布---------------------
    [imagePicket setBlockPublishAction:^(UIButton *button,NSMutableArray *photos,NSString *videoUrl,NSInteger videoNum,UIImage* coverImg){
        NSLog(@"cjw:%@",videoUrl);
        if(videoNum>1){
            [MBProgressHUD toast:@"上传视频最多只能一个" toView:weakSelf.view];
        }
        else
        {
            NSString *title;
            NSString *message;
            if (imgPicketType==ImagePicket_circle || imgPicketType==ImagePicket_reply){
                message = [weakSelf.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if (message.length==0) {
                    [MBProgressHUD toast:@"内容不能为空，请输入内容" toView:weakSelf.view];
                    return ;
                }
            }
            else{
                title  = [imagePicket.titleTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if (title.length==0) {
                    [MBProgressHUD toast:@"标题不能为空，请输入标题" toView:weakSelf.view];
                    return ;
                }
                message = [imagePicket.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
            
            acionBlock(weakSelf.fid,title,message,photos,videoUrl,videoNum,coverImg);
        }
    }];
}

//发送帖子
+(void)sendPost:(NSDictionary*)param
        isUplodVideo:(BOOL)isUplodVideo
        uploadVideoResult: (TXPublishResult*)videoResult
        viewController:(UIViewController*)viewController
        closeType:(BOOL)isDismiss{
    if (!param) {
        return;
    }
    
    [param setValue:@"mobiletype" forKey:@"ios"];
    AppDelegate* _app = [AppDelegate getApp];
    [_app.net request:URL_newpost param:param withMethod:@"POST"
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  [MBProgressHUD hideHUD];
                  NSLog(@"cjw:%@",responseObject);
                  NSDictionary *dict = (NSDictionary *)responseObject;
                  if([dict[@"code"] integerValue]==0){
                      NSArray *arry=dict[@"data"][@"reply"];
                      if (isUplodVideo) {
                          NSInteger tid=[arry[0][@"tid"] intValue];
                          if(tid<=0){
                              [MBProgressHUD showError:@"帖子发送错误"];
                          }
                          else if(!videoResult){
                              [MBProgressHUD showError:@"视频发送错误"];
                          }
                          else{
                              [CjwFun saveVideoInfo:tid videoId:videoResult.videoId videoURL:videoResult.videoURL coverURL:videoResult.coverURL viewController:viewController closeType:isDismiss];
                          }
                      }
                      else{
                          //[MBProgressHUD toast:dict[@"msg"] toView:viewController.view];
                      }
                  }
                  else{
                      [MBProgressHUD showError:dict[@"msg"]];
                  }
                  
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              }
     ];
    [MBProgressHUD hideHUD];
    if (isDismiss) {
        [viewController dismissViewControllerAnimated:YES completion:^{
           [MBProgressHUD showSuccess:@"你的信息已发送，请稍后下拉刷新查看！"];
        }];
    }
    else{
        [viewController.navigationController popViewControllerAnimated:YES];
        [MBProgressHUD showSuccess:@"你的信息已发送，请稍后下拉刷新查看！"];
    }
}

//上传图片
+(void)uploadImage:(UIImage*)image resultAcion:(void (^)(id responseObject))acionBlock{
    AppDelegate* _app = [AppDelegate getApp];
    [_app.net upload:@"http://bbs.zhuji.net/zjapp/json/upload_image" param:nil
        constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            NSData *data = UIImageJPEGRepresentation(image, 0.8);       //将UIImage转为NSData，1.0表示不压缩图片质量。
            [formData appendPartWithFileData:data name:@"Filedata" fileName:@"test.png" mimeType:@"image/png"];
        }
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"请求成功（图片）%@",responseObject);
            acionBlock(responseObject);
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"请求失败（图片）——%@",error);
        }];
}

//上传视频到腾讯云
+(void)uploadVideo:(NSString*)videoUrl
        coverImage:(UIImage*)coverimg
          delegate:(id<TXVideoPublishListener>)delegate
{
    AppDelegate* _app = [AppDelegate getApp];
    [_app.net request:URL_vod_signature
                param:nil
           withMethod:@"POST"
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"cjw:%@",responseObject);
                  NSDictionary *dict = (NSDictionary *)responseObject;
                  if([dict[@"code"] integerValue]==0){
                      TXUGCPublish  *videoPublish = [[TXUGCPublish alloc] initWithUserID:@"carol_ios"];
                      videoPublish.delegate = delegate;
                      TXPublishParam *videoPublishParams = [[TXPublishParam alloc] init];
                      videoPublishParams.signature  = dict[@"data"];
                      videoPublishParams.videoPath  = videoUrl;
                      videoPublishParams.coverImage = coverimg;
                      [videoPublish publishVideo:videoPublishParams];
                  }
                  else{
                      [MBProgressHUD hideHUD];
                      [MBProgressHUD showError:dict[@"msg"]];
                  }
                  
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  [MBProgressHUD hideHUD];
              }
     ];
}

//上传视频最后一步,保存信息
+(void)saveVideoInfo:(NSInteger)tid
             videoId:(NSString*)videotid
            videoURL:(NSString*)videorurl
            coverURL:(NSString*)coverurl
            viewController:(UIViewController*)viewControl
           closeType:(BOOL)isDismiss
{
    __weak typeof(&*viewControl)weakSelf = viewControl;
    
    NSLog(@"viewControl:%@,%ld",viewControl,isDismiss);
    AppDelegate* _app = [AppDelegate getApp];
    NSDictionary *param=@{@"tid":NSString(tid),@"video_id":videotid,@"video_url":videorurl,@"video_cover":coverurl};
    [_app.net request:URL_video_circle
                param:param
           withMethod:@"POST"
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"cjw:%@",responseObject);
                  [MBProgressHUD hideHUD];
                  NSDictionary *dict = (NSDictionary *)responseObject;
                  if([dict[@"code"] integerValue]==0){
                      [MBProgressHUD toast:dict[@"msg"]  toView:viewControl.view];
                  }
                  else{
                      [MBProgressHUD showError:dict[@"msg"]];
                  }
                  if (isDismiss) {
                      [weakSelf dismissViewControllerAnimated:YES completion:nil];
                  }
                  else{
                      [weakSelf.navigationController popViewControllerAnimated:YES];
                  }
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  [MBProgressHUD hideHUD];
              }
     ];
}

//发送回复
+(void)sendReply:(NSString*)message
         withTid:(NSString*)tid
     withRequote:(NSString*)pid
      withImages:(NSString*)images
     resultAcion:(void (^)(id responseObject))acionBlock
{
    NSMutableDictionary *param=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"reply",@"action",tid,@"tid",@"ios",@"mobiletype",message,@"message",nil];
    if (pid.length>0) {
        [param setValue:pid forKey:@"repquote"];
    }
    
    if (images.length>0) {
        [param setValue:images forKey:@"images"];
    }
    
    AppDelegate* _app = [AppDelegate getApp];
    [_app.net request:URL_newpost param:param withMethod:@"POST"
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  acionBlock(responseObject);
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              }];
}

//------------------字典转Json字符串--------------------------
+ (NSString *)dictToJson:(NSDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    //去掉字符串中的空格
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    return mutStr;
}

//------------------JSON字符串转化为字典--------------------------
+ (NSDictionary *)jsonToDict:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err){
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

//判断字符串为空http://www.cocoachina.com/cms/wap.php?action=article&id=21540
+  (BOOL)isEmpty:(NSString *)aStr {
    if (!aStr) {
        return YES;
    }
    if ([aStr isKindOfClass:[NSNull class]]) {
        return YES;
    }
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedStr = [aStr stringByTrimmingCharactersInSet:set];
    if (!trimmedStr.length) {
        return YES;
    }
    return NO;
}

@end
