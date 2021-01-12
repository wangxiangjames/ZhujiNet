//
//  CjwGridMenu.h
//  ZhujiNet
//
//  Created by chenjinwei on 2017/6/2.
//  Copyright © 2017年 zhuji.net. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CjwGridMenu;

@protocol CjwGridMenuDataSource <NSObject>
@optional
/**
 提供数据的数量
 @param cjwGridMenu 控件本身
 @return 返回数量
 */
- (NSInteger)numberOfItemsInCjwGridMenu:(CjwGridMenu *)cjwGridMenu;

/**
 提供选项标题
 @param cjwGridMenu 当前控件
 @param index 选项下标
 @return 返回标题
 */
- (NSString *)cjwGridMenu:(CjwGridMenu *)cjwGridMenu titleForItemAtIndex:(NSInteger)index;

/**
 提供选项的图标地址路径
 @param cjwGridMenu 当前控件
 @param index 选项下标
 @return 返回图标路径
 */
- (NSURL *)cjwGridMenu:(CjwGridMenu *)cjwGridMenu iconURLForItemAtIndex:(NSInteger)index;

@end

//------------------------------------------------
@protocol CjwGridMenuDelegate <NSObject>
@optional
/**
 设置每页的行数 默认 2
 @param cjwGridMenu 当前控件
 @return 行数
 */
- (NSInteger)numberOfRowsPerPageInCjwGridMenu:(CjwGridMenu *)cjwGridMenu;

/**
 设置每页的列数 默认 4
 @param cjwGridMenu 当前控件
 @return 列数
 */
- (NSInteger)numberOfColumnsPerPageInCjwGridMenu:(CjwGridMenu *)cjwGridMenu;

/**
 当选项被点击回调
 @param cjwGridMenu 当前控件
 @param index 点击下标
 */
- (void)cjwGridMenu:(CjwGridMenu *)cjwGridMenu didSelectItemAtIndex:(NSInteger)index;

/**
 返回当前选中的pageControl 颜色
 @param cjwGridMenu 当前控件
 @return 颜色
 */
- (UIColor *)colorForCurrentPageControlInCjwGridMenu:(CjwGridMenu *)cjwGridMenu ;
@end

//------------------------------------------------
@interface CjwGridMenu : UIView
@property (weak, nonatomic) id<CjwGridMenuDataSource>   dataSource;
@property (weak, nonatomic) id<CjwGridMenuDelegate>     delegate;
@property (strong, nonatomic) UIImage                   *defaultImage;
@property (assign, nonatomic) NSUInteger                iconWidth;
@property (assign, nonatomic) CGFloat                   cornerRadius;
@property (nonatomic,strong) UIColor*                   colorText;
@property (nonatomic,assign) CGFloat                    iconAlpha;
//刷新
- (void)reloadData;

@end
