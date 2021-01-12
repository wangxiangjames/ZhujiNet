//
//  CjwCell.m
//  CjwSchool
//
//  Created by chenjinwei on 16/4/13.
//  Copyright © 2016年 chenjinwei. All rights reserved.
//
#import "Define.h"
#import "AppDelegate.h"
#import "CjwVedioCell.h"
#import "UIImage+Mycategory.h"
#import "UILabel+LineWordSpace.h"
#import "UIImageView+WebCache.h"
#import <SJUIKit/SJCornerMask.h>

#define CellTitleFontSize 19
#define CellSubTitleFontSize 12
#define CellFlagFontSize 10

@interface CjwVedioCell(){
    AppDelegate     *_app ;
}
@end

@implementation CjwVedioCell

/*- (void)awakeFromNib {
 // Initialization code
 }*/

//  Cell的构造方法
+ (instancetype)creatWithNib :(NSString *)nibName inTableView :(UITableView *)tableView
{
    CjwVedioCell *cell = [tableView dequeueReusableCellWithIdentifier:nibName];
    if (!cell) {
        NSLog(@"creatWithNib nibName:%@",nibName);
        cell = [[NSBundle mainBundle] loadNibNamed:nibName  owner:nil options:kNilOptions].lastObject;
    }
    return cell;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark 初始化视图
-(void)initSubView{
    
    CGFloat kWight = [UIScreen mainScreen].bounds.size.width;
    
    _img0=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kWight,  kWight * 9/16)];
    [self.contentView addSubview:_img0];
    _img1=[[UIImageView alloc]init];
    [self.contentView addSubview:_img1];
    _img2=[[UIImageView alloc]init];
    [self.contentView addSubview:_img2];
    
    _video=[[UIImageView alloc]init];
    _video.image=[UIImage imageNamed:@"play"];
    _video.contentMode=UIViewContentModeScaleToFill;
    [self.contentView addSubview:_video];
    
    _playerImg=[[SJPlayerSuperImageView alloc]initWithFrame:CGRectMake(0, 0, kWight,  kWight * 9/16)];
    [self.contentView addSubview:_playerImg];
    
    UIColor *colorOne = [UIColor colorWithRed:0  green:0  blue:0  alpha:1.0];
    UIColor *colorTwo = [UIColor colorWithRed:0  green:0  blue:0  alpha:0.0];
    NSArray *colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, colorTwo.CGColor, nil];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    //设置开始和结束位置(设置渐变的方向)
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(0, 1);
    gradient.colors = colors;
    gradient.frame = CGRectMake(0, 0, SCREEN_WIDTH, 100);
    _topView=[[UIView alloc]init];
    [_topView.layer insertSublayer:gradient atIndex:0];
    [self.contentView addSubview:_topView];
    
    _title=[[UILabel alloc]init];
    _title.numberOfLines = 0;
    [self.contentView addSubview:_title];
    
    _subtitle=[[UILabel alloc]init];
    //[_info sizeToFit];
    [self.contentView addSubview:_subtitle];
    
    _dateline=[[UILabel alloc]init];
    [self.contentView addSubview:_dateline];
    
    _flag=[[UILabel alloc]init];
    _flag.font=[UIFont systemFontOfSize:CellFlagFontSize];
    _flag.textAlignment = NSTextAlignmentCenter;
    _flag.layer.borderWidth = 0.5;
    _flag.layer.cornerRadius = 3;
    [self.contentView addSubview:_flag];
    
    _imginfo=[[UILabel alloc]init];
    _imginfo.font=[UIFont systemFontOfSize:CellFlagFontSize];
    _imginfo.textAlignment = NSTextAlignmentCenter;
    _imginfo.layer.cornerRadius = 5;
    [self.contentView addSubview:_imginfo];
    
    
    
    _btnZan=[[UIButton alloc] init];
    [_btnZan setTitle:@"赞" forState:UIControlStateNormal];
    [_btnZan setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    _btnZan.titleLabel.font=[UIFont systemFontOfSize:12];
    _btnZan.titleEdgeInsets=UIEdgeInsetsMake(0, 10, 0, 0);
    [_btnZan setImage:[UIImage imageNamed:@"btn_no_zan"] forState:UIControlStateNormal];
    [self.contentView addSubview:_btnZan];

    
    _btnReply=[[UIButton alloc] init];
    [_btnReply setTitle:@"回复" forState:UIControlStateNormal];
    [_btnReply setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    _btnReply.titleLabel.font=[UIFont systemFontOfSize:12];
    _btnReply.titleEdgeInsets=UIEdgeInsetsMake(0, 10, 0, 0);
    [_btnReply setImage:[UIImage imageNamed:@"btn_comment"] forState:UIControlStateNormal];
    [self.contentView addSubview:_btnReply];
    
    
    _btnMore=[[UIButton alloc] init];
    [_btnMore setImage:[UIImage imageNamed:@"more"] forState:UIControlStateNormal];
    [self.contentView addSubview:_btnMore];
    
    [self updateSkin];
}

-(void)updateSkin{
    _app = [AppDelegate getApp];
    self.backgroundColor=_app.skin.colorCellBg;
    UIView *viewCellSelectBg = [[UIView alloc]initWithFrame:self.frame];
    viewCellSelectBg.backgroundColor = _app.skin.colorCellSelectBg;
    self.selectedBackgroundView = viewCellSelectBg;
    
    _img0.alpha=_app.skin.floatImgAlpha;
    _img0.layer.borderWidth = _app.skin.floatImgBorderWidth;
    _img0.layer.borderColor = _app.skin.colorImgBorder.CGColor;
    
    _img1.alpha=_app.skin.floatImgAlpha;
    _img1.layer.borderWidth = _app.skin.floatImgBorderWidth;
    _img1.layer.borderColor = _app.skin.colorImgBorder.CGColor;
    
    _img2.alpha=_app.skin.floatImgAlpha;
    _img2.layer.borderWidth = _app.skin.floatImgBorderWidth;
    _img2.layer.borderColor = _app.skin.colorImgBorder.CGColor;
    
    _title.textColor=[UIColor whiteColor];
    
    _subtitle.textColor=[UIColor whiteColor];
    _subtitle.font=[UIFont systemFontOfSize:CellSubTitleFontSize];
    
    _dateline.textColor=_app.skin.colorCellSubTitle;
    _dateline.font=[UIFont systemFontOfSize:CellSubTitleFontSize];
    
    _imginfo.textColor=_app.skin.colorImginfo;
    _imginfo.layer.backgroundColor=_app.skin.colorImginfoBg.CGColor;
}

-(void)setItem:(CjwItem *)item{
    _type=item.type;
    _isVideo=item.isVideo;
    _title.text=item.title;
    _subtitle.text=item.subtitle;
    _dateline.text=item.author;
    _flag.text=item.flag;
    _imginfo.text=item.imginfo;
    
    if (item.url_pic0!=nil) {
        [_img0 sd_setImageWithURL:[NSURL URLWithString:item.url_pic0] placeholderImage:ImageNamed(kImgHolder)
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                            if(error){
                                _img0.image=ImageNamed(kImgHolder);
                            }
                        }];
    }
    else{
        _img0.image=[UIImage imageNamed:item.img];
    }
    
    if (item.url_pic1!=nil) {
        [_img1 sd_setImageWithURL:[NSURL URLWithString:item.url_pic1] placeholderImage:ImageNamed(kImgHolder)
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                            if(error){
                                _img1.image=ImageNamed(kImgHolder);
                            }
                        }];
    }
    else{
        _img1.image=[UIImage imageNamed:item.img];
    }
    
    if (item.url_pic2!=nil) {
        [_img2 sd_setImageWithURL:[NSURL URLWithString:item.url_pic2] placeholderImage:ImageNamed(kImgHolder)
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                            if(error){
                                _img2.image=ImageNamed(kImgHolder);
                            }
                        }];
    }
    else{
        _img2.image=[UIImage imageNamed:item.img];
    }
    
    //-------------------------------
    _flag.textColor=[UIColor colorWithHexString:@"ff4444"];
    _flag.layer.borderColor = [UIColor colorWithHexString:@"ff4444"].CGColor;
    if([_flag.text length]>0){
        _flag.hidden=NO;
    }
    else{
        _flag.hidden=YES;
    }
    
    if([_imginfo.text length]>0){
        _imginfo.hidden=NO;
    }
    else{
        _imginfo.hidden=YES;
    }
    
    if(_isVideo==YES){
        _video.hidden=NO;
        _imginfo.layer.cornerRadius = 10;
    }
    else{
        _video.hidden=YES;
        _imginfo.layer.cornerRadius = 5;
    }
    
}

