//
//  WelcomeViewController.m
//  ZjzxApp
//
//  Created by chenjinwei on 17/3/19.
//  Copyright © 2017年 zhuji.net. All rights reserved.
//

#import "WelcomeViewController.h"
#import "RootViewController.h"
#import "MenuModel.h"
#import "BbsForumModel.h"

@interface WelcomeViewController (){
    AppDelegate     *_app;
    NSTimer*        _timer;
    NSInteger       _times;
    NSInteger       _nEnterApp;
    BOOL            _isDismiss;
    NSString        *_launchWebUrl;
}
@property (nonatomic, strong) UIImageView   *launchImageView;
@property (nonatomic, strong) UIButton      *btnSkip;

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    _nEnterApp=0;
    _times=5;
    _isDismiss=NO;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"logo"];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    
    _launchImageView= [[UIImageView alloc] init];
    _launchImageView.contentMode = UIViewContentModeScaleAspectFill;
    _launchImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLaunchTap:)];
    [_launchImageView addGestureRecognizer:singleTap];
    [self.view addSubview:_launchImageView];
    
    _btnSkip=[[UIButton alloc]init];
    _btnSkip.backgroundColor=[UIColor lightGrayColor];
    _btnSkip.layer.borderWidth=1;
    _btnSkip.layer.borderColor=[UIColor grayColor].CGColor;
    _btnSkip.layer.cornerRadius=10;
    _btnSkip.titleLabel.font = [UIFont systemFontOfSize: 12.0];
    _btnSkip.alpha=0.8;
    _btnSkip.hidden=YES;
    [_btnSkip setTitle:[NSString stringWithFormat:@"跳过 %ld",_times] forState: UIControlStateNormal];
    [_btnSkip setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_btnSkip addTarget:self action:@selector(actionBtnSkip:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnSkip];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom);
        make.width.mas_equalTo(self.view.width);
    }];
    
    [_launchImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(@0);
        make.size.mas_equalTo(self.view);
    }];
    
    [_btnSkip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@60);
        make.right.equalTo(@-30);
        make.size.mas_equalTo(CGSizeMake(60,25));
    }];
}


-(void)viewDidAppear:(BOOL)animated{
    [User autoLogin];
    
    _app = [AppDelegate getApp];
    [self loadLaunch];
    [_app.net request:self url:URL_channel];
    //sleep(1.5);
    _timer= [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerHander) userInfo:nil repeats:YES];
    CATransition *transition = [CATransition animation];
    transition.duration = 1;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [_launchImageView.layer addAnimation:transition forKey:@"anim"];
    
    [CjwFun domainForLogin];
    [CjwFun domainForLogout];
    [CjwFun loadFollow];
    [self loadForumMenu];
    [self checkUser];
}

//加载论坛菜单
-(void)loadForumMenu{
    [_app.net request:URL_bbs_forum param:nil withMethod:@"POST"
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSDictionary *dict = (NSDictionary *)responseObject;
                  if([dict[@"code"] integerValue]==0){
                      _app.forumMenu=[BbsForumModel mj_objectArrayWithKeyValuesArray:dict[@"data"]];
                  }
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              }];
}

//检测用户合法性
-(void)checkUser{
    if(_app.user.uid>0){
        //NSLog(@"checkUser:%@,%@",_app.user.username,_app.user.password);
        NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:_app.user.username,@"username",_app.user.password,@"password", nil];
        [_app.net request:URL_login param:paramDic withMethod:@"POST"
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                      NSDictionary *dict = (NSDictionary *)responseObject;
                      if([dict[@"code"] integerValue]!=0){
                          [_app.user logout];
                          _app.userLoginStatus=login_status_reout;
                      }
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  }];
    }
    else{
        //未登陆，去除数据
        [_app.locationLike removeAllObjects];
        [CjwFun putLocaionDict:kLocationLike value:_app.locationLike];
    }
}

-(void)loadLaunch{
    __weak typeof(&*self)weakSelf = self;
    [_app.net request:URL_launch param:nil withMethod:@"POST"
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSDictionary *dict = (NSDictionary *)responseObject;
                  if([dict[@"code"] integerValue]==0){
                      if(![dict[@"data"] isKindOfClass:[NSDictionary class]]){
                          _times=0;
                      }
                      else{
                          _launchWebUrl=[dict[@"data"] valueForKey:@"url"];
                          [weakSelf.launchImageView sd_setImageWithURL:[NSURL URLWithString:[dict[@"data"] valueForKey:@"image"]]];
                          weakSelf.btnSkip.hidden=NO;
                      }
                  }
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  _times=3;
              }];
}

