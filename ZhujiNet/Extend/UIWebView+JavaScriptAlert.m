//
//  UIWebView+JavaScriptAlert.m
//  ZhujiNet
//
//  Created by zhujiribao on 2018/4/19.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//

#import "UIWebView+JavaScriptAlert.h"

@implementation UIWebView (JavaScriptAlert)

-(void)webView:(UIWebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(id)frame
{
    UIAlertView * customAlert = [[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [customAlert show];
    
}

@end
