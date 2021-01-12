//
//  CommonCell.m
//  ZhujiNet
//
//  Created by zhujiribao on 2018/3/7.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//

#import "UILabel+LineWordSpace.h"
#import "UIView+Frame.h"
#import "HexColor.h"
#import "Masonry.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "CircleDetailCell.h"

@interface  CircleDetailCell(){
    AppDelegate     *_app ;
    
    UILabel         *_title;
    UIImageView     *_ivUser;
    UIButton        *_btnUser;
    UILabel         *_level;
    UILabel         *_viewNum;
    NSMutableArray  *_picViews;         //图片数组
    NSInteger       _numPic;             //图片数量
    NSArray         *_imglist;
    NSInteger       _img_width;
    NSInteger       _img_height;
}

@property (nonatomic, strong)UIImageView*   videoFlag;
@property (nonatomic, assign)BOOL           isVideo;

@end

@implementation CircleDetailCell

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
        [self initSubView];
    }
    return self;
}

- (void)initSubView {
    _app = [AppDelegate getApp];
    _ivUser=[[UIImageView alloc] init];
    _ivUser.layer.cornerRadius=20;
    _ivUser.layer.masksToBounds=YES;
    [self.contentView addSubview:_ivUser];
    
    _btnUser=[[UIButton alloc]init];
    _btnUser.titleLabel.font=[UIFont systemFontOfSize:16];
    _btnUser.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_btnUser setTitleColor:_app.skin.colorButton forState:UIControlStateNormal];
    [self.contentView addSubview:_btnUser];
    
    _level=[[UILabel alloc]init];
    _level.textColor=[UIColor redColor];
    _level.font=[UIFont systemFontOfSize:10];
    _level.textAlignment=NSTextAlignmentCenter;
    _level.layer.cornerRadius=3;
    _level.layer.masksToBounds=YES;
    _level.textColor=_app.skin.colorMainLight;
    _level.backgroundColor=_app.skin.colorMainLight;
    _level.textColor=_app.skin.colorNavbar;
    [self.contentView addSubview:_level];
    
    _viewNum=[[UILabel alloc]init];
    _viewNum.font=[UIFont systemFontOfSize:11];
    _viewNum.textColor=[UIColor colorWithHexString:@"888888"];
    [self.contentView addSubview:_viewNum];
    
    _btnFollow=[[UIButton alloc]init];
    [_btnFollow addTarget:self action:@selector(followAction:) forControlEvents:UIControlEventTouchUpInside];
    [_btnFollow setTitle: @"关注" forState: UIControlStateNormal];
    _btnFollow.titleLabel.font=[UIFont systemFontOfSize:14];
    _btnFollow.backgroundColor=_app.skin.colorMainLight;
    [_btnFollow setTitleColor:_app.skin.colorNavMenu forState:UIControlStateNormal];
    _btnFollow.alpha=_app.skin.floatImgAlpha;
    _btnFollow.layer.cornerRadius=3;
    [self.contentView addSubview:_btnFollow];
    
    _title=[[UILabel alloc]init];
    _title.font=[UIFont boldSystemFontOfSize:18];
    _title.textColor=_app.skin.colorCellTitle;
    _title.numberOfLines=0;
    [self.contentView addSubview:_title];
    
    _picViews=[NSMutableArray arrayWithCapacity:9];
    for (int i=0; i<9; i++) {
        UIImageView *iv=[[UIImageView alloc]init];
        iv.hidden=YES;
        iv.contentMode=UIViewContentModeScaleToFill;
        iv.tag = i;
        iv.userInteractionEnabled = YES;
        [self.contentView addSubview:iv];
        [_picViews addObject:iv];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageViewAction:)];
        [iv addGestureRecognizer:tap];
    }
    
    self.videoFlag=[[UIImageView alloc]init];
    self.videoFlag.image=[UIImage imageNamed:@"play"];
    self.videoFlag.contentMode=UIViewContentModeScaleToFill;
    [self.contentView addSubview:self.videoFlag];
    
}

- (void)setFrame:(CGRect)frame {
    frame.size.height=self.height;
    [super setFrame:frame];
}

