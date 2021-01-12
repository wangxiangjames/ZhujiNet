//
//  MapViewController.h
//  ZhujiNet
//
//  Created by zhujiribao on 2018/7/2.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>

@interface MapViewController : UIViewController
@property (nonatomic,copy) NSString     *city;
@property (nonatomic,copy) NSString     *place;
@property (nonatomic,assign) CLLocationCoordinate2D   coord;

@end
