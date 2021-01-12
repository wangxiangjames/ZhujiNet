//
//  MapViewController.m
//  ZhujiNet
//
//  Created by zhujiribao on 2018/7/2.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//

#import "MapViewController.h"
#import "HexColor.h"
#import "Define.h"
#import "Masonry.h"
#import "CjwSheetView.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>

@interface MapViewController ()<BMKMapViewDelegate,BMKGeoCodeSearchDelegate,BMKLocationServiceDelegate>{
    BMKMapView         *_mapView;
    BMKGeoCodeSearch   *_searcher;
    BMKLocationService *_locService;
    
    BMKPlanNode     *_myNode ;
    BMKPlanNode     *_sellerNode;
    
    UILabel         *_placeName;
    UILabel         *_placeAddr;
    
    CjwSheetView    *_sheet;
}
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    
    _sheet = [[CjwSheetView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [_sheet addContentView:[self createMenuView]];
    
    _myNode = [[BMKPlanNode alloc]init];
    _sellerNode= [[BMKPlanNode alloc]init];
    
    _mapView = [[BMKMapView alloc]initWithFrame:self.view.bounds];
    self.view = _mapView;
    
    _mapView.showsUserLocation = YES;//显示定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;    //设置定位的状态为普通定位模式
    [_mapView setZoomLevel:18.0];
    
    //-----------------------------------------
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    [_locService startUserLocationService];
    
    //-----------------------------------------
    _searcher =[[BMKGeoCodeSearch alloc]init];
    _searcher.delegate = self;
    
    if (self.coord.latitude>0 && self.coord.longitude>0) {
        [self findInMap:self.coord];
    }
    else{
        [self findInMap:self.place withCity:self.city];
    }
    
    [self addView];
}


-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [_mapView viewWillAppear];
    _mapView.delegate = nil; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _searcher.delegate = nil;
    _locService.delegate =nil;
}

-(void)findInMap:(NSString*)placeName withCity:(NSString*)city{
    self.city=city.length>0?city:@"诸暨";
    
    //发起地理位置检索
    BMKGeoCodeSearchOption *geoCodeSearchOption = [[BMKGeoCodeSearchOption alloc]init];
    geoCodeSearchOption.city =self.city;
    geoCodeSearchOption.address = placeName;
    BOOL flag = [_searcher geoCode:geoCodeSearchOption];
    if(flag){
        NSLog(@"geo检索发送成功");
        self.place=placeName;
    }
    else{
        NSLog(@"geo检索发送失败");
    }
}

-(void)findInMap:(CLLocationCoordinate2D) coor{
    /*CLLocationCoordinate2D coor;
    coor.latitude = 29.7274699717;
    coor.longitude = 120.1978101428;*/
    
    _sellerNode.pt=coor;
    
    BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
    item.coordinate = coor;
    [_mapView addAnnotation:item];
    [_mapView setCenterCoordinate:coor animated:YES];
    
    BMKReverseGeoCodeSearchOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeSearchOption alloc]init];
    reverseGeoCodeSearchOption.location = _sellerNode.pt;
    BOOL flag = [_searcher reverseGeoCode:reverseGeoCodeSearchOption];
    if(flag){
        NSLog(@"反geo检索发送成功");
    }
    else{
        NSLog(@"反geo检索发送失败");
    }
}

-(void)addView{
    UIButton *btnBack = [[UIButton alloc]initWithFrame:CGRectMake(14, 30, 40, 35)];
    [btnBack setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    btnBack.backgroundColor=[UIColor colorWithWhite:0.5 alpha:0.7];
    btnBack.layer.cornerRadius=8;
    [btnBack addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnBack];
    
    UIView *bottomView=[[UIView alloc]init];
    bottomView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    UIButton *daohang = [[UIButton alloc]init];
    daohang.backgroundColor=[UIColor colorWithHexString:@"5EA90B"];
    [daohang setBackgroundImage:[UIImage imageNamed:@"map"] forState:UIControlStateNormal];
    daohang.layer.cornerRadius=30;
    [daohang addTarget:self action:@selector(daohangAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:daohang];
    
    _placeName=[[UILabel alloc]init];
    _placeName.font= [UIFont systemFontOfSize:20.0];
    [self.view addSubview:_placeName];
    
    _placeAddr=[[UILabel alloc]init];
    _placeAddr.font= [UIFont systemFontOfSize:13.0];
    _placeAddr.textColor=[UIColor colorWithWhite:0.5 alpha:1];
    [self.view addSubview:_placeAddr];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.view);
        make.width.mas_equalTo(self.view);
        make.height.mas_equalTo(80+Height_HomeIndicator);
    }];
    
    [daohang mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bottomView).offset(10);
        make.right.mas_equalTo(bottomView).offset(-15);
        make.height.mas_equalTo(60);
        make.width.mas_equalTo(60);
    }];
    
    [_placeName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bottomView).offset(14);
        make.left.mas_equalTo(bottomView).offset(14);
        make.right.mas_equalTo(daohang.mas_left).offset(-14);
        make.height.mas_equalTo(25);
    }];
    
    [_placeAddr mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self->_placeName.mas_bottom).offset(5);
        make.left.mas_equalTo(bottomView).offset(14);
        make.right.mas_equalTo(daohang.mas_left).offset(-14);
    }];
}

