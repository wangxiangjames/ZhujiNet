//
//  ShareModel.h
//  ZhujiNet
//
//  Created by zhujiribao on 2018/2/10.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ShareModel : NSObject

@property (nonatomic,copy) NSString     *title;
@property (nonatomic,copy) NSString     *descr;
@property (nonatomic,copy) NSString     *webpageUrl;
@property (nonatomic,copy) NSString     *thumbUrl;
@property (nonatomic,copy) UIImage      *thumbImg;

@end
