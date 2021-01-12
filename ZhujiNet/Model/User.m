//
//  User.m
//  ZjzxApp
//
//  Created by chenjinwei on 2017/3/31.
//  Copyright © 2017年 zhuji.net. All rights reserved.
//

#import "User.h"
#import "LoginViewController.h"
#import "MineViewController.h"
#import "WKWebViewController.h"
#import "AFHTTPSessionManager+Synchronous.h"
#import "KeyChainManager.h"
#import "UpdatePhoneController.h"

#define UID         @"uid"
#define RCID        @"rcid"
#define ZXID        @"zxid"
#define RCTYPE      @"rctype"
#define ZXTYPE      @"zxtype"
#define USERNAME    @"username"
#define PASSWORD    @"password"
#define GENDER      @"gender"
#define MOBILE      @"mobile"
#define BIRTH       @"birth"
#define TOKEN       @"token"
#define AVATAR      @"avatar"
#define GROUP       @"group"
#define CREDITS     @"credits"
#define AREA        @"area"
#define LEVEL       @"level"
#define GOLD        @"gold"
#define TNUM        @"tnum"
#define SIGHTML     @"sightml"
#define INVITECODE  @"invitecode"

@implementation User
static User* _instance = nil;

+(id) shareInstance{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *targetPath = [docPath stringByAppendingPathComponent:@"user.archiver"];
        _instance = [NSKeyedUnarchiver unarchiveObjectWithFile:targetPath];
        if(_instance==nil){
            _instance=[[super allocWithZone:NULL] init];
        }
    }) ;
    return _instance ;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInteger:_uid forKey:UID];
    [aCoder encodeInteger:_rcid forKey:RCID];
    [aCoder encodeInteger:_zxid forKey:ZXID];
    [aCoder encodeObject:_rctype forKey:RCTYPE];
    [aCoder encodeObject:_zxtype forKey:ZXTYPE];
    [aCoder encodeObject:_username forKey:USERNAME];
    [aCoder encodeObject:_password forKey:PASSWORD];
    [aCoder encodeObject:_avatar forKey:AVATAR];
    [aCoder encodeObject:_token forKey:TOKEN];
    [aCoder encodeObject:_gender forKey:GENDER];
    [aCoder encodeObject:_mobile forKey:MOBILE];
    [aCoder encodeObject:_birth forKey:BIRTH];
    [aCoder encodeObject:_area forKey:AREA];
    [aCoder encodeObject:_group forKey:GROUP];
    [aCoder encodeObject:_credits forKey:CREDITS];
    [aCoder encodeObject:_level forKey:LEVEL];
    [aCoder encodeObject:_gold forKey:GOLD];
    [aCoder encodeObject:_tnum forKey:TNUM];
    [aCoder encodeObject:_sightml forKey:SIGHTML];
    [aCoder encodeObject:_invitecode forKey:INVITECODE];
}

