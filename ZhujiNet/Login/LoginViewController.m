//
//  LoginViewController.m
//  ZjzxApp
//
//  Created by chenjinwei on 17/3/29.
//  Copyright © 2017年 zhuji.net. All rights reserved.
//

#import "LoginViewController.h"
#import "ZJRegisterViewController.h"
#import "ZJForgetViewController.h"
#import "MineViewController.h"
#import "UpdatePhoneController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <WebKit/WebKit.h>
#import "WKWebViewController.h"
@interface LoginViewController ()<WKNavigationDelegate,WKUIDelegate>{
    AppDelegate     *_app;
    UITextField     *_telField;
    UITextField     *_pswField;
    UIButton        *_loginButton;
    
    WKWebView       *_webViewAutoLogin;
    NSMutableArray *_domainLogout;
    NSMutableArray *_domainLogin;
    
    double          mytime;
}

@end

@implementation LoginViewController

- (void)viewWillAppear:(BOOL)animated{
    _app = [AppDelegate getApp];
    [_app.skin setSkin:self];
    self.navigationItem.title=@"登录";
    
    if (_app.user.uid>0 && _app.userLoginStatus==login_status_relogin){
        _domainLogin=[_app.domainLogin mutableCopy];
        _app.userLoginStatus=login_status_in;

        NSDictionary* item=[_domainLogin lastObject];
        NSString* link=[item[@"url"] copy];
        NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:link] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10];
        [_webViewAutoLogin loadRequest:request];
    }

    if (_app.user.uid==0 && _app.userLoginStatus==login_status_reout){
        _domainLogout=[_app.domainLogout mutableCopy];
        _app.userLoginStatus=login_status_out;

        NSDictionary* item=[_domainLogout lastObject];
        NSString* link=[item[@"url"] copy];
        NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:link] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10];
        [_webViewAutoLogin loadRequest:request];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigation];
    
    self.navigationController.navigationBar.topItem.title = @"";
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.processPool = [WKWebViewController singleWkProcessPool];
    config.preferences = [[WKPreferences alloc] init];
    config.preferences.minimumFontSize = 10;
    config.preferences.javaScriptEnabled = YES;
    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    _webViewAutoLogin = [[WKWebView alloc] initWithFrame:CGRectMake(0,0,0,0) configuration:config];
    _webViewAutoLogin.navigationDelegate=self;
    _webViewAutoLogin.UIDelegate=self;
    
    UIImageView *accountView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    accountView.image = [UIImage imageNamed:@"username_input_marker"];
    [self.view addSubview:accountView];
    
    UIImageView *passwordView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 50, 30)];
    passwordView.image = [UIImage imageNamed:@"psw_input_marker"];
    [self.view addSubview:passwordView];
    
    _telField = [[UITextField alloc] init];
    _telField.placeholder = @"用户名/手机号";
    [self.view addSubview:_telField];
    
    _pswField = [[UITextField alloc] init];
    _pswField.placeholder = @"密码";
    _pswField.returnKeyType = UIReturnKeyDone;
    _pswField.secureTextEntry = YES;
    [self.view addSubview:_pswField];
    
    _loginButton = [[UIButton alloc] init];
    _loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.f];
    _loginButton.layer.masksToBounds = YES;
    _loginButton.layer.cornerRadius = 5.f;
    [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIImage * bgImage1 = [UIImage imageWithColor:[UIColor redColor] size:CGSizeMake(1, 1)];
    UIImage * bgImage2 = [UIImage imageWithColor:[UIColor colorWithHexString:@"#dd0000"] size:CGSizeMake(1, 1)];
    [_loginButton setBackgroundImage:bgImage1 forState:UIControlStateNormal];
    [_loginButton setBackgroundImage:bgImage2 forState:UIControlStateHighlighted];
    [_loginButton addTarget:self action:@selector(loginButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_loginButton];
    
    UIButton *forgetButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [forgetButton setTitle:@"忘记密码" forState:UIControlStateNormal];
    [forgetButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [forgetButton addTarget:self action:@selector(forgetButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    forgetButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [self.view addSubview:forgetButton];
    
    UIButton *reginButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [reginButton setTitle:@"用户注册" forState:UIControlStateNormal];
    [reginButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [reginButton addTarget:self action:@selector(registerEvent:) forControlEvents:UIControlEventTouchUpInside];
    reginButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [self.view addSubview:reginButton];
    
    UIView *line1=[[UIView alloc]init];
    line1.backgroundColor=[UIColor colorWithHexString:@"dddddd"];
    [self.view addSubview:line1];
    
    UIView *line2=[[UIView alloc]init];
    line2.backgroundColor=[UIColor colorWithHexString:@"dddddd"];
    [self.view addSubview:line2];
    
    [accountView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(40);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];

    [_telField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(accountView.mas_right).offset(10);
        make.top.mas_equalTo(accountView.mas_top).offset(-4);
        make.width.mas_equalTo(self.view).offset(-100);
        make.height.mas_equalTo(40);
    }];

    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(accountView.mas_bottom).offset(15);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(1);
    }];
    
    [passwordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(line1.mas_bottom).offset(20);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [_pswField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(passwordView.mas_right).offset(10);
        make.top.mas_equalTo(passwordView.mas_top).offset(-4);
        make.width.mas_equalTo(self.view).offset(-100);
        make.height.mas_equalTo(40);
    }];
    
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(passwordView.mas_bottom).offset(15);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(1);
    }];
    
    [_loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(10);
        make.top.mas_equalTo(line2.mas_bottom).offset(30);
        make.right.mas_equalTo(self.view).offset(-10);
        make.height.mas_equalTo(50);
    }];
    
    [forgetButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(_loginButton.mas_bottom).offset(10);
    }];

    [reginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(_loginButton.mas_bottom).offset(10);
    }];
    
    [_telField becomeFirstResponder];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
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

