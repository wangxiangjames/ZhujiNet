//
//  WeatherCell.m
//  ZhujiNet
//
//  Created by zhujiribao on 2017/8/7.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import "WeatherCell.h"
#import "HexColor.h"
#import "Masonry.h"
#import "Common.h"
#import "NSObject+MJKeyValue.h"
#import "UIImage+ImageEffects.h"

@interface WeatherCell()

@property (strong, nonatomic) UIImageView   *background;
@property (strong, nonatomic) UIView        *line;
@property (strong, nonatomic) UILabel       *from;
@property (strong, nonatomic) UIImageView   *arrow;
@property (strong, nonatomic) UILabel       *more;
@property (strong, nonatomic) UILabel       *today;
@property (strong, nonatomic) UILabel       *tomorrow;
@property (strong, nonatomic) UILabel       *todayAir;
@property (strong, nonatomic) UILabel       *tomorrowAir;
@property (strong, nonatomic) UIImageView   *todayImage;
@property (strong, nonatomic) UIImageView   *tomorrowImage;
@property (strong, nonatomic) UILabel       *todayDegree;
@property (strong, nonatomic) UILabel       *tomorrowDegree;
@property (strong, nonatomic) UILabel       *dateline;
@property (strong, nonatomic) UILabel       *week;
@property (strong, nonatomic) UILabel       *tomorrowStatus;

@end

@implementation WeatherCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.background = [[UIImageView alloc] init];
        [self.contentView addSubview:self.background];
        
        self.line = [[UIImageView alloc] init];
        self.line.backgroundColor=[UIColor whiteColor];
        self.line.alpha=0.7;
        [self.contentView addSubview:self.line];
        
        self.from=[[UILabel alloc]init];
        self.from.text=@"诸暨气象台发布";
        self.from.textColor=[UIColor whiteColor];
        self.from.textAlignment=NSTextAlignmentCenter;
        self.from.font=[UIFont systemFontOfSize:12.f];
        self.from.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        self.from.layer.cornerRadius=12;
        self.from.clipsToBounds=YES;
        [self.contentView addSubview:self.from];
        
        self.more=[[UILabel alloc]init];
        self.more.text=@"未来5天天气";
        self.more.textColor=[UIColor whiteColor];
        self.more.textAlignment=NSTextAlignmentCenter;
        self.more.font=[UIFont systemFontOfSize:13.f];
        [self.contentView addSubview:self.more];
        
        self.arrow = [[UIImageView alloc] init];
        UIImage *img=[UIImage imageNamed:@"arrow_left"];
        self.arrow.image=[img imageWithTintColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.arrow];
        
        self.today=[[UILabel alloc]init];
        self.today.text=@"今天";
        self.today.textColor=[UIColor whiteColor];
        self.today.textAlignment=NSTextAlignmentCenter;
        self.today.font=[UIFont systemFontOfSize:15.f];
        [self.contentView addSubview:self.today];
        
        self.tomorrow=[[UILabel alloc]init];
        self.tomorrow.text=@"明天";
        self.tomorrow.textColor=[UIColor whiteColor];
        self.tomorrow.textAlignment=NSTextAlignmentCenter;
        self.tomorrow.font=[UIFont systemFontOfSize:15.f];
        [self.contentView addSubview:self.tomorrow];
        
        self.todayAir=[[UILabel alloc]init];
        self.todayAir.text=@"44轻度";
        self.todayAir.textColor=[UIColor whiteColor];
        self.todayAir.textAlignment=NSTextAlignmentCenter;
        self.todayAir.font=[UIFont systemFontOfSize:13.f];
        self.todayAir.backgroundColor=[HXColor colorWithHexString:@"f49900"];
        self.todayAir.layer.cornerRadius=4;
        self.todayAir.clipsToBounds=YES;
        [self.contentView addSubview:self.todayAir];
        

        self.tomorrowAir=[[UILabel alloc]init];
        self.tomorrowAir.text=@"44 轻度";
        self.tomorrowAir.textColor=[UIColor whiteColor];
        self.tomorrowAir.textAlignment=NSTextAlignmentCenter;
        self.tomorrowAir.font=[UIFont systemFontOfSize:13.f];
        self.tomorrowAir.backgroundColor=[HXColor colorWithHexString:@"3fc06d"];
        self.tomorrowAir.layer.cornerRadius=4;
        self.tomorrowAir.clipsToBounds=YES;
        [self.contentView addSubview:self.tomorrowAir];
        
        self.todayImage = [[UIImageView alloc] init];
        [self.contentView addSubview:self.todayImage];
        
        self.tomorrowImage = [[UIImageView alloc] init];
        [self.contentView addSubview:self.tomorrowImage];

        self.todayDegree=[[UILabel alloc]init];
        self.todayDegree.textColor=[UIColor whiteColor];
        self.todayDegree.font=[UIFont systemFontOfSize:28.f];
        [self.contentView addSubview:self.todayDegree];
        
        self.tomorrowDegree=[[UILabel alloc]init];
        self.tomorrowDegree.numberOfLines=0;
        self.tomorrowDegree.textColor=[UIColor whiteColor];
        self.tomorrowDegree.font=[UIFont systemFontOfSize:15.f];
        [self.contentView addSubview:self.tomorrowDegree];
        
        self.dateline=[[UILabel alloc]init];
        self.dateline.textColor=[UIColor whiteColor];
        self.dateline.font=[UIFont systemFontOfSize:12.f];
        self.dateline.textAlignment=NSTextAlignmentCenter;
        self.dateline.backgroundColor= [UIColor colorWithPatternImage:[UIImage imageNamed:@"weather_kuang"]];
        [self.contentView addSubview:self.dateline];
        
        self.week=[[UILabel alloc]init];
        self.week.textColor=[UIColor whiteColor];
        self.week.font=[UIFont systemFontOfSize:14.f];
        [self.contentView addSubview:self.week];
        
        self.tomorrowStatus=[[UILabel alloc]init];
        self.tomorrowStatus.textAlignment=NSTextAlignmentCenter;
        self.tomorrowStatus.textColor=[UIColor whiteColor];
        self.tomorrowStatus.font=[UIFont systemFontOfSize:14.f];
        [self.contentView addSubview:self.tomorrowStatus];
        
        AppDelegate *_app = [AppDelegate getApp];
        [_app.net request:self url:[NSString stringWithFormat:@"%@/getWeatherInfo",URL_weather]];
    }
    return self;
}

