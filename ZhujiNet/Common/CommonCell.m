//
//  CommonCell.m
//  ZhujiNet
//
//  Created by zhujiribao on 2018/3/7.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//
#import "Define.h"
#import "UILabel+LineWordSpace.h"
#import "UIView+Frame.h"
#import "HexColor.h"
#import "Masonry.h"
#import "UIImageView+WebCache.h"
#import "CommonCell.h"
#import "CjwFun.h"

@interface  CommonCell()

@property (nonatomic, assign)COMMON_CELL    cellType;
@property (nonatomic, strong)UILabel*       titleLable;
@property (nonatomic, strong)UILabel*       contentLable;
@property (nonatomic, strong)UILabel*       datetimeLable;
@property (nonatomic, strong)UILabel*       fieldLable;
@property (nonatomic, strong)UIImageView*   imgView;
@property (nonatomic, strong)UIImageView*   imgView1;
@property (nonatomic, strong)UIImageView*   imgView2;
@property (nonatomic, strong)UIButton*      btn;
@property (nonatomic, strong)UIButton*      btn2;
@end

@implementation CommonCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier typeCell:(COMMON_CELL) cellType{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubView];
        [self makeCellType:cellType];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubView];
    }
    return self;
}

- (void)initSubView {
    self.titleLable=[[UILabel alloc]init];
    self.titleLable.numberOfLines=0;
    [self.contentView addSubview:self.titleLable];
    
    self.contentLable=[[UILabel alloc]init];
    self.contentLable.numberOfLines=0;
    [self.contentView addSubview:self.contentLable];
    
    self.datetimeLable=[[UILabel alloc]init];
    [self.contentView addSubview:self.datetimeLable];

    self.imgView=[[UIImageView alloc]init];
    [self.contentView addSubview:self.imgView];
}

- (void)setFrame:(CGRect)frame {
    frame.size.height=self.height;
    [super setFrame:frame];
}

