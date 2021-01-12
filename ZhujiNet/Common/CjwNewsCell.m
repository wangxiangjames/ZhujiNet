//
//  CjwCell.m
//  CjwSchool
//
//  Created by chenjinwei on 16/4/13.
//  Copyright © 2016年 chenjinwei. All rights reserved.
//
#import "Define.h"
#import "AppDelegate.h"
#import "CjwNewsCell.h"
#import "UIImage+Mycategory.h"
#import "UILabel+LineWordSpace.h"
#import "UIImageView+WebCache.h"
#define CellTitleFontSize 19
#define CellSubTitleFontSize 12
#define CellFlagFontSize 10

@interface CjwNewsCell(){
    AppDelegate     *_app ;
}
@end

@implementation CjwNewsCell

/*- (void)awakeFromNib {
    // Initialization code
}*/

//  Cell的构造方法
+ (instancetype)creatWithNib :(NSString *)nibName inTableView :(UITableView *)tableView
{
    CjwNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:nibName];
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
    
    _img0=[[SJPlayerSuperImageView alloc]init];
    [self.contentView addSubview:_img0];
    _img1=[[FLAnimatedImageView alloc]init];
    [self.contentView addSubview:_img1];
    _img2=[[FLAnimatedImageView alloc]init];
    [self.contentView addSubview:_img2];
    
    _img0.contentMode=UIViewContentModeScaleAspectFill;
    _img0.clipsToBounds = YES;
    _img1.contentMode=UIViewContentModeScaleAspectFill;
    _img1.clipsToBounds = YES;
    _img2.contentMode=UIViewContentModeScaleAspectFill;
    _img2.clipsToBounds = YES;
    
    _imginfo=[[UILabel alloc]init];
    _imginfo.font=[UIFont systemFontOfSize:CellFlagFontSize];
    _imginfo.textAlignment = NSTextAlignmentCenter;
    _imginfo.layer.cornerRadius = 5;
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
    
    _title.textColor=_app.skin.colorCellTitle;
    
    _subtitle.textColor=_app.skin.colorCellSubTitle;
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
    _dateline.text=item.dateline;
    _flag.text=item.flag;
    _imginfo.text=item.imginfo;

    if (item.url_pic0!=nil && item.url_pic0.length>0) {
        [_img0 sd_setImageWithURL:[NSURL URLWithString:item.url_pic0] placeholderImage:ImageNamed(kImgHolder)
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                           if(error){
                               _img0.image=ImageNamed(kImgHolder);
                           }
                       }];
    }
    /*else{
        _img0.image=[UIImage imageNamed:item.img];
    }*/
    
    if (item.url_pic1!=nil && item.url_pic0.length>0) {
        [_img1 sd_setImageWithURL:[NSURL URLWithString:item.url_pic1] placeholderImage:ImageNamed(kImgHolder)
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                            if(error){
                                _img1.image=ImageNamed(kImgHolder);
                            }
                        }];
    }
    /*else{
        _img1.image=[UIImage imageNamed:item.img];
    }*/
    
    if (item.url_pic2!=nil && item.url_pic0.length>0) {
        [_img2 sd_setImageWithURL:[NSURL URLWithString:item.url_pic2] placeholderImage:ImageNamed(kImgHolder)
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                            if(error){
                                _img2.image=ImageNamed(kImgHolder);
                            }
                        }];
    }
    /*else{
        _img2.image=[UIImage imageNamed:item.img];
    }*/
    
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
            
        case cell_type_news_text:
            cellH=self.cell_news_text;
            break;
            
        case cell_type_news_pic_one:
            cellH=self.cell_news_pic_one;
            break;
            
        case cell_type_news_pic_three:
            cellH=self.cell_news_pic_three;
            break;
            
        case cell_type_news_pic_one_big:
            cellH=self.cell_news_pic_one_big;
            break;
            
        case cell_type_news_pic_one_ad:
            cellH=self.cell_news_pic_one_ad;
            break;
            
        default:
            break;
    }
    //NSLog(@"CjwCell height:%f",cellH);
    return cellH;
}

