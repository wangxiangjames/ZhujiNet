//
//  CjwNet.m
//  ZjzxApp
//
//  Created by chenjinwei on 17/3/19.
//  Copyright © 2017年 zhuji.net. All rights reserved.
//

#import "Define.h"
#import "CjwNet.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "AFHTTPSessionManager+Synchronous.h"

@interface CjwNet (){
    AFURLSessionManager *_manager;
    NSData  *_cooikeSuffer;
    AppDelegate *_app;
}
@end

@implementation CjwNet

-(CjwNet *)init{
    if(self=[super init]){
        _cooikeSuffer=nil;
        _manager= [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return self;
}


-(void)request:(NSObject*)obj url:(NSString*)url param:(NSDictionary*) param {
    [self request:obj url:url param:param callTag:0];
}

-(void)request:(NSObject*)obj url:(NSString*)url {
    [self request:obj url:url param:nil callTag:0];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wundeclared-selector"

-(void)request:(NSObject*)obj url:(NSString*)url param:(NSDictionary*) param callTag:(int)callTag{
    //NSLog(@"%s",__FUNCTION__);
    
    __weak typeof(&*obj)weakSelf = obj;
    
    BOOL isSelector= [weakSelf respondsToSelector:@selector(requestCallback: status:)];
    if (isSelector) {
        
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:url  parameters:param error:nil];
        NSString *userAgent = [NSString stringWithFormat:@"iOS/%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
        //如果token存在
        _app = [AppDelegate getApp];
        if (_app.user.uid>0) {
            NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:kUserToken];
            if (token) {
                //NSLog(@"token-cjw:%@",token);
                [request setValue:token forHTTPHeaderField:kUserToken];
            }
        }
        
        [request setTimeoutInterval:30];
        
        NSURLSessionUploadTask *uploadTask;
        uploadTask = [_manager
                      uploadTaskWithStreamedRequest:request
                      progress:nil
                      completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                          if (error) {
                              NSLog(@"Error: %@", error);
                              NSDictionary* dict=@{@"stat":@-1,@"tag":[NSNumber numberWithInt:callTag]};
                              [weakSelf performSelector:@selector(requestCallback: status:) withObject:error withObject:dict];
                          } else {
                              //NSLog(@"%@ %@", response, responseObject);
                              NSDictionary* dict=@{@"stat":@0,@"tag":[NSNumber numberWithInt:callTag]};
                              [weakSelf performSelector:@selector(requestCallback: status:) withObject:responseObject withObject:dict];
                          }
                      }];
        
        [uploadTask resume];
        
        /*AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        // 添加这句代码
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
        NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:kUserToken];
        [manager POST:url parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSDictionary* dict=@{@"stat":@0,@"tag":[NSNumber numberWithInt:callTag]};
            [weakSelf performSelector:@selector(requestCallback: status:) withObject:responseObject withObject:dict];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSDictionary* dict=@{@"stat":@-1,@"tag":[NSNumber numberWithInt:callTag]};
            [weakSelf performSelector:@selector(requestCallback: status:) withObject:error withObject:dict];
        }];*/
    }
}

#pragma clang diagnostic pop

-(void)request:(NSString*)url param:(NSDictionary*)param withMethod:(NSString*)method
       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:url  parameters:param error:nil];
    
    NSString *userAgent = [NSString stringWithFormat:@"iOS/%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    //如果token存在
    _app = [AppDelegate getApp];
    if (_app.user.uid>0) {
        NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:kUserToken];
        if (token) {
            //NSLog(@"token-cjw:%@",token);
            [request setValue:token forHTTPHeaderField:kUserToken];
        }
    }
    
    [request setTimeoutInterval:30];

    NSURLSessionUploadTask *uploadTask = [_manager
                  uploadTaskWithStreamedRequest:request
                  progress:nil
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (error) {
                          NSLog(@"Error: %@", error);
                          failure(nil,error);
                          
                      } else {
                          //NSLog(@"%@ %@", response, responseObject);
                          success(nil,responseObject);
                      }
                  }];
    
    [uploadTask resume];
    
    
    /*NSMutableURLRequest *request = [_manager.requestSerializer requestWithMethod:method URLString:url parameters:param error:nil];
    NSString *userAgent = [NSString stringWithFormat:@"iOS/%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    //如果token存在
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:kUserToken];
    if (token) {
        [request setValue:token forHTTPHeaderField:@"token"];
    }
    [request setTimeoutInterval:30];
    AFHTTPRequestOperation *operation=[_manager HTTPRequestOperationWithRequest:request success:success failure:failure];
    [_manager.operationQueue addOperation:operation];*/
    
}


