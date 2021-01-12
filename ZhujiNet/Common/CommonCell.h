//
//  CommonCell.h
//  ZhujiNet
//
//  Created by zhujiribao on 2018/3/7.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CjwItem.h"

typedef NS_ENUM(NSInteger, COMMON_CELL)
{
    CELL_SYSINFO=1,                         //系统信息
    CELL_SEARCH=2,                          //搜索
    CELL_SEARCH_USER=3,
    CELL_SEARCH_USER_MORE=4,
    CELL_MYTHEAD=5,                         //我的帖子
    CELL_SHANG=6,                           //打赏
    CELL_FOLLOW=7,                          //关注
    CELL_NEWS_ONE_IMG=8,                    //新闻样式：1图
    CELL_NEWS_THREE_IMG=9,                  //新闻样式：3图
    CELL_NEWS_TEXT=10                        //新闻样式：文本
};

@interface CommonCell : UITableViewCell

@property (nonatomic, assign) CGFloat  height;

-(void)setItem:(CjwItem *)item;
-(void)setArray:(NSArray *)anArray;

-(void)makeCellType:(COMMON_CELL)cellType;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier typeCell:(COMMON_CELL) cellType;
@property (nonatomic,copy) void(^blockBtnAction)(UIButton *sender);
@property (nonatomic,copy) void(^blockImageAction)(NSInteger row);
@end
