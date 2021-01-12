//
//  ForumSubModel.h
//  ZhujiNet
//
//  Created by zhujiribao on 2018/1/23.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ForumSubModel : NSObject
@property (copy, nonatomic) NSString *fid;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *image;
@property (assign, nonatomic)BOOL bAdd;
@end