-(void)viewTapped:(UITapGestureRecognizer*)tap {
    [_telField resignFirstResponder];
    [_pswField resignFirstResponder];
}

- (void)loginButtonClick:(UIButton*)sender
{
    if (_telField.text.length == 0 || _pswField.text.length == 0) {
        [MBProgressHUD showError:@"用户名或密码不能为空"];
        return;
    }
    
    [self.view endEditing:YES];
    [MBProgressHUD showMessage:@"请稍候" toView:self.view];
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:_telField.text,@"username",_pswField.text,@"password", nil];
    [_app.net request:self url:URL_login param:paramDic];
}

- (void)requestCallback:(id)response status:(id)status{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if([[status objectForKey:@"stat"] isEqual:@0]){
        NSDictionary *dict = (NSDictionary *)response;
        if ([dict[@"code"] isEqual:@0]) {
            if([_app.user login:dict[@"data"] withPassword:_pswField.text]){
                mytime=[[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
                
                [MBProgressHUD showMessage:@"请稍候"];
                _domainLogin=[_app.domainLogin mutableCopy];
                _app.userLoginStatus=login_status_in;
                NSDictionary* item=[_domainLogin lastObject];
                NSString* link=[item[@"url"] copy];
                NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:link] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10];
                [_webViewAutoLogin loadRequest:request];
                NSLog(@"url:%@",link);
                //------------------------------------------------
                [CjwFun loadFollow];
            }
        }
        else{
            [MBProgressHUD showError:dict[@"msg"]];
        }
    }
    else{
        NSLog(@"%@",response);
        [MBProgressHUD showError:@"登录失败"];
    }
}


