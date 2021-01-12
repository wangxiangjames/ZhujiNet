//
//  CjwCell.h
//  CjwSchool
//
//  Created by chenjinwei on 16/4/13.
//  Copyright © 2016年 chenjinwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CjwItem.h"
#import "FLAnimatedImageView+WebCache.h"
#import "SJPlayerSuperImageView.h"
@interface CjwNewsCell : UITableViewCell

@property (nonatomic,assign) NSInteger  padding;     //单元格縮近
@property (nonatomic,assign) CGFloat    height;      //单元格高度
@property (nonatomic,assign) NSInteger  type;       //单元格类别
@property (nonatomic,assign)    BOOL    isVideo;

@property (strong, nonatomic)  SJPlayerSuperImageView  *img0;
@property (strong, nonatomic)  FLAnimatedImageView  *img1;
@property (strong, nonatomic)  FLAnimatedImageView  *img2;
@property (strong, nonatomic)  UIImageView  *video;

@property (strong, nonatomic)  UILabel      *flag;      //标记类别
@property (strong, nonatomic)  UILabel      *title;
@property (strong, nonatomic)  UILabel      *subtitle;
@property (strong, nonatomic)  UILabel      *dateline;
@property (strong, nonatomic)  UILabel      *imginfo;   //图片信息  

+ (instancetype)creatWithNib :(NSString *)nibName inTableView :(UITableView *)tableView;
-(void)setItem:(CjwItem *)item;

@end
