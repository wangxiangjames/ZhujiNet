//
//  CjwCell.m
//  CjwSchool
//
//  Created by chenjinwei on 16/4/13.
//  Copyright © 2016年 chenjinwei. All rights reserved.
//
#import "Define.h"
#import "AppDelegate.h"
#import "CjwCell.h"
#import "UIImage+Mycategory.h"
#import "UILabel+LineWordSpace.h"
#import "UIImageView+WebCache.h"
#import "HexColor.h"

#define CellTitleFontSize 19
#define CellSubTitleFontSize 12
#define CellFlagFontSize 10

@interface CjwCell(){
    AppDelegate     *_app ;
}
@end

@implementation CjwCell

/*- (void)awakeFromNib {
    // Initialization code
}*/

//  Cell的构造方法
+ (instancetype)creatWithNib :(NSString *)nibName inTableView :(UITableView *)tableView
{
    CjwCell *cell = [tableView dequeueReusableCellWithIdentifier:nibName];
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
    
    switch (self.type) {
        case cell_type_menu_bbs_left:
            self.contentView.backgroundColor = selected ? _app.skin.colorCellBg : _app.skin.colorTableBg;
            _title.font= selected ?[UIFont boldSystemFontOfSize:17]:[UIFont systemFontOfSize:15];
            //_title.font=selected ?[UIFont fontWithName:@"Arial Rounded MT Bold" size:(17.0)]:[UIFont fontWithName:@"Arial" size:15.0];
            self.superview.superview.backgroundColor=_app.skin.colorTableBg;
            _subtitle.backgroundColor=selected ?_app.skin.colorMainLight:_app.skin.colorTableBg;
            self.contentView.layer.borderWidth=selected?0:0.5;
            self.contentView.layer.borderColor=_app.skin.colorCellSeparator.CGColor;
            break;

        case cell_type_menu_bbs_right:
            self.contentView.backgroundColor =_app.skin.colorCellBg;
            self.superview.superview.backgroundColor=_app.skin.colorCellBg;
            break;
            
        case cell_type_text_one:
            self.contentView.backgroundColor =_app.skin.colorTableBg;
            break;
            
        default:
            self.contentView.backgroundColor =_app.skin.colorCellBg;
            self.superview.superview.backgroundColor=_app.skin.colorTableBg;
            break;
    }

}

#pragma mark 初始化视图
-(void)initSubView{
    
    _img0=[[UIImageView alloc]init];
    [self.contentView addSubview:_img0];
    _img1=[[UIImageView alloc]init];
    [self.contentView addSubview:_img1];
    _img2=[[UIImageView alloc]init];
    [self.contentView addSubview:_img2];

    _img0.contentMode=UIViewContentModeScaleAspectFill;
    _img0.clipsToBounds = YES;
    _img1.contentMode=UIViewContentModeScaleAspectFill;
    _img1.clipsToBounds = YES;
    _img2.contentMode=UIViewContentModeScaleAspectFill;
    _img2.clipsToBounds = YES;
    
    _title=[[UILabel alloc]init];
    _title.numberOfLines = 0;
    [self.contentView addSubview:_title];
    
    _subtitle=[[UILabel alloc]init];
    _subtitle.font=[UIFont systemFontOfSize:CellSubTitleFontSize];
    //[_info sizeToFit];
    [self.contentView addSubview:_subtitle];
    
    _level=[[UILabel alloc]init];

    _level.font=[UIFont systemFontOfSize:CellSubTitleFontSize];
    [self.contentView addSubview:_level];
    
    _rank=[[UILabel alloc]init];
    _rank.font=[UIFont systemFontOfSize:CellSubTitleFontSize];
    [self.contentView addSubview:_rank];
    
    _dateline=[[UILabel alloc]init];
    _dateline.font=[UIFont systemFontOfSize:CellSubTitleFontSize];
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
    _imginfo.layer.backgroundColor=[UIColor colorWithHexString:@"000000" alpha:100/255].CGColor;
    _imginfo.textColor=[UIColor colorWithHexString:@"ffffff"];
    [self.contentView addSubview:_imginfo];
    
    _video=[[UIImageView alloc]init];
    _video.image=[UIImage imageNamed:@"play"];
    _video.contentMode=UIViewContentModeScaleToFill;
    [self.contentView addSubview:_video];
    
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
    
    _video.alpha=_app.skin.floatImgAlpha;
    
    _title.textColor=_app.skin.colorCellTitle;
    
    _subtitle.textColor=_app.skin.colorCellSubTitle;
    _subtitle.font=[UIFont systemFontOfSize:CellSubTitleFontSize];
    
    _dateline.textColor=_app.skin.colorCellSubTitle;
    _dateline.font=[UIFont systemFontOfSize:CellSubTitleFontSize];
    
    _level.textColor=_app.skin.colorCellTitle;
    _level.alpha=_app.skin.floatImgAlpha;
    
    _rank.textColor=_app.skin.colorCellTitle;
    _rank.alpha=_app.skin.floatImgAlpha;
}