-(void)makeCellType:(COMMON_CELL)cellType{
    self.cellType=cellType;
    
    if (self.cellType==CELL_SYSINFO) {
        self.titleLable.font=[UIFont systemFontOfSize:18];
        
        self.contentLable.font=[UIFont systemFontOfSize:16];
        self.contentLable.textColor=[UIColor colorWithHexString:@"444444"];
        
        self.datetimeLable.textColor=[UIColor lightGrayColor];
        self.datetimeLable.font=[UIFont systemFontOfSize:12];
    }
    
    if (self.cellType==CELL_SEARCH) {
        self.titleLable.font=[UIFont systemFontOfSize:17];
        
        self.contentLable.textColor=[UIColor lightGrayColor];
        self.contentLable.font=[UIFont systemFontOfSize:12];
        
        self.datetimeLable.textColor=[UIColor lightGrayColor];
        self.datetimeLable.font=[UIFont systemFontOfSize:12];
        
        if(self.imgView1==nil){
            self.imgView1=[[UIImageView alloc]init];
            [self.contentView addSubview:self.imgView1];
        }
        if(self.imgView2==nil){
            self.imgView2=[[UIImageView alloc]init];
            [self.contentView addSubview:self.imgView2];
        }
    }

    if (self.cellType==CELL_SEARCH_USER) {
        self.titleLable.textColor=[UIColor lightGrayColor];
        self.titleLable.font=[UIFont systemFontOfSize:12];
        self.titleLable.numberOfLines=1;
        
        self.contentLable.textColor=[UIColor lightGrayColor];
        self.contentLable.font=[UIFont systemFontOfSize:12];
        self.contentLable.numberOfLines=1;
        
        self.datetimeLable.textColor=[UIColor lightGrayColor];
        self.datetimeLable.font=[UIFont systemFontOfSize:12];
        self.datetimeLable.numberOfLines=1;
        
        self.imgView.layer.cornerRadius=30;
        self.imgView.layer.masksToBounds=YES;
        self.imgView.layer.borderColor=[UIColor colorWithHexString:@"efefef"].CGColor;
        self.imgView.layer.borderWidth=0.5;
        self.imgView.userInteractionEnabled = YES;
        self.imgView.tag=0;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [self.imgView addGestureRecognizer:singleTap];
        
        if(self.imgView1==nil){
            self.imgView1=[[UIImageView alloc]init];
            [self.contentView addSubview:self.imgView1];
            self.imgView1.layer.cornerRadius=30;
            self.imgView1.layer.masksToBounds=YES;
            self.imgView1.layer.borderColor=[UIColor colorWithHexString:@"efefef"].CGColor;
            self.imgView1.layer.borderWidth=0.5;
            self.imgView1.userInteractionEnabled = YES;
            self.imgView1.tag=1;
            UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
            [self.imgView1 addGestureRecognizer:singleTap1];
        }
        if(self.imgView2==nil){
            self.imgView2=[[UIImageView alloc]init];
            [self.contentView addSubview:self.imgView2];
            self.imgView2.layer.cornerRadius=30;
            self.imgView2.layer.masksToBounds=YES;
            self.imgView2.layer.borderColor=[UIColor colorWithHexString:@"efefef"].CGColor;
            self.imgView2.layer.borderWidth=0.5;
            self.imgView2.userInteractionEnabled = YES;
            self.imgView2.tag=2;
            UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
            [self.imgView2 addGestureRecognizer:singleTap2];
        }
        
        if (self.btn==nil) {
            self.btn=[UIButton new];
            [self.btn setTitle:@"更多>>" forState:UIControlStateNormal];
            [self.btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            self.btn.titleLabel.font=[UIFont systemFontOfSize:13];
            [self.btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:self.btn];
        }
    }
    
    if (self.cellType==CELL_SEARCH_USER_MORE) {
        self.titleLable.textColor=[UIColor lightGrayColor];
        self.titleLable.font=[UIFont systemFontOfSize:12];
        self.titleLable.numberOfLines=1;
        
        self.imgView.layer.cornerRadius=30;
        self.imgView.layer.masksToBounds=YES;
        self.imgView.layer.borderColor=[UIColor colorWithHexString:@"efefef"].CGColor;
        self.imgView.layer.borderWidth=0.5;
    }
    
    if (self.cellType==CELL_MYTHEAD) {
        self.titleLable.font=[UIFont systemFontOfSize:17];
        
        self.contentLable.textColor=[UIColor lightGrayColor];
        self.contentLable.font=[UIFont systemFontOfSize:12];
        
        self.datetimeLable.textColor=[UIColor lightGrayColor];
        self.datetimeLable.font=[UIFont systemFontOfSize:12];
    }

    if (self.cellType==CELL_SHANG || self.cellType==CELL_FOLLOW) {
        self.titleLable.font=[UIFont systemFontOfSize:14];
        
        self.contentLable.font=[UIFont systemFontOfSize:15];
        self.contentLable.textColor=[UIColor colorWithHexString:@"444444"];
        
        self.datetimeLable.font=[UIFont systemFontOfSize:12];
        self.datetimeLable.textColor=[UIColor lightGrayColor];
        
        self.imgView.layer.cornerRadius=20;
        self.imgView.layer.masksToBounds=YES;
        self.imgView.layer.borderColor=[UIColor colorWithHexString:@"efefef"].CGColor;
        self.imgView.layer.borderWidth=0.5;
    }
    
    if (self.cellType==CELL_NEWS_THREE_IMG) {
        if(self.imgView1==nil){
            self.imgView1=[[UIImageView alloc]init];
            [self.contentView addSubview:self.imgView1];
        }
        if(self.imgView2==nil){
            self.imgView2=[[UIImageView alloc]init];
            [self.contentView addSubview:self.imgView2];
        }
    }
    
    if (self.cellType==CELL_NEWS_ONE_IMG || self.cellType==CELL_NEWS_THREE_IMG) {
        if (self.fieldLable==nil) {
            self.fieldLable=[[UILabel alloc]init];
            [self.contentView addSubview:self.fieldLable];
        }

        self.titleLable.numberOfLines=2;
        self.titleLable.font=[UIFont systemFontOfSize:18];
        
        self.contentLable.textColor=[UIColor lightGrayColor];
        self.contentLable.font=[UIFont systemFontOfSize:12];
        
        self.datetimeLable.textColor=[UIColor lightGrayColor];
        self.datetimeLable.font=[UIFont systemFontOfSize:12];
        
        self.fieldLable.layer.backgroundColor=[UIColor colorWithHexString:@"000000"  alpha:0.5].CGColor;
        self.fieldLable.textAlignment = NSTextAlignmentCenter;
        self.fieldLable.layer.cornerRadius = 8;
        self.fieldLable.font=[UIFont systemFontOfSize:10];
        self.fieldLable.textColor=[UIColor whiteColor];
    }
    
    if (self.cellType==CELL_NEWS_TEXT) {
        self.titleLable.numberOfLines=0;
        self.titleLable.font=[UIFont systemFontOfSize:18];
        
        self.contentLable.textColor=[UIColor lightGrayColor];
        self.contentLable.font=[UIFont systemFontOfSize:12];
        
        self.datetimeLable.textColor=[UIColor lightGrayColor];
        self.datetimeLable.font=[UIFont systemFontOfSize:12];
    }
}

-(void)setItem:(CjwItem *)item{
    self.titleLable.text=item.title;
    self.datetimeLable.text=item.dateline;
    
    if (self.cellType==CELL_SYSINFO) {
        self.contentLable.text=item.subtitle;
        [UILabel setLineSpaceForLabel:self.contentLable withSpace:3];
    }
    
    if (self.cellType==CELL_SEARCH) {
        if (item.flag!=nil) {
            NSRange range =[item.title rangeOfString:item.flag];
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:self.titleLable.text];
            [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:range];
            self.titleLable.attributedText=attrStr;
        }
        self.contentLable.text=item.from;
    }

    if (self.cellType==CELL_SEARCH_USER_MORE) {
        self.titleLable.text=item.author;
        self.titleLable.font=[UIFont systemFontOfSize:15];
        self.titleLable.textColor=[UIColor colorWithHexString:@"444444"];
        if (item.flag!=nil) {
            NSRange range =[self.titleLable.text rangeOfString:item.flag];
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:self.titleLable.text];
            [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:range];
            self.titleLable.attributedText=attrStr;
        }
        
        [self.imgView sd_setImageWithURL:[NSURL URLWithString:item.img]];
    }
    
    if (self.cellType==CELL_MYTHEAD) {

        if ([item.from isEqual:[NSNull null]] || [item.from isEqualToString:@""]) {
            self.contentLable.text=[NSString stringWithFormat:@"时间：%@    回复数：%@",item.dateline,item.replies];
        }
        else{
            self.contentLable.text=[NSString stringWithFormat:@"版块：%@    时间：%@    回复数：%@",item.from,item.dateline,item.replies];
        }
        self.datetimeLable.text=@" ";
    }
    
    if (self.cellType==CELL_SHANG) {
        self.contentLable.text=item.subtitle;
        [self.imgView sd_setImageWithURL:[NSURL URLWithString:
                                          [NSString stringWithFormat:@"http://bbs.zhuji.net//uc_server/avatar.php?uid=%@",item.authorid]]];
    }
    
    if (self.cellType==CELL_FOLLOW) {
        if (self.btn==nil) {
            self.btn=[UIButton new];
            [self.btn setTitle:@"取消关注" forState:UIControlStateNormal];
            [self.btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.btn.titleLabel.font=[UIFont systemFontOfSize:13];
            [self.btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
            self.btn.backgroundColor=[UIColor redColor];
            self.btn.layer.cornerRadius=4;
            [self.contentView addSubview:self.btn];
        }
        
        if (self.btn2==nil) {
            self.btn2=[UIButton new];
            [self.btn2 setTitle:@"他(她)的动态" forState:UIControlStateNormal];
            [self.btn2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.btn2.titleLabel.font=[UIFont systemFontOfSize:13];
            [self.btn2 addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
            self.btn2.backgroundColor=[UIColor redColor];
            self.btn2.layer.cornerRadius=4;
            [self.contentView addSubview:self.btn2];
        }
        
        [self.imgView sd_setImageWithURL:[NSURL URLWithString:
                                          [NSString stringWithFormat:@"http://bbs.zhuji.net//uc_server/avatar.php?uid=%@",item.authorid]]];
    }
    
    if (self.cellType==CELL_NEWS_ONE_IMG || self.cellType==CELL_NEWS_THREE_IMG) {
        self.contentLable.text=item.subtitle;
        self.fieldLable.text=item.imginfo;
        [self.imgView sd_setImageWithURL:[NSURL URLWithString:item.url_pic0]];
    }
    
    if (self.cellType==CELL_NEWS_THREE_IMG) {
        [self.imgView1 sd_setImageWithURL:[NSURL URLWithString:item.url_pic1]];
        [self.imgView2 sd_setImageWithURL:[NSURL URLWithString:item.url_pic2]];
    }
    
    if (self.cellType==CELL_NEWS_TEXT) {
        self.contentLable.text=item.subtitle;
    }
}

- (CGFloat)height
{
    CGFloat cellHeight=0;
    
    switch (self.cellType) {
        case CELL_SEARCH:
            cellHeight=[self search_height];
            break;
            
        case CELL_SEARCH_USER:
            cellHeight=[self search_height_user];
            break;
            
        case CELL_SEARCH_USER_MORE:
            cellHeight=[self search_height_user_more];
            break;
            
        case CELL_SYSINFO:
            cellHeight=[self sysinfo_height];
            break;
            
        case CELL_MYTHEAD:
            cellHeight=[self mythread_height];
            break;

        case CELL_SHANG:
            cellHeight=[self shang_height];
            break;
            
        case CELL_FOLLOW:
            cellHeight=[self follow_height];
            break;
        
        case CELL_NEWS_ONE_IMG:
            cellHeight=[self news_one_img_height];
            break;
            
        case CELL_NEWS_THREE_IMG:
            cellHeight=[self news_three_img_height];
            break;

        case CELL_NEWS_TEXT:
            cellHeight=[self news_text_height];
            break;
            
        default:
            cellHeight=[self news_text_height];
            break;
    }
    return cellHeight;
}

-(void)setArray:(NSArray *)anArray{
    NSInteger count=anArray.count;
    if (count>=3) {
        CjwItem *item=anArray[0];
        [self.imgView sd_setImageWithURL:[NSURL URLWithString:item.img]];
        self.titleLable.text=item.author;
        
        item=anArray[1];
        [self.imgView1 sd_setImageWithURL:[NSURL URLWithString:item.img]];
        self.contentLable.text=item.author;
        
        item=anArray[2];
        [self.imgView2 sd_setImageWithURL:[NSURL URLWithString:item.img]];
        self.datetimeLable.text=item.author;
    }
    else if(count==2){
        CjwItem *item=anArray[0];
        [self.imgView sd_setImageWithURL:[NSURL URLWithString:item.img]];
        self.titleLable.text=item.author;
        
        item=anArray[1];
        [self.imgView1 sd_setImageWithURL:[NSURL URLWithString:item.img]];
        self.contentLable.text=item.author;
        
        self.imgView2.hidden=YES;
        
    }
    else if(count==1){
        CjwItem *item=anArray[0];
        [self.imgView sd_setImageWithURL:[NSURL URLWithString:item.img]];
        self.titleLable.text=item.author;
        
        self.imgView1.hidden=YES;
        self.imgView2.hidden=YES;
    }
    
    if(count<=3){
        self.btn.hidden=YES;
    }
    else{
        self.btn.hidden=NO;
    }
}

-(CGFloat) sysinfo_height{
    CGFloat contentWidth=[UIScreen mainScreen].bounds.size.width-20-20;
    
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(20);
        make.top.mas_equalTo(self.contentView).offset(10);
    }];
    
    [self.contentLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.titleLable.mas_bottom).offset(10);
        make.width.mas_lessThanOrEqualTo(contentWidth);
    }];

    [self.datetimeLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.contentLable.mas_bottom).offset(10);
    }];
    
    [self layoutIfNeeded];
    
    return self.datetimeLable.y+self.datetimeLable.height+10;
}

