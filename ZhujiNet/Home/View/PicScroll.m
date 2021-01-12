//
//  CjwPicScroll.m
//  ZhujiNet
//
//  Created by zhujiribao on 2017/7/31.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import "PicScroll.h"
#import "Common.h"
#import "CircleHotModel.h"
#import "ForumSubModel.h"

@implementation PicScroll
- (id)initWithFrame:(CGRect)frame wihtHeight:(NSInteger)height{
    self = [super initWithFrame:frame];
    if (self) {
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.contentSize=CGSizeMake(100, height);
        self.contentHeight=height;
    }
    return self;
}

-(void)updateMenuPic:(NSArray*) array{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat picX = 0;
    CGFloat viewHeight=self.contentHeight;
    CGFloat itemWidth=50;
    
    for (NSInteger index = 0; index < [array count]; index++){
        
        ForumSubModel *forumsub=[array objectAtIndex:index];
        UIView* view=[[UIView alloc]init];
        
        UIImageView *iv = [[UIImageView alloc]init];
        iv.frame = CGRectMake(0, 0, itemWidth, itemWidth);
        [iv sd_setImageWithURL:[NSURL URLWithString:forumsub.image]];
        iv.layer.cornerRadius = itemWidth/2.0;
        iv.layer.masksToBounds = YES;
        [view addSubview:iv];
        
        UILabel* user=[[UILabel alloc]initWithFrame:CGRectMake(0, viewHeight-30, itemWidth, 30)];
        user.text=forumsub.name;
        user.font=[UIFont systemFontOfSize:12];
        user.textAlignment=NSTextAlignmentCenter;
        [view addSubview:user];
        
        view.frame= CGRectMake(picX, 0, itemWidth, viewHeight);
        view.layer.masksToBounds=YES;
        [self addSubview:view];
        UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImageViewAction:)];
        [view addGestureRecognizer:tapGesturRecognizer];
        view.tag=index;
        picX += itemWidth+21;
    }
    self.contentSize=CGSizeMake(picX-5, viewHeight);
}

-(void)updateHotPic:(NSArray*) array{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat picX = 0;
    CGFloat viewHeight=self.contentHeight;
    CGFloat itemWidth=100;
    
    for (NSInteger index = 0; index < [array count]; index++){
        
        CircleHotModel *hot=[array objectAtIndex:index];
        UIView* view=[[UIView alloc]init];
        
        UIImageView *iv = [[UIImageView alloc]init];
        iv.contentMode=UIViewContentModeScaleAspectFill;
        iv.clipsToBounds = YES;
        iv.frame = CGRectMake(0, 0, itemWidth, viewHeight-30);
        [iv sd_setImageWithURL:[NSURL URLWithString:hot.image]];
        [view addSubview:iv];
        
        UILabel* user=[[UILabel alloc]initWithFrame:CGRectMake(5, viewHeight-30, 70, 30)];
        user.text=hot.author;
        user.font=[UIFont systemFontOfSize:12];
        user.textColor=[UIColor lightGrayColor];
        [view addSubview:user];
        
        UIButton* danzan=[[UIButton alloc]initWithFrame:CGRectMake(itemWidth-30, viewHeight-30, 30, 30)];
        if (hot.islike==1) {
            [danzan setImage:[UIImage imageNamed:@"btn_zan"] forState:UIControlStateNormal];
        }
        else{
            [danzan setImage:[UIImage imageNamed:@"btn_no_zan"] forState:UIControlStateNormal];
        }

        [danzan addTarget:self action:@selector(actionLike:) forControlEvents:UIControlEventTouchUpInside];
        danzan.tag=index;
        danzan.alpha=0.6;
        [view addSubview:danzan];
        
        view.frame= CGRectMake(picX, 0, itemWidth, viewHeight);
        view.layer.cornerRadius=10;
        view.layer.borderWidth=1;
        view.layer.borderColor=[UIColor colorWithHexString:@"eeeeee"].CGColor;
        view.layer.masksToBounds=YES;
        [self addSubview:view];
        UITapGestureRecognizer *tapGesturRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapImageViewAction:)];
        [view addGestureRecognizer:tapGesturRecognizer];
        view.tag=index;
        picX += itemWidth+5;
    }
    self.contentSize=CGSizeMake(picX-5, viewHeight);
}

-(void)tapImageViewAction:(UITapGestureRecognizer*)gesture{
    UIView *view=(UIView*) gesture.view;
    NSLog(@"点击了tapView%ld",view.tag);
    
    if(self.blockTapImageViewAction){
        self.blockTapImageViewAction(gesture);
    }
}

-(void)actionLike:(id)sender{
    NSInteger i = [sender tag];
    NSLog(@"Danzan%ld",i);
    
    if(self.blockLikeAction){
        self.blockLikeAction(sender);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