-(CGFloat)cell_news_text{
    CGRect bounds =[ UIScreen mainScreen ].bounds;
    CGFloat padding_Left=14;                            //左边距
    CGFloat padding_top=14;                             //上边距
    CGFloat padding_right=14;                           //右边距
    CGFloat padding_bottom=14;                          //下边距
    CGFloat spaceV=10;                                  //垂直间距
    
    CGFloat cellW=bounds.size.width -padding_Left-padding_right;    //单元宽度
    
    _img0.hidden=YES;
    _img1.hidden=YES;
    _img2.hidden=YES;


    CGSize titleSize=[CjwFun sizeForText:_title width:cellW font:[UIFont systemFontOfSize:CellTitleFontSize] lineSapce:3];
    _title.numberOfLines = 0;
    _title.lineBreakMode = NSLineBreakByWordWrapping;
    _title.frame=CGRectMake(padding_Left, padding_top,cellW, titleSize.height);
    
    CGFloat cellTextH=padding_top+titleSize.height+spaceV;
    CGFloat flagW=0;
    if([_flag.text length]>0){
        _flag.hidden=NO;
        flagW=CellSubTitleFontSize*[_flag.text length]+4;
        _flag.frame=CGRectMake(padding_Left, cellTextH-1, flagW, CellSubTitleFontSize+2);
        flagW=flagW+15;
    }
    else{
        _flag.hidden=YES;
    }
    _subtitle.frame=CGRectMake(padding_Left+flagW, cellTextH, cellW, CellSubTitleFontSize);
    
    CGSize datelineSize = [_dateline.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:CellSubTitleFontSize]}];
    _dateline.frame=CGRectMake(padding_Left+cellW-datelineSize.width, cellTextH, cellW, CellSubTitleFontSize);
    
    cellTextH=cellTextH+CellSubTitleFontSize+padding_bottom;
    return cellTextH;
}

-(CGFloat)cell_news_pic_one{
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
    
    //_subtitle.text=[NSString stringWithFormat:@"%@   %@", _subtitle.text,_dateline.text];
    //_dateline.text=@"";
    
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
    
    if (_subtitle.text.length>0) {
        [UILabel setWordSpaceForLabel:_subtitle withSpace:-0.6];
    }
    if (_dateline.text.length>0) {
        [UILabel setWordSpaceForLabel:_dateline withSpace:-0.6];
    }
    
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
    
    _title.font = [UIFont systemFontOfSize:CellTitleFontSize];
    _title.numberOfLines = 4;
    CGSize size = [_title sizeThatFits:CGSizeMake(textW, MAXFLOAT)];
    CGFloat titleHeight=size.height;
    
    CGFloat cellTextH=padding_top+titleHeight+spaceV;
    CGFloat yTop=padding_top;
    if(cellImgH>cellTextH){
        //yTop=padding_top+(cellImgH-cellTextH)/2;        //垂直居中显示
        cellTextH=cellImgH;
    }
    _title.frame=CGRectMake(padding_Left, yTop,textW, titleHeight);
    CGFloat flagW=0;
    if([_flag.text length]>0){
        flagW=CellSubTitleFontSize*[_flag.text length]+4;
        _flag.frame=CGRectMake(padding_Left, cellTextH, flagW, CellSubTitleFontSize+2);
        flagW=flagW+10;
    }
    _subtitle.frame=CGRectMake(flagW+padding_Left, cellTextH, textW, CellSubTitleFontSize);
    
    CGSize datelineSize = [_dateline.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:CellSubTitleFontSize]}];
    _dateline.frame=CGRectMake(padding_Left+cellW-datelineSize.width, cellTextH, datelineSize.width, CellSubTitleFontSize);
    
    return cellTextH+_subtitle.height+padding_bottom;
}

