//
//  MineViewController.m
//  ZhujiNet
//
//  Created by chenjinwei on 17/6/19.
//  Copyright © 2017年 zhuji.net. All rights reserved.
//

#import "MineViewController.h"
#import "MineBaseViewController.h"
#import "RootViewController.h"
#import "LoginViewController.h"
#import "SDImageCache.h"
#import "SysinfoViewController.h"
#import "MyThreadController.h"
#import "FollowController.h"
#import "UpdatePhoneController.h"
#import "CjwFun.h"
#import "KeyChainManager.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <WebKit/WebKit.h>
#import "WKWebViewController.h"
const NSString *TELPHONE=@"0575-87020951";

@interface MineViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UIAlertViewDelegate,WKNavigationDelegate,WKUIDelegate>{
    AppDelegate                 *_app;
    CjwItem                     *_cjwItem;          //加载的单项数据
    CjwCell                     *_cjwCell;
    UITableView                 *_tableView;
    UIView                      *_footerView;
    NSMutableArray              *_data;
    CGFloat                     _cellHeaderHeight;
    NSInteger                   _btnTagBase;
    NSString                    *_invitecode;
    
    WKWebView                  *_webViewAutoLogin;
    NSMutableArray              *_domainLogout;
}

@end

@implementation MineViewController

- (void)viewWillAppear:(BOOL)animated{
    _app = [AppDelegate getApp];
    [_app.skin setSkin:self];
    self.navigationItem.title = @"我";
    
    if (_app.user.uid>0 && ![CjwFun checkTelNumber:_app.user.mobile]) {
        UpdatePhoneController* updatePhone=[UpdatePhoneController new];
        updatePhone.isBindPage=YES;
        [self presentViewController:updatePhone animated:YES completion:nil];
    }
    
    [self addData:nil];
    [self addTableView];
    [_tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigation];
    
    _app = [AppDelegate getApp];
    
    _btnTagBase=20000;
    _data = [NSMutableArray arrayWithCapacity:8];
    
    //[_app.net request:self url:URL_userinfo];
    NSDictionary *param=@{@"uuid":[KeyChainManager getUUID]};
    [_app.net request:self url:URL_userinfo param:param callTag:0];
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.processPool = [WKWebViewController singleWkProcessPool];
    config.preferences = [[WKPreferences alloc] init];
    config.preferences.minimumFontSize = 10;
    config.preferences.javaScriptEnabled = YES;
    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    //----------------------------------------------
    _webViewAutoLogin = [[WKWebView alloc] initWithFrame:CGRectMake(0,0,0,0) configuration:config];
    _webViewAutoLogin.UIDelegate=self;
    _webViewAutoLogin.navigationDelegate=self;
    NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:URL_userinfo]];
    [_webViewAutoLogin loadRequest:request];
    
    NSLog(@"local:%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"WebKitLocalStorageDatabasePathPreferenceKey"]);
}