//对对象属性进行解码方法
- (id)initWithCoder:(NSCoder *)aDecoder{
    self=[super init];
    if (self!=nil) {
        _uid=[aDecoder decodeIntForKey:UID];
        _rcid=[aDecoder decodeIntForKey:RCID];
        _zxid=[aDecoder decodeIntForKey:ZXID];
        _rctype=[[aDecoder decodeObjectForKey:RCTYPE]copy];
        _zxtype=[[aDecoder decodeObjectForKey:ZXTYPE]copy];
        _username=[[aDecoder decodeObjectForKey:USERNAME]copy];
        _password=[[aDecoder decodeObjectForKey:PASSWORD]copy];
        _avatar=[[aDecoder decodeObjectForKey:AVATAR]copy];
        _token=[[aDecoder decodeObjectForKey:TOKEN]copy];
        _gender=[[aDecoder decodeObjectForKey:GENDER]copy];
        _mobile=[[aDecoder decodeObjectForKey:MOBILE]copy];
        _birth=[[aDecoder decodeObjectForKey:BIRTH]copy];
        _area=[[aDecoder decodeObjectForKey:AREA]copy];
        _group=[[aDecoder decodeObjectForKey:GROUP]copy];
        _credits=[[aDecoder decodeObjectForKey:CREDITS]copy];
        _level=[[aDecoder decodeObjectForKey:LEVEL]copy];
        _gold=[[aDecoder decodeObjectForKey:GOLD]copy];
        _tnum=[[aDecoder decodeObjectForKey:TNUM]copy];
        _sightml=[[aDecoder decodeObjectForKey:SIGHTML]copy];
        _invitecode==[[aDecoder decodeObjectForKey:INVITECODE]copy];
        
    }
    return self;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"%@",@{@"uid":NSString(_uid),
                                              @"rcid":NSString(_rcid),
                                              @"zxid":NSString(_zxid),
                                              @"rctype":[NSString stringWithFormat:@"%@",_rctype],
                                              @"zxtype":[NSString stringWithFormat:@"%@",_zxtype],
                                              @"username":[NSString stringWithFormat:@"%@",_username],
                                              @"token":[NSString stringWithFormat:@"%@",_token],
                                              @"password":[NSString stringWithFormat:@"%@",_password],
                                              @"avatar":[NSString stringWithFormat:@"%@",_avatar],
                                              @"gender":[NSString stringWithFormat:@"%@",_gender],
                                              @"mobile":[NSString stringWithFormat:@"%@",_mobile],
                                              @"birth":[NSString stringWithFormat:@"%@",_birth],
                                              @"area":[NSString stringWithFormat:@"%@",_area],
                                              @"group":[NSString stringWithFormat:@"%@",_group],
                                              @"credits":[NSString stringWithFormat:@"%@",_credits],
                                              @"gold":[NSString stringWithFormat:@"%@",_gold],
                                              @"level":[NSString stringWithFormat:@"%@",_level],
                                              @"tnum":[NSString stringWithFormat:@"%@",_tnum],
                                              @"sightml":[NSString stringWithFormat:@"%@",_sightml],
                                              @"invitecode":[NSString stringWithFormat:@"%@",_invitecode],
                                              }];
}

-(NSInteger)checkUserLogin:(UIViewController*) viewController{
    if (self.uid==0) {
        [viewController.navigationController pushViewController:[[LoginViewController alloc]init] animated:YES];
    }
    
    if (self.uid>0 && ![CjwFun checkTelNumber:self.mobile]) {
        UpdatePhoneController* updatePhone=[UpdatePhoneController new];
        updatePhone.isBindPage=YES;
        [viewController presentViewController:updatePhone animated:YES completion:nil];
        self.uid=0;
    }
    
    return self.uid;
}

-(void)enterMineinfo:(UIViewController*) viewController{
//    if (self.uid==0) {
//        LoginViewController* login=[[LoginViewController alloc]init];
//        login.bEnterMineinfo=YES;
//        [viewController.navigationController pushViewController:login animated:YES];
//    }
//    else{
        MineViewController *mine=[[MineViewController alloc]init];
        [viewController.navigationController pushViewController:mine animated:TRUE];
//    }
}

-(BOOL)login:(NSDictionary*)dict withPassword:(NSString*)pwd{
    //NSLog(@"%@",dict);
    self.uid=[dict[@"uid"] integerValue];
    self.zxid=[dict[@"zxid"] integerValue];
    self.rcid=[dict[@"rcid"] integerValue];
    self.zxtype=dict[@"zxtype"];
    self.rctype=dict[@"rctype"];
    self.username=dict[@"username"];
    self.password=pwd;
    self.avatar=dict[@"avatar"];
    self.token=dict[@"token"];
    self.invitecode=dict[@"invitecode"];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.token forKey:kUserToken];
    //登录成功后取得更多信息
    AppDelegate *app = [AppDelegate getApp];
    NSDictionary *param=@{@"uuid":[KeyChainManager getUUID]};
    [app.net request:self url:URL_userinfo param:param];
    
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号量
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.completionQueue = dispatch_get_global_queue(0, 0);  //将回调放入子线程
//    [manager GET:URL_userinfo parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        [self save:responseObject];
//        dispatch_semaphore_signal(semaphore);//不管请求状态是什么，都得发送信号，否则会一直卡着进程
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        dispatch_semaphore_signal(semaphore);//不管请求状态是什么，都得发送信号，否则会一直卡着进程
//    }];
//
//    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);  //等待
    
    return YES;
}