-(void)setItem:(CjwItem *)item{
    _type=item.type;
    _isVideo=item.isVideo;
    _title.text=item.title;
    _subtitle.text=item.subtitle;
    _dateline.text=item.dateline;
    _flag.text=item.flag;
    _imginfo.text=item.imginfo;
    _rank.text=item.rank;
    _level.text=item.level;

    if (item.url_pic0!=nil) {
        [_img0 sd_setImageWithURL:[NSURL URLWithString:item.url_pic0] placeholderImage:[UIImage imageNamed:@"test2"]
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                           if(error){
                               _img0.image=[UIImage imageNamed:@"test2"];
                           }
                       }];
    }
    else{
        _img0.image=[UIImage imageNamed:item.img];
    }
    
    if (item.url_pic1!=nil) {
        [_img1 sd_setImageWithURL:[NSURL URLWithString:item.url_pic1] placeholderImage:[UIImage imageNamed:@"test2"]
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                            if(error){
                                _img1.image=[UIImage imageNamed:@"test2"];
                            }
                        }];
    }
    else{
        _img1.image=[UIImage imageNamed:item.img];
    }
    
    if (item.url_pic2!=nil) {
        [_img2 sd_setImageWithURL:[NSURL URLWithString:item.url_pic2] placeholderImage:[UIImage imageNamed:@"test2"]
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                            if(error){
                                _img2.image=[UIImage imageNamed:@"test2"];
                            }
                        }];
    }
    else{
        _img2.image=[UIImage imageNamed:item.img];
    }
    
    //-------------------------------
    //_flag.textColor=Color(0xff4444);
    //_flag.layer.borderColor = Color(0xff4444).CGColor;
    if (item.flagcolor.length>0) {
        _flag.textColor=[HXColor colorWithHexString:item.flagcolor];
        _flag.layer.borderColor=[HXColor colorWithHexString:item.flagcolor].CGColor;
    }
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
    if(_type==cell_type_text_one){
        self.contentView.backgroundColor=[UIColor colorWithHexString:@"f2f2f2"];
        _img0.hidden=YES;
    }
    else{
        self.contentView.backgroundColor=[UIColor whiteColor];
            _img0.hidden=NO;
    }
    if(_type==cell_type_text_one_end){
        _img0.hidden=YES;
    }
    
    if(_type==cell_type_comment){
        _img0.layer.masksToBounds = YES;
        _img0.layer.cornerRadius = 20;
        _img0.layer.borderWidth=0.5;
        _img0.layer.borderColor=[UIColor colorWithHexString:@"aaaaaa"].CGColor;
    }
    else{
        _img0.layer.cornerRadius = 0;
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
        case cell_type_menu:
            cellH=self.cell_menu;
            break;

        case cell_type_menu_bbs_left:
            cellH=self.cell_menu_bbs_left;
            break;
            
        case cell_type_menu_bbs_right:
            cellH=self.cell_menu_bbs_right;
            break;
            
            
        case cell_type_text_one:
            cellH=self.cell_text_one;
            break;
            
        case cell_type_pic_one:
            cellH=self.cell_pic_one;
            break;
            
        case cell_type_text_one_end:
            cellH=self.cell_text_one_end;
            break;
            
        case cell_type_comment:
            cellH=self.cell_comment;
            break;
            
        case cell_type_mine:
            cellH=self.cell_mine;
            break;
            
        case cell_type_mine_score:
            cellH=self.cell_mine_score;
            break;
            
        case cell_type_mine_base_text:
            cellH=self.cell_mine_base_text;
            break;
            
        case cell_type_mine_base_pic:
            cellH=self.cell_mine_base_pic;
            break;
    
        case cell_type_news_text:
            cellH=self.cell_news_text;
            break;
            
        case cell_type_mine_login:
            cellH=self.cell_mine_login;
            break;
            
        default:
            break;
    }

    //NSLog(@"CjwCell height:%f",cellH);
    return cellH;
}

