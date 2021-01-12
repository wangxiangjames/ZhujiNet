//
//  RootViewController.h
//  ZjzxApp
//
//  Created by chenjinwei on 17/3/17.
//  Copyright © 2017年 zhuji.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImagePicketViewController.h"


@interface RootViewController : UITabBarController

@property(nonatomic,assign) ImagePicket_type    imagePicketPageType;
@property(nonatomic,copy) NSString              *selectForumTitle;       //选择的论坛菜单;
-(void)navBbsCircleShop:(id)sender;

@end