-(CGFloat) search_height{
    CGFloat contentWidth=[UIScreen mainScreen].bounds.size.width-20-20;
    
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.contentView).offset(10);
        make.width.mas_lessThanOrEqualTo(contentWidth);
    }];
    
    [self.contentLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.titleLable.mas_bottom).offset(10);
    }];
    
    [self.datetimeLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentLable.mas_right).offset(20);
        make.top.mas_equalTo(self.titleLable.mas_bottom).offset(10);
    }];
    
    [self layoutIfNeeded];
    
    return self.datetimeLable.y+self.datetimeLable.height+10;
}

-(CGFloat)search_height_user{
    CGFloat pad=(self.contentView.frame.size.width-3*60-40)/3;
    
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10);
        make.left.mas_equalTo(self.contentView).offset(pad);
        make.height.mas_equalTo(60);
        make.width.mas_equalTo(60);
    }];

    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.imgView.mas_bottom).offset(5);
        make.centerX.mas_equalTo(self.imgView);
    }];
    
    [self.imgView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10);
        make.left.equalTo(self.imgView.mas_right).offset(pad);
        make.height.mas_equalTo(60);
        make.width.mas_equalTo(60);
    }];
    
    [self.contentLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.imgView1.mas_bottom).offset(5);
        make.centerX.mas_equalTo(self.imgView1);
    }];
    
    [self.imgView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10);
        make.left.equalTo(self.imgView1.mas_right).offset(pad);
        make.height.mas_equalTo(60);
        make.width.mas_equalTo(60);
    }];
    
    [self.datetimeLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.imgView2.mas_bottom).offset(5);
        make.centerX.mas_equalTo(self.imgView2);
    }];
    
    [self.btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView).offset(-20);
    }];
    
    return 100;
}

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    UIImageView *image = (UIImageView *)[gestureRecognizer view];
    if (self.blockImageAction) {
        self.blockImageAction(image.tag);
    }
}

