//
//  CicleHeaderCell.m
//  ZhujiNet
//
//  Created by zhujiribao on 2017/7/31.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import "ShopCell.h"
#import "Common.h"

@interface ShopCell()                                    //评论区单元格样式

@property (nonatomic, strong)UIImageView*       avatar;         //头像
@property (nonatomic, strong)UILabel*           username;       //用户名
@property (nonatomic, strong)UILabel*           readnum;        //阅读数
@property (nonatomic, strong)UILabel*           from;           //来自
@property (nonatomic, strong)UILabel*           dateline;       //时间
@property (nonatomic, strong)UIView*            userView;       //用户视图，用于点击
@property (nonatomic, strong)UIButton*          btnLike;        //点赞按钮
@property (nonatomic, strong)UIButton*          btnReply;       //回复按钮
@property (nonatomic, strong)UIButton*          btnShare;       //分享按钮
@property (nonatomic, strong)UILabel*           content;        //内容
@property (nonatomic, strong)NSMutableArray*    picViews;       //图片数组
@property (nonatomic, assign)NSInteger          numPic;         //图片数量
@property (nonatomic, strong)UIView*            separator;      //水平分割线

@end


@implementation ShopCell

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
        //self.userView.backgroundColor=[UIColor redColor];
        [self.contentView addSubview:self.userView];
        
        self.avatar=[[UIImageView alloc]init];
        self.avatar.layer.cornerRadius=20;
        self.avatar.layer.masksToBounds=YES;
        [self.userView addSubview:self.avatar];

        self.username=[[UILabel alloc]init];
        self.username.text=@"用户名";
        self.username.font=[UIFont systemFontOfSize:16];
        [self.userView addSubview:self.username];
        
        self.readnum=[[UILabel alloc]init];
        self.readnum.text=@"阅读数";
        self.readnum.textColor=[UIColor blackColor];
        self.readnum.font=[UIFont systemFontOfSize:12];
        [self.userView addSubview:self.readnum];
        
        self.dateline=[[UILabel alloc]init];
        self.dateline.text=@"30分钟前";
        self.dateline.textColor=[UIColor blackColor];
        self.dateline.font=[UIFont systemFontOfSize:12];
        [self.userView addSubview:self.dateline];
        
        self.from=[[UILabel alloc]init];
        self.from.textColor=[UIColor redColor];
        self.from.font=[UIFont systemFontOfSize:14];
        self.from.text=@"";
        [self.contentView addSubview:self.from];
        
        self.btnLike=[[UIButton alloc]init];
        [self.btnLike setTitle:@"赞" forState:UIControlStateNormal];
        self.btnLike.titleLabel.font=[UIFont systemFontOfSize:15];
        self.btnLike.titleEdgeInsets=UIEdgeInsetsMake(0, 10, 0, 0);
        [self.btnLike setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.btnLike setImage:[UIImage imageNamed:@"btn_no_zan"] forState:UIControlStateNormal];
        [self.btnLike addTarget:self action:@selector(actionLike:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.btnLike];
        
        self.btnReply=[[UIButton alloc]init];
        [self.btnReply setTitle:@"回帖" forState:UIControlStateNormal];
        [self.btnReply setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.btnReply.titleLabel.font=[UIFont systemFontOfSize:15];
        self.btnReply.titleEdgeInsets=UIEdgeInsetsMake(0, 10, 0, 0);
        [self.btnReply setImage:[UIImage imageNamed:@"remark"] forState:UIControlStateNormal];
        [self.btnReply addTarget:self action:@selector(actionReply:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.btnReply];

        self.btnShare=[[UIButton alloc]init];
        [self.btnShare setTitle:@"分享" forState:UIControlStateNormal];
        [self.btnShare setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.btnShare.titleLabel.font=[UIFont systemFontOfSize:15];
        self.btnShare.titleEdgeInsets=UIEdgeInsetsMake(0, 10, 0, 0);
        [self.btnShare setImage:[UIImage imageNamed:@"remark"] forState:UIControlStateNormal];
        [self.btnShare addTarget:self action:@selector(actionShare:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.btnShare];
        
        self.content=[[UILabel alloc]init];
        self.content.text=@"点赞在英语里没有这个词，不过在Facebook和Twitter上有点赞的功能，也就是一个大拇指朝上的按钮，外国人称它为thumb up，所以点赞也就是thumb up，thumb大拇指的意思，up也就是上的";
        self.content.numberOfLines=0;
        self.content.font=[UIFont systemFontOfSize:17];
        [UILabel setLineSpaceForLabel:self.content withSpace:3];
        self.content.textColor=[UIColor blackColor];
        [self.contentView addSubview:self.content];
     
        self.picViews=[NSMutableArray arrayWithCapacity:9];
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
        
        self.separator=[[UIView alloc]init];
        self.separator.backgroundColor=[UIColor colorWithHexString:@"eeeeee"];
        [self.contentView addSubview:self.separator];
        
        [self updateSkin];
    }
    return self;
}

-(void)updateSkin{
    CjwSkin* skin=[AppDelegate getApp].skin;
    
    self.backgroundColor=skin.colorCellBg;
    self.avatar.layer.borderColor=skin.colorImgBorder.CGColor;
    self.avatar.layer.borderWidth=0.5;
    self.username.textColor=skin.colorMainLight;
    self.dateline.textColor=skin.colorCellSubTitle;
    self.readnum.textColor=skin.colorCellSubTitle;
    self.content.textColor=skin.colorCellTitle;
    self.from.textColor=skin.colorMain;
    for (int i=0; i<[self.picViews count]; i++) {
        UIImageView* iv=[self.picViews objectAtIndex:i];
        iv.layer.borderColor=skin.colorImgBorder.CGColor;
        iv.layer.borderWidth=0.5;
        
    }
}

- (void)setFrame:(CGRect)frame {
    frame.size.height=self.height;
    self.forum.cellHeight=self.height;

    [super setFrame:frame];
}

-(void)setForum:(ForumModel *)forum{
    CjwSkin* skin=[AppDelegate getApp].skin;
    
    self.username.text=forum.author;
    self.dateline.text=forum.dateline;
    self.content.text=forum.subject;
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:forum.avatar]];
    self.readnum.text=[NSString stringWithFormat:@"%@阅读",forum.views];
    
    self.from.text=[NSString stringWithFormat:@"来自%@",forum.name];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:self.from.text];
    NSRange range = NSMakeRange(0, 2);
    [attrStr addAttribute:NSForegroundColorAttributeName value:skin.colorCellSubTitle range:range];
    self.from.attributedText=attrStr;
    
    self.numPic=[forum.imagelist count];
    if(self.numPic>3){
        self.numPic=3;
    }
    for (int i=0; i<[self.picViews count]; i++) {
        UIImageView* iv=[self.picViews objectAtIndex:i];
        if(i<self.numPic){
            [iv sd_setImageWithURL:[NSURL URLWithString:[forum.imagelist objectAtIndex:i]]
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

- (CGFloat)height
{
    CGFloat contentWidth=[UIScreen mainScreen].bounds.size.width-28;
    CGFloat pictureWidth=contentWidth;
    
    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];

    [self.username mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avatar.mas_right).offset(10);
        make.top.equalTo(self.avatar).offset(3);
    }];
    
    [self.dateline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.username);
        make.top.equalTo(self.username.mas_bottom).offset(3);
    }];

    [self.readnum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.dateline.mas_right).offset(10);
        make.top.equalTo(self.username.mas_bottom).offset(2);
     }];
    
    [self.userView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.top.mas_equalTo(14);
        make.bottom.mas_equalTo(self.avatar.mas_bottom);
        make.right.mas_equalTo(self.dateline);
    }];
    
    [self.from mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-14);
        make.top.mas_equalTo(self.username);
    }];
    
    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.top.equalTo(self.userView.mas_bottom).offset(10);
        make.width.mas_lessThanOrEqualTo(contentWidth);
    }];
    
    //-----------------------------------------------------
    for (int i=0; i<self.numPic; i++) {
        UIImageView* iv=self.picViews[i];
        [iv mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.userView.mas_left).offset(i*pictureWidth/3);
            make.top.equalTo(self.content.mas_bottom).offset(14);
            make.width.mas_lessThanOrEqualTo(pictureWidth/3-2);
            make.height.mas_lessThanOrEqualTo(pictureWidth/3-2);
        }];
    }
    //-----------------------------------------------------
    [self.separator mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.content);
        if(self.numPic <=0){
            make.top.mas_equalTo(self.content.mas_bottom).offset(14);
        }
        else{
            make.top.mas_equalTo(self.content.mas_bottom).offset(pictureWidth/3+28);
        }
        make.size.mas_equalTo(CGSizeMake(pictureWidth, 1));
    }];
    
    CGFloat offset=(pictureWidth/3-80);
    [self.btnShare mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.separator).offset(offset/2);
        make.top.mas_equalTo(self.separator).offset(2);
        make.size.mas_equalTo(CGSizeMake(80, 40));
    }];
   
    [self.btnReply mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.btnShare.mas_right).offset(offset);
        make.top.mas_equalTo(self.btnShare);
        make.size.mas_equalTo(CGSizeMake(80, 40));
    }];

    [self.btnLike mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.btnReply.mas_right).offset(offset);
        make.top.mas_equalTo(self.btnShare);
        make.size.mas_equalTo(CGSizeMake(80, 40));
    }];
    
    [self layoutIfNeeded];
    return self.btnShare.y+self.btnShare.height+2;
}

-(void)tapImageViewAction:(UITapGestureRecognizer*)gesture{
    if(self.blockTapImageViewAction){
        self.blockTapImageViewAction(gesture);
    }
}

-(void)actionLike:(id)sender{
    if(self.blockLikeAction){
        self.blockLikeAction(sender);
    }
}

-(void)actionShare:(id)sender{
    if(self.blockShareAction){
        self.blockShareAction(sender);
    }
}

-(void)actionReply:(id)sender{
    if(self.blockReplyAction){
        self.blockReplyAction(sender);
    }
}

@end