-(CGFloat)cell_pic_one{
    /*[self.img mas_makeConstraints:^(MASConstraintMaker *make) {
     make.top.mas_equalTo(10);
     make.left.mas_equalTo(10);
     make.width.equalTo(self.mas_width).multipliedBy(0.33);
     make.height.equalTo(self.img.mas_width).multipliedBy(0.625);
     }];
     
     [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
     make.top.mas_equalTo(10);
     make.left.mas_equalTo(self.img.mas_right).offset(10);
     make.right.mas_equalTo(-10);
     make.bottom.mas_equalTo(self.info.mas_top).offset(-10);
     }];
     
     [self.info mas_makeConstraints:^(MASConstraintMaker *make) {
     make.left.mas_equalTo(self.img.mas_right).offset(10);
     make.right.mas_equalTo(-10);
     make.bottom.mas_equalTo(-10);
     }];*/
    
    CGRect bounds =[ UIScreen mainScreen ].bounds;
    CGFloat padding_Left=14;                            //左边距
    CGFloat padding_top=14;                             //上边距
    CGFloat padding_right=14;                           //右边距
    CGFloat padding_bottom=14;                          //下边距
    CGFloat sapceH=10;                                  //水平间距
    CGFloat spaceV=10;                                  //垂直间距
    
    CGFloat cellW=bounds.size.width -padding_Left-padding_right;    //单元宽度
    CGFloat imgSapceH=3;                                //三图水平间距
    CGFloat textW=cellW*2/3-sapceH;                     //文本宽度
    CGFloat imgW=(cellW-2*imgSapceH)/3;                 //图片宽度
    CGFloat imgH=imgW *0.625;                           //高是宽的5/8
    CGFloat cellImgH=padding_top+imgH+padding_bottom;   //图片占位总高
    
    _img0.hidden=NO;
    _img1.hidden=YES;
    _img2.hidden=YES;
    _img0.frame=CGRectMake(padding_Left+cellW-imgW, padding_top, imgW, imgH);
    
    if([_imginfo.text length]>0){
        CGSize imgInfoSize=CGSizeZero;
        if(_isVideo==YES){
            _imginfo.text=[NSString stringWithFormat:@"    %@",_imginfo.text ];
            imgInfoSize = [_imginfo.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:CellFlagFontSize]}];
            _video.frame=CGRectMake(padding_Left+cellW-imgInfoSize.width-2*spaceV, padding_top+imgH-(CellFlagFontSize+4+spaceV), 20, 20);
        }
        else{
            imgInfoSize = [_imginfo.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:CellFlagFontSize]}];
        }
        
        _imginfo.frame=CGRectMake(padding_Left+cellW-imgInfoSize.width-2*spaceV, padding_top+imgH-(CellFlagFontSize+4+spaceV), imgInfoSize.width+2*spaceV-4, imgInfoSize.height+8);
    }
    
    CGSize titleSize=[CjwFun sizeForText:_title width:textW font:[UIFont systemFontOfSize:CellTitleFontSize-2] lineSapce:3];
    _title.numberOfLines = 0;
    _title.lineBreakMode = NSLineBreakByWordWrapping;
    
    CGFloat cellTextH=padding_top+titleSize.height+spaceV+CellSubTitleFontSize+padding_bottom;
    
    CGFloat yTop=padding_top;
    if(cellImgH>cellTextH){
        yTop=padding_top+(cellImgH-cellTextH)/2;        //垂直居中显示
    }
    _title.frame=CGRectMake(padding_Left, yTop,textW, titleSize.height);
    CGFloat flagW=0;
    if([_flag.text length]>0){
        flagW=CellSubTitleFontSize*[_flag.text length]+4;
        _flag.frame=CGRectMake(padding_Left, yTop+titleSize.height+spaceV-1, flagW, CellSubTitleFontSize+2);
        flagW=flagW+15;
    }
    
    _subtitle.frame=CGRectMake(flagW+padding_Left, yTop+titleSize.height+spaceV, textW, CellSubTitleFontSize);
    
    CGSize datelineSize = [_dateline.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:CellSubTitleFontSize]}];
    _dateline.frame=CGRectMake(padding_Left+textW-datelineSize.width, yTop+titleSize.height+spaceV, datelineSize.width, CellSubTitleFontSize);
    
    return cellTextH>cellImgH ? cellTextH:cellImgH;
}

