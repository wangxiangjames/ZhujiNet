//
//  WeatherModel.h
//  ZhujiNet
//
//  Created by chenjinwei on 17/7/15.
//  Copyright © 2017年 zhuji.net. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherModel : NSObject

@property (copy, nonatomic) NSString *alldaycondition;
@property (copy, nonatomic) NSString *tempDay;
@property (copy, nonatomic) NSString *tempNight;
@property (copy, nonatomic) NSString *backgrountimage;
@property (copy, nonatomic) NSString *itemimage;
@property (copy, nonatomic) NSString *windRegime;
@property (copy, nonatomic) NSString *airquality;
@property (copy, nonatomic) NSString *airqualitylevel;
@property (copy, nonatomic) NSString *week;
@property (copy, nonatomic) NSString *date;
@property (copy, nonatomic) NSString *month;

@property (copy, nonatomic) NSString *tomorrowcondition;
@property (copy, nonatomic) NSString *tomorrowtempday;
@property (copy, nonatomic) NSString *tomorrowtempnight;
@property (copy, nonatomic) NSString *tomorrowairquality;
@property (copy, nonatomic) NSString *tomorrowairqualitylevel;
@property (copy, nonatomic) NSString *tomorrowitemimage;

@end