-(CGFloat)search_height_user_more{
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.height.mas_equalTo(60);
        make.width.mas_equalTo(60);
    }];
    
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.imgView.mas_right).offset(14);
        make.centerY.mas_equalTo(self.imgView);
    }];
    
    return 80;
}

-(CGFloat) mythread_height{
    CGFloat contentWidth=[UIScreen mainScreen].bounds.size.width-20-20;
    
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.contentView).offset(10);
        make.width.mas_lessThanOrEqualTo(contentWidth);
    }];
    
    [self.contentLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(self.titleLable.mas_bottom).offset(10);
    }];
    
    [self.datetimeLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentLable.mas_right).offset(20);
        make.top.mas_equalTo(self.titleLable.mas_bottom).offset(10);
    }];
    
    [self layoutIfNeeded];
    
    return self.datetimeLable.y+self.datetimeLable.height+10;
}

-(CGFloat) shang_height{
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(10);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.imgView.mas_right).offset(14);
        make.top.mas_equalTo(self.imgView).offset(4);
        make.width.mas_greaterThanOrEqualTo(@65);
    }];
    
    [self.datetimeLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLable);
        make.top.mas_equalTo(self.titleLable.mas_bottom).offset(4);
    }];

    [self.contentLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(10);
        make.left.mas_equalTo(self.titleLable.mas_right).offset(14);
        make.right.mas_equalTo(self.contentView).offset(-14);
    }];
    
    [self layoutIfNeeded];
    
    CGFloat contH=self.contentLable.y+self.contentLable.height+10;
    CGFloat imgH=self.imgView.y+self.imgView.height+10;
    return contH>imgH ? contH: imgH;
}