-(void)setNavigation{
    UIButton *navBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [navBack setFrame:CGRectMake(0, 0, 28, 28)];
    [navBack setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [navBack addTarget:self action:@selector(onNavBackClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navBack];
}

- (void)onNavBackClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)addData:(NSDictionary *)dict{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *ver=[NSString stringWithFormat:@"当前版本：%@",[infoDictionary objectForKey:@"CFBundleShortVersionString"]];
    
    NSArray *title = @[@"",@"",@"我的贴子",@"我的回贴",@"我的关注",/*@"好友聊天",@"好友申请",*/@"系统消息",@"清除缓存",[NSString stringWithFormat:@"客服电话：%@",TELPHONE],@"邀请码",ver];
    NSArray *icon = @[@"80",@"",@"wdtz",@"wdht",@"wdgz",/*@"hylt",@"hysq",*/@"xtxx",@"qchc",@"kfdh",@"hysq",@"ver"];
    
    [_data removeAllObjects];
    if (dict==nil) {
        for(int i=0;i<[title count];i++){
            CjwItem *cjwItem=[[CjwItem alloc]init];
            cjwItem.title=title[i];
            cjwItem.img=icon[i];
            if(i==0){
                if(_app.user.uid==0){
                    cjwItem.type=cell_type_mine_login;
                }
                else{
                    cjwItem.title=[NSString stringWithFormat:@"%@",_app.user.username];
                    cjwItem.url_pic0=[NSString stringWithFormat:@"%@",_app.user.avatar];
                    cjwItem.type=cell_type_mine;
                    cjwItem.subtitle=[_app.user.sightml isEqualToString:@""]?@"你还没个性签名，快去编辑吧！":[NSString stringWithFormat:@"%@",_app.user.sightml];
                    cjwItem.rank=[NSString stringWithFormat:@"%@",_app.user.group];;
                    cjwItem.level=[NSString stringWithFormat:@"LV%@",_app.user.level];
                }
            }
            else if(i==1){
                if(_app.user.uid>0){
                    cjwItem.type=cell_type_mine_score;
                    cjwItem.title=[NSString stringWithFormat:@"帖子 %@",_app.user.tnum];
                    cjwItem.subtitle=[NSString stringWithFormat:@"金钱 %@",_app.user.gold];
                    cjwItem.rank=[NSString stringWithFormat:@"积分 %@",_app.user.credits];
                    cjwItem.level=[NSString stringWithFormat:@"等级 %@",_app.user.level];
                }
            }
            else{
                cjwItem.type=cell_type_menu;
                if(i==8){
                    cjwItem.title=[NSString stringWithFormat:@"好友邀请码：%@", _app.user.invitecode==NULL?@"":_app.user.invitecode];
                }
            }
            [_data addObject:cjwItem];
        }
    }
    else{
        for(int i=0;i<[title count];i++){
            CjwItem *cjwItem=[[CjwItem alloc]init];
            cjwItem.title=title[i];
            cjwItem.img=icon[i];
            if(i==0){
                cjwItem.title=dict[@"username"];
                cjwItem.url_pic0=dict[@"avatar"];
                cjwItem.type=cell_type_mine;
                cjwItem.subtitle=[dict[@"sightml"] isEqualToString:@""]?@"你还没个性签名，快去编辑吧！":dict[@"sightml"];
                cjwItem.rank=dict[@"group"];
                cjwItem.level=[NSString stringWithFormat:@"LV%@",dict[@"level"]];
            }
            else if(i==1){
                cjwItem.type=cell_type_mine_score;
                cjwItem.title=[NSString stringWithFormat:@"帖子 %@",dict[@"tnum"]];
                cjwItem.subtitle=[NSString stringWithFormat:@"金钱 %@",dict[@"gold"]];
                cjwItem.rank=[NSString stringWithFormat:@"积分 %@",dict[@"credits"]];
                cjwItem.level=[NSString stringWithFormat:@"等级 %@",dict[@"level"]];
            }
            else{
                cjwItem.type=cell_type_menu;
                if(i==8){
                    if(_invitecode.length==0){
                        _invitecode=dict[@"invitecode"]==NULL || [dict[@"invitecode"] intValue]==0 ? @"":dict[@"invitecode"];
                    }
                    cjwItem.title=[NSString stringWithFormat:@"好友邀请码：%@", _invitecode];
                }
            }
            [_data addObject:cjwItem];
        }
    }
}


- (void)requestCallback:(id)response status:(id)status{
    NSLog(@"cjw::%@", response);
    if ([status[@"stat"] isEqual:@0]) {
        
        NSDictionary *dict = (NSDictionary *)response;
        if([dict[@"code"] intValue]==0){
            [self addData:dict[@"data"]];
            [_app.user save:response];
        }
        else{
            _invitecode=dict[@"data"];
            CjwItem *cjwItem=_data[8];
            cjwItem.title=[NSString stringWithFormat:@"好友邀请码：%@", dict[@"data"]];
        }
        
        [_tableView reloadData];
        
    }
    else{
        NSLog(@"网络失败");
    }
    
}

-(void)addTableView{
    _cjwCell=[[CjwCell alloc]init];
    
    CGRect rect=CGRectMake(0, 0, self.view.frame.size.width,  self.view.frame.size.height);
    _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.backgroundColor=_app.skin.colorTableBg;
    _tableView.separatorColor =_app.skin.colorCellSeparator;
    _tableView.separatorInset=UIEdgeInsetsZero;
    _tableView.layoutMargins=UIEdgeInsetsZero;
    _tableView.tableFooterView = self.footerView;
    [self.view addSubview:_tableView];
}

#pragma mark -
#pragma mark - UITableView dateSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CjwItem *item=_data[indexPath.row];
    if (indexPath.row==0) {
        static NSString  *identifier = @"identifierCell1";
        CjwCell *cell = [_tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil){
            cell = [[CjwCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            cell.contentView.backgroundColor=_app.skin.colorCellBg;
        }
        if(_app.user.uid==0){
            
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.item=item;
        return cell;
    }
    else{
        static NSString  *identifier = @"identifierCell2";
        CjwCell *cell = [_tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil){
            cell = [[CjwCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            cell.contentView.backgroundColor=_app.skin.colorCellBg;
            if(indexPath.row==8 && _invitecode.length==0){
                UIButton* btn=[[UIButton alloc]init];
                btn.alpha=_app.skin.floatImgAlpha;
                btn.layer.cornerRadius = 15.0;
                btn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
                btn.layer.borderColor = [UIColor colorWithHexString:@"ffffff"].CGColor;
                [btn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
                btn.layer.borderWidth = 0.8f;
                btn.frame=CGRectMake(170,12,80, 30);
                [btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
                btn.tag = indexPath.row+_btnTagBase;
                [cell.contentView addSubview:btn];
                [btn setTitle:@"去填写" forState:UIControlStateNormal];
                btn.backgroundColor=_app.skin.colorMainLight;
            }
            if(indexPath.row==1 && _app.user.uid==0){
                UIButton* btn=[[UIButton alloc]init];
                btn.alpha=_app.skin.floatImgAlpha;
                btn.layer.cornerRadius = 19.0;
                btn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
                btn.layer.borderColor = [UIColor colorWithHexString:@"ffffff"].CGColor;
                [btn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
                btn.layer.borderWidth = 0.8f;
                btn.frame=CGRectMake((SCREEN_WIDTH-96)/2,0,96, 38);
                [btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
                btn.tag = indexPath.row+_btnTagBase;
                [cell.contentView addSubview:btn];
                [btn setTitle:@"登录/注册" forState:UIControlStateNormal];
                btn.backgroundColor=_app.skin.colorMain;
            }
        }
        
        UIButton* btn = (UIButton*)[cell.contentView viewWithTag:indexPath.row+_btnTagBase];
        if ((_invitecode.length>0 ||[CjwFun isEmpty:_app.user.invitecode]==NO) && indexPath.row==8) {
            btn.hidden=YES;
        }
        
        if (_app.user.uid>0 && indexPath.row==1) {
            btn.hidden=YES;
        }
        
        if(indexPath.row==1  || indexPath.row==6  || indexPath.row==7  || indexPath.row==8 || indexPath.row==9){
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        else{
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.item=item;
        return cell;
    }
}

#pragma mark 设置每行高度（每行高度可以不一样）
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    _cjwCell.item=_data[indexPath.row];
    if(indexPath.row==1 || indexPath.row==4)
    {
        return _cjwCell.height+_app.skin.floatSeparatorSpaceHeight;
    }
    return _cjwCell.height;
}

-(void)tableView:(UITableView* )tableView willDisplayCell:(UITableViewCell* )cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==1 || indexPath.row==4|| indexPath.row==9){
        cell.separatorInset=UIEdgeInsetsMake(0, cell.bounds.size.width/2, 0, cell.bounds.size.width/2);
    }
    else{
        if(indexPath.row==0 && _app.user.uid==0){
            cell.separatorInset=UIEdgeInsetsMake(0, cell.bounds.size.width, 0, 0);
        }
        else{
            cell.separatorInset=UIEdgeInsetsMake(0, 15, 0, 15);
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(_app.user.uid==0 && (indexPath.row==0 || indexPath.row==2 || indexPath.row==3 || indexPath.row==4|| indexPath.row==5)){
        LoginViewController* login=[[LoginViewController alloc]init];
        [self.navigationController pushViewController:login animated:YES];
        return;
    }
    
    switch (indexPath.row) {
        case 0:
        {
            MineBaseViewController *minebase=[[MineBaseViewController alloc]init];
            [self.navigationController pushViewController:minebase animated:TRUE];
        }
            break;
        case 2:
        {
            MyThreadController* mythread=[[MyThreadController alloc]init];
            mythread.isMythread=YES;
            [self.navigationController pushViewController:mythread animated:YES];
        }
            break;
        case 3:
        {
            MyThreadController* mythread=[[MyThreadController alloc]init];
            mythread.isMythread=NO;
            [self.navigationController pushViewController:mythread animated:YES];
            
            /*[_app.skin setSkinNight];
             RootViewController *rootViewController = [[RootViewController alloc] init];
             _app.tabController=rootViewController;
             _app.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
             MineViewController *mine=[[MineViewController alloc]init];
             [_app.tabController.viewControllers[0].navigationController pushViewController:mine animated:NO];*/
            
        }
            break;
        case 4:
        {
            FollowController *follow=[[FollowController alloc]init];
            follow.isHeadNone=YES;
            //[self presentViewController:follow animated:YES completion:nil];
            [self.navigationController pushViewController:follow animated:YES];
        }
            break;
            /*case 5:
             {
             [MBProgressHUD toast:@"敬请期待" toView:self.view];
             }
             break;
             case 6:
             {
             [MBProgressHUD toast:@"敬请期待" toView:self.view];
             }
             break;*/
        case 7-2:
        {
            [self.navigationController pushViewController:[[SysinfoViewController alloc]init] animated:YES];
        }
            break;
        case 8-2:
        {
            [MBProgressHUD showMessage:@"正在清理缓存……"];
            [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
            [[SDImageCache sharedImageCache] clearMemory];  //可不写
            [MBProgressHUD hideHUD];
            [[NSURLCache  sharedURLCache ] removeAllCachedResponses];   //清理web缓存
            [MBProgressHUD toast:@"清理成功" toView:self.view];
        }
            break;
            
        case 9-2:
        {
            NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",TELPHONE];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
            
        }
            break;
        default:
            break;
    }
    
}

//--------------------------------------------------------
- (UIView*)footerView
{
    if (_footerView == nil && _app.user.uid>0) {
        _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 65)];
        //_footerView.backgroundColor = SHColor_separator;
        UIButton    *button = [[UIButton alloc] initWithFrame:CGRectMake(14, 10, SCREEN_WIDTH-28, 40)];
        button.backgroundColor = _app.skin.colorMain;
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 5.f;
        button.layer.borderColor = _app.skin.colorCellSeparator.CGColor;
        button.layer.borderWidth = 1.f;
        [button setTitle:@"退出登录" forState:UIControlStateNormal];
        [button setTitleColor:_app.skin.colorNavbar forState:UIControlStateNormal];
        [button addTarget:self action:@selector(logoutButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:button];
    }
    return _footerView;
}


- (void)logoutButtonClicked:(UIButton*)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定退出吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

#pragma marks -- UIAlertViewDelegate --
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1){
        if (_app.followUser.count>0) {
            [_app.followUser removeAllObjects];
        }
        [_app.user logout];
        
        _domainLogout=[_app.domainLogout mutableCopy];
        _app.userLoginStatus=login_status_out;
        
        [MBProgressHUD showMessage:@"请稍候" toView:self.view];
        
        
        NSDictionary* item=[_domainLogout lastObject];
        NSString* link=[item[@"url"] copy];
        NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:link] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10];
        [_webViewAutoLogin loadRequest:request];
    }
}

- (void)buttonClicked:(UIButton *)sender{
    if(_btnTagBase+1==sender.tag){
        LoginViewController* login=[[LoginViewController alloc]init];
        [self.navigationController pushViewController:login animated:YES];
        return;
    }
    
    NSLog(@"buttonClicked:%ld",(long)sender.tag);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请输入好友邀请码" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入好友邀请码";
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *envirnmentNameTextField = alertController.textFields.firstObject;
        self->_invitecode=envirnmentNameTextField.text;
        NSLog(@"你输入的文本%@",envirnmentNameTextField.text);
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString* appver=[infoDictionary objectForKey:@"CFBundleShortVersionString"];
        NSLog(@"appver:%@",appver);
        
        id param=@{@"invitecode":self->_invitecode,@"uuid":[KeyChainManager getUUID],@"appver":appver};
        [_app.net request:URL_invitecode_add param:param withMethod:@"POST"
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dict = (NSDictionary *)responseObject;
            if([dict[@"code"] integerValue]==0){
                [CjwFun showAlertMessage:dict[@"msg"] currViewController:self];
                CjwItem *cjwItem=_data[8];
                cjwItem.title=[NSString stringWithFormat:@"好友邀请码：%@", self->_invitecode];
                [self->_tableView reloadData];
            }
            else{
                [CjwFun showAlertMessage:dict[@"msg"] currViewController:self];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
        
    }]];
    [self presentViewController:alertController animated:true completion:nil];
}

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
//    JSContext *context = [_webViewAutoLogin valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
//    context[@"OC"] = self;
    //--------------------------------自动退出--------------------------------
    if(_app.user.uid==0 && _domainLogout.count>0){
        NSString *jsString = @"localStorage.clear()";
        [webView evaluateJavaScript:jsString completionHandler:nil];
        NSLog(@"autoexit:%@",[_domainLogout lastObject]);
        
        [_domainLogout removeLastObject];
        if(_domainLogout.count==0){
            [MBProgressHUD hideHUD];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
    if (_app.user.uid==0 && _domainLogout.count>0) {
        NSDictionary* item=[_domainLogout lastObject];
        NSString* link=[item[@"url"] copy];
        NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:link] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10];
        [_webViewAutoLogin loadRequest:request];
    }
}

//-(void)webViewDidFinishLoad:(UIWebView *)webView
//{
//    JSContext *context = [_webViewAutoLogin valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
//    context[@"OC"] = self;
//    
//    //--------------------------------自动退出--------------------------------
//    if(_app.user.uid==0 && _domainLogout.count>0){
//        NSString *jsString = @"localStorage.clear()";
//        [webView stringByEvaluatingJavaScriptFromString:jsString];
//        NSLog(@"autoexit:%@",[_domainLogout lastObject]);
//        
//        [_domainLogout removeLastObject];
//        if(_domainLogout.count==0){
//            [MBProgressHUD hideHUD];
//            [self.navigationController popToRootViewControllerAnimated:YES];
//        }
//    }
//    if (_app.user.uid==0 && _domainLogout.count>0) {
//        NSDictionary* item=[_domainLogout lastObject];
//        NSString* link=[item[@"url"] copy];
//        NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:link] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10];
//        [_webViewAutoLogin loadRequest:request];
//    }
//}

//加载失败的时候调用
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (_app.user.uid==0 && _domainLogout.count>1) {
        [_domainLogout removeLastObject];
        NSDictionary* item=[_domainLogout lastObject];
        NSString* link=[item[@"url"] copy];
        NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:link] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10];
        [_webViewAutoLogin loadRequest:request];
    }
    
    if (_app.user.uid==0 && _domainLogout.count==1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    NSLog(@"页面加载失败");
}
//-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
//{
//    if (_app.user.uid==0 && _domainLogout.count>1) {
//        [_domainLogout removeLastObject];
//        NSDictionary* item=[_domainLogout lastObject];
//        NSString* link=[item[@"url"] copy];
//        NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:link] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10];
//        [_webViewAutoLogin loadRequest:request];
//    }
//
//    if (_app.user.uid==0 && _domainLogout.count==1) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//
//    NSLog(@"didFailLoadWithError");
//}

//-------------------------------------------------------------

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:self];
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


//NSFileManager *fileManager = [NSFileManager defaultManager];
//NSString *path=[[NSUserDefaults standardUserDefaults] objectForKey:@"WebKitLocalStorageDatabasePathPreferenceKey"];
//NSArray *contents = [fileManager contentsOfDirectoryAtPath:path error:NULL];
//NSEnumerator *e = [contents objectEnumerator];
//NSString *filename;
//while ((filename = [e nextObject])) {
//    if ([filename hasPrefix:@"http_"]) {
//        if([fileManager removeItemAtPath:[path stringByAppendingPathComponent:filename] error:NULL]){
//            NSLog(@"deok");
//        }
//        else{
//            NSLog(@"deno");
//        }
//    }
//}
//[self.navigationController popToRootViewControllerAnimated:YES];
