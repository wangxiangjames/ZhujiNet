//
//  CjwTabViewController.h
//  ZhujiNet
//
//  Created by zhujiribao on 2017/7/19.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Define.h"

@interface CjwTabViewController : UIViewController

@property (nonatomic ,strong) NSMutableArray   *menuArray;             /** 标签文字数组*/
@property (nonatomic, assign) BOOL              isShowSelectBtnLine;    /** 是否显示底线 */
@property (nonatomic ,strong) UIColor           *colorSelectBtnLine;    /** 底线颜色 */
@property (nonatomic ,strong) UIColor           *colorMidLine;          /** 中间线颜色 */
@property (nonatomic ,strong) UIColor           *colorMenuTitle;        /** 菜单文本颜色 */
@property (nonatomic ,strong) UIColor           *colorMenuTitleSelect;  /** 菜单文本选择颜色 */
@property (nonatomic ,strong) UIColor           *colorMenuBackground;   /** 菜单背景颜色 */
@property (nonatomic ,strong) UIColor           *colorMenuLine;         /** 菜单分割线颜色 */
@property (nonatomic ,strong) UIButton          *btnMore;               /** 更多按钮 */
@property (nonatomic ,assign) CGFloat           minButtonWidth;         /** 按钮最小宽度 */
@property (nonatomic ,assign) CGFloat           bottomLineWidth;        /** 底线长度，若为0，跟按钮长度相同 */
@property (nonatomic ,assign) CGFloat           titleFontSize;          /** 字体大小 */
@property (nonatomic ,assign) CGFloat           menuHeight;             /** 导航菜单高度  */
@property (nonatomic, assign) NSInteger         curIndex;               /** 当前的 */

-(void)addChildViewController;
-(void)setTabMenu:(NSInteger)index;
-(void)updateTabMenu;

@end