- (void)requestCallback:(id)response status:(id)status{
    if([[status objectForKey:@"stat"] isEqual:@0]){
        self.weatherModel=[WeatherModel mj_objectWithKeyValues:response];
    }
    else{
        NSLog(@"%@",response);
    }
}

- (CGFloat)height
{
    [self.background mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(SCREEN_WIDTH*0.66);
        make.top.mas_equalTo(40);
        make.width.mas_equalTo(1);
        make.bottom.mas_equalTo(self.contentView).offset(-18);
    }];
    
    [self.from mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(8);
        make.top.mas_equalTo(8);
        make.size.mas_equalTo(CGSizeMake(110, 24));
    }];

    [self.arrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-8);
        make.top.mas_equalTo(8);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
   
    [self.more mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.arrow);
        make.top.mas_equalTo(8);
        make.size.mas_equalTo(CGSizeMake(120, 24));
    }];
    
    [self.today mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(SCREEN_WIDTH*0.2);
        make.top.equalTo(self.from.mas_bottom).offset(10);
    }];

    [self.todayAir mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.today.mas_right).offset(5);
        make.top.equalTo(self.today);
        make.width.greaterThanOrEqualTo(@60);
        make.height.mas_equalTo(18);
    }];

    [self.tomorrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.line).offset(18);
        make.top.equalTo(self.today);
    }];
    
    [self.tomorrowAir mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.tomorrow.mas_right).offset(5);
        make.top.equalTo(self.today);
        make.width.greaterThanOrEqualTo(@60);
        make.height.mas_equalTo(18);
    }];

    [self.todayImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30);
        make.top.equalTo(self.today.mas_bottom).offset(2);
        make.size.mas_equalTo(CGSizeMake(42, 51));
    }];
    
    [self.todayDegree mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.todayImage.mas_right).offset(14);
        make.top.equalTo(self.todayImage).offset(10);
    }];

    [self.tomorrowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.line).offset(20);
        make.top.equalTo(self.today.mas_bottom).offset(2);
        make.size.mas_equalTo(CGSizeMake(42, 51));
    }];
    
    [self.tomorrowDegree mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.tomorrowImage.mas_right).offset(14);
        make.top.equalTo(self.todayImage).offset(8);
    }];
    
    [self.week mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.line).offset(-8);
        make.top.equalTo(self.todayImage.mas_bottom).offset(2);
        make.width.mas_greaterThanOrEqualTo(SCREEN_WIDTH*0.42);
    }];

    [self.dateline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.week.mas_left).offset(-5);
        make.top.equalTo(self.todayImage.mas_bottom).offset(-5);
        make.size.mas_equalTo(CGSizeMake(48, 30));
    }];
    
    [self.tomorrowStatus mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.line).offset(20);
        make.top.equalTo(self.todayImage.mas_bottom).offset(2);
        make.width.greaterThanOrEqualTo(@80);
    }];
    
    [self layoutIfNeeded];
    return self.today.y+self.today.height+14;
}

