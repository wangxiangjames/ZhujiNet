//
//  ZJRegisterNextViewController.m
//  ZhujiNet
//
//  Created by zhujiribao on 2018/3/6.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//

#import "ZJRegisterNextViewController.h"
#import "ZJRegisterViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "WKWebViewController.h"

@interface ZJRegisterNextViewController ()<UITextFieldDelegate,WKNavigationDelegate,WKUIDelegate> {
    AppDelegate     *_app;
    UITextField     *_userField;
    UITextField     *_pswField;
    UITextField     *_psw2Field;
    UIButton        *_btnSubmit;
    //--------------------------------
    WKWebView       *_webViewAutoLogin;
    NSMutableArray *_domainLogin;
}
@end

@implementation ZJRegisterNextViewController

- (void)viewWillAppear:(BOOL)animated{
    _app = [AppDelegate getApp];
    [_app.skin setSkin:self];
    self.title = @"用户注册";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigation];
    
    self.navigationController.navigationBar.topItem.title = @"";
    
    UILabel* telLable=[[UILabel alloc]init];
    telLable.text=@"用户名";
    telLable.font=[UIFont systemFontOfSize:15];
    [self.view addSubview:telLable];
    
    UILabel* pwdLable=[[UILabel alloc]init];
    pwdLable.text=@"新的密码";
    pwdLable.font=[UIFont systemFontOfSize:15];
    [self.view addSubview:pwdLable];
    
    UILabel* picLable=[[UILabel alloc]init];
    picLable.text=@"确认密码";
    picLable.font=[UIFont systemFontOfSize:15];
    [self.view addSubview:picLable];
    
    _userField = [[UITextField alloc] init];
    _userField.placeholder = @"请输入用户名";
    _userField.font=[UIFont systemFontOfSize:16];
    _pswField.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:_userField];
    
    _pswField = [[UITextField alloc] init];
    _pswField.placeholder = @"请输入新的密码";
    _pswField.returnKeyType = UIReturnKeyDone;
    _pswField.secureTextEntry = YES;
    _pswField.font=[UIFont systemFontOfSize:16];
    [self.view addSubview:_pswField];
    
    _psw2Field = [[UITextField alloc] init];
    _psw2Field.placeholder = @"再输入一次新密码";
    _psw2Field.font=[UIFont systemFontOfSize:16];
    _psw2Field.returnKeyType = UIReturnKeyDone;
    _psw2Field.secureTextEntry = YES;
    [self.view addSubview:_psw2Field];
    
    _btnSubmit = [[UIButton alloc] init];
    _btnSubmit.titleLabel.font = [UIFont boldSystemFontOfSize:18.f];
    _btnSubmit.layer.masksToBounds = YES;
    _btnSubmit.layer.cornerRadius = 5.f;
    [_btnSubmit setTitle:@"提交" forState:UIControlStateNormal];
    [_btnSubmit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIImage * bgImage1 = [UIImage imageWithColor:[UIColor redColor] size:CGSizeMake(1, 1)];
    UIImage * bgImage2 = [UIImage imageWithColor:[UIColor colorWithHexString:@"#dd0000"] size:CGSizeMake(1, 1)];
    [_btnSubmit setBackgroundImage:bgImage1 forState:UIControlStateNormal];
    [_btnSubmit setBackgroundImage:bgImage2 forState:UIControlStateHighlighted];
    [_btnSubmit addTarget:self action:@selector(btnSumbitClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btnSubmit];
    
    UIView *line1=[[UIView alloc]init];
    line1.backgroundColor=[UIColor colorWithHexString:@"dddddd"];
    [self.view addSubview:line1];
    
    UIView *line2=[[UIView alloc]init];
    line2.backgroundColor=[UIColor colorWithHexString:@"dddddd"];
    [self.view addSubview:line2];
    
    UIView *line3=[[UIView alloc]init];
    line3.backgroundColor=[UIColor colorWithHexString:@"dddddd"];
    [self.view addSubview:line3];
    
    [telLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(30);
        make.size.mas_equalTo(CGSizeMake(80, 40));
    }];
    
    [_userField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(telLable.mas_right).offset(5);
        make.top.mas_equalTo(telLable.mas_top);
        make.width.mas_equalTo(self.view).offset(-130);
        make.height.mas_equalTo(40);
    }];
    
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(telLable.mas_bottom).offset(5);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(1);
    }];
    
    [pwdLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(line1.mas_bottom).offset(5);
        make.size.mas_equalTo(CGSizeMake(80, 40));
    }];
    
    [_pswField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(pwdLable.mas_right).offset(5);
        make.top.mas_equalTo(pwdLable.mas_top);
        make.width.mas_equalTo(self.view).offset(-130);
        make.height.mas_equalTo(40);
    }];
    
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(pwdLable.mas_bottom).offset(5);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(1);
    }];
    
    [picLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(line2.mas_bottom).offset(5);
        make.size.mas_equalTo(CGSizeMake(80, 40));
    }];
    
    [_psw2Field mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(picLable.mas_right).offset(5);
        make.top.mas_equalTo(picLable.mas_top);
        make.width.mas_equalTo(self.view).offset(-130);
        make.height.mas_equalTo(40);
    }];
    
    [line3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(picLable.mas_bottom).offset(5);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.height.mas_equalTo(1);
    }];
    
    [_btnSubmit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view).offset(10);
        make.top.mas_equalTo(line3.mas_bottom).offset(20);
        make.right.mas_equalTo(self.view).offset(-10);
        make.height.mas_equalTo(50);
    }];
    
    [_userField becomeFirstResponder];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
    
    //--------------------------------
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.processPool = [WKWebViewController singleWkProcessPool];
    config.preferences = [[WKPreferences alloc] init];
    config.preferences.minimumFontSize = 10;
    config.preferences.javaScriptEnabled = YES;
    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    _webViewAutoLogin = [[WKWebView alloc] initWithFrame:CGRectMake(0,0,0,0) configuration:config];
    _webViewAutoLogin.navigationDelegate=self;
    _webViewAutoLogin.UIDelegate = self;
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