//-------------------------------------------------------------------
- (void)registerEvent:(UIButton*)sender
{
    ZJRegisterViewController *controller = [[ZJRegisterViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}


- (void)forgetButtonClicked:(UIButton*)sender
{
    ZJForgetViewController  *controller = [[ZJForgetViewController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
}

//-------------------------------------------------------------------
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
//    JSContext *context = [_webViewAutoLogin valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
//    context[@"OC"] = self;
    if(_app.user.uid>0 && _domainLogin.count>0){
        
        NSArray *paramDic = @[NSString(_app.user.uid),
                              NSString(_app.user.rcid),
                              NSString(_app.user.zxid),
                              _app.user.username];
           //转为json
           NSData *data = [NSJSONSerialization dataWithJSONObject:paramDic options:(NSJSONWritingPrettyPrinted) error:nil];
           NSString *paramStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSString *jsonStr = [NSString stringWithFormat:@"goLoginInit(%@)",paramStr];
           [webView evaluateJavaScript:jsonStr completionHandler:^(id data, NSError * _Nullable error) {
               // 调用js后, OC收到的回调方法
           }];
        
//        JSValue *jval = [context[@"goLoginInit"] callWithArguments:@[NSString(_app.user.uid),
//                                                                     NSString(_app.user.rcid),
//                                                                     NSString(_app.user.zxid),
//                                                                     _app.user.username]];
//        double temp=[[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
        
//        NSLog(@"autologin:%@,%@,%.0f",jval,[_domainLogin lastObject],(temp-mytime));
        [_domainLogin removeLastObject];
        if(_domainLogin.count==0){
            [MBProgressHUD hideHUD];
            if (![CjwFun checkTelNumber:_app.user.mobile]) {
                UpdatePhoneController* updatePhone=[UpdatePhoneController new];
                updatePhone.isBindPage=YES;
                [self presentViewController:updatePhone animated:YES completion:nil];
            }
            else{
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
    if (_app.user.uid>0 && _domainLogin.count>0) {
        NSDictionary* item=[_domainLogin lastObject];
        NSString* link=[item[@"url"] copy];
        NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:link] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10];
        [_webViewAutoLogin loadRequest:request];
        
        mytime = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
    }
    
    //--------------------------------自动退出--------------------------------
    if(_app.user.uid==0 && _domainLogout.count>0){
        //NSString *returnStr = [_webViewAutoLogin stringByEvaluatingJavaScriptFromString:@"autoexit()"];
        //NSLog(@"autoexit:%@,%@",returnStr,[_domainLogout lastObject]);
        [webView evaluateJavaScript:@"autoexit" completionHandler:^(id data, NSError * _Nullable error) {
            // 调用js后, OC收到的回调方法
        }];
//        JSValue *jval = [context[@"autoexit"] callWithArguments:@[]];
//        NSLog(@"autoexit:%@,%@",jval,[_domainLogout lastObject]);
        [_domainLogout removeLastObject];
        if(_domainLogout.count==0){
            [self.navigationController popViewControllerAnimated:YES];
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
//    //--------------------------------自动登陆--------------------------------
//    if(_app.user.uid>0 && _domainLogin.count>0){
//        JSValue *jval = [context[@"goLoginInit"] callWithArguments:@[NSString(_app.user.uid),
//                                                                     NSString(_app.user.rcid),
//                                                                     NSString(_app.user.zxid),
//                                                                     _app.user.username]];
//        double temp=[[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
//
//        NSLog(@"autologin:%@,%@,%.0f",jval,[_domainLogin lastObject],(temp-mytime));
//        [_domainLogin removeLastObject];
//        if(_domainLogin.count==0){
//            [MBProgressHUD hideHUD];
//            if (![CjwFun checkTelNumber:_app.user.mobile]) {
//                UpdatePhoneController* updatePhone=[UpdatePhoneController new];
//                updatePhone.isBindPage=YES;
//                [self presentViewController:updatePhone animated:YES completion:nil];
//            }
//            else{
//                [self.navigationController popViewControllerAnimated:YES];
//            }
//        }
//    }
//    if (_app.user.uid>0 && _domainLogin.count>0) {
//        NSDictionary* item=[_domainLogin lastObject];
//        NSString* link=[item[@"url"] copy];
//        NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:link] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10];
//        [_webViewAutoLogin loadRequest:request];
//
//        mytime = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
//    }
//
//    //--------------------------------自动退出--------------------------------
//    if(_app.user.uid==0 && _domainLogout.count>0){
//        //NSString *returnStr = [_webViewAutoLogin stringByEvaluatingJavaScriptFromString:@"autoexit()"];
//        //NSLog(@"autoexit:%@,%@",returnStr,[_domainLogout lastObject]);
//        JSValue *jval = [context[@"autoexit"] callWithArguments:@[]];
//        NSLog(@"autoexit:%@,%@",jval,[_domainLogout lastObject]);
//        [_domainLogout removeLastObject];
//        if(_domainLogout.count==0){
//            [self.navigationController popViewControllerAnimated:YES];
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
    if (_app.user.uid>0 && _domainLogin.count>1) {
        [_domainLogin removeLastObject];
        NSDictionary* item=[_domainLogin lastObject];
        NSString* link=[item[@"url"] copy];
        NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:link] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10];
        [_webViewAutoLogin loadRequest:request];
    }
    
    if (_app.user.uid>0 && _domainLogin.count==1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    //-----------------------------------------
    
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
    
    NSLog(@"didFailLoadWithError");
}
//-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
//{
//    if (_app.user.uid>0 && _domainLogin.count>1) {
//        [_domainLogin removeLastObject];
//        NSDictionary* item=[_domainLogin lastObject];
//        NSString* link=[item[@"url"] copy];
//        NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:link] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10];
//        [_webViewAutoLogin loadRequest:request];
//    }
//    
//    if (_app.user.uid>0 && _domainLogin.count==1) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//    //-----------------------------------------
//    
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
//
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:self];
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