- (void)setFrame:(CGRect)frame {
    frame.origin.x +=_padding;
    frame.size.width -= 2 * _padding;
    frame.size.height=self.height;
    [super setFrame:frame];
}


-(CGFloat)height{
    CGFloat cellH=0;
    switch (self.type) {
            
        case cell_type_news_pic_one_big:
            cellH=self.cell_news_pic_one_big;
            break;
            
        default:
            break;
    }
    //NSLog(@"CjwCell height:%f",cellH);
    return cellH;
}


-(CGFloat)cell_news_pic_one_big{
    
    CGRect bounds =[ UIScreen mainScreen ].bounds;
    CGFloat padding_Left=0;                            //左边距
    CGFloat padding_top=0;                             //上边距
    CGFloat padding_right=0;                           //右边距
    //CGFloat padding_bottom=0;                          //下边距
    CGFloat spaceV=10;                                  //垂直间距
    
    CGFloat cellW=bounds.size.width -padding_Left-padding_right;    //单元宽度
    CGFloat imgW=cellW;                               //图片宽度
    CGFloat imgH=imgW *9/16;                           //高是宽的5/8
    
    _img0.hidden=NO;
    _img1.hidden=NO;
    _img2.hidden=YES;
    
    CGFloat cellH=padding_top;
    _img0.frame=CGRectMake(padding_Left, cellH, imgW, imgH);
//    SJCornerMaskSetRound(_img0, 2, UIColor.brownColor);
    
    if(_isVideo==YES){
        _video.frame=CGRectMake(padding_Left+cellW/2-24, cellH+imgH/2-20, 48, 48);
    }
    
    CGSize titleSize=[CjwFun sizeForText:_title width:cellW-28 font:[UIFont systemFontOfSize:CellTitleFontSize] lineSapce:2];
    _title.numberOfLines = 0;
    _title.lineBreakMode = NSLineBreakByWordWrapping;
    _title.frame=CGRectMake(padding_Left+14, spaceV,cellW-28, titleSize.height);
    
    _topView.frame=CGRectMake(padding_Left, cellH, imgW, 100);
    
    _subtitle.frame=CGRectMake(padding_Left+14, titleSize.height+14, cellW, CellSubTitleFontSize);
    
    if([_imginfo.text length]>0){
        CGSize imgInfoSize = [_imginfo.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:CellFlagFontSize]}];
        _imginfo.frame=CGRectMake(imgW-imgInfoSize.width-spaceV-14, cellH+imgH-(CellFlagFontSize+8+spaceV), imgInfoSize.width+2*spaceV-4, imgInfoSize.height+8);
    }
    
    cellH=cellH+imgH+spaceV;
    

    //[_img1 sd_setImageWithURL:[NSURL URLWithString:@"http://www.zhuji.net/pro/images/2017072730167823.jpg"]];
    _img1.layer.cornerRadius=19;
    _img1.layer.masksToBounds=YES;
    _img1.frame=CGRectMake(14, cellH-3, 38, 38);
    
    /*CGFloat flagW=0;
    if([_flag.text length]>0){
        flagW=CellSubTitleFontSize*[_flag.text length]+4;
        _flag.frame=CGRectMake(padding_Left, cellH-1, flagW, CellSubTitleFontSize+2);
        flagW=flagW+15;
    }
    
     */
    
    CGSize datelineSize = [_dateline.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:CellSubTitleFontSize]}];
    _dateline.frame=CGRectMake(14+40+5, cellH+10, datelineSize.width, CellSubTitleFontSize);
    //_dateline.text=@"用户名";
    
    _btnMore.frame=CGRectMake(SCREEN_WIDTH-30-14, cellH+2, 30, 30);
    _btnReply.frame=CGRectMake(SCREEN_WIDTH-30-14-70, cellH+2, 60, 30);
    _btnZan.frame=CGRectMake(SCREEN_WIDTH-30-14-130, cellH+2, 60, 30);
    
    cellH=cellH+CellSubTitleFontSize+30;
    return cellH;
}

@end
