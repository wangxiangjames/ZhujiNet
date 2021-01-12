//
//  ForumViewController.h
//  ZhujiNet
//
//  Created by chenjinwei on 17/6/11.
//  Copyright © 2017年 zhuji.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImagePicketViewController.h"

@interface ForumViewController : UIViewController
@property (nonatomic,copy) NSString             *url;
@property (nonatomic,copy) NSString             *navTitle;
@property (nonatomic,assign)BOOL                isNewsType;
@property (nonatomic,assign) NSInteger          fid;
@property (nonatomic,assign) ImagePicket_type   imgPicketType;
@end
