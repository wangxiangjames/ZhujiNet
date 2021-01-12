//
//  WebViewController.m
//  ZjrbPaper
//
//  Created by zhujiribao on 2018/2/25.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//

#import "WKWebViewController.h"
#import <WebKit/WebKit.h>
#import <ShareSDK/ShareSDK.h>
#import "CjwFun.h"
#import <ShareSDKUI/ShareSDKUI.h>
#import "Define.h"
#import "AppDelegate.h"
#import "MapViewController.h"

@interface WKWebViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>{
    BOOL            theBool;
    NSTimer         *myTimer;
    AppDelegate     *_app;
    NSString        *_navRightUrl;
}
@property(nonatomic,assign)BOOL                 isOurShared;
@end

@implementation WKWebViewController

+ (WKProcessPool*)singleWkProcessPool{

    static WKProcessPool *sharedPool;

    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{

        sharedPool = [[WKProcessPool alloc]init];

    });

    return sharedPool;

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    if (self.share !=nil) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(navrightAction)];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSString *videoPauseJSStr = @"document.documentElement.getElementsByTagName(\"video\")[0].pause()";
    [self.webView evaluateJavaScript:videoPauseJSStr completionHandler:nil];
    
    
    // 移除 progress view
    // because UINavigationBar is shared with other ViewControllers
    [self.progressView removeFromSuperview];
    if (myTimer) {
        [myTimer invalidate];
        myTimer = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _app= [AppDelegate getApp];
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.processPool = [WKWebViewController singleWkProcessPool];
    config.preferences = [[WKPreferences alloc] init];
    config.preferences.minimumFontSize = 10;
    config.preferences.javaScriptEnabled = YES;
    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    config.userContentController = [[WKUserContentController alloc] init];
    [config.userContentController addScriptMessageHandler:self name:@"callAppLogin"];
    [config.userContentController addScriptMessageHandler:self name:@"openActivity"];
    [config.userContentController addScriptMessageHandler:self name:@"closeActivity"];
   
    [config.userContentController addScriptMessageHandler:self name:@"openHtmlViewActivity"];
    [config.userContentController addScriptMessageHandler:self name:@"openHtmlShareViewActivity"];
    [config.userContentController addScriptMessageHandler:self name:@"closeHtmlViewActivity"];
    [config.userContentController addScriptMessageHandler:self name:@"callphone"];
    [config.userContentController addScriptMessageHandler:self name:@"sharedurl"];
    [config.userContentController addScriptMessageHandler:self name:@"navrighturl"];
    [config.userContentController addScriptMessageHandler:self name:@"openMapActivity"];
    
    float homeIndicatorHeight=Height_HomeIndicator;
    if (self.isHomeIndicator) {
        homeIndicatorHeight=0;
    }
    CGFloat height=self.view.frame.size.height- self.tabBarController.tabBar.frame.size.height- Height_NavBar-homeIndicatorHeight;
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,
                                                               height) configuration:config];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate =self;
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.webUrl]];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
    
    //进度条添加到navigationBar
    CGFloat progressBarHeight = 2.0f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    self.progressView = [[UIProgressView alloc] initWithFrame:barFrame];
    self.progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.progressView.progressTintColor = [UIColor yellowColor];
    [self.navigationController.navigationBar addSubview:self.progressView];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
}