-(UIView*)createMenuView{
    UIView *viewBg=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 108+78+54+Height_HomeIndicator)];
    [self.view addSubview:viewBg];
    
    UIButton* btnCancel=[[UIButton alloc]init];
    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    [btnCancel setTitleColor:[UIColor colorWithHexString:@"222222"] forState:UIControlStateNormal];
    btnCancel.titleLabel.font=[UIFont systemFontOfSize:18];
    [btnCancel addTarget:self action:@selector(actionSelectMenu:) forControlEvents:UIControlEventTouchUpInside];
    [viewBg addSubview:btnCancel];
    
    UIView *line=[[UIView alloc] init];
    line.backgroundColor=[UIColor colorWithWhite:0.8 alpha:0.4];
    [viewBg addSubview:line];
    
    UIButton* btnGaode=[[UIButton alloc]init];
    btnGaode.tag=10;
    [btnGaode setTitle:@"高德地图" forState:UIControlStateNormal];
    [btnGaode setTitleColor:[UIColor colorWithHexString:@"222222"] forState:UIControlStateNormal];
    btnGaode.titleLabel.font=[UIFont systemFontOfSize:18];
    [btnGaode addTarget:self action:@selector(actionSelectMenu:) forControlEvents:UIControlEventTouchUpInside];
    [viewBg addSubview:btnGaode];
    
    UIView *line2=[[UIView alloc] init];
    line2.backgroundColor=[UIColor colorWithWhite:0.8 alpha:0.4];
    [viewBg addSubview:line2];
    
    UIButton* btnBaidu=[[UIButton alloc]init];
    btnBaidu.tag=11;
    [btnBaidu setTitle:@"百度地图" forState:UIControlStateNormal];
    [btnBaidu setTitleColor:[UIColor colorWithHexString:@"222222"] forState:UIControlStateNormal];
    btnBaidu.titleLabel.font=[UIFont systemFontOfSize:18];
    [btnBaidu addTarget:self action:@selector(actionSelectMenu:) forControlEvents:UIControlEventTouchUpInside];
    [viewBg addSubview:btnBaidu];
    
    UIView *line3=[[UIView alloc] init];
    line3.backgroundColor=[UIColor colorWithWhite:0.8 alpha:0.4];
    [viewBg addSubview:line3];

    UIButton* btnApple=[[UIButton alloc]init];
    btnApple.tag=12;
    [btnApple setTitle:@"Apple 地图" forState:UIControlStateNormal];
    [btnApple setTitleColor:[UIColor colorWithHexString:@"222222"] forState:UIControlStateNormal];
    btnApple.titleLabel.font=[UIFont systemFontOfSize:18];
    [btnApple addTarget:self action:@selector(actionSelectMenu:) forControlEvents:UIControlEventTouchUpInside];
    [viewBg addSubview:btnApple];
    
    //----------------------------------------
    [btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(viewBg).offset(-Height_HomeIndicator);
        make.centerX.equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 64));
    }];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(btnCancel.mas_top);
        make.centerX.equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 6));
    }];
    
    [btnApple mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(btnCancel.mas_top).offset(-8);
        make.centerX.equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 54));
    }];
    
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(btnApple.mas_top);
        make.centerX.equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 1));
    }];
    
    [btnGaode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(btnApple.mas_top);
        make.centerX.equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 54));
    }];
    
    [line3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(btnGaode.mas_top);
        make.centerX.equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 1));
    }];
    
    [btnBaidu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(btnGaode.mas_top);
        make.centerX.equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 60));
    }];
    
    return viewBg;
}