//自动登录—异步
+(void)autoLogin{
    AppDelegate *app = [AppDelegate getApp];
    if (app.user.uid!=0) {
        NSMutableDictionary *paramDic2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:app.user.username,@"username",app.user.password,@"password", nil];
        [app.net request:URL_login param:paramDic2 withMethod:@"POST"
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSDictionary *dict = (NSDictionary *)responseObject;
                      if([dict[@"code"] integerValue]==0){
                          [app.user login:dict[@"data"] withPassword:app.user.password];
                          app.userLoginStatus=login_status_relogin;
                      }
                  }
                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                      
                  }];
    }
}

- (void)requestCallback:(id)response status:(id)status{
    if([[status objectForKey:@"stat"] isEqual:@0]){
        if ([[status objectForKey:@"tag"] isEqual:@1]) {
            
        }
        else{
            [self save:response];
        }
    }
    else{
        NSLog(@"%@",response);
        [MBProgressHUD showError:@"登录失败"];
    }
}

-(BOOL)save:(id)response{
    BOOL bret=NO;
    
    NSDictionary *dict = (NSDictionary *)response;
    if ([dict[@"code"] isEqual:@0]) {
        self.gold=dict[@"data"][@"gold"];
        self.level=dict[@"data"][@"level"];
        self.group=dict[@"data"][@"group"];
        self.tnum=dict[@"data"][@"tnum"];
        self.credits=dict[@"data"][@"credits"];
        self.group=dict[@"data"][@"group"];
        self.mobile=dict[@"data"][@"mobile"];
        self.birth=dict[@"data"][@"birth"];
        self.gender=dict[@"data"][@"gender"];
        self.area=dict[@"data"][@"area"];
        self.sightml=dict[@"data"][@"sightml"];
        self.invitecode=dict[@"data"][@"invitecode"];
        
        //NSLog(@"userinfo:%@",self);
        
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        //文件类型可以随便取，不一定要正确的格式
        NSString *targetPath = [docPath stringByAppendingPathComponent:@"user.archiver"];
        //将自定义对象保存在指定路径下
        BOOL success=[NSKeyedArchiver archiveRootObject:self toFile:targetPath];
        if (success || ![CjwFun checkTelNumber:self.mobile]) {
            NSLog(@"user对象归档成功.");
            bret=YES;
        }
    }
    return bret;
}


-(void)logout{
    _uid=0;
    _rcid=0;
    _zxid=0;
    _zxtype=nil;
    _rctype=nil;
    _username=nil;
    _password=nil;
    _gender=nil;
    _mobile=nil;
    _level=nil;
    _avatar=nil;
    _token=nil;
    _group=nil;
    _credits=nil;
    _tnum=nil;
    _birth=nil;
    _sightml=nil;
    _area=nil;
    _gold=nil;
    _invitecode=nil;
    
    NSFileManager* fileManager=[NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    //文件名
    NSString *uniquePath=[[paths objectAtIndex:0] stringByAppendingPathComponent:@"user.archiver"];
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:uniquePath];
    if (!blHave) {
        NSLog(@"user.archiver is not find!");
        return ;
    }else {
        NSLog(@" user.archiver is find!");
        BOOL blDele= [fileManager removeItemAtPath:uniquePath error:nil];
        if (blDele) {
            NSLog(@"dele user.archiver success");
        }else {
            NSLog(@"dele  user.archiver fail");
        }
        
    }
}

@end