- (void)navrightAction{
    if (self.share!=nil) {
        [self actionShare:self.share];
    }
    if ([[_navRightUrl lowercaseString] hasPrefix:@"http://"]) {
        WKWebViewController  *webView=[[WKWebViewController alloc] init];
        webView.webUrl=_navRightUrl;
        [self.navigationController pushViewController:webView animated:TRUE];
    }
    else{

      [self.webView evaluateJavaScript:_navRightUrl completionHandler:nil];//[self.webView stringByEvaluatingJavaScriptFromString:_navRightUrl];
//        NSLog(@"navrightAction:%@",returnStr);
    }
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if ([message.name isEqualToString:@"callAppLogin"]) {
        
        [_app.user checkUserLogin:self];
      
    }
    if ([message.name isEqualToString:@"openActivity"]) {
        
        WKWebViewController  *webView=[[WKWebViewController alloc] init];
        webView.webUrl=message.body[@"arg0"];
        [self.navigationController pushViewController:webView animated:TRUE];
        
    }
    if ([message.name isEqualToString:@"closeActivity"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
    if ([message.name isEqualToString:@"openHtmlViewActivity"]) {
        NSLog(@"%@", message.body);
        WKWebViewController  *webView=[[WKWebViewController alloc] init];
        webView.webUrl=message.body[@"arg0"];
        [self.navigationController pushViewController:webView animated:TRUE];
    }
    if ([message.name isEqualToString:@"openHtmlShareViewActivity"]) {
        NSLog(@"%@", message.body);
        ShareModel* share=[[ShareModel alloc]init];
        
        share.webpageUrl=message.body[@"arg0"];
        share.title=message.body[@"arg1"];
        share.descr=message.body[@"arg2"];
        share.thumbUrl =message.body[@"arg3"];
        WKWebViewController  *webView=[[WKWebViewController alloc] init];
        webView.webUrl=message.body[@"arg0"];
        webView.share=share;
        [self.navigationController pushViewController:webView animated:TRUE];
    }
    if ([message.name isEqualToString:@"closeHtmlViewActivity"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    

    if ([message.name isEqualToString:@"callphone"]) {
        NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",message.body[@"arg0"]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
    
    if ([message.name isEqualToString:@"sharedurl"]) {
        NSLog(@"%@", message.body);
        ShareModel* share=[[ShareModel alloc]init];
        share.webpageUrl=message.body[@"arg0"];
        share.title=message.body[@"arg1"];
        share.descr=message.body[@"arg2"];
        [self actionShare:share];
    }
    if ([message.name isEqualToString:@"navrighturl"]) {
        _navRightUrl=message.body[@"arg0"];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:message.body[@"arg1"] style:UIBarButtonItemStylePlain target:self action:@selector(navrightAction)];
    }
    if ([message.name isEqualToString:@"openMapActivity"]) {
        MapViewController *map=[[MapViewController alloc] init];
        map.place=message.body[@"arg0"];
        map.city=message.body[@"arg3"];
        
        if ([message.body[@"arg1"] doubleValue]>0 && [message.body[@"arg2"] doubleValue]>0) {
            CLLocationCoordinate2D coord;
            //coord.longitude = 120.274233;
            //coord.latitude = 29.717704;
            coord.longitude=[message.body[@"arg1"] doubleValue];
            coord.latitude=[message.body[@"arg2"] doubleValue];
            map.coord=coord;
        }
        
        [self.navigationController pushViewController:map animated:TRUE];
        return;
    }
    
    
    
}

-(void)actionShare:(ShareModel*)shareModel{
//    [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_WechatTimeLine),@(UMSocialPlatformType_WechatFavorite),
//                                               @(UMSocialPlatformType_QQ),@(UMSocialPlatformType_Qzone ),@(UMSocialPlatformType_Sina)]];
//    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
//        [CjwFun shareWebPageToPlatformType:platformType currentViewController:self shareCont:shareModel];
//    }];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params SSDKSetupShareParamsByText:shareModel.descr
                                images:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:shareModel.thumbUrl]]]
                                   url:[NSURL URLWithString:shareModel.webpageUrl]
                                 title:shareModel.title
                                  type:SSDKContentTypeAuto];
    SSUIShareSheetConfiguration *config = [SSUIShareSheetConfiguration new];
    
    [ShareSDK showShareActionSheet:self.view customItems:@[@(SSDKPlatformSubTypeWechatSession),@(SSDKPlatformSubTypeWechatTimeline),@(SSDKPlatformSubTypeWechatFav),@(SSDKPlatformTypeQQ),@(SSDKPlatformSubTypeQZone),@(SSDKPlatformTypeSinaWeibo)] shareParams:params sheetConfiguration:config onStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
        
    }];
}

//-------------------------------------------------------------

#pragma mark KVO的监听代理
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //加载进度值
    if ([keyPath isEqualToString:@"estimatedProgress"]){
        if (object == self.webView){
            self.progressView.alpha = 1;
            [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
            if(self.webView.estimatedProgress >= 1.0f)
            {
                [UIView animateWithDuration:0.5 animations:^{
                    self.progressView.alpha = 0;
                } completion:^(BOOL finished) {
                    [self.progressView setProgress:0.0f animated:NO];
                }];
            }
        }
        else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
    else if ([keyPath isEqualToString:@"title"]){//网页title
        if (object == self.webView){
            self.navigationItem.title = self.webView.title;
        }
        else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
    else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    
    // 加载完成
    /*if (!_webView.loading) {
        手动调用JS代码
        NSString *js = @"callJsAlert()";
        [_webView evaluateJavaScript:js completionHandler:^(id _Nullable response, NSError * _Nullable error) {
            NSLog(@"response: %@ error: %@", response, error);
        }];
    }*/
}

#pragma mark - WKNavigationDelegate
// 页面加载开始  Provisional临时的
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"页面开始加载");
    
}

// 加载内容
-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    NSLog(@"内容正在加载当中");
}

// 页面加载完成
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSLog(@"页面加载完成");
   
    if (self.webTitle.length>0) {
        self.navigationItem.title=self.webTitle;
    }
    else{
        self.navigationItem.title = webView.title;
    }
}

//  页面加载失败
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"页面加载失败");
}

// 接收到服务器重新配置请求之后再执行
-(void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    
}

// API是根据WebView对于即将跳转的HTTP请求头信息和相关信息来决定是否跳转
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSURLRequest * request = navigationAction.request;
    NSLog(@"%@",request.URL.absoluteString);
    
    // 判断请求头是否是 https://www.baidu.com 如果是就不在请求加载跳转
    WKNavigationActionPolicy  actionPolicy = WKNavigationActionPolicyAllow;
    if ([request.URL.absoluteString hasPrefix:@"https://www.baidu.com"]) {
        actionPolicy = WKNavigationActionPolicyCancel;
    }
    // 必须这样执行，不然会崩
    decisionHandler(actionPolicy);
}

// API是根据客户端受到的服务器响应头以及response相关信息来决定是否可以跳转
-(void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    NSLog(@"%@",navigationResponse.response);
    /**
     *  判断响应的数据里面的URL是https://www.baidu.com/开头的，要是就不让它加载跳转
     */
    WKNavigationResponsePolicy responsePolicy = WKNavigationResponsePolicyAllow;
    if ([navigationResponse.response.URL.absoluteString hasPrefix:@"https://www.baidu.com/"]) {
        responsePolicy = WKNavigationResponsePolicyCancel;
    }
    decisionHandler(responsePolicy);
}

//-----------------------------------------------------------

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)dealloc{
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