-(void)upload:(NSString*)url param:(NSDictionary*)param constructingBodyWithBlock:(void(^)(id<AFMultipartFormData> formData)) formdata
       success:(void (^)(NSURLSessionDataTask *operation, id responseObject))success
       failure:(void (^)(NSURLSessionDataTask *operation, NSError *error))failure
{
    NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:kUserToken];
    AFHTTPSessionManager *manage=[AFHTTPSessionManager manager];
    if (token) {
        [manage.requestSerializer setValue:token forHTTPHeaderField:@"token"];
        NSLog(@"token:%@",token);
    }
   
    [manage POST:url parameters:param headers:nil constructingBodyWithBlock:formdata progress:nil success:success failure:failure];
   
    
    /*NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:kUserToken];
    AFHTTPSessionManager *manage = [AFHTTPSessionManager manager];
    [manage.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    manage.requestSerializer = [AFHTTPRequestSerializer serializer];
    manage.responseSerializer = [AFHTTPResponseSerializer serializer];
    manage.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/javascript",@"text/plain", nil];
    if (token) {
        [manage.requestSerializer setValue:token forHTTPHeaderField:@"token"];
        NSLog(@"token:%@",token);
    }
    [manage POST:url parameters:param constructingBodyWithBlock:formdata progress:nil success:success failure:failure];
    */
    /*if (token) {
     [_manager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
     NSLog(@"token:%@",token);
     }*/
    //[_manager POST:url parameters:param constructingBodyWithBlock:formdata success:success failure:failure];
}



+(void)saveCookie:(NSString*)host{
    
    NSHTTPCookieStorage *myCookie = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [myCookie cookies]) {
        NSLog(@"%@", cookie);
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie]; // 保存
    }
    
    // 寻找URL为HOST的相关cookie，不用担心，步骤2已经自动为cookie设置好了相关的URL信息
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:host]]; // 这里的HOST是你web服务器的域名地址
    // 比如你之前登录的网站地址是abc.com（当然前面要加http://，如果你服务器需要端口号也可以加上端口号），那么这里的HOST就是http://abc.com
    
    // 设置header，通过遍历cookies来一个一个的设置header
    for (NSHTTPCookie *cookie in cookies){
        
        // cookiesWithResponseHeaderFields方法，需要为URL设置一个cookie为NSDictionary类型的header，注意NSDictionary里面的forKey需要是@"Set-Cookie"
        NSArray *headeringCookie = [NSHTTPCookie cookiesWithResponseHeaderFields:
                                    [NSDictionary dictionaryWithObject:
                                     [[NSString alloc] initWithFormat:@"%@=%@",[cookie name],[cookie value]]
                                                                forKey:@"Set-Cookie"]
                                                                          forURL:[NSURL URLWithString:host]];
        
        // 通过setCookies方法，完成设置，这样只要一访问URL为HOST的网页时，会自动附带上设置好的header
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:headeringCookie
                                                           forURL:[NSURL URLWithString:host]
                                                  mainDocumentURL:nil];
    }
}

+(void)test{
    //同步请求成功
    
    static NSString *test=@"";
    NSMutableDictionary *paramDic2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"景丰",@"username",@"654321",@"password", nil];
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号量
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.completionQueue = dispatch_get_global_queue(0, 0);  //将回调放入子线程
    [manager GET:URL_login parameters:paramDic2 headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        test=responseObject;
        NSLog(@"test::%@",responseObject);
        dispatch_semaphore_signal(semaphore);//不管请求状态是什么，都得发送信号，否则会一直卡着进程
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_semaphore_signal(semaphore);//不管请求状态是什么，都得发送信号，否则会一直卡着进程
    }];
    
    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);  //等待
    NSLog(@"test::ok%@",test);
    
    
//    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
//    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://m.zhuji.net:9201/new4sshop/myAutoLogin.html?uid=110&zxid=1000&rcid=555&ucaccount=诸暨在线"]]];
    
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.completionQueue = dispatch_queue_create("AFNetworking+Synchronous", NULL);
//    NSMutableDictionary *paramDic2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"景丰",@"username",@"654321",@"password", nil];
//    NSError *error = nil;
//    NSData *result = [manager syncPOST:URL_login
//                            parameters:paramDic2
//                                  task:NULL
//                                 error:&error];
//    NSLog(@"%@",result);
    
}

@end


/*
 AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
 NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:kUserToken];
 if (token) {
 [manager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
 NSLog(@"token:%@",token);
 }
 
 [manager POST:@"http://bbs.zhuji.net/zjapp/json/upload_avatar" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
 
 UIImage *image = [UIImage imageNamed:@"wz_b3"];
 NSData *data = UIImageJPEGRepresentation(image, 1.0);//将UIImage转为NSData，1.0表示不压缩图片质量。
 [formData appendPartWithFileData:data name:@"Filedata" fileName:@"test.png" mimeType:@"image/png"];
 //----------上传文件-----------
 NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
 [dictionary setObject:@"multipart/form-data" forKey:@"Content-Type"];
 [dictionary setObject:[NSNumber numberWithInteger:data.length] forKey:@"Content-Length"];
 [dictionary setObject:@"form-data; name=\"Filedata\"; filename=\"temp.png\"" forKey:@"Content-Disposition"];
 [formData appendPartWithHeaders:dictionary body:data];
 //---------
} success:^(AFHTTPRequestOperation *operation, id responseObject) {//发送成功会来到这里
    NSLog(@"获取用户名称请求成功（图片）%@",responseObject);
} failure:^(AFHTTPRequestOperation *operation, NSError *error) {//发送成功会来到这里
    NSLog(@"获取用户名称请求失败（图片）——%@",error);
    
}];
*/
