//
//  CicleHeaderCell.m
//  ZhujiNet
//
//  Created by zhujiribao on 2017/7/31.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import "CircleHeaderCell.h"
#import "Common.h"

@interface CircleHeaderCell()                                //诸暨圈头部单元格样式

@property (nonatomic, strong)UILabel*       titleOne;       //标题1
@property (nonatomic, strong)UIImageView*   like;           //点赞图标
@property (nonatomic, strong)UIView*        separator;      //水平分割线
@property (nonatomic, strong)UIView*        vline_1;        //竖线1
@property (nonatomic, strong)UIView*        vline_2;        //竖线2
@property (nonatomic, strong)UILabel*       titleTwo;       //标题2

@end


@implementation CircleHeaderCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleOne=[[UILabel alloc]init];
        self.titleOne.text=@"热门圈子";
        self.titleOne.textColor=[UIColor blackColor];
        [self.contentView addSubview:self.titleOne];
    
        self.menuPicScroll=[[PicScroll alloc]initWithFrame:CGRectMake(0, 0, 0, 0) wihtHeight:78];
        [self.contentView addSubview:self.menuPicScroll];
        
        self.separator=[[UIView alloc]init];
        self.separator.backgroundColor=[UIColor colorWithHexString:@"e2e2e2"];
        [self.contentView addSubview:self.separator];
        
        self.titleTwo=[[UILabel alloc]init];
        self.titleTwo.text=@"今日热门";
        self.titleTwo.textColor=[UIColor blackColor];
        [self.contentView addSubview:self.titleTwo];
        
        self.vline_1=[[UIView alloc]init];
        self.vline_1.backgroundColor=[UIColor redColor];
        [self.contentView addSubview:self.vline_1];
   
        self.vline_2=[[UIView alloc]init];
        self.vline_2.backgroundColor=[UIColor redColor];
        [self.contentView addSubview:self.vline_2];
        
        self.hotPicScroll=[[PicScroll alloc]initWithFrame:CGRectMake(0, 0, 0, 0) wihtHeight:140];
        [self.contentView addSubview:self.hotPicScroll];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    frame.size.height=self.height;
    [super setFrame:frame];
}

- (CGFloat)height
{
    [self.vline_1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.top.mas_equalTo(14);
        make.size.mas_equalTo(CGSizeMake(3, 20));
    }];
    
    [self.titleOne mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.vline_1.mas_right).offset(14);
        make.top.mas_equalTo(self.vline_1.mas_top);
    }];
    
    [self.menuPicScroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.vline_1.mas_left);
        make.top.equalTo(self.vline_1.mas_bottom).offset(14);
        make.right.equalTo(self.contentView.mas_right).offset(-14);
        make.height.mas_equalTo(self.menuPicScroll.contentSize.height);
    }];
    
    [self.separator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.menuPicScroll.mas_bottom).offset(5);
        make.height.mas_equalTo(5);
    }];
    
    [self.vline_2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.top.mas_equalTo(self.separator.mas_top).offset(14);
        make.size.mas_equalTo(CGSizeMake(3, 20));
    }];
    
    [self.titleTwo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.vline_2.mas_right).offset(14);
        make.top.equalTo(self.vline_2.mas_top);
        make.width.mas_lessThanOrEqualTo([UIScreen mainScreen].bounds.size.width-80);
    }];
    
    [self.hotPicScroll mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.vline_2.mas_left);
        make.top.equalTo(self.vline_2.mas_bottom).offset(14);
        make.right.equalTo(self.contentView.mas_right).offset(-14);
        make.height.mas_equalTo(self.hotPicScroll.contentSize.height);
    }];
    
    [self layoutIfNeeded];
    return self.hotPicScroll.y+self.hotPicScroll.height+14;
}

-(void)actionWalk:(id)sender{
    if(self.blockWalkAction){
        self.blockWalkAction(sender);
    }
}

@end
