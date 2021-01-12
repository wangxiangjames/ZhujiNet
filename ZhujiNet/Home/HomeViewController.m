//
//  HomeViewController.m
//  ZhujiNet
//
//  Created by zhujiribao on 2017/7/19.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import "HomeViewController.h"
#import "CjwAlertView.h"
#import "ContentViewController.h"
#import "BYDetailsList.h"
#import "ForumViewController.h"
#import "MenuEditController.h"
#import "MenuModel.h"
#import "DetailViewController.h"
#import "WKWebViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface HomeViewController ()<UIWebViewDelegate,UITextViewDelegate>{
    AppDelegate         *_app;
    UIAlertController   *userAlertController;
    //UIWebView         *_webViewAutoLogin;
    //NSMutableArray    *_domainLogout;
    //NSMutableArray    *_domainLogin;
}

@property (nonatomic,strong) BYDetailsList *menuList;
@property (nonatomic,strong) NSMutableArray *listBottom;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoNotification:) name:@"userInfoNotification" object:nil];
    
    //----------------------------------------------
//    _webViewAutoLogin = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,0,0)];
//    _webViewAutoLogin.delegate=self;
}

//------------------------推送-------------------------------------
- (void)viewWillAppear:(BOOL)animated{
     _app = [AppDelegate getApp];
    if (_app.ymUserInfo) {
        [self navigatePage:_app.ymUserInfo];
        _app.ymUserInfo=nil;
    }
    if ([_app.launchWebUrl length]>0) {
        [self navigateWeb:_app.launchWebUrl];
        _app.launchWebUrl=nil;
    }
    [self.navigationController setNavigationBarHidden:NO];
    [self remindUser];
    
//    if (_app.user.uid>0 && _app.userLoginStatus==login_status_relogin){
//        _domainLogin=[_app.domainLogin mutableCopy];
//        _app.userLoginStatus=login_status_in;
//
//        NSDictionary* item=[_domainLogin lastObject];
//        NSString* link=[item[@"url"] copy];
//        NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:link] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10];
//        [_webViewAutoLogin loadRequest:request];
//    }
//
//    if (_app.user.uid==0 && _app.userLoginStatus==login_status_reout){
//        _domainLogout=[_app.domainLogout mutableCopy];
//        _app.userLoginStatus=login_status_out;
//
//        NSDictionary* item=[_domainLogout lastObject];
//        NSString* link=[item[@"url"] copy];
//        NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:link] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10];
//        [_webViewAutoLogin loadRequest:request];
//    }
    
}

-(void)userInfoNotification:(NSNotification*)notification{
    NSDictionary *nameDictionary = [notification object];
    [self navigatePage:nameDictionary];
}

-(void)navigatePage:(NSDictionary *) dict{
    NSString *tid=[dict objectForKey:@"url"];
    if([tid hasPrefix:@"http://"]==YES || [tid hasPrefix:@"https://"]==YES ){
        [self navigateWeb:tid];
        return;
    }
    DetailViewController *detail=[[DetailViewController alloc]init];
    detail.webUrl=[NSString stringWithFormat:@"http://app.zhuji.net/content/news/%@.html?header=no",tid];
    detail.tid=tid;
    [self.navigationController pushViewController:detail animated:TRUE];
}

-(void)navigateWeb:(NSString*)url{
    WKWebViewController *webView=[[WKWebViewController alloc] init];
    webView.webUrl=url;
    [self.navigationController pushViewController:webView animated:TRUE];
}

//-------------------------------------------------------------

- (void)addChildViewController{
    _app = [AppDelegate getApp];
    
    //self.menuArray = [[NSMutableArray alloc] initWithArray:@[@"推荐",@"视频",@"头条号",@"诸暨",@"数码",@"人才",@"房产",@"交警",@"时尚"]];
    self.btnMore=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 38)];
    self.btnMore.backgroundColor=[UIColor colorWithHexString:@"FFFFFF" alpha:0.9];
    [self.btnMore setImage:[UIImage imageNamed:@"nav_menu_add"] forState:UIControlStateNormal];
    [self.btnMore addTarget:self action:@selector(actionMenuAdd:) forControlEvents:UIControlEventTouchUpInside];
    
    self.menuArray = _app.menu;
    //NSLog(@"chen url:%@",[MenuModel mj_keyValuesArrayWithObjectArray:_app.menu]);
    for (int i = 0; i < self.menuArray.count; i++) {
        MenuModel* menu=self.menuArray[i];
        if(menu.ishide==1){
            break;
        }
        if ([menu.url isEqualToString:@""]) {
            ContentViewController * cvc = [[ContentViewController alloc] init];
            cvc.title = menu.title;
            cvc.dmode=menu.dmode;   //列表版式
            cvc.url = [NSString stringWithFormat:@"%@?channel=%ld",URL_thread,menu.fid];
            cvc.fid=menu.fid;
            cvc.ispost=menu.ispost;
            cvc.istype=menu.istype;
            [self addChildViewController:cvc];
        }
        else{
            WKWebViewController  *webView=[[WKWebViewController alloc] init];
            webView.webUrl=menu.url;
            webView.title = menu.title;
            [self addChildViewController:webView];
        }
    }
}

