//
//  ShangController.h
//  ZhujiNet
//
//  Created by zhujiribao on 2018/3/26.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PassValueDelegate.h"

@interface ShangController : UIViewController
@property (nonatomic,copy) NSString                     *tid;
@property (nonatomic,assign) NSInteger                  authorid;
@property (nonatomic,assign) BOOL                       bYiShang;
@property(nonatomic,assign) NSObject<PassValueDelegate> *delegate;
@end