-(void)backAction:(UIButton *)sender{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController popViewControllerAnimated:TRUE];
}

-(void)actionSelectMenu:(UIButton *)sender{
    switch ([sender tag]) {
        case 10:{
                if (![[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:@"iosamap://"]]){
                     UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@"提示" message:@"您还未下载高德地图！" preferredStyle:UIAlertControllerStyleAlert];
                     UIAlertAction *leftAction = [UIAlertAction actionWithTitle:@"确定" style: UIAlertActionStyleDefault handler:nil];
                     [alertCtrl addAction:leftAction];
                     [self presentViewController:alertCtrl animated:YES completion:nil];
                    return;
                }

                CLLocationCoordinate2D coor=_sellerNode.pt;
                coor=[self getGaoDeCoordinateByBaiDuCoordinate:coor];
                NSString* urlString=[[NSString stringWithFormat:@"iosamap://navi?sourceApplication=%@&backScheme=%@&lat=%lf&lon=%lf&dev=0&style=2",@"掌上诸暨",@"zhujionline",coor.latitude,coor.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            }
            break;
            
        case 11:{
                BMKOpenDrivingRouteOption *opt = [[BMKOpenDrivingRouteOption alloc] init];
                //opt.appScheme = @"baidumapsdk://mapsdk.baidu.com";
                opt.startPoint = _myNode;
                opt.endPoint = _sellerNode;
                BMKOpenErrorCode code = [BMKOpenRoute openBaiduMapDrivingRoute:opt];
                NSLog(@"%d", code);
            }
            break;
            
        case 12:{
                CLLocationCoordinate2D coor=_sellerNode.pt;
                coor=[self getGaoDeCoordinateByBaiDuCoordinate:coor];
                NSString *urlString = [[NSString stringWithFormat:@"http://maps.apple.com/?daddr=%f,%f&saddr=Current+Location",coor.latitude,coor.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
            }
            break;
    }
    [_sheet closeView];
}
    
-(void)daohangAction:(UIButton *) sender{
    [_sheet showInView:self.view];
    return;
}

//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [_locService stopUserLocationService];
    _myNode.pt=userLocation.location.coordinate;
    _myNode.name = userLocation.title;
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
}

//返回地址信息搜索结果
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error {
    if (error == BMK_SEARCH_NO_ERROR) {
        
        _sellerNode.pt=result.location;
        _sellerNode.name=self.place;
        _sellerNode.cityName=self.city;
        
        BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
        item.coordinate = result.location;
        [_mapView addAnnotation:item];
        [_mapView setCenterCoordinate:result.location animated:YES];
        
        BMKReverseGeoCodeSearchOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeSearchOption alloc]init];
        reverseGeoCodeSearchOption.location = result.location;
        BOOL flag = [_searcher reverseGeoCode:reverseGeoCodeSearchOption];
        if(flag)
        {
            NSLog(@"反geo检索发送成功");
        }
        else
        {
            NSLog(@"反geo检索发送失败");
        }
    }
    else {
        NSLog(@"抱歉，未找到结果");
    }
}

-(void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeSearchResult *)result
                       errorCode:(BMKSearchErrorCode)error{
    if (error == BMK_SEARCH_NO_ERROR) {
        if (self.place.length>0) {
             _placeName.text=self.place;
        }
        else{
            self.place=result.businessCircle.length>0 ? result.businessCircle:result.addressDetail.streetName;
            _placeName.text=self.place;
        }
        _placeAddr.text=result.address;
        
        _sellerNode.name=self.place;
        _sellerNode.cityName=self.city.length>0 ? self.city:@"诸暨";
        
        NSLog(@"%@",result.address);
    }
    else {
        NSLog(@"抱歉，未找到结果");
    }
}

// 百度地图经纬度转换为高德地图经纬度
- (CLLocationCoordinate2D)getGaoDeCoordinateByBaiDuCoordinate:(CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(coordinate.latitude - 0.006, coordinate.longitude - 0.0065);
}

// 高德地图经纬度转换为百度地图经纬度
- (CLLocationCoordinate2D)getBaiDuCoordinateByGaoDeCoordinate:(CLLocationCoordinate2D)coordinate
{
    return CLLocationCoordinate2DMake(coordinate.latitude + 0.006, coordinate.longitude + 0.0065);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

