//
//  DetailViewController.h
//  ZhujiNet
//
//  Created by zhujiribao on 2017/7/28.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXVideoPlayerController.h"
#import "Common.h"

@interface DetailViewController : UIViewController
@property (nonatomic,copy) NSString                     *vedioUrl;
@property (nonatomic,copy) NSString                     *videoCover;
@property (nonatomic,copy) NSString                     *videoTime;
@property (nonatomic,copy) NSString                     *webUrl;
@property (nonatomic,copy) NSString                     *tid;
@property (nonatomic,copy) NSString                     *artTitle;
@property (nonatomic, strong)UITableView                *tableView;
@property (nonatomic, strong) ZXVideoPlayerController   *video;
@property (nonatomic,assign) CGFloat                    mediaTop;
@property (nonatomic,assign)CGPoint                     tableContentOffset;
@property (nonatomic,assign)NSInteger                   contmode;
@property (nonatomic,copy) NSString                     *sharepic;
@end