-(void)actionMenuAdd:(id)sender{
    MenuEditController *menuEdit = [[MenuEditController alloc] init];
    menuEdit.menuArray=self.menuArray;
    menuEdit.tabViewController=self;
    //menuEdit.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    menuEdit.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:menuEdit animated:YES completion:^(void){ NSLog(@"finish");}];
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
//         [_domainLogin removeLastObject];
//    }
//    if (_app.user.uid>0 && _domainLogin.count>0) {
//        NSDictionary* item=[_domainLogin lastObject];
//        NSString* link=[item[@"url"] copy];
//        NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:link] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10];
//        [_webViewAutoLogin loadRequest:request];
//    }
//
//    //--------------------------------自动退出--------------------------------
//    if(_app.user.uid==0 && _domainLogout.count>0){
//        //NSString *returnStr = [_webViewAutoLogin stringByEvaluatingJavaScriptFromString:@"autoexit()"];
//        //NSLog(@"autoexit:%@,%@",returnStr,[_domainLogout lastObject]);
//        JSValue *jval = [context[@"autoexit"] callWithArguments:@[]];
//        NSLog(@"autoexit:%@,%@",jval,[_domainLogout lastObject]);
//        [_domainLogout removeLastObject];
//    }
//    if (_app.user.uid==0 && _domainLogout.count>0) {
//        NSDictionary* item=[_domainLogout lastObject];
//        NSString* link=[item[@"url"] copy];
//        NSURLRequest *request = [NSURLRequest requestWithURL: [NSURL URLWithString:link] cachePolicy:NSURLRequestReloadRevalidatingCacheData timeoutInterval:10];
//        [_webViewAutoLogin loadRequest:request];
//    }
//}

//-------------------------------------------------------------

-(void)remindUser{
    NSLog(@"--cc--:%@",self->_app.locationUserData);
    
    if([self->_app.locationUserData[@"agree"] isEqualToString:@"1"]){
        return;
    }
    userAlertController = [UIAlertController alertControllerWithTitle:@"个人隐私保护指引"
                                                                             message:@"\n\n\n\n\n\n\n\n\n\n\n"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"我知道了"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         self->_app.locationUserData[@"agree"]=@"1";
                                                         [CjwFun putLocaionDict:kLocationUserData value:self->_app.locationUserData];
                                                         
                                                     }];
    
    UIView* view=[[UIView alloc]init];
    view.backgroundColor=[UIColor clearColor];
    UITextView *textView  = [[UITextView alloc] init];
    textView.backgroundColor=[UIColor clearColor];
    textView.delegate = self;
    textView.editable = NO;
    textView.scrollEnabled = YES;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:14],
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:@"欢迎您使用掌上诸暨！我们将通过《用户协议》和《隐私政策》帮助您了解我们收集、使用、存储和共享个人信息的情况。此外，您还能了解到您所享有的相关权力及实现途径，以及我们为保护好您的个人信息所采取的安全措施。如您同意，请点击下方按钮开始接受我们的服务。" attributes:attributes];
    [attr addAttribute:NSLinkAttributeName
                 value:@"http://app.zhuji.net/user/bbs/useragreement"
                 range:[[attr string] rangeOfString:@"《用户协议》"]];
    [attr addAttribute:NSLinkAttributeName
                 value:@"http://app.zhuji.net/user/bbs/userprivacy"
                 range:[[attr string] rangeOfString:@"《隐私政策》"]];
    
    NSDictionary *linkAttributes = @{NSForegroundColorAttributeName: [UIColor redColor],
                                     NSUnderlineColorAttributeName: [UIColor lightGrayColor],
                                     NSUnderlineStyleAttributeName: @(NSUnderlinePatternSolid)};
    textView.linkTextAttributes = linkAttributes;
    textView.attributedText = attr;
    [view addSubview:textView];
    [userAlertController.view addSubview:view];
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self->userAlertController.view);
        make.top.mas_equalTo(self->userAlertController.view).offset(48);
        make.bottom.mas_equalTo(self->userAlertController.view).offset(-45);
    }];
    
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(view).offset(15);
        make.top.mas_equalTo(view);
        make.right.mas_equalTo(view).offset(-5);
        make.bottom.mas_equalTo(view);
    }];
    
    [userAlertController addAction:okAction];
    [self presentViewController:userAlertController animated:YES completion:nil];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    NSLog(@"%@",URL);
    [self navigateWeb:[URL absoluteString]];
    [userAlertController dismissViewControllerAnimated:YES completion:nil];
    return NO;
    return YES; // let the system open this URL
}

//-------------------------------------------------------------

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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
