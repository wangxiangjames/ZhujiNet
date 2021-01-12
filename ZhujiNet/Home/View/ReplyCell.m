//
//  CicleHeaderCell.m
//  ZhujiNet
//
//  Created by zhujiribao on 2017/7/31.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import "ReplyCell.h"
#import "Common.h"
#import "InsetLabel.h"

@interface ReplyCell()                                    //评论区单元格样式

@property (nonatomic, strong)UIImageView*   avatar;         //头像
@property (nonatomic, strong)UILabel*       username;       //用户名
@property (nonatomic, strong)UILabel*       level;          //级别
@property (nonatomic, strong)UILabel*       from;           //来自
@property (nonatomic, strong)UILabel*       dateline;       //时间
@property (nonatomic, strong)UIView*        userView;       //用户视图，用于点击
@property (nonatomic, strong)UIButton*      btnReply;       //回复按钮
@property (nonatomic, strong)UILabel*       content;        //内容
@property (nonatomic, strong)InsetLabel*    quote;          //引用
@property (nonatomic, strong)NSMutableArray *picViews;       //图片数组
@property (nonatomic, assign)NSInteger       numPic;         //图片数量
@end


@implementation ReplyCell

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
        
        self.userView=[[UIView alloc]init];
        [self.contentView addSubview:self.userView];
        
        self.avatar=[[UIImageView alloc]init];
        [self.avatar sd_setImageWithURL:[NSURL URLWithString:@"http://www.zhuji.net/pro/images/2017072730167823.jpg"]];
        self.avatar.layer.cornerRadius=20;
        self.avatar.layer.masksToBounds=YES;
        [self.userView addSubview:self.avatar];

        self.username=[[UILabel alloc]init];
        self.username.text=@"用户名";
        self.username.font=[UIFont systemFontOfSize:16];
        [self.userView addSubview:self.username];
        
        self.level=[[UILabel alloc]init];
        self.level.textColor=[UIColor redColor];
        self.level.text=@"LV12";
        self.level.font=[UIFont systemFontOfSize:10];
        self.level.textAlignment=NSTextAlignmentCenter;
        self.level.layer.cornerRadius=3;
        self.level.layer.masksToBounds=YES;
        [self.userView addSubview:self.level];
        
        self.from=[[UILabel alloc]init];
        self.from.textColor=[UIColor blackColor];
        self.from.text=@"诸暨网友";
        self.from.font=[UIFont systemFontOfSize:12];
        [self.userView addSubview:self.from];

        self.dateline=[[UILabel alloc]init];
        self.dateline.text=@"30分钟前";
        self.dateline.textColor=[UIColor blackColor];
        self.dateline.font=[UIFont systemFontOfSize:12];
        [self.userView addSubview:self.dateline];
        
        self.btnLike=[[UIButton alloc]init];
        [self.btnLike setTitle:@"赞" forState:UIControlStateNormal];
        self.btnLike.titleLabel.font=[UIFont systemFontOfSize:12];
        self.btnLike.titleEdgeInsets=UIEdgeInsetsMake(0, 10, 0, 0);
        [self.btnLike setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.btnLike setImage:[UIImage imageNamed:@"btn_no_zan"] forState:UIControlStateNormal];
        [self.btnLike addTarget:self action:@selector(btnLikeAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.btnLike];
        
        self.btnReply=[[UIButton alloc]init];
        [self.btnReply setTitle:@"回复" forState:UIControlStateNormal];
        [self.btnReply setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.btnReply.titleLabel.font=[UIFont systemFontOfSize:12];
        self.btnReply.titleEdgeInsets=UIEdgeInsetsMake(0, 10, 0, 0);
        [self.btnReply setImage:[UIImage imageNamed:@"remark"] forState:UIControlStateNormal];
        [self.btnReply addTarget:self action:@selector(btnReplyAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.btnReply];

        self.quote=[[InsetLabel alloc]init];
        self.quote.edgeInsets=UIEdgeInsetsMake(8, 8, 8, 8);
        self.quote.text=@"";
        self.quote.numberOfLines=0;
        self.quote.font=[UIFont systemFontOfSize:15];
        self.quote.textColor=[UIColor blackColor];
        self.quote.backgroundColor=[UIColor colorWithHexString:@"eeeeee"];
        [self.contentView addSubview:self.quote];
        
        self.content=[[UILabel alloc]init];
        self.content.text=@"";
        self.content.numberOfLines=0;
        self.content.font=[UIFont systemFontOfSize:17];
        [UILabel setLineSpaceForLabel:self.content withSpace:3];
        self.content.textColor=[UIColor blackColor];
        [self.contentView addSubview:self.content];
     
        self.picViews=[NSMutableArray arrayWithCapacity:3];
        for (int i=0; i<3; i++) {
            UIImageView *iv=[[UIImageView alloc]init];
            iv.hidden=YES;
            iv.contentMode=UIViewContentModeScaleToFill;
            iv.tag = i;
            iv.userInteractionEnabled = YES;
            [self.contentView addSubview:iv];
            [self.picViews addObject:iv];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageViewAction:)];
            [iv addGestureRecognizer:tap];
        }
        
        [self updateSkin];
        
    }
    return self;
}