-(CGFloat) follow_height{
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(10);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.imgView.mas_right).offset(14);
        make.top.mas_equalTo(self.imgView).offset(4);
        make.width.mas_greaterThanOrEqualTo(@60);
    }];
    
    [self.datetimeLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLable);
        make.top.mas_equalTo(self.titleLable.mas_bottom).offset(4);
    }];
    
    [self.btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).offset(-10);
        make.centerY.mas_equalTo(self.contentView);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(30);
    }];
    
    [self.btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.btn.mas_left).offset(-10);
        make.centerY.mas_equalTo(self.contentView);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(30);
    }];
    
    [self layoutIfNeeded];
    
    return self.imgView.y+self.imgView.height+10;
}

-(void)btnAction:(UIButton *)sender{
    if (self.blockBtnAction) {
        self.blockBtnAction(sender);
    }
    NSLog(@"Btn");
}


-(CGFloat) news_one_img_height{
    CGFloat imgW= (SCREEN_WIDTH-28)/3;
    CGFloat imgH=imgW *0.625;
    
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(14);
        make.right.mas_equalTo(self.contentView).offset(-14);
        make.size.mas_equalTo(CGSizeMake(imgW, imgH));
    }];
    
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {;
        make.left.mas_equalTo(self.contentView).offset(14);
        make.centerY.mas_equalTo(self.imgView).offset(-7);
        make.right.mas_equalTo(self.imgView.mas_left).offset(-14);
    }];
    
    [self.contentLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(14);
        make.top.mas_equalTo(self.titleLable.mas_bottom).offset(10);
    }];
    
    [self.datetimeLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.imgView.mas_left).offset(-14);
        make.top.mas_equalTo(self.contentLable);
    }];
    
    [self.fieldLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.imgView).offset(-5);
        make.bottom.mas_equalTo(self.imgView).offset(-5);
        make.width.mas_greaterThanOrEqualTo(32);
        make.height.mas_equalTo(16);
    }];
    
    [self layoutIfNeeded];
    
    //CGFloat contH=self.contentLable.y+self.contentLable.height+10;
    CGFloat picH=self.imgView.y+self.imgView.height+10;
    //return contH > picH ? contH : picH;
    return picH;
}


