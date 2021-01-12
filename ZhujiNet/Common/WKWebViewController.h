//
//  WebViewController.h
//  ZjrbPaper
//
//  Created by zhujiribao on 2018/2/25.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "ShareModel.h"


@interface WKWebViewController : UIViewController

@property (nonatomic, strong) UIProgressView *progressView;//进度条
@property(nonatomic,strong)WKWebView    *webView;
@property(nonatomic,copy)NSString       *webUrl;
@property(nonatomic,copy)NSString       *webTitle;

@property(nonatomic,assign)BOOL         isHomeIndicator;
@property(nonatomic,strong)ShareModel   *share;
+ (WKProcessPool*)singleWkProcessPool;
@end
