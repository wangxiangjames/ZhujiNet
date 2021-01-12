//
//  CjwNet.h
//  ZjzxApp
//
//  Created by chenjinwei on 17/3/19.
//  Copyright © 2017年 zhuji.net. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
typedef NSURLSessionTask AFHTTPRequestOperation;

@interface CjwNet : NSObject

-(void)request:(NSObject*)obj url:(NSString*)url;
-(void)request:(NSObject*)obj url:(NSString*)url param:(NSDictionary*)param;
-(void)request:(NSObject*)obj url:(NSString*)url param:(NSDictionary*)param callTag:(int)callTag;

-(void)request:(NSString*)url param:(NSDictionary*)param withMethod:(NSString*)method
       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

-(void)upload:(NSString*)url param:(NSDictionary*)param constructingBodyWithBlock:(void(^)(id<AFMultipartFormData> formData)) formdata
      success:(void (^)(NSURLSessionDataTask *operation, id responseObject))success
      failure:(void (^)(NSURLSessionDataTask *operation, NSError *error))failure;

+(void)saveCookie:(NSString*)host;

+(void)test;

@end


/*
 网络调用： reuqest:回调对象 url:网址 param:调用参数=nil callTag:识别调用tag=0
 回调函数： -(void)requestCallback:(id)response status:(id)status
 repose:返回服务信息  status:返回NSDictionary状态码 stat＝－1失败，失败信息可通过reponse查看，stat＝0 成功，
 */

/*-----------------同步----------------------
 NSMutableDictionary *paramDic2 = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"chenjw",@"username",@"chenjw",@"password", nil];
 AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
 NSError *error = nil;
 NSString *result = [manager syncGET:URL_login
 parameters:paramDic2
 operation:NULL
 error:&error];
 NSLog(@"chen:%@",result);
 */