-(void)setWeatherModel:(WeatherModel *)weatherModel{
    self.dateline.text=[NSString stringWithFormat:@"%@/%@",weatherModel.month,weatherModel.date];
    self.todayDegree.text=[NSString stringWithFormat:@"%@ ~ %@ ℃",weatherModel.tempDay,weatherModel.tempNight];
    self.week.text=[NSString stringWithFormat:@"%@  %@  %@",weatherModel.week,weatherModel.alldaycondition,weatherModel.windRegime];
    self.todayAir.text=[NSString stringWithFormat:@"%@ %@",weatherModel.airquality,weatherModel.airqualitylevel];
    
    NSString* itemimagePath=[NSString stringWithFormat:@"%@/images/%@",URL_weather ,weatherModel.itemimage];
    [self.todayImage sd_setImageWithURL:[NSURL URLWithString:itemimagePath] placeholderImage:[UIImage imageNamed:kImgHolder]];
    
    self.tomorrowStatus.text=weatherModel.tomorrowcondition;
    self.tomorrowDegree.text=[NSString stringWithFormat:@"%@º\n%@º",weatherModel.tomorrowtempday,weatherModel.tomorrowtempnight];
    //@"25º\n27º"
    self.tomorrowAir.text=[NSString stringWithFormat:@"%@ %@",weatherModel.tomorrowairquality,weatherModel.tomorrowairqualitylevel];
    
    NSString* imagePath=[NSString stringWithFormat:@"%@/images/%@",URL_weather ,weatherModel.tomorrowitemimage];
    [self.tomorrowImage sd_setImageWithURL:[NSURL URLWithString:imagePath] placeholderImage:[UIImage imageNamed:kImgHolder]];
    NSLog(@"imgURL:%@",imagePath);
    
    NSString* bgPath=[NSString stringWithFormat:@"%@/images/%@",URL_weather ,weatherModel.backgrountimage];
    [self.background sd_setImageWithURL:[NSURL URLWithString:bgPath] placeholderImage:[UIImage imageNamed:@"rain"]];
    NSLog(@"bgPath:%@",bgPath);
    
    if([weatherModel.airqualitylevel isEqualToString:@"优"]){
        self.todayAir.backgroundColor=[HXColor colorWithHexString:@"00CC00"];
    }
    else if([weatherModel.airqualitylevel isEqualToString:@"良"]){
        self.todayAir.backgroundColor=[HXColor colorWithHexString:@"009900"];
    }
    else if([weatherModel.airqualitylevel isEqualToString:@"轻度污染"]){
        self.todayAir.backgroundColor=[HXColor colorWithHexString:@"ff9933"];
    }
    else if([weatherModel.airqualitylevel isEqualToString:@"中度污染"]){
        self.todayAir.backgroundColor=[HXColor colorWithHexString:@"CC0000"];
    }
    else if([weatherModel.airqualitylevel isEqualToString:@"重度污染"]){
        self.todayAir.backgroundColor=[HXColor colorWithHexString:@"9900CC"];
    }
    else if([weatherModel.airqualitylevel isEqualToString:@"严重污染"]){
        self.todayAir.backgroundColor=[HXColor colorWithHexString:@"660000"];
    }
    
    if([weatherModel.tomorrowairqualitylevel isEqualToString:@"优"]){
        self.tomorrowAir.backgroundColor=[HXColor colorWithHexString:@"00CC00"];
    }
    else if([weatherModel.tomorrowairqualitylevel isEqualToString:@"良"]){
        self.tomorrowAir.backgroundColor=[HXColor colorWithHexString:@"009900"];
    }
    else if([weatherModel.tomorrowairqualitylevel isEqualToString:@"轻度污染"]){
        self.tomorrowAir.backgroundColor=[HXColor colorWithHexString:@"ff9933"];
    }
    else if([weatherModel.tomorrowairqualitylevel isEqualToString:@"中度污染"]){
        self.tomorrowAir.backgroundColor=[HXColor colorWithHexString:@"CC0000"];
    }
    else if([weatherModel.tomorrowairqualitylevel isEqualToString:@"重度污染"]){
        self.tomorrowAir.backgroundColor=[HXColor colorWithHexString:@"9900CC"];
    }
    else if([weatherModel.tomorrowairqualitylevel isEqualToString:@"严重污染"]){
        self.tomorrowAir.backgroundColor=[HXColor colorWithHexString:@"660000"];
    }
    
    
    [self height];
}

@end
