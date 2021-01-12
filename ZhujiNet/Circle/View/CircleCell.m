//
//  CicleHeaderCell.m
//  ZhujiNet
//
//  Created by zhujiribao on 2017/7/31.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import "CircleCell.h"
#import "Common.h"
#import "CircleReplyModel.h"
#import "LikeModel.h"

@interface CircleCell() {                                   //评论区单元格样式
    AppDelegate*   _app;
}
@property (nonatomic, strong)UIImageView*       avatar;         //头像
@property (nonatomic, strong)UILabel*           username;       //用户名
@property (nonatomic, strong)UILabel*           level;          //级别
@property (nonatomic, strong)UILabel*           from;           //来自
@property (nonatomic, strong)UILabel*           dateline;       //时间
@property (nonatomic, strong)UIView*            userView;       //用户视图，用于点击
@property (nonatomic, strong)UIButton*          btnLike;        //点赞按钮
@property (nonatomic, strong)UIButton*          btnReply;       //回复按钮
@property (nonatomic, strong)UIButton*          btnShare;       //分享按钮
@property (nonatomic, strong)UIButton*          btnLookAll;     //查看全部按钮
@property (nonatomic, strong)UIButton*          btnMore;        //更多按钮
@property (nonatomic, strong)UILabel*           content;        //内容
@property (nonatomic, strong)NSMutableArray*    picViews;       //图片数组
@property (nonatomic, assign)NSInteger          numPic;         //图片数量
@property (nonatomic, strong)UIView*            separator;      //水平分割线
@property (nonatomic, strong)UIView*            separator2;     //水平分割线
@property (nonatomic, strong)UILabel*           likelist;       //点赞
@property (nonatomic, strong)UILabel*           comment;        //评论
@property (nonatomic, strong)UIImageView*       ivLike;         //评论
@property (nonatomic, strong)UIView*            line1;
@property (nonatomic, strong)UIView*            line2;

@property (nonatomic, assign)NSInteger          img_width;
@property (nonatomic, assign)NSInteger          img_height;
@property (nonatomic, assign)NSInteger          postnum;
@property (nonatomic, assign)NSInteger          likenum;

@property (nonatomic, strong)UIImageView*       videoFlag;

@property (nonatomic, assign)BOOL               isVideo;
@end


