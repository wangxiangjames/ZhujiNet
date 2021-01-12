//
//  RootViewController.m
//  ZjzxApp
//
//  Created by chenjinwei on 17/3/17.
//  Copyright © 2017年 zhuji.net. All rights reserved.
//

#import "RootViewController.h"
#import "HomeViewController.h"
#import "BBSViewController.h"
#import "CircleViewController.h"
#import "ShopViewController.h"
#import "MineViewController.h"
#import "BBSMenuViewController.h"
#import "SearchViewController.h"
#import "ViewController.h"
#import "BbsForumModel.h"
#import "TXUGCPublish.h"
#import "WKWebViewController.h"
#import "LoginViewController.h"
#import "UpdatePhoneController.h"

@interface RootViewController ()<TXVideoPublishListener>{
    AppDelegate                 *_app;
    UIViewController            *_needCloseController;
    
    NSMutableDictionary         *_newPost;
    NSMutableArray              *_selectPhoto;
    NSInteger                   _currUploadNum;
    NSString                    *_imgid;
    
    //--------------------------------
    NSUInteger                  _fid;
    NSString                    *_title;
    NSString                    *_message;
    NSMutableArray              *_photos;
    BOOL                        _bUploadVideo;
    TXPublishResult*            _videoResult;
    
}

@end

@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _app = [AppDelegate getApp];
    _newPost= [NSMutableDictionary dictionary];
    _selectPhoto= [NSMutableArray arrayWithCapacity:9];
    _currUploadNum=0;
    _imgid=@"";
    _title=@"";
    _message=@"";
    _videoResult=[[TXPublishResult alloc]init];
    
    HomeViewController* one=[[HomeViewController alloc] init];
    one.tabBarItem=[[UITabBarItem alloc]initWithTitle:@"首页" image:[UIImage imageNamed:@"tab_home"] tag:0];
    one.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_home_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    BBSViewController* two=[[BBSViewController alloc] init];
    two.tabBarItem=[[UITabBarItem alloc]initWithTitle:@"论坛" image:[UIImage imageNamed:@"tab_bbs"] tag:1];
    two.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_bbs_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    CircleViewController* three=[[CircleViewController alloc] init];
    three.tabBarItem=[[UITabBarItem alloc]initWithTitle:@"诸暨圈" image:[UIImage imageNamed:@"tab_circle"] tag:2];
    three.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_circle_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    //ShopViewController* four=[[ShopViewController alloc] init];
    //four.tabBarItem=[[UITabBarItem alloc]initWithTitle:@"社区店" image:[UIImage imageNamed:@"tab_shop"] tag:3];
    //four.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_shop_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    WKWebViewController* four=[[WKWebViewController alloc] init];
    four.webUrl=URL_government;
    four.isHomeIndicator=YES;
    four.tabBarItem=[[UITabBarItem alloc]initWithTitle:@"政务" image:[UIImage imageNamed:@"tab_gov"] tag:3];
    four.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_gov_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    WKWebViewController* five=[[WKWebViewController alloc] init];
    five.webUrl=URL_service;
    five.isHomeIndicator=YES;
    five.tabBarItem=[[UITabBarItem alloc]initWithTitle:@"生活" image:[UIImage imageNamed:@"tab_service"] tag:4];
    five.tabBarItem.selectedImage = [[UIImage imageNamed:@"tab_service_select"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    self.viewControllers=@[one,two,three,four,five];
    
    //在滚动菜单导航UIScrollView将自动下移调整关掉
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self setNavAction:@"首页"];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    [self setNavAction:item.title];
    //self.navigationItem.title=item.title;
    switch (item.tag)
    {
        case 0:self.navigationItem.title=@"掌上诸暨";break;
        case 1:self.navigationItem.title=@"论坛";break;
        case 2:self.navigationItem.title=@"诸暨圈";break;
        case 3:self.navigationItem.title=@"政务";break;
        case 4:self.navigationItem.title=@"生活";
            break;
    }
    
    //NSLog(@"%ld",item.tag);
}

-(void)setNavAction:(NSString*)tabTitle{
    UIBarButtonItem *item=[[UIBarButtonItem alloc]
                           initWithImage:[UIImage imageNamed:@"nav_avatar"]
                           style:UIBarButtonItemStylePlain
                           target:self
                           action:@selector(navLeftMine:)];
    item.imageInsets = UIEdgeInsetsMake(2, 2, 2, 2);
    self.navigationItem.leftBarButtonItem =item;
    
    if ([tabTitle isEqualToString:@"首页"]) {
        UIBarButtonItem *item=[[UIBarButtonItem alloc]
                                   initWithImage:[UIImage imageNamed:@"nav_sou"]
                                   style:UIBarButtonItemStylePlain
                                   target:self
                                   action:@selector(navRightSearch:)];
        item.imageInsets = UIEdgeInsetsMake(2, 2, 2, 2);
        self.navigationItem.rightBarButtonItem =item;
    }
    
    if ([tabTitle isEqualToString:@"论坛"] || [tabTitle isEqualToString:@"社区店"]||[tabTitle isEqualToString:@"诸暨圈"]) {
        self.selectForumTitle=@"";
        
        NSString *imageNamed=@"nav_write";
        
        if ([tabTitle isEqualToString:@"论坛"]) {
            _imagePicketPageType=ImagePicket_bbs;
        }
        if ([tabTitle isEqualToString:@"社区店"]) {
            _imagePicketPageType=ImagePicket_shop;
        }
        if ([tabTitle isEqualToString:@"诸暨圈"]) {
            _imagePicketPageType=ImagePicket_circle;
            imageNamed=@"nav_photo";
        }
        
        UIBarButtonItem *item=[[UIBarButtonItem alloc]
                               initWithImage:[UIImage imageNamed:imageNamed]
                               style:UIBarButtonItemStylePlain
                               target:self
                               action:@selector(navBbsCircleShop:)];
        item.imageInsets = UIEdgeInsetsMake(2, 2, 2, 2);
        self.navigationItem.rightBarButtonItem =item;
    }
    
    if ([tabTitle isEqualToString:@"生活"]||[tabTitle isEqualToString:@"政务"]) {
        self.navigationItem.rightBarButtonItem =nil;
    }
}

