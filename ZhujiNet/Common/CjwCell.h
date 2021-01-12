//
//  CjwCell.h
//  CjwSchool
//
//  Created by chenjinwei on 16/4/13.
//  Copyright © 2016年 chenjinwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CjwItem.h"

/*
 2017.7.18  modfiy
 */
typedef NS_ENUM(NSInteger, cell_type)
{
    //以下是枚举成员
    cell_type_menu = 0,                     //默认菜单
    cell_type_news_text = 1,                //新闻类别_文本模式
    cell_type_news_pic_one= 2,              //新闻类别_单图模式
    cell_type_news_pic_three = 3,           //新闻类别_3图模式
    cell_type_news_pic_one_big = 4,         //新闻类别_大图模式
    cell_type_news_pic_one_ad = 5,          //广告模式
    
    cell_type_menu_bbs_left = 20,           //社区版块菜单左侧
    cell_type_menu_bbs_right = 21,          //社区版块菜单右侧
    cell_type_text_one=22,                  //相关阅读栏目名称
    cell_type_text_one_end=23,
    cell_type_pic_one=24,                   //相关阅读
    cell_type_comment=25,                   //评论区
    cell_type_mine=26,
    cell_type_mine_score=27,
    cell_type_mine_base_text=28,
    cell_type_mine_base_pic=29,
    cell_type_mine_login=30,
};

@interface CjwCell : UITableViewCell

@property (nonatomic,assign) NSInteger  padding;     //单元格縮近
@property (nonatomic,assign) CGFloat    height;      //单元格高度
@property (nonatomic,assign) NSInteger  type;       //单元格类别
@property (nonatomic,assign) BOOL       isVideo;

@property (strong, nonatomic) IBOutlet UIImageView  *img0;
@property (strong, nonatomic) IBOutlet UIImageView  *img1;
@property (strong, nonatomic) IBOutlet UIImageView  *img2;
@property (strong, nonatomic) IBOutlet UIImageView  *video;

@property (strong, nonatomic) IBOutlet UILabel      *title;
@property (strong, nonatomic) IBOutlet UILabel      *subtitle;
@property (strong, nonatomic) IBOutlet UILabel      *level;     //级别
@property (strong, nonatomic) IBOutlet UILabel      *rank;      //军衔
@property (strong, nonatomic) IBOutlet UILabel      *flag;      //标记类别
@property (strong, nonatomic) IBOutlet UILabel      *dateline;
@property (strong, nonatomic) IBOutlet UILabel      *imginfo;   //图片信息
//@property (strong, nonatomic) IBOutlet UIButton    *btn;

+ (instancetype)creatWithNib :(NSString *)nibName inTableView :(UITableView *)tableView;
-(void)setItem:(CjwItem *)item;

@end