-(CGFloat)cell_news_pic_three{
    
    CGRect bounds =[ UIScreen mainScreen ].bounds;
    CGFloat padding_Left=14;                            //左边距
    CGFloat padding_top=14;                             //上边距
    CGFloat padding_right=14;                           //右边距
    CGFloat padding_bottom=14;                          //下边距
    CGFloat imgSapceH=3;                                //三图水平间距
    CGFloat spaceV=10;                                  //垂直间距
    
    CGFloat cellW=bounds.size.width -padding_Left-padding_right;    //单元宽度
    CGFloat imgW=(cellW-2*imgSapceH)/3;                               //图片宽度
    CGFloat imgH=imgW *0.625;                           //高是宽的5/8
    
    CGSize titleSize=[CjwFun sizeForText:_title width:cellW font:[UIFont systemFontOfSize:CellTitleFontSize] lineSapce:3];
    _title.numberOfLines = 0;
    _title.lineBreakMode = NSLineBreakByWordWrapping;
    _title.frame=CGRectMake(padding_Left, padding_top,cellW, titleSize.height);
    
    _img0.hidden=NO;
    _img1.hidden=NO;
    _img2.hidden=NO;
    
    CGFloat cellH=padding_top+titleSize.height+spaceV;
    _img0.frame=CGRectMake(padding_Left, cellH, imgW, imgH);
    _img1.frame=CGRectMake(padding_Left + imgW + imgSapceH, cellH, imgW, imgH);
    _img2.frame=CGRectMake(padding_Left + 2*(imgW + imgSapceH), cellH, imgW, imgH);
    
    if([_imginfo.text length]>0){
        CGSize imgInfoSize = CGSizeZero;
    
        if(_isVideo==YES){
            _imginfo.text=[NSString stringWithFormat:@"    %@",_imginfo.text ];
            imgInfoSize = [_imginfo.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:CellFlagFontSize]}];
            _video.frame=CGRectMake(padding_Left+cellW-imgInfoSize.width-2*spaceV, cellH+imgH-(CellFlagFontSize+4+spaceV), 20, 20);
        }
        else{
           imgInfoSize = [_imginfo.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:CellFlagFontSize]}];
        }
        
        _imginfo.frame=CGRectMake(padding_Left+cellW-imgInfoSize.width-2*spaceV, cellH+imgH-(CellFlagFontSize+4+spaceV), imgInfoSize.width+2*spaceV-4, imgInfoSize.height+8);
        
    }
    
    cellH=cellH+imgH+spaceV;

    CGFloat flagW=0;
    if([_flag.text length]>0){
        flagW=CellSubTitleFontSize*[_flag.text length]+4;
        _flag.frame=CGRectMake(padding_Left, cellH-1, flagW, CellSubTitleFontSize+2);
        flagW=flagW+15;
    }
    _subtitle.frame=CGRectMake(padding_Left+flagW, cellH, cellW, CellSubTitleFontSize);
    
    CGSize datelineSize = [_dateline.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:CellSubTitleFontSize]}];
    _dateline.frame=CGRectMake(padding_Left+cellW-datelineSize.width, cellH, datelineSize.width, CellSubTitleFontSize);
    
    cellH=cellH+CellSubTitleFontSize+padding_bottom;
    return cellH;
}