//-------------------------------------------------------------------
-(void)viewTapped:(UITapGestureRecognizer*)tap {
    [_userField resignFirstResponder];
    [_pswField resignFirstResponder];
    [_psw2Field resignFirstResponder];
}

- (void)btnSumbitClick:(UIButton*)sender
{
    NSString* user=_userField.text;
    if(user.length == 0){
        [CjwFun showAlertMessage:@"注册的用户名不能为空！" currViewController:self];
        return;
    }
    if(_pswField.text.length == 0){
        [CjwFun showAlertMessage:@"密码不能为空，请输入密码！" currViewController:self];
        return;
    }
    
    if(![_pswField.text isEqualToString:_psw2Field.text]){
        [CjwFun showAlertMessage:@"两次输入的密码不相同" currViewController:self];
        return;
    }
    _btnSubmit.enabled=NO;
    [self.view endEditing:YES];
    [MBProgressHUD showMessage:@"请稍候"];
    
    id param=@{@"username":user,@"password":_pswField.text,@"mobile":self.mobile,@"verifycode":self.verifycode};
    [_app.net request:self url:URL_register param:param];
}

- (void)requestCallback:(id)response status:(id)status{
    [MBProgressHUD hideHUD];
    
    if([[status objectForKey:@"stat"] isEqual:@0]){
        NSDictionary *dict = (NSDictionary *)response;
        if ([dict[@"code"] isEqual:@0]) {
            [MBProgressHUD showSuccess:@"恭喜您，成功注册用户！" toView:self.view];

            if([_app.user login:dict[@"data"] withPassword:_pswField.text]){
                //------------------------------------------------
                _app.user.mobile=self.mobile;
                
                _domainLogin=[_app.domainLogin mutableCopy];
                _app.userLoginStatus=login_status_in;
                NSDictionary* item=[_domainLogin lastObject];
                NSString* link=[item[@"url"] copy];
                NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:link] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10];
                [_webViewAutoLogin loadRequest:request];
                //------------------------------------------------
            }
        }
        else{
            [MBProgressHUD showError:dict[@"msg"]];
        }
        _btnSubmit.enabled=YES;
    }
    else{
        NSLog(@"%@",response);
        [MBProgressHUD showError:@"网络错误"];
    }
}


-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
//    JSContext *context = [_webViewAutoLogin valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
//    context[@"OC"] = self;
    
    //--------------------------------自动登陆--------------------------------
    if(_app.user.uid>0 && _domainLogin.count>0){
        NSArray *paramDic = @[NSString(_app.user.uid),
                              NSString(_app.user.rcid),
                              NSString(_app.user.zxid),
                              _app.user.username];
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
//        NSLog(@"autologin:%@,%@",jval,[_domainLogin lastObject]);
        [_domainLogin removeLastObject];
        if(_domainLogin.count==0){
            if (self.navigationController.viewControllers.count>=4) {
                [self.navigationController popToViewController:
                 [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-4]
                                                      animated:YES];
            }
            else{
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            [MBProgressHUD showSuccess:@"登录成功"];
        }
        
    }
    if (_app.user.uid>0 && _domainLogin.count>0) {
        NSDictionary* item=[_domainLogin lastObject];
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
//        NSLog(@"autologin:%@,%@",jval,[_domainLogin lastObject]);
//        [_domainLogin removeLastObject];
//        if(_domainLogin.count==0){
//            if (self.navigationController.viewControllers.count>=4) {
//                [self.navigationController popToViewController:
//                 [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-4]
//                                                      animated:YES];
//            }
//            else{
//                [self.navigationController popToRootViewControllerAnimated:YES];
//            }
//            [MBProgressHUD showSuccess:@"登录成功"];
//        }
//        
//    }
//    if (_app.user.uid>0 && _domainLogin.count>0) {
//        NSDictionary* item=[_domainLogin lastObject];
//        NSString* link=[item[@"url"] copy];
//        NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:link] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10];
//        [_webViewAutoLogin loadRequest:request];
//    }
//    //--------------------------------------------------------------------
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
