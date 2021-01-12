//
//  ContentViewController.h
//  ZhujiNet
//
//  Created by zhujiribao on 2017/7/25.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#include "ZXVideoPlayerController.h"
#import "WeatherModel.h"

@interface ContentViewController : UIViewController

@property (nonatomic,copy) NSString                     *url;
@property (nonatomic,assign) NSInteger                  fid;
@property (nonatomic, strong) ZXVideoPlayerController   *video;
@property (strong, nonatomic)WeatherModel               *weatherModel;
@property (nonatomic,assign) NSInteger                  ispost;
@property (nonatomic,assign) NSInteger                  istype;
@property (nonatomic,assign) NSInteger                  dmode;      //列表版式

-(void)onTabMenuClick;

@end
