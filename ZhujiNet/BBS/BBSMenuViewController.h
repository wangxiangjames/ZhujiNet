//
//  BBSMenuViewController.h
//  ZhujiNet
//
//  Created by chenjinwei on 17/6/11.
//  Copyright © 2017年 zhuji.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBSMenuViewController : UIViewController
@property (nonatomic,assign) BOOL               isHaveAddButton;
@property (nonatomic,copy) NSString             *navTitle;
@property (nonatomic,strong) UIViewController   *pushController;
@property (nonatomic,strong) NSMutableArray     *arrayBbsForum;
@end
