//
//  ViewController.m
//  ZhujiNet
//
//  Created by zhujiribao on 2017/7/18.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import "ViewController.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>

@interface ViewController ()<BMKMapViewDelegate,BMKGeoCodeSearchDelegate,BMKLocationServiceDelegate>{
    BMKMapView* _mapView;
    BMKGeoCodeSearch* _searcher;
    BMKLocationService* _locService;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor whiteColor];
    
    _mapView = [[BMKMapView alloc]initWithFrame:self.view.bounds];
    self.view = _mapView;
    
    _mapView.showsUserLocation = YES;//显示定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态为普通定位模式
    [_mapView setZoomLevel:18.0];
    
    //-----------------------------------------
    /*_locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    //启动LocationService
    [_locService startUserLocationService];*/
    
    //-----------------------------------------
   _searcher =[[BMKGeoCodeSearch alloc]init];
    _searcher.delegate = self;
    //发起地理位置检索
    BMKGeoCodeSearchOption *geoCodeSearchOption = [[BMKGeoCodeSearchOption alloc]init];
    geoCodeSearchOption.address = @"人民医院";
    geoCodeSearchOption.city = @"诸暨";
    BOOL flag = [_searcher geoCode:geoCodeSearchOption];
    if(flag)
    {
        NSLog(@"geo检索发送成功");
    }
    else
    {
        NSLog(@"geo检索发送失败");
    }
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    _mapView.delegate = nil; // 此处记得不用的时候需要置nil，否则影响内存的释放
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _searcher.delegate = nil;
}

//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [_locService stopUserLocationService];
    /*BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
    item.coordinate = userLocation.location.coordinate;
    [_mapView addAnnotation:item];
    [_mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
     */
    NSLog(@"%@",userLocation.title);
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
}

//返回地址信息搜索结果
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeSearchResult *)result errorCode:(BMKSearchErrorCode)error {
    if (error == BMK_SEARCH_NO_ERROR) {
        //NSLog(@"search:%@",result);
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
        
        
        //CLLocationCoordinate2D coor;
        //coor.latitude = result.location.latitude;
        //coor.longitude = result.location.longitude;
        //[_mapView setCenterCoordinate:coor animated:YES];
        
        //[self openMapDrivingRoute];

        BMKOpenDrivingRouteOption *opt = [[BMKOpenDrivingRouteOption alloc] init];
        opt.appScheme = @"baidumapsdk://mapsdk.baidu.com";
        
        BMKPlanNode* start = [[BMKPlanNode alloc]init];
        //指定起点经纬度
        start.name = @"诸暨报业大楼";
        start.cityName = @"诸暨";
        //指定起点
        opt.startPoint = start;
        
        //初始化终点节点
        BMKPlanNode* end = [[BMKPlanNode alloc]init];
        end.pt = result.location;
        //指定终点名称
        end.name = @"人民医院";
        end.cityName = @"诸暨";
        opt.endPoint = end;
        BMKOpenErrorCode code = [BMKOpenRoute openBaiduMapDrivingRoute:opt];
        NSLog(@"%d", code);
    }
    else {
        NSLog(@"抱歉，未找到结果");
    }
}

-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeSearchResult *)result
                        errorCode:(BMKSearchErrorCode)error{
    if (error == BMK_SEARCH_NO_ERROR) {
        NSLog(@"成%@",result.businessCircle);
    }
    else {
        NSLog(@"抱歉，未找到结果");
    }
}

//打开地图 驾车路线检索
- (void)openMapDrivingRoute {
    BMKOpenDrivingRouteOption *opt = [[BMKOpenDrivingRouteOption alloc] init];
    //    opt.appName = @"SDK调起Demo";
    opt.appScheme = @"baidumapsdk://mapsdk.baidu.com";
    //初始化起点节点
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    //指定起点经纬度
    CLLocationCoordinate2D coor1;
    coor1.latitude = 39.90868;
    coor1.longitude = 116.204;
    //指定起点名称
    start.name = @"西直门";
    start.cityName = @"";
    //指定起点
    opt.startPoint = start;
    
    //初始化终点节点
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    CLLocationCoordinate2D coor2;
    coor2.latitude = 39.90868;
    coor2.longitude = 116.3956;
    end.pt = coor2;
    //指定终点名称
    end.name = @"天安门";
    end.cityName = @"北京";
    opt.endPoint = end;
    BMKOpenErrorCode code = [BMKOpenRoute openBaiduMapDrivingRoute:opt];
    NSLog(@"%d", code);
    return;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
