//
//  CjwFun.h
//  CjwSchool
//
//  Created by chenjinwei on 16/4/11.
//  Copyright © 2016年 chenjinwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import <UMShare/UMShare.h>
//#import <UMSocialCore/UMSocialCore.h>
#import <ShareSDK/ShareSDK.h>
#include "ShareModel.h"
#import "TXUGCPublish.h"
#import "ImagePicketViewController.h"

@interface CjwFun : NSObject

+ (void) showAlertMessage:(NSString *) message currViewController:(UIViewController*)viewController;
+(NSString *)currentTimeStr;
+ (BOOL)checkTelNumber:(NSString *) telNumber;
+ (BOOL)isNumber:(NSString *)number;

//计算label高度，width 宽度， font 大小， space 行距
+(CGSize)sizeForText:(UILabel*)label width:(CGFloat)width font:(UIFont*)font  lineSapce:(CGFloat)space;
+(CGSize)sizeForText:(NSString*)text font:(UIFont*)font;

+(void) putLocaionDict:(NSString*)key value:(NSObject *)obj;
+(NSObject *) getLocaionDict:(NSString*)key;

+ (void)initShare;
+(void)shareWebPageToPlatformType:(SSDKPlatformType)platformType currentViewController:(id)viewController shareCont:(ShareModel*)share;

+(void)domainForLogin;
+(void)domainForLogout;
+(void)loadFollow;

+(void)selectImgCont:(ImagePicket_type)imgPicketType
                 fid:(NSInteger)selectFid
            topTitle:(NSString *) selectForumTitle
        withTextCont:(NSString *) textCont
      viewController:(UIViewController*)viewController
         resultAcion:(void (^)(NSInteger fid,NSString *title,NSString *contnet,NSMutableArray *photos,NSString *videoUrl,
                               NSInteger videoNum,UIImage* coverImg))acionBlock;

//发送帖子
+(void)sendPost:(NSDictionary*)param isUplodVideo:(BOOL)isUplodVideo uploadVideoResult: (TXPublishResult*)videoResult
    viewController:(UIViewController*)viewController closeType:(BOOL)isDismiss;
//上传图片
+(void)uploadImage:(UIImage*)image resultAcion:(void (^)(id responseObject))acionBlock;
//上传视频到腾讯云
+(void)uploadVideo:(NSString*)videoUrl coverImage:(UIImage*)coverimg delegate:(id<TXVideoPublishListener>)delegate;

//发送回复
+(void)sendReply:(NSString*)message
         withTid:(NSString*)tid
     withRequote:(NSString*)pid
      withImages:(NSString*)images
     resultAcion:(void (^)(id responseObject))acionBlock;

+ (NSDictionary *)jsonToDict:(NSString *)jsonString;
+ (NSString *)dictToJson:(NSDictionary *)dict;
+ (BOOL)isEmpty:(NSString *)aStr;
@end
