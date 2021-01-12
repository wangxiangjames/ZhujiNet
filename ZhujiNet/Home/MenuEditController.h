//
//  MenuEditController.h
//  ZhujiNet
//
//  Created by zhujiribao on 2017/8/30.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"
#import "CjwTabViewController.h"

@interface MenuEditController : UIViewController

@property (nonatomic ,strong) NSMutableArray        *menuArray;
@property (nonatomic ,strong) CjwTabViewController  *tabViewController;
@end
