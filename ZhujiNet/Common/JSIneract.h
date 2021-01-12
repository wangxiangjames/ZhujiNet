//
//  JSIneract.h
//  ZhujiNet
//
//  Created by zhujiribao on 2018/4/10.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

@protocol JSIneract <JSExport>

- (void)callAppLogin;
- (void)openActivity:(NSString *)url;
- (void)closeActivity;
- (void)openHtmlViewActivity:(NSString *)url;
- (void)openHtmlViewActivity:(NSString *)url withTitle:(NSString*)title;
- (void)closeHtmlViewActivity;
- (void)callphone:(NSString *)tel;
- (void)sharedurl:(NSString*)url withTitle:(NSString*)title withDesc:(NSString*)desc;
- (void)navrighturl:(NSString*)url withTitle:(NSString*)title;
- (void)openMapActivity:(NSString*)place withLongitude:(double)longitude withLatitude:(double)latitude withCity:(NSString*)city;
- (NSString*)appVersion;
- (void)openHtmlShareViewActivity:(NSString *)url withShareurl:(NSString *)shareurl withTitle:(NSString*)title withDesc:(NSString*)desc  withImageurl:(NSString*)imgurl;
- (NSString*)appToken;
- (void)appUpload:(NSString*)auid withAttach:(NSString *)attach;
- (NSString*)appUUID;
@end