- (void)navLeftMine:(id)sender
{    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleDone target:self action:nil];
    self.parentViewController.navigationItem.backBarButtonItem = backItem;
    [_app.user enterMineinfo:self];
}


- (void)navRightSearch:(id)sender
{
    SearchViewController *search=[[SearchViewController alloc]init];
    [self.navigationController pushViewController:search animated:TRUE];
}

-(void)navBbsCircleShop:(id)sender{
    if (_app.user.uid==0) {
        LoginViewController* login=[[LoginViewController alloc]init];
        [self.navigationController pushViewController:login animated:YES];
        return;
    }
    
    if (_app.user.uid>0 && ![CjwFun checkTelNumber:_app.user.mobile]) {
        UpdatePhoneController* updatePhone=[UpdatePhoneController new];
        updatePhone.isBindPage=YES;
        [self presentViewController:updatePhone animated:YES completion:nil];
    }
    
    [CjwFun selectImgCont:_imagePicketPageType
                      fid:0
                 topTitle:self.selectForumTitle
             withTextCont:nil
            viewController:self
              resultAcion:^(NSInteger fid,NSString *title,NSString *contnet,NSMutableArray *photos,NSString *videoUrl,NSInteger videoNum,UIImage* coverImg){
                  
                  _photos=photos;
                  _fid=fid;
                  _title=title;
                  _message=contnet;
                  
                  if (_imagePicketPageType==ImagePicket_circle) {
                      _title=contnet;
                  }
                  
                  [MBProgressHUD showMessage:@"请稍候"];
                  
                  if(videoNum==1){
                      _bUploadVideo=YES;
                      [CjwFun uploadVideo:videoUrl coverImage:coverImg delegate:self];
                  }
                  else{
                      _bUploadVideo=NO;
                      [self uploadContent:_photos forumId:_fid forumTitle:_title forumContent:_message videoUrl:nil];
                  }
              }];
}

-(void)uploadContent:(NSMutableArray*)photos forumId:(NSInteger) fid forumTitle:(NSString*)title forumContent:(NSString*)content videoUrl:(NSString*)vUrl {
    [_newPost removeAllObjects];
    [_selectPhoto removeAllObjects];
    [_selectPhoto addObjectsFromArray:photos];
    _currUploadNum=0;
    _imgid=@"";
    
    [_newPost setObject:@"newthread" forKey:@"action"];
    [_newPost setObject:NSString(fid) forKey:@"fid"];
    [_newPost setObject:title forKey:@"subject"];
    [_newPost setObject:content forKey:@"message"];
    if(vUrl){
        [_newPost setObject:vUrl forKey:@"videourl"];
    }
    
    if (_selectPhoto.count>_currUploadNum) {
        _currUploadNum=1;
        [self uploadImages:_selectPhoto[_currUploadNum-1]];
    }
    else{
        [CjwFun sendPost:_newPost isUplodVideo:_bUploadVideo uploadVideoResult:_videoResult viewController:self
               closeType:(_imagePicketPageType==ImagePicket_circle)?YES:NO];
    }
}

-(void)uploadImages:(UIImage*)image{
    [CjwFun uploadImage:image resultAcion:^(id responseObject){
        NSDictionary *dict = (NSDictionary *)responseObject;
        if ([dict objectForKey:@"data"]) {
            if ([_imgid isEqualToString:@""]) {
                _imgid=dict[@"data"][@"imgid"];
            }
            else{
                _imgid= [NSString stringWithFormat:@"%@|%@",_imgid,dict[@"data"][@"imgid"]];
            }
            
            if (_selectPhoto.count>_currUploadNum) {
                _currUploadNum++;
                [self uploadImages:_selectPhoto[_currUploadNum-1]];
            }
            else{
                [_newPost setObject:_imgid forKey:@"images"];
                [CjwFun sendPost:_newPost isUplodVideo:_bUploadVideo uploadVideoResult:_videoResult viewController:self
                       closeType:(_imagePicketPageType==ImagePicket_circle)?YES:NO];
            }
            NSLog(@"cjw:%@",_newPost);
        }
    }];
}

#pragma mark - TXVideoPublishListener
-(void) onPublishProgress:(NSInteger)uploadBytes totalBytes: (NSInteger)totalBytes
{
    NSLog(@"onPublishProgress [%ld/%ld]", (long)uploadBytes, (long)totalBytes);
}

-(void) onPublishComplete:(TXPublishResult*)result
{
    if (result.retCode != 0) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD toast:result.descMsg toView:self.view];
    }
    else{
        _videoResult=result;
        [self uploadContent:_photos forumId:_fid forumTitle:_title forumContent:_message videoUrl:result.videoURL];

        NSLog(@"onPublishComplete %@,%@,%@", result.videoId,result.videoURL, result.coverURL);
    }
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
