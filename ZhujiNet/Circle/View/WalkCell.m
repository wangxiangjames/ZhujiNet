//
//  WalkCell.m
//  ZhujiNet
//
//  Created by zhujiribao on 2017/8/11.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import "WalkCell.h"
#import "Common.h"

@interface WalkCell()                                    

@property (nonatomic, strong)UIImageView*   avatar;         //头像
@property (nonatomic, strong)UILabel*       username;       //用户名
@property (nonatomic, strong)UILabel*       rank;           //名次
@property (nonatomic, strong)UILabel*       score;          //分数
@property (nonatomic, strong)UILabel*       likeNum;        //点赞数
@property (nonatomic, strong)UIImageView*   like;           //头像

@end

@implementation WalkCell

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
        
        self.avatar=[[UIImageView alloc]init];
        [self.avatar sd_setImageWithURL:[NSURL URLWithString:@"http://www.zhuji.net/pro/images/2017072730167823.jpg"]];
        self.avatar.layer.cornerRadius=20;
        self.avatar.layer.masksToBounds=YES;
        [self.contentView addSubview:self.avatar];
        
        self.username=[[UILabel alloc]init];
        self.username.text=@"用户名";
        self.username.font=[UIFont systemFontOfSize:16];
        [self.contentView addSubview:self.username];
        
        self.rank=[[UILabel alloc]init];
        self.rank.textColor=[UIColor blackColor];
        self.rank.text=@"1";
        self.rank.font=[UIFont systemFontOfSize:16];
        self.rank.textAlignment=NSTextAlignmentCenter;
        [self.contentView addSubview:self.rank];
        
        self.score=[[UILabel alloc]init];
        self.score.textColor=[HXColor colorWithHexString:@"f0b050"];
        self.score.text=@"264";
        self.score.font=[UIFont systemFontOfSize:28];
        [self.contentView addSubview:self.score];
        
        self.likeNum=[[UILabel alloc]init];
        self.likeNum.text=@"3";
        self.likeNum.textColor=[UIColor lightGrayColor];
        self.likeNum.font=[UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.likeNum];
        
        self.like=[[UIImageView alloc]init];
        self.like.image=[UIImage imageNamed:@"danzan"];
        [self.contentView addSubview:self.like];
        
        [self updateSkin];
        
    }
    return self;
}

-(void)updateSkin{
    CjwSkin* skin=[AppDelegate getApp].skin;
    
    self.backgroundColor=skin.colorCellBg;
}

-(void)setItem:(CjwItem *)item{
    //CjwSkin* skin=[AppDelegate getApp].skin;
    //[self.avatar sd_setImageWithURL:[NSURL URLWithString:item.url_pic0]];
    //self.username.text=[item.subtitle length]>0 ? item.subtitle :@" ";
    self.rank.text=item.rank;
}


- (void)setFrame:(CGRect)frame {
    frame.size.height=self.height;
    [super setFrame:frame];
}

- (CGFloat)height
{
    [self.rank mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.rank.mas_right).offset(16);
        make.centerY.equalTo(self.contentView);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    [self.username mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avatar.mas_right).offset(16);
        make.centerY.equalTo(self.contentView);
    }];

    [self.like mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.centerY.equalTo(self.contentView).offset(10);
    }];
    [self.likeNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).offset(-23);
        make.centerY.equalTo(self.contentView).offset(-10);
    }];
    [self.score mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.like.mas_left).offset(-20);
        make.centerY.equalTo(self.contentView);
    }];
    
    [self layoutIfNeeded];
    return 60;
}


@end