-(CGFloat)cell_comment{
    CGRect bounds =[ UIScreen mainScreen ].bounds;
    CGFloat padding_Left=14;                            //左边距
    CGFloat padding_top=14;                             //上边距
    CGFloat padding_right=14;                           //右边距
    CGFloat padding_bottom=14;                          //下边距
    //CGFloat sapceH=10;                                  //水平间距
    CGFloat spaceV=10;                                  //垂直间距
    
    CGFloat cellW=bounds.size.width -padding_Left-padding_right;    //单元宽度
    //CGFloat imgSapceH=3;                                //三图水平间距
    CGFloat imgW=40;                                    //图片宽度
    CGFloat imgH=40;                                    //高是宽的5/8
    //CGFloat cellImgH=padding_top+imgH+padding_bottom;   //图片占位总高
    
    _img0.hidden=NO;
    _img1.hidden=YES;
    _img2.hidden=YES;
    _img0.frame=CGRectMake(padding_Left, padding_top, imgW, imgH);
    
    CGFloat textW=cellW-padding_Left-imgW;                     //文本宽度
    CGFloat yTop=padding_top+4;
    _subtitle.frame=CGRectMake(2*padding_Left+imgW, yTop, textW, CellSubTitleFontSize);
    yTop+=CellSubTitleFontSize+padding_top/2;
    
    CGSize datelineSize = [_dateline.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:CellSubTitleFontSize]}];
    _dateline.frame=CGRectMake(2*padding_Left+imgW, yTop, datelineSize.width, CellSubTitleFontSize);
    yTop+=CellSubTitleFontSize+padding_top;
    
    CGSize titleSize=[CjwFun sizeForText:_title width:textW font:[UIFont systemFontOfSize:CellTitleFontSize-3] lineSapce:3];
    _title.numberOfLines = 0;
    _title.lineBreakMode = NSLineBreakByWordWrapping;
    
    CGFloat cellTextH=padding_top+titleSize.height+spaceV+CellSubTitleFontSize+padding_bottom;
    _title.frame=CGRectMake(2*padding_Left+imgW, yTop,textW, titleSize.height);
    
    cellTextH=yTop+titleSize.height+padding_top;
    
    return cellTextH;
}