-(void)updateSkin{
    CjwSkin* skin=[AppDelegate getApp].skin;
    
    self.backgroundColor=skin.colorCellBg;
    self.level.textColor=skin.colorMainLight;
    self.level.backgroundColor=skin.colorMainLight;
    self.level.textColor=skin.colorNavbar;
    self.username.textColor=skin.colorMainLight;
    self.from.textColor=skin.colorCellSubTitle;
    self.dateline.textColor=skin.colorCellSubTitle;
    self.content.textColor=skin.colorCellTitle;
}

-(void)setReplyModel:(ReplyModel *)reply{
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:reply.avatar]];
    self.username.text=[reply.author length]>0 ? reply.author :@"游客";
    self.dateline.text=reply.dateline;
    self.content.text=reply.message;
    self.quote.text=reply.quote;
    self.from.text=reply.area;
    if(self.quote.text.length>0){
        self.quote.hidden=NO;
    }
    else{
        self.quote.hidden=YES;
    }
    
    if(reply.level==0){
        self.level.hidden=YES;
    }
    else{
        self.level.text=[NSString stringWithFormat:@"LV%ld",reply.level];
        self.level.hidden=NO;
    }
    
    if (reply.support>0) {
        NSString *num=NSString(reply.support);
        [self.btnLike setTitle:num forState:UIControlStateNormal];
    }
    
    self.numPic=reply.imglist.count;
    if (self.numPic>3) {
        self.numPic=3;
    }
    NSLog(@"chenjinwei:%ld",self.numPic);
    
    for (int i=0; i<[self.picViews count]; i++) {
        UIImageView* iv=[self.picViews objectAtIndex:i];
        if(i<self.numPic){
            [iv sd_setImageWithURL:[NSURL URLWithString:[reply.imglist objectAtIndex:i]]
                  placeholderImage:[UIImage imageNamed:kImgHolder]
                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                             if(error){
                                 iv.image=[UIImage imageNamed:kImgHolder];
                             }
                         }
             ];
            iv.hidden=NO;
        }
        else{
            iv.hidden=YES;
        }
    }
}

- (void)setFrame:(CGRect)frame {
    frame.size.height=self.height;
    [super setFrame:frame];
}

- (CGFloat)height
{
    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];

    [self.username mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avatar.mas_right).offset(10);
        make.top.equalTo(self.avatar).offset(2);
    }];
    
    [self.level mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.username.mas_right).offset(6);
        make.top.equalTo(self.username).offset(3);
        make.size.mas_equalTo(CGSizeMake(36, 14));
    }];
    
    [self.from mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.username);
        make.top.equalTo(self.username.mas_bottom).offset(3);
    }];

    [self.dateline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.from.mas_right).offset(10);
        make.bottom.equalTo(self.from.mas_bottom);
    }];
    
    [self.userView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.top.mas_equalTo(12);
        make.bottom.mas_equalTo(self.avatar.mas_bottom);
        make.right.mas_equalTo(self.dateline);
    }];
    
    [self.btnReply mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-14);
        make.top.mas_equalTo(self.username).offset(-3);
        make.size.mas_equalTo(CGSizeMake(60, 30));
    }];

    [self.btnLike mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.btnReply.mas_left);
        make.top.mas_equalTo(self.btnReply);
        make.size.mas_equalTo(CGSizeMake(60, 30));
    }];

    [self.quote mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.username);
        make.top.equalTo(self.userView.mas_bottom).offset(10);
        make.width.mas_lessThanOrEqualTo([UIScreen mainScreen].bounds.size.width-78);
    }];
    
    if(self.quote.isHidden){
        [self.content mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.username);
            make.top.equalTo(self.userView.mas_bottom).offset(10);
            make.width.mas_lessThanOrEqualTo([UIScreen mainScreen].bounds.size.width-78);
        }];
    }
    else{
        [self.content mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.username);
            make.top.equalTo(self.quote.mas_bottom).offset(10);
            make.width.mas_lessThanOrEqualTo([UIScreen mainScreen].bounds.size.width-78);
        }];
    }
    
    CGFloat pictureWidth=[UIScreen mainScreen].bounds.size.width-78;
    
    for (int i=0; i<self.numPic; i++) {
        UIImageView* iv=self.picViews[i];
        iv.hidden=NO;
        [iv mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.avatar.mas_right).offset(6+i*pictureWidth/3);
            make.top.equalTo(self.content.mas_bottom).offset(14);
            make.width.mas_lessThanOrEqualTo(pictureWidth/3-2);
            make.height.mas_lessThanOrEqualTo(pictureWidth/3-2);
        }];
    }

    NSLog(@"abc:%@",self.quote.text);
    [self layoutIfNeeded];
    if (self.numPic>0) {
        return self.content.y+self.content.height+14+pictureWidth/3+10;
    }
    else{
        return self.content.y+self.content.height+14;
    }
}

-(void)btnLikeAction:(UIButton *)sender{
    if (self.blockLikeAction) {
        self.blockLikeAction(sender);
    }
    NSLog(@"like");
}

-(void)btnReplyAction:(UIButton *)sender{
    if (self.blockReplyAction) {
        self.blockReplyAction(sender);
    }
    NSLog(@"relply");
}

-(void)tapImageViewAction:(UITapGestureRecognizer*)gesture{
    if(self.blockTapImageViewAction){
        self.blockTapImageViewAction(gesture);
    }
}

@end