-(CGFloat)cell_news_pic_one_big{
    
    CGRect bounds =[ UIScreen mainScreen ].bounds;
    CGFloat padding_Left=14;                            //左边距
    CGFloat padding_top=14;                             //上边距
    CGFloat padding_right=14;                           //右边距
    CGFloat padding_bottom=14;                          //下边距
    CGFloat spaceV=10;                                  //垂直间距
    
    CGFloat cellW=bounds.size.width -padding_Left-padding_right;    //单元宽度
    CGFloat imgW=cellW;                               //图片宽度
    CGFloat imgH=imgW *9/16;                           //高是宽的5/8
    
    CGSize titleSize=[CjwFun sizeForText:_title width:cellW font:[UIFont systemFontOfSize:CellTitleFontSize] lineSapce:3];
    _title.numberOfLines = 0;
    _title.lineBreakMode = NSLineBreakByWordWrapping;
    _title.frame=CGRectMake(padding_Left, padding_top,cellW, titleSize.height);
    
    _img0.hidden=NO;
    _img1.hidden=YES;
    _img2.hidden=YES;
    
    CGFloat cellH=padding_top+titleSize.height+spaceV;
    _img0.frame=CGRectMake(padding_Left, cellH, imgW, imgH);
    
    if(_isVideo==YES){
        _video.frame=CGRectMake(padding_Left+cellW/2-24, cellH+imgH/2-24, 48, 48);
    }
    
    if([_imginfo.text length]>0){
        CGSize imgInfoSize = [_imginfo.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:CellFlagFontSize]}];
        _imginfo.frame=CGRectMake(padding_Left+imgW-imgInfoSize.width-2*spaceV, cellH+imgH-(CellFlagFontSize+4+spaceV), imgInfoSize.width+2*spaceV-4, imgInfoSize.height+8);
    }
    
    cellH=cellH+imgH+spaceV;
    
    CGFloat flagW=0;
    if([_flag.text length]>0){
        flagW=CellSubTitleFontSize*[_flag.text length]+4;
        _flag.frame=CGRectMake(padding_Left, cellH-1, flagW, CellSubTitleFontSize+2);
        flagW=flagW+15;
    }

    _subtitle.frame=CGRectMake(padding_Left+flagW, cellH, cellW, CellSubTitleFontSize);
    
    CGSize datelineSize = [_dateline.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:CellSubTitleFontSize]}];
    _dateline.frame=CGRectMake(padding_Left+cellW-datelineSize.width, cellH, datelineSize.width, CellSubTitleFontSize);
    
    cellH=cellH+CellSubTitleFontSize+padding_bottom;
    return cellH;
}

-(CGFloat)cell_news_pic_one_ad{
    
    CGRect bounds =[ UIScreen mainScreen ].bounds;
    CGFloat padding_Left=14;                            //左边距
    CGFloat padding_top=14;                             //上边距
    CGFloat padding_right=14;                           //右边距
    CGFloat padding_bottom=14;                          //下边距
    CGFloat spaceV=10;                                  //垂直间距
    
    CGFloat cellW=bounds.size.width -padding_Left-padding_right;    //单元宽度
    CGFloat imgW=cellW;                               //图片宽度
    CGFloat imgH=imgW *3/10;                           //高是宽的5/8
    
    CGSize titleSize=[CjwFun sizeForText:_title width:cellW font:[UIFont systemFontOfSize:CellTitleFontSize] lineSapce:3];
    _title.numberOfLines = 0;
    _title.lineBreakMode = NSLineBreakByWordWrapping;
    _title.frame=CGRectMake(padding_Left, padding_top,cellW, titleSize.height);
    
    _img0.hidden=NO;
    _img1.hidden=YES;
    _img2.hidden=YES;
    
    CGFloat cellH=padding_top+titleSize.height+spaceV;
    _img0.frame=CGRectMake(padding_Left, cellH, imgW, imgH);
    if([_imginfo.text length]>0){
        CGSize imgInfoSize = [_imginfo.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:CellFlagFontSize]}];
        _imginfo.frame=CGRectMake(padding_Left+imgW-imgInfoSize.width-2*spaceV, cellH+imgH-(CellFlagFontSize+4+spaceV), imgInfoSize.width+2*spaceV-4, imgInfoSize.height+8);
    }
    
    cellH=cellH+imgH+spaceV;
    
    CGFloat flagW=0;
    if([_flag.text length]>0){
        flagW=CellSubTitleFontSize*[_flag.text length]+4;
        _flag.frame=CGRectMake(padding_Left, cellH-1, flagW, CellSubTitleFontSize+2);
        flagW=flagW+15;
        _flag.textColor=[UIColor colorWithHexString:@"007dfd"];
        _flag.layer.borderColor = [UIColor colorWithHexString:@"007dfd"].CGColor;
    }

    _subtitle.frame=CGRectMake(padding_Left+flagW, cellH, cellW, CellSubTitleFontSize);
    
    CGSize datelineSize = [_dateline.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:CellSubTitleFontSize]}];
    _dateline.frame=CGRectMake(padding_Left+cellW-datelineSize.width, cellH, datelineSize.width, CellSubTitleFontSize);
    
    cellH=cellH+CellSubTitleFontSize+padding_bottom;
    return cellH;
}

@end