-(CGFloat)cell_menu{
    CGFloat padding_Left=14;
    CGFloat imgW=25;
    CGFloat imgH=25;
    _img0.layer.borderWidth=0;
    _img0.frame=CGRectMake(padding_Left, 13, imgW, imgH);
    _title.font=[UIFont systemFontOfSize:CellTitleFontSize-2];
    _title.textAlignment=NSTextAlignmentLeft;
    _title.frame=CGRectMake(padding_Left+imgW+padding_Left, 0,self.bounds.size.width, 52);
    return 52;
}

-(CGFloat)cell_mine_base_text{
    CGFloat padding_Left=14;
    _title.font=[UIFont systemFontOfSize:CellTitleFontSize-1];
    _title.textAlignment=NSTextAlignmentLeft;
    _title.frame=CGRectMake(padding_Left, 0,self.bounds.size.width, 52);
    
    _subtitle.numberOfLines = 0;
    CGSize subtitleSize=[CjwFun sizeForText:_subtitle width:SCREEN_WIDTH*0.7 font:[UIFont systemFontOfSize:CellTitleFontSize-3] lineSapce:3];
    CGFloat tempHeight=subtitleSize.height;
    if(tempHeight<25){
        tempHeight=52;
        _subtitle.textAlignment=NSTextAlignmentRight;
        _subtitle.frame=CGRectMake(SCREEN_WIDTH-SCREEN_WIDTH*0.7-34, 0,SCREEN_WIDTH*0.7,tempHeight);
    }
    else{
        tempHeight+=30;
        _subtitle.frame=CGRectMake(SCREEN_WIDTH-SCREEN_WIDTH*0.7-24, 0,SCREEN_WIDTH*0.7,tempHeight);
        _subtitle.textAlignment=NSTextAlignmentLeft;
    }
    
    return tempHeight;
}

-(CGFloat)cell_mine_base_pic{
    CGFloat padding_Left=14;
    CGFloat imgW=60;
    
    _title.font=[UIFont systemFontOfSize:CellTitleFontSize-1];
    _title.textAlignment=NSTextAlignmentLeft;
    _title.frame=CGRectMake(padding_Left, 0,self.bounds.size.width, 80);
    
    _img0.layer.borderWidth=0.5;
    _img0.layer.cornerRadius=30;
    _img0.layer.masksToBounds=YES;
    _img0.frame=CGRectMake(SCREEN_WIDTH-imgW-34, 10,imgW, imgW);
    
    return 80;
}


-(CGFloat)cell_mine_login{
    CGFloat imgW=64;
    CGFloat imgH=64;
    _img1.layer.cornerRadius=32;
    _img1.layer.masksToBounds=YES;
    _img1.image=[UIImage imageNamed:@"avator"];
    _img1.frame=CGRectMake((SCREEN_WIDTH-imgW)/2, 17, imgW, imgH);
    return 90;
}

-(CGFloat)cell_mine{
    CGFloat padding_Left=14;
    CGFloat imgW=60;
    CGFloat imgH=60;
    _img0.layer.cornerRadius=30;
    _img0.layer.masksToBounds=YES;
    _img0.frame=CGRectMake(padding_Left, 12, imgW, imgH);
    _title.textAlignment=NSTextAlignmentLeft;
    CGSize titleSize = [_title.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:CellTitleFontSize-2]}];
    _title.frame=CGRectMake(padding_Left+imgW+padding_Left, 17,padding_Left+imgW+padding_Left+titleSize.width, 22);
    
    _level.hidden=NO;
    _level.layer.cornerRadius=3;
    _level.layer.masksToBounds=YES;
    _level.textColor=[UIColor whiteColor];
    _level.textAlignment=NSTextAlignmentCenter;
    CGSize imginfoSize = [_level.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:CellTitleFontSize-2]}];
    _level.frame=CGRectMake(padding_Left+imgW+padding_Left+titleSize.width+10, 19,imginfoSize.width, 18);
    _level.backgroundColor=_app.skin.colorMainLight;
    
    
    _rank.hidden=NO;
    _rank.layer.cornerRadius=3;
    _rank.layer.masksToBounds=YES;
    CGSize flagSize = [_rank.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:CellTitleFontSize-2]}];
    _rank.frame=CGRectMake(padding_Left+imgW+padding_Left+titleSize.width+10+imginfoSize.width+10, 19,flagSize.width, 18);
    _rank.backgroundColor=_app.skin.colorMainLight;
    _rank.textAlignment=NSTextAlignmentCenter;
    _rank.textColor=[UIColor whiteColor];
    
    _subtitle.font=[UIFont systemFontOfSize:CellTitleFontSize-4];
    _subtitle.frame=CGRectMake(padding_Left+imgW+padding_Left, 43,self.bounds.size.width, 22);
    
    return 82;
}