-(void)setData:(CircleModel *)model{
    if (![model.videourl isEqualToString:@""]) {
        model.imglist=[[NSArray alloc]initWithObjects:model.videocover, nil];
        model.img_height=240;
        model.img_width=400;
        self.isVideo=YES;
        self.videoFlag.hidden=NO;
    }
    else{
        self.videoFlag.hidden=YES;
    }
    
    [_ivUser sd_setImageWithURL:[NSURL URLWithString:model.avatar]];
    [_btnUser setTitle:model.author forState: UIControlStateNormal];
    _level.text=[NSString stringWithFormat:@"LV%ld",model.level];
    _viewNum.text=[NSString stringWithFormat:@"%@    %ld阅读",model.dateline,model.hits];
    _title.text=model.title;
    if (_title.text) {
        [UILabel setLineSpaceForLabel:_title withSpace:10];
    }
    
    _imglist=model.imglist;
    _img_height=model.img_height;
    _img_width=model.img_width;
    
    _numPic=[_imglist count];
    for (int i=0; i<[_picViews count]; i++) {
        UIImageView* iv=[_picViews objectAtIndex:i];
        if(i<_numPic){
            [iv sd_setImageWithURL:[NSURL URLWithString:[_imglist objectAtIndex:i]]
                  placeholderImage:[UIImage imageNamed:kImgHolder]
                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                             if(error){
                                 iv.image=[UIImage imageNamed:kImgHolder];
                             }
                             else{
                                 model.img_width=image.size.width;
                                 model.img_height=image.size.height;
                                 _img_height=model.img_height;
                                 _img_width=model.img_width;
                                 [self layoutIfNeeded];
                             }
                         }
             ];
            iv.hidden=NO;
        }
        else{
            iv.hidden=YES;
        }
    }
    
    _img_height=model.img_height;
    _img_width=model.img_width;
    CGFloat pictureWidth=([UIScreen mainScreen].bounds.size.width-28)*3/4;
    if(_img_width>pictureWidth){
        _img_width=pictureWidth;
        _img_height=model.img_height*_img_width/model.img_width;
    }
    if (_img_height>SCREEN_HEIGHT) {
        _img_height=SCREEN_HEIGHT;
        _img_width=model.img_width*_img_height/model.img_height;
    }
    
    if(model.cellHeight==0){
        model.cellHeight=self.height;
    }
}

-(CGFloat) height{
    //-------------------------------------------------------
    [_ivUser mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(14);
        make.left.mas_equalTo(self).offset(14);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    [_btnUser mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_ivUser).offset(6);
        make.left.mas_equalTo(_ivUser.mas_right).offset(8);
        make.height.mas_equalTo(16);
    }];
    
    [_level mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_btnUser);
        make.left.mas_equalTo(_btnUser.mas_right).offset(8);
        make.height.mas_equalTo(16);
        make.width.greaterThanOrEqualTo(@40);
    }];
    
    [_viewNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_btnUser.mas_bottom).offset(4);
        make.left.mas_equalTo(_btnUser.mas_left);
        make.height.mas_equalTo(16);
    }];
    
    [_btnFollow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(_ivUser);
        make.right.offset(-14);
        make.size.mas_equalTo(CGSizeMake(50,28));
    }];
    
    [_title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_ivUser.mas_bottom).offset(14);
        make.left.mas_equalTo(_ivUser.mas_left);
        make.right.offset(-14);
    }];

    CGFloat pictureWidth=[UIScreen mainScreen].bounds.size.width-28;
    UIImageView* iv;
    //-----------------------------------------------------
    if (_numPic==1) {
        iv=_picViews[0];
        iv.hidden=NO;
        [iv mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(_ivUser.mas_left);
            make.top.equalTo(_title.mas_bottom).offset(10);
            make.width.mas_lessThanOrEqualTo(_img_width);
            make.height.mas_lessThanOrEqualTo(_img_height);
        }];
        if (self.isVideo) {
            [self.videoFlag mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(iv);
                make.size.mas_equalTo(CGSizeMake(40, 40));
            }];
        }
    }
    else if(_numPic>1){
        int colnum=3;
        if(_numPic==4){
            colnum=2;
        }
        for (int i=0; i<_numPic; i++) {
            UIImageView* iv=_picViews[i];
            iv.hidden=NO;
            [iv mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(_ivUser.mas_left).offset((i%colnum)*pictureWidth/3);
                make.top.equalTo(_title.mas_bottom).offset((i/colnum)*pictureWidth/3+14);
                make.width.mas_lessThanOrEqualTo(pictureWidth/3-2);
                make.height.mas_lessThanOrEqualTo(pictureWidth/3-2);
            }];
        }
        iv=_picViews[_numPic-1];
    }
    //-----------------------------------------------------
    
    [self layoutIfNeeded];
    CGFloat h=_title.y+_title.height+14;
    if(_numPic <=0){
    }
    else if(_numPic==1){
        h+=_img_height;
    }
    else if(_numPic==4){
        h+=2*pictureWidth/3;
    }
    else{
        h+=((_numPic-1)/3+1)*pictureWidth/3;
    }
    
    return h+20;
}

-(void)tapImageViewAction:(UITapGestureRecognizer*)gesture{
    if(self.blockTapImageViewAction){
        self.blockTapImageViewAction(gesture);
    }
}

-(void)followAction:(UIButton*)sender{
    if (self.blockFollowAction) {
        self.blockFollowAction(sender);
    }
}

@end
