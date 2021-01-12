//
//  User.h
//  ZjzxApp
//
//  Created by chenjinwei on 2017/3/31.
//  Copyright © 2017年 zhuji.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface User : NSObject<NSCoding>

@property(nonatomic,assign)NSInteger    uid;
@property(nonatomic,assign)NSInteger    rcid;
@property(nonatomic,assign)NSInteger    zxid;
@property(nonatomic,copy)NSString       *zxtype;
@property(nonatomic,copy)NSString       *rctype;
@property(nonatomic,copy)NSString       *username;
@property(nonatomic,copy)NSString       *password;
@property(nonatomic,copy)NSString       *avatar;
@property(nonatomic,copy)NSString       *token;
@property(nonatomic,copy)NSString       *gold;
@property(nonatomic,copy)NSString       *level;
@property(nonatomic,copy)NSString       *group;
@property(nonatomic,copy)NSString       *area;
@property(nonatomic,copy)NSString       *tnum;
@property(nonatomic,copy)NSString       *credits;
@property(nonatomic,copy)NSString       *mobile;
@property(nonatomic,copy)NSString       *gender;
@property(nonatomic,copy)NSString       *birth;
@property(nonatomic,copy)NSString       *sightml;
@property(nonatomic,copy)NSString       *invitecode;

+(id) shareInstance;
+(void)autoLogin;

-(NSInteger)checkUserLogin:(UIViewController*) viewController;
-(void)enterMineinfo:(UIViewController*) viewController;
-(BOOL)save:(id)response;
-(BOOL)login:(NSDictionary*)dict withPassword:(NSString*)pwd;
-(void)logout;

@end