@implementation CircleCell

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
        _app = [AppDelegate getApp];
        
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
        
        self.level=[[UILabel alloc]init];
        self.level.textColor=[UIColor redColor];
        self.level.text=@"LV12";
        self.level.font=[UIFont systemFontOfSize:10];
        self.level.textAlignment=NSTextAlignmentCenter;
        self.level.layer.cornerRadius=3;
        self.level.layer.masksToBounds=YES;
        [self.userView addSubview:self.level];
        
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
        
        self.btnMore=[[UIButton alloc]init];
        [self.btnMore setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.btnMore setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
        [self.btnMore addTarget:self action:@selector(actionMore:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.btnMore];
        
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
        [self.btnShare setImage:[UIImage imageNamed:@"circle_share"] forState:UIControlStateNormal];
        [self.btnShare addTarget:self action:@selector(actionShare:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.btnShare];
        
        self.line1=[[UIView alloc]init];
        self.line1.backgroundColor=[UIColor lightGrayColor];
        [self.contentView addSubview:self.line1];
        
        self.line2=[[UIView alloc]init];
        self.line2.backgroundColor=[UIColor lightGrayColor];
        [self.contentView addSubview:self.line2];
        
        self.content=[[UILabel alloc]init];
        self.content.text=@"";
        self.content.numberOfLines=0;
        self.content.font=[UIFont systemFontOfSize:17];
        [UILabel setLineSpaceForLabel:self.content withSpace:3];
        self.content.textColor=[UIColor blackColor];
        [self.contentView addSubview:self.content];
     
        self.picViews=[NSMutableArray arrayWithCapacity:9];
        for (int i=0; i<9; i++) {
            UIImageView *iv=[[UIImageView alloc]init];
            iv.hidden=YES;
            iv.contentMode=UIViewContentModeScaleAspectFill;
            iv.clipsToBounds = YES;
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

        self.ivLike=[[UIImageView alloc]init];
        self.ivLike.image=[UIImage imageNamed:@"btn_no_zan"];
        [self.contentView addSubview:self.ivLike];
        
        self.likelist=[[UILabel alloc]init];
        self.likelist.text=@"";
        self.likelist.numberOfLines=0;
        self.likelist.font=[UIFont systemFontOfSize:13];
        [UILabel setLineSpaceForLabel:self.content withSpace:3];
        self.likelist.textColor=[UIColor colorWithHexString:@"1b62f1"];
        [self.contentView addSubview:self.likelist];
        
        self.comment=[[UILabel alloc]init];
        self.comment.numberOfLines=0;
        self.comment.textColor=[UIColor blackColor];
        self.comment.font=[UIFont systemFontOfSize:14];
        self.comment.text=@"";
        [self.contentView addSubview:self.comment];
        
        self.separator2=[[UIView alloc]init];
        self.separator2.backgroundColor=[UIColor colorWithHexString:@"eeeeee"];
        [self.contentView addSubview:self.separator2];
        
        self.btnLookAll=[[UIButton alloc]init];
        [self.btnLookAll setTitle:@"查看全部(5)" forState:UIControlStateNormal];
        [self.btnLookAll setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.btnLookAll.titleLabel.font=[UIFont systemFontOfSize:15];
        [self.btnLookAll addTarget:self action:@selector(actionLookAll:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.btnLookAll];
        
        self.videoFlag=[[UIImageView alloc]init];
        self.videoFlag.image=[UIImage imageNamed:@"play"];
        self.videoFlag.contentMode=UIViewContentModeScaleToFill;
        [self.contentView addSubview:self.videoFlag];
        
        [self updateSkin];
    }
    return self;
}

-(void)updateSkin{
    CjwSkin* skin=[AppDelegate getApp].skin;
    
    self.backgroundColor=skin.colorCellBg;
    self.avatar.layer.borderColor=skin.colorImgBorder.CGColor;
    self.avatar.layer.borderWidth=0.5;
    self.level.textColor=skin.colorMainLight;
    self.level.backgroundColor=skin.colorMainLight;
    self.level.textColor=skin.colorNavbar;
    self.username.textColor=skin.colorCellTitle;
    self.dateline.textColor=skin.colorCellSubTitle;
    self.line1.backgroundColor=skin.colorCellSubTitle;
    self.line2.backgroundColor=skin.colorCellSubTitle;
    self.content.textColor=skin.colorCellTitle;
    self.from.textColor=skin.colorMainLight;
    for (int i=0; i<[self.picViews count]; i++) {
        UIImageView* iv=[self.picViews objectAtIndex:i];
        iv.layer.borderColor=skin.colorImgBorder.CGColor;
        iv.layer.borderWidth=0.5;
        
    }
}

/*- (void)layoutSubviews {
    [super layoutSubviews];
    [self height];
}*/

- (void)setFrame:(CGRect)frame {
    frame.size.height=self.height;
    [super setFrame:frame];
}

-(void)setCircleModel:(CircleModel *)circle{
    AppDelegate* _app=[AppDelegate getApp];
    CjwSkin* skin=_app.skin;
    
    if (![circle.videourl isEqualToString:@""]) {
        //circle.imglist=@[circle.videocover];
        circle.imglist=[[NSArray alloc]initWithObjects:circle.videocover, nil];
        self.isVideo=YES;
        self.videoFlag.hidden=NO;
        if (circle.img_width==0) {
            circle.img_width=400;
            circle.img_height=250;
        }
    }
    else{
        self.videoFlag.hidden=YES;
    }

    self.username.text=circle.author;
    self.level.text=[NSString stringWithFormat:@"LV%ld",circle.level ];
    self.dateline.text=circle.dateline;
    self.content.text=circle.title;
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:circle.avatar]];
    
    self.from.text=[NSString stringWithFormat:@"来自%@",circle.forumname];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:self.from.text];
    NSRange range = NSMakeRange(0, 2);
    [attrStr addAttribute:NSForegroundColorAttributeName value:skin.colorCellSubTitle range:range];
    self.from.attributedText=attrStr;
    //---------------------------------
    self.img_height=circle.img_height;
    self.img_width=circle.img_width;
    CGFloat pictureWidth=([UIScreen mainScreen].bounds.size.width-78)*2/3;
    if(self.img_width>pictureWidth){
        self.img_width=pictureWidth;
        self.img_height=circle.img_height*self.img_width/circle.img_width;
    }
    if (self.img_height>SCREEN_HEIGHT) {
        self.img_height=SCREEN_HEIGHT;
        self.img_width=circle.img_width*self.img_height/circle.img_height;
    }
    
    NSString* flage=@"，";
    NSString* likelist=@"";
    BOOL isHaveMyLike=NO;
    
    for(NSInteger i=0;i<[circle.likelist count];i++) {
        if(i==[circle.likelist count]-1){
            flage=@"";
        }
        LikeModel *like=[circle.likelist objectAtIndex:i];
        likelist=[NSString stringWithFormat:@"%@%@%@",likelist,like.username,flage];
        
        if (_app.user.uid==like.uid) {
            isHaveMyLike=YES;
        }
    }
    self.likelist.text=likelist;
    if (isHaveMyLike || [_app.locationLike  objectForKey: NSString(circle.tid])) {
        [self.btnLike setImage:[UIImage imageNamed:@"btn_zan"] forState:UIControlStateNormal];
    }
    else{
        [self.btnLike setImage:[UIImage imageNamed:@"btn_no_zan"] forState:UIControlStateNormal];
    }
    
    //NSString* strComment=@"小明说：点赞在英语里没有这个词\n小王说：不过在Facebook和Twitter上有点赞的功能，也就是一个大拇指朝上的按钮\n小李：外国人称它为thumb up，所以点赞";
    NSString* nr=@"\n";
    NSString* strComment=@"";
    for(NSInteger i=0;i<[circle.postlist count];i++) {
        if(i==[circle.postlist count]-1){
            nr=@"";
        }
        CircleReplyModel *reply=[circle.postlist objectAtIndex:i];
        strComment=[NSString stringWithFormat:@"%@%@：%@%@",strComment,reply.username,reply.comment,nr];
    }
    attrStr = [[NSMutableAttributedString alloc] initWithString:strComment];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:6];//调整行间距
    [attrStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0,strComment.length)];
    
    NSArray *components = [strComment componentsSeparatedByString:@"\n"];
    int length=0;
    for (int i=0; i<components.count; i++) {
        NSRange range=[[components objectAtIndex:i] rangeOfString:@"："];
        if (range.location != NSNotFound) {
            [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(length,range.location+1)];
        }
        length+=[[components objectAtIndex:i] length]+1;
    }
    self.comment.attributedText=attrStr;
    
    self.postnum=circle.postnum;
    self.likenum=[circle.likelist count];
    
    if(self.likenum==0 && self.postnum==0){
        [self.separator setHidden:YES];
    }
    else{
        [self.separator setHidden:NO];
    }
    if (self.likenum==0) {
        [self.ivLike setHidden:YES];
    }
    else
    {
        [self.ivLike setHidden:NO];
    }
    if (self.postnum<=4) {
        [self.separator2 setHidden:YES];
        [self.btnLookAll setHidden:YES];
    }
    else{
        [self.btnLookAll setTitle:[NSString stringWithFormat: @"查看全部(%ld)",circle.postnum] forState:UIControlStateNormal];
        [self.separator2 setHidden:NO];
        [self.btnLookAll setHidden:NO];
    }
    
    //NSLog(@"chenjinwei:%ld",self.img_height);
    
    self.numPic=[circle.imglist count];
    for (int i=0; i<[self.picViews count]; i++) {
        UIImageView* iv=[self.picViews objectAtIndex:i];
        if(i<self.numPic){
            [iv sd_setImageWithURL:[NSURL URLWithString:[circle.imglist objectAtIndex:i]]
                  placeholderImage:[UIImage imageNamed:kImgHolder]
                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                             if(error){
                                 iv.image=[UIImage imageNamed:kImgHolder];
                             }
                             else{
                                 if (self.isVideo) {
                                     circle.img_width=image.size.width;
                                     circle.img_height=image.size.height;
                                     self.img_height=circle.img_height;
                                      self.img_width=circle.img_width;
                                     CGFloat pictureWidth=([UIScreen mainScreen].bounds.size.width-78)*2/3;
                                     if(self.img_width>pictureWidth){
                                         self.img_width=pictureWidth;
                                         self.img_height=circle.img_height*self.img_width/circle.img_width;
                                     }
                                     if (self.img_height>SCREEN_HEIGHT) {
                                         self.img_height=SCREEN_HEIGHT;
                                         self.img_width=circle.img_width*self.img_height/circle.img_height;
                                     }
                                     if (!circle.isVideoHeight) {
                                         [self layoutSubviews];
                                         circle.cellHeight=0;
                                         circle.isVideoHeight=YES;
                                     }
                                 }
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
    CGFloat contentWidth=[UIScreen mainScreen].bounds.size.width-78;
    CGFloat pictureWidth=[UIScreen mainScreen].bounds.size.width-78;
    
    [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];

    [self.username mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avatar.mas_right).offset(10);
        make.top.equalTo(self.avatar).offset(3);
    }];
    
    [self.level mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.username.mas_right).offset(6);
        make.top.equalTo(self.username).offset(3);
        make.size.mas_equalTo(CGSizeMake(36, 14));
    }];
    
    [self.dateline mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.username);
        make.top.equalTo(self.username.mas_bottom).offset(3);
    }];

    [self.userView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.top.mas_equalTo(14);
        make.bottom.mas_equalTo(self.avatar.mas_bottom);
        make.right.mas_equalTo(self.dateline);
    }];
    
    [self.from mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-44);
        make.top.mas_equalTo(self.level);
    }];
    
    [self.btnMore mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-14);
        make.top.mas_equalTo(self.level).offset(-3);
    }];
    
    [self.content mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.username);
        make.top.equalTo(self.userView.mas_bottom).offset(14);
        make.width.mas_lessThanOrEqualTo(contentWidth);
    }];

    UIImageView* iv;
    //-----------------------------------------------------
    if (self.numPic==1) {
        iv=self.picViews[0];
        iv.hidden=NO;
        [iv mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.username.mas_left);
            make.top.equalTo(self.content.mas_bottom).offset(10);
            //make.width.mas_lessThanOrEqualTo(pictureWidth/3);
            //make.height.mas_lessThanOrEqualTo(pictureWidth/3);
            make.width.mas_lessThanOrEqualTo(self.img_width);
            make.height.mas_lessThanOrEqualTo(self.img_height);
        }];
        if (self.isVideo) {
            [self.videoFlag mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(iv);
                make.size.mas_equalTo(CGSizeMake(40, 40));
           }];
        }
    }
    else if(self.numPic>1){
        int colnum=3;
        if(self.numPic==4){
            colnum=2;
        }
        for (int i=0; i<self.numPic; i++) {
            UIImageView* iv=self.picViews[i];
            iv.hidden=NO;
            [iv mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self.username.mas_left).offset((i%colnum)*pictureWidth/3);
                make.top.equalTo(self.content.mas_bottom).offset((i/colnum)*pictureWidth/3+14);
                make.width.mas_lessThanOrEqualTo(pictureWidth/3-2);
                make.height.mas_lessThanOrEqualTo(pictureWidth/3-2);
            }];
        }
        iv=self.picViews[self.numPic-1];
    }
    //-----------------------------------------------------
    
    [self.btnShare mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.content);
        if(self.numPic <=0){
            make.top.mas_equalTo(self.content.mas_bottom).offset(20);
        }
        else if(self.numPic==1){
            make.top.mas_equalTo(self.content.mas_bottom).offset(self.img_height+20);
        }
        else if(self.numPic==4){
            make.top.mas_equalTo(self.content.mas_bottom).offset(2*pictureWidth/3+20);
        }
        else{
            make.top.mas_equalTo(self.content.mas_bottom).offset(((self.numPic-1)/3+1)*pictureWidth/3+20);
        }
        make.size.mas_equalTo(CGSizeMake(pictureWidth/3, 40));
    }];

    [self.btnLike mas_remakeConstraints:^(MASConstraintMaker *make) {
         make.left.mas_equalTo(self.btnShare.mas_right);
         make.top.mas_equalTo(self.btnShare);
         make.size.mas_equalTo(CGSizeMake(pictureWidth/3, 40));
     }];
   
    [self.btnReply mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.btnLike.mas_right);
        make.top.mas_equalTo(self.btnShare);
        make.size.mas_equalTo(CGSizeMake(pictureWidth/3, 40));
    }];
    
    [self.line1 mas_remakeConstraints:^(MASConstraintMaker *make) {
         make.left.mas_equalTo(self.btnShare.mas_right).offset(2);
         make.top.mas_equalTo(self.btnShare).offset(12);
         make.size.mas_equalTo(CGSizeMake(1, 18));
     }];

    [self.line2 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.btnLike.mas_right);
        make.top.mas_equalTo(self.btnShare).offset(12);
        make.size.mas_equalTo(CGSizeMake(1, 18));
    }];
    
    [self.separator mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.content);
        make.top.mas_equalTo(self.btnShare.mas_bottom).offset(5);
        make.size.mas_equalTo(CGSizeMake(pictureWidth, 1));
    }];

    [self.ivLike mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.content).offset(-20);
        make.top.mas_equalTo(self.btnShare.mas_bottom).offset(16);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
    [self.likelist mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.content);
        make.top.mas_equalTo(self.separator).offset(10);
        make.width.mas_lessThanOrEqualTo(pictureWidth);
    }];
    
    [self.comment mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.content);
        make.top.mas_equalTo(self.likelist.mas_bottom).offset(14);
        make.width.mas_lessThanOrEqualTo(pictureWidth);
    }];

    [self.separator2 mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.content);
        make.top.mas_equalTo(self.comment.mas_bottom).offset(14);
        make.size.mas_equalTo(CGSizeMake(pictureWidth, 1));
    }];
    
    [self.btnLookAll mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.content);
        make.top.mas_equalTo(self.separator2);
        make.height.mas_equalTo(40);
    }];
    
    [self layoutIfNeeded];
    
    CGFloat yuHeight=0;
    if(self.likenum==0 && self.postnum==0){
        yuHeight-=40;
    }
    else if((self.likenum>0 && self.postnum>0)  ||  (self.likenum==0 && self.postnum>0)){
        
    }
    else{
        yuHeight-=12;
    }
    
    if (self.postnum<=4) {
        yuHeight-=40;
    }

    return self.btnLookAll.y+self.btnLookAll.height+14+yuHeight;
    
    /*CGFloat yuHeight=0;
    if(self.likenum==0 ||self.postnum>0){
        yuHeight+=25;
    }
    else{
        yuHeight-=5;
    }
    if (self.postnum<=4) {
        yuHeight +=60;
    }
    else{
        yuHeight-=20;
    }
    
    return self.btnLookAll.y+self.btnLookAll.height+14-yuHeight;*/
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

-(void)actionLookAll:(id)sender{
    if(self.blockLookAllAction){
        self.blockLookAllAction(sender);
    }
}

-(void)actionMore:(id)sender{
 if(self.blockMoreAction){
     self.blockMoreAction(sender);
 }
}


@end
