//
//  CjwSkin.h
//  CjwSchool
//
//  Created by chenjinwei on 16/3/20.
//  Copyright © 2016年 chenjinwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIColor.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, skin_type)
{
    //以下是枚举成员
    skin_type_default = 0,                  //默认菜单
    skin_type_night = 1,                    //夜间模式
};

@interface CjwSkin : NSObject

@property (nonatomic,strong) UIColor* colorMain;            //主色
@property (nonatomic,strong) UIColor* colorMainLight;       //浅主色
@property (nonatomic,strong) UIColor* colorMainDark;        //暗主色

@property (nonatomic,strong) UIColor* colorButtonMain;      //按钮文本主色    :红色
@property (nonatomic,strong) UIColor* colorButton;          //默认按钮文本颜色: 黑色
@property (nonatomic,strong) UIColor* colorButtonMainLight; //默认按钮文本颜色: 白色

@property (nonatomic,strong) UIColor* colorNavbar;          //导航栏文字颜色
@property (nonatomic,strong) UIColor* colorNavbarBg;        //导航栏背景色

@property (nonatomic,strong) UIColor* colorTabbar;          //标签栏默认文字颜色
@property (nonatomic,strong) UIColor* colorTabbarSelected;  //标签栏选中文字颜色
@property (nonatomic,strong) UIColor* colorTabbarBg;        //标签栏背景色

@property (nonatomic,strong) UIColor* colorCellTitle;       //表格标题
@property (nonatomic,strong) UIColor* colorCellSubTitle;    //表格副标题
@property (nonatomic,strong) UIColor* colorCellSeparator;   //表格间隔线
@property (nonatomic,strong) UIColor* colorCellBg;          //单元格背景色
@property (nonatomic,strong) UIColor* colorCellSelectBg;    //单元格选中背景色

@property (nonatomic,strong) UIColor* colorGridMenuText;    //滑动菜单文本色
@property (nonatomic,strong) UIColor* colorViewBg;          //视图背景色
@property (nonatomic,strong) UIColor* colorTableBg;          //视图背景色

@property (nonatomic,strong) UIColor* colorImgBorder;       //图片边框线色
@property (nonatomic,strong) UIColor* colorImginfo;         //图片附加信息色
@property (nonatomic,strong) UIColor* colorImginfoBg;       //图片附加背景色

@property (nonatomic,assign) CGFloat floatImgAlpha;         //图片透明度
@property (nonatomic,assign) CGFloat floatImgBorderWidth;   //图片边框线宽度大小



@property (nonatomic,strong) UIColor* colorNavMenu;         //导航菜单文字颜色
@property (nonatomic,strong) UIColor* colorNavMenuBg;       //导航菜单背景色
@property (nonatomic,strong) UIColor* colorNavMenuLine;     //导航菜单线条颜色


@property (nonatomic,assign) CGFloat floatSeparatorSpaceHeight;    //表格间隔空间高度
@property (nonatomic,assign) skin_type curSkin;                     //当前肤色

-(void)setSkin:(UIViewController *)viewController;
-(void)setSkinDefault;
-(void)setSkinNight;
    
//-(UIButton*)setTitle:(NSString *)title;

@end