- (void)requestCallback:(id)response status:(id)status{
    
    _nEnterApp=1;
    
    if([[status objectForKey:@"stat"] isEqual:@0]){
        NSDictionary *dict = (NSDictionary *)response;
        [_app.menu removeAllObjects];
        
        //NSLog(@"chen-menu0:%@",response);
        
        NSArray *topMenuStore=[MenuModel mj_objectArrayWithKeyValuesArray:[CjwFun getLocaionDict:kHomeTopMenu]];
        NSMutableArray *newMenuStore=[topMenuStore mutableCopy];
        if(topMenuStore.count>0){
            bool bUpdate=false;
            NSMutableArray *webTopMenu=[MenuModel mj_objectArrayWithKeyValuesArray:dict[@"data"]];
            //服务器菜单比对
            for (MenuModel* webItem in webTopMenu) {
                bool bHave=false;
                for (MenuModel* itemStroe in topMenuStore) {
                    if([webItem.title isEqualToString:itemStroe.title]){
                        bHave=true;
                        break;
                    }
                }
                if(bHave==false){
                    [newMenuStore addObject:webItem];
                    bUpdate=true;
                }
            }
            //检查一下删除菜单
            for (MenuModel* itemStroe in topMenuStore)  {
                bool bHave=false;
                for (MenuModel* webItem in webTopMenu) {
                    if([webItem.title isEqualToString:itemStroe.title]){
                        bHave=true;
                        break;
                    }
                }
                if(bHave==false){
                    [newMenuStore removeObject:itemStroe];
                    bUpdate=true;
                }
            }
            
            //检查菜单更新
            for (MenuModel* webItem in webTopMenu) {
                for (MenuModel* itemStroe in newMenuStore) {
                    if([webItem.title isEqualToString:itemStroe.title]){
                        if (![webItem.url isEqualToString:itemStroe.url]) {
                            itemStroe.url=webItem.url;
                            bUpdate=true;
                        }
                    }
                }
            }
            
            _app.menu=newMenuStore;
            if(bUpdate){
                //NSArray *array = [MenuModel mj_keyValuesArrayWithObjectArray:_app.menu];
                //[CjwFun putLocaionDict:kHomeTopMenu value:array];
                
                [_app.menu removeAllObjects];
                [_app.menu addObjectsFromArray:[MenuModel mj_objectArrayWithKeyValuesArray:dict[@"data"]]];
                NSArray *array = [MenuModel mj_keyValuesArrayWithObjectArray:_app.menu];
                [CjwFun putLocaionDict:kHomeTopMenu value:array];
            }
            else{
                //比对其它是否变化进行保存
                for (MenuModel* itemStroe in topMenuStore)  {
                    for (MenuModel* webItem in webTopMenu) {
                        if([webItem.title isEqualToString:itemStroe.title]){
                            if(itemStroe.fid!=webItem.fid || itemStroe.ispost!=webItem.ispost
                               || itemStroe.dmode!=webItem.dmode || ![itemStroe.url isEqualToString:webItem.url] ){
                                bUpdate=true;
                            }
                            if(bUpdate) {
                                itemStroe.fid=webItem.fid;
                                itemStroe.ispost=webItem.ispost;
                                itemStroe.url=webItem.url;
                                itemStroe.dmode=webItem.dmode;
                            }
                        }
                    }
                }
                if(bUpdate){
                    NSArray *array = [MenuModel mj_keyValuesArrayWithObjectArray:topMenuStore];
                    [CjwFun putLocaionDict:kHomeTopMenu value:array];
                }
            }
        }
        else{
            [_app.menu addObjectsFromArray:[MenuModel mj_objectArrayWithKeyValuesArray:dict[@"data"]]];
            //Model array -> JSON array
            NSArray *array = [MenuModel mj_keyValuesArrayWithObjectArray:_app.menu];
            [CjwFun putLocaionDict:kHomeTopMenu value:array];
        }

    }
    else{
        NSArray *topMenuStore=[MenuModel mj_objectArrayWithKeyValuesArray:[CjwFun getLocaionDict:kHomeTopMenu]];
        if(topMenuStore.count==0){
            _nEnterApp=2;
        }
        else{
            _app.menu=[topMenuStore mutableCopy];
        }
    }
    
    //NSLog(@"chen-menu:%@",[MenuModel mj_keyValuesArrayWithObjectArray:_app.menu]);
}

-(void)timerHander{
    _times--;
    [_btnSkip setTitle:[NSString stringWithFormat:@"跳过 %ld",_times] forState: UIControlStateNormal];
    
    if (_timer.isValid && _nEnterApp>0 && _times<=0) {
        [_timer invalidate];        // 从运行循环中移除
        _timer=nil;                 // 将销毁定时器
        
        if(_nEnterApp==2){
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"未连接" message:@"当前网络不可用，请检查你的网络设置" preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alertController animated:YES completion:nil];
            [alertController addAction:[UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
               //[[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                exit(0);
            }]];
        }
        else{
            [self dismissSelf];
        }
    }
}

-(void)actionBtnSkip:(id)sender{
    [self dismissSelf];
}

- (void)handleLaunchTap:(UIGestureRecognizer *)gestureRecognizer {
    if ([_launchWebUrl length]>0) {
        _app.launchWebUrl=_launchWebUrl;
        [self dismissSelf];
    }
}

-(void)dismissSelf{
    if(_isDismiss==NO){
        _isDismiss=YES;
    }
    else{
        return;
    }
    RootViewController *rootViewController = [[RootViewController alloc] init];
    _app.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    _app.window.backgroundColor=[UIColor whiteColor];
    _app.tabController=rootViewController;
    
    [self dismissViewControllerAnimated:YES completion:^(void){
        self.modalTransitionStyle =   UIModalTransitionStyleCrossDissolve;
    }];
    
    typedef void (^Animation)(void);
    rootViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    Animation animation = ^{
        BOOL oldState = [UIView areAnimationsEnabled];
        [UIView setAnimationsEnabled:NO];
        [UIView setAnimationsEnabled:oldState];
    };
    
    [UIView transitionWithView:_app.window
                      duration:0.8f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:animation
                    completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"%s",__FUNCTION__);
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