-(CGFloat)cell_mine_score{
    CGFloat imgW=28;
    CGFloat imgH=28;
    
    CGFloat padding_Left=(SCREEN_WIDTH/4-imgW)/2;
    
    _img0.image=[UIImage imageNamed:@"tz"];
    _img0.layer.borderWidth=0;
    _img0.frame=CGRectMake(padding_Left, 12, imgW, imgH);
    
    _img1.image=[UIImage imageNamed:@"jq"];
    _img1.layer.borderWidth=0;
    _img1.frame=CGRectMake(padding_Left+SCREEN_WIDTH/4, 12, imgW, imgH);

    _img2.image=[UIImage imageNamed:@"dj"];
    _img2.layer.borderWidth=0;
    _img2.frame=CGRectMake(padding_Left+SCREEN_WIDTH/2, 12, imgW, imgH);
    
    _video.hidden=NO;
    _video.image=[UIImage imageNamed:@"jf"];
    _video.layer.borderWidth=0;
    _video.frame=CGRectMake(padding_Left+SCREEN_WIDTH*3/4, 12, imgW, imgH);
    
    //_title.text=@"帖子 20000";
    //_title.textColor=CellInfoColor;
    CGSize titleSize = [_title.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:CellTitleFontSize-7]}];
    _title.font=[UIFont systemFontOfSize:CellTitleFontSize-7];
    padding_Left=(SCREEN_WIDTH/4-titleSize.width)/2;
    _title.frame=CGRectMake(padding_Left, imgH+18, SCREEN_WIDTH/4, 20);
    
    //_subtitle.text=@"金钱 230";
    CGSize subtitleSize = [_subtitle.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:CellTitleFontSize-7]}];
    _subtitle.font=[UIFont systemFontOfSize:CellTitleFontSize-7];
    _subtitle.textColor=_app.skin.colorCellTitle;
    padding_Left=(SCREEN_WIDTH/4-subtitleSize.width)/2;
    _subtitle.frame=CGRectMake(padding_Left+SCREEN_WIDTH/4, imgH+18, SCREEN_WIDTH/4, 20);
    
    //_level.text=@"等级 LV10";
    CGSize levelSize = [_level.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:CellTitleFontSize-7]}];
    _level.font=[UIFont systemFontOfSize:CellTitleFontSize-7];
    padding_Left=(SCREEN_WIDTH/4-levelSize.width)/2;
    _level.frame=CGRectMake(padding_Left+SCREEN_WIDTH/2, imgH+18, SCREEN_WIDTH/4, 20);
    _level.alpha=1;
    
    //_rank.text=@"积分 503011";
    CGSize rankSize = [_rank.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:CellTitleFontSize-7]}];
    _rank.font=[UIFont systemFontOfSize:CellTitleFontSize-7];
    padding_Left=(SCREEN_WIDTH/4-rankSize.width)/2;
    _rank.frame=CGRectMake(padding_Left+SCREEN_WIDTH*3/4, imgH+18, SCREEN_WIDTH/4, 20);
    _rank.alpha=1;
    
    _dateline.backgroundColor=_app.skin.colorCellSeparator;
    _dateline.frame=CGRectMake(SCREEN_WIDTH/4, 10, 1, 56);
    
    _flag.layer.borderWidth=0;
    _flag.backgroundColor=_app.skin.colorCellSeparator;
    _flag.hidden=NO;
    _flag.frame=CGRectMake(SCREEN_WIDTH/2, 10, 1, 56);
    
    _imginfo.backgroundColor=_app.skin.colorCellSeparator;
    _imginfo.hidden=NO;
    _imginfo.frame=CGRectMake(SCREEN_WIDTH*3/4, 10, 1, 56);
    
    return 80;
}


