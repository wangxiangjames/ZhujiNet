//
//  CjwSkin.m
//  CjwSchool
//
//  Created by chenjinwei on 16/3/20.
//  Copyright © 2016年 chenjinwei. All rights reserved.
//

#import "CjwSkin.h"
#import "Define.h"
#import "HexColor.h"

@interface CjwSkin(){
    UILabel* _lableTitle;
}
@end

@implementation CjwSkin

-(CjwSkin *)init{
    if(self=[super init]){
        [self setSkinDefault];
    }
    return self;
}


-(void)setSkinDefault{
    _curSkin=                   skin_type_default;
    _colorMain=                 [HXColor colorWithHexString:@"df3031"];
    _colorMainLight=            [HXColor colorWithHexString:@"FF8070"];
    _colorMainDark=             [HXColor colorWithHexString:@"4990E2"];
    
    _colorNavbar=               [HXColor colorWithHexString:@"ffffff"];
    _colorNavbarBg=             [HXColor colorWithHexString:@"df3031"];
    
    //_colorTabbar =            [HXColor colorWithHexString:@"888888"];
    _colorTabbarSelected=       [HXColor colorWithHexString:@"ff0000"];
    _colorTabbarBg=             [HXColor colorWithHexString:@"ffffff"];
    
    _colorCellTitle=            [HXColor colorWithHexString:@"222222"];
    _colorCellSubTitle=         [HXColor colorWithHexString:@"999999"];
    _colorCellBg=               [HXColor colorWithHexString:@"ffffff"];
    _colorCellSelectBg=         [HXColor colorWithHexString:@"eeeeee"];
    _colorCellSeparator=        [HXColor colorWithHexString:@"e2e2e2"];
    
    _colorImgBorder=            [HXColor colorWithHexString:@"efefef"];
    _colorImginfo=              [HXColor colorWithHexString:@"ffffff"];
    _colorImginfoBg=            [HXColor colorWithHexString:@"000000" alpha:0.5];
    
    _floatImgAlpha=             1;
    _floatImgBorderWidth=       0.5;
    
    _colorViewBg=               [HXColor colorWithHexString:@"ffffff"];
    _colorTableBg=              [HXColor colorWithHexString:@"f2f2f2"];
    _colorGridMenuText=         [HXColor colorWithHexString:@"222222"];
    
    _colorButton=               [HXColor colorWithHexString:@"222222"];
    _colorButtonMain=           [HXColor colorWithHexString:@"ff0000"];
    _colorButtonMainLight=      [HXColor colorWithHexString:@"ffffff"];
    
    _floatSeparatorSpaceHeight=5;
}


-(void)setSkinNight{
    _curSkin=                   skin_type_night;
    
    _colorMain=                 [HXColor colorWithHexString:@"650000"];
    _colorMainLight=            [HXColor colorWithHexString:@"FF8070" alpha:0.5];
    
    _colorNavbar=               [HXColor colorWithHexString:@"959595"];
    _colorNavbarBg=             [HXColor colorWithHexString:@"650000"];
    
    //_colorTabbar =            [HXColor colorWithHexString:@"888888"];
    _colorTabbarSelected=       [HXColor colorWithHexString:@"935656"];
    _colorTabbarBg=             [HXColor colorWithHexString:@"0c0c0c"];
    
    _colorCellTitle=            [HXColor colorWithHexString:@"666666"];
    _colorCellSubTitle=         [HXColor colorWithHexString:@"666666"];
    _colorCellBg=               [HXColor colorWithHexString:@"252525"];
    _colorCellSelectBg=         [HXColor colorWithHexString:@"3f3f3f"];
    _colorCellSeparator=        [HXColor colorWithHexString:@"464646"];
    
    _colorImgBorder=            [HXColor colorWithHexString:@"464646"];
    _colorImginfo=              [HXColor colorWithHexString:@"999999"];
    _floatImgAlpha=             0.35;
    _floatImgBorderWidth=       0.5;
    
    _colorViewBg=               [HXColor colorWithHexString:@"cccccc"];
    _colorTableBg=              [HXColor colorWithHexString:@"1c1c1c"];
    _colorGridMenuText=         [HXColor colorWithHexString:@"666666"];
    
    _colorButton=               [HXColor colorWithHexString:@"cccccc"];
    _colorButtonMain=           [HXColor colorWithHexString:@"ffaaaa"];
    _colorButtonMainLight=      [HXColor colorWithHexString:@"dddddd"];
    
    _floatSeparatorSpaceHeight=5;
}


-(void)setSkin:(UIViewController *)viewController{
    //--------------修改状态栏高亮---------------
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    viewController.navigationController.navigationBar.barStyle = UIStatusBarStyleLightContent;
    [viewController.parentViewController.tabBarController setNeedsStatusBarAppearanceUpdate];
    
    //--------------导航栏标题，大小，颜色---------------
    UINavigationController * navigation=viewController.parentViewController.navigationController;
    if (navigation==nil) {
        navigation=viewController.navigationController;
    }
    viewController.navigationController.navigationBar.tintColor = self.colorNavbar;
    viewController.parentViewController.title = viewController.tabBarController.tabBar.selectedItem.title;
    navigation.navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:self.colorNavbar,NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:21.0]};
    navigation.navigationBar.barTintColor=self.colorNavbarBg;
    navigation.navigationBar.translucent = NO;
    
    //--------------标签栏颜色---------------
    //viewController.tabBarController.tabBar.backgroundColor=self.colorTabbarBg;
    viewController.tabBarController.tabBar.tintColor=self.colorTabbarSelected;
    //[[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName:self.colorTabbar} forState:UIControlStateNormal];
    //[[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName:self.colorTabbarSelected} forState:UIControlStateSelected];
    [[UITabBar appearance] setBarTintColor:self.colorTabbarBg];
    //--------------控制器背景色---------------
    viewController.view.backgroundColor =self.colorViewBg;
}

//改变返回按钮文字，这里设置为空
//viewController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];

/*-(UILabel*)setTitle:(NSString *)title{
 if(_lableTitle==nil){
 _lableTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH-40 , 44)];
 _lableTitle.textColor=self.colorNavbar;
 _lableTitle.font=[UIFont systemFontOfSize:20.f];
 }
 _lableTitle.text=title;
 return _lableTitle;
 }*/


@end