-(CGFloat) news_three_img_height{
    CGFloat imgW= (SCREEN_WIDTH-28)/3;
    CGFloat imgH=imgW *0.625;

    CGSize titleSize=[CjwFun sizeForText:self.titleLable width:SCREEN_WIDTH-28 font:[UIFont systemFontOfSize:18] lineSapce:3];
    
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(10);
        make.left.mas_equalTo(self.contentView).offset(14);
        make.right.mas_equalTo(self.contentView).offset(-14);
    }];
    
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLable.mas_bottom).offset(10);
        make.left.mas_equalTo(self.contentView).offset(14);
        make.size.mas_equalTo(CGSizeMake(imgW, imgH));
    }];

    [self.imgView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLable.mas_bottom).offset(10);
        make.left.mas_equalTo(self.imgView.mas_right).offset(2);
        make.size.mas_equalTo(CGSizeMake(imgW, imgH));
    }];
    
    [self.imgView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLable.mas_bottom).offset(10);
        make.left.mas_equalTo(self.imgView1.mas_right).offset(2);
        make.size.mas_equalTo(CGSizeMake(imgW, imgH));
    }];
    
    [self.contentLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(14);
        make.top.mas_equalTo(self.imgView.mas_bottom).offset(10);
    }];
    
    [self.datetimeLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView).offset(-14);
        make.top.mas_equalTo(self.imgView.mas_bottom).offset(10);
    }];
    
    [self.fieldLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.imgView2).offset(-5);
        make.bottom.mas_equalTo(self.imgView2).offset(-5);
        make.width.mas_greaterThanOrEqualTo(32);
        make.height.mas_equalTo(16);
    }];
    
    return 10+titleSize.height+10+imgH+36;
    
    //[self layoutIfNeeded];
    //return self.datetimeLable.y+self.datetimeLable.height+10;
}


-(CGFloat) news_text_height{
    CGSize titleSize=[CjwFun sizeForText:self.titleLable width:SCREEN_WIDTH-28 font:[UIFont systemFontOfSize:18] lineSapce:3];
    [self.titleLable mas_makeConstraints:^(MASConstraintMaker *make) {;
        make.top.mas_equalTo(self.contentView).offset(10);
        make.left.mas_equalTo(self.contentView).offset(14);
        make.right.mas_equalTo(self.contentView).offset(-14);
    }];
    
    [self.contentLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLable.mas_bottom).offset(10);
        make.left.mas_equalTo(self.contentView).offset(14);
    }];
    
    [self.datetimeLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLable.mas_bottom).offset(10);
        make.right.mas_equalTo(self.contentView).offset(-14);
        make.height.mas_equalTo(14);
    }];
    
    return 10+titleSize.height+34;
}

@end
