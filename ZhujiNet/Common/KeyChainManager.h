//
//  KeyChainManager.h
//  ZjrbPaper
//
//  Created by zhujiribao on 2018/2/25.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeyChainManager : NSObject

+(void)saveUUID:(NSString *)uuid;
+(NSString *)getUUID;
+(void)deleteUUID;

@end