-(CGFloat)cell_text_one{
    _title.font=[UIFont systemFontOfSize:CellTitleFontSize-3];
    _title.textAlignment=NSTextAlignmentLeft;
    _title.frame=CGRectMake(14, 0,self.bounds.size.width, 40);
    return 40;
}

-(CGFloat)cell_text_one_end{
    _title.font=[UIFont systemFontOfSize:CellTitleFontSize-3];
    _title.textAlignment=NSTextAlignmentLeft;
    _title.frame=CGRectMake(64, 0,self.bounds.size.width, 100);
    return 100;
}

-(CGFloat)cell_menu_bbs_left{
    _title.textAlignment=NSTextAlignmentCenter;
    _title.frame=CGRectMake(0, 0,self.bounds.size.width, 50);
    _subtitle.frame=CGRectMake(0,0,4, 50);
    return 50;
}

-(CGFloat)cell_menu_bbs_right{
    /*if (_btn==nil) {
        _btn=[[UIButton alloc]init];
        _btn.layer.cornerRadius = 15.0;
        _btn.titleLabel.font = [UIFont systemFontOfSize: 15.0];
        _btn.layer.borderColor = [UIColor redColor].CGColor;
        [_btn setTitleColor:[UIColor redColor]forState:UIControlStateNormal];
        _btn.layer.borderWidth = 0.8f;
        [self addSubview:_btn];
    }*/
    CGFloat padding_Left=14;                            //左边距
    CGFloat padding_top=7;                             //上边距
    _img0.layer.cornerRadius = 5;
    _img0.clipsToBounds = YES;
    _img0.frame=CGRectMake(padding_Left, padding_top, 56, 56);
    CGFloat cellH=padding_top+56+padding_top;
    
    _title.frame=CGRectMake(padding_Left+56+padding_Left, padding_top+12,self.bounds.size.width-100, 30);
    //_subtitle.frame=CGRectMake(padding_Left+56+padding_Left, padding_top+25,self.bounds.size.width-100, 30);
    
    //_img1.image=[UIImage imageNamed:@"start"];
    //_img1.layer.borderWidth=0;
    //_img1.frame=CGRectMake(padding_Left+56+padding_Left, padding_top+28,22, 22);
    
    //[_btn setTitle:@"收藏" forState:UIControlStateNormal];
    //_btn.frame=CGRectMake(self.bounds.size.width-85, padding_top+12,70, 30);
    
    return cellH;
}

-(CGFloat)cell_news_text{
    CGRect bounds =[ UIScreen mainScreen ].bounds;
    CGFloat padding_Left=14;                            //左边距
    CGFloat padding_top=14;                             //上边距
    CGFloat padding_right=14;                           //右边距
    CGFloat padding_bottom=14;                          //下边距
    
    CGFloat cellW=bounds.size.width -padding_Left-padding_right;    //单元宽度
    
    _img0.hidden=YES;
    _img1.hidden=YES;
    _img2.hidden=YES;
    
    
    CGSize titleSize=[CjwFun sizeForText:_title width:cellW font:[UIFont systemFontOfSize:CellTitleFontSize-1] lineSapce:3];
    _title.numberOfLines = 0;
    _title.lineBreakMode = NSLineBreakByWordWrapping;
    _title.frame=CGRectMake(padding_Left, padding_top,cellW, titleSize.height);
    
    _subtitle.hidden=YES;
    _dateline.hidden=YES;
    
    return padding_top+titleSize.height+padding_bottom;
}

@end
