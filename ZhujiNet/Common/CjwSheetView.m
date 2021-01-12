//
//  CjwSheetView.m
//  ZhujiNet
//
//  Created by zhujiribao on 2017/9/2.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import "CjwSheetView.h"

@implementation CjwSheetView

- (id)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame])
    {
        //alpha 0.0  白色   alpha 1 ：黑色   alpha 0～1 ：遮罩颜色，逐渐
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
        self.alpha = 0.0;
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeView)]];
        
        if (_contentView == nil){
            _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, frame.size.height*0.7, frame.size.width, frame.size.height*0.3)];
            _contentView.backgroundColor = [UIColor whiteColor];
            [self addSubview:_contentView];
        }
    }
    
    return self;
}

- (void)loadMaskView{
}

- (void)addContentView:(UIView *)view{
    [_contentView addSubview:view];
    self.contnetHeight=view.frame.size.height;
}

//展示从底部向上弹出的UIView（包含遮罩）
- (void)showInView:(UIView *)view{
    self.hidden=NO;
    if (!view){
        return;
    }
    
    [view addSubview:self];
    [view addSubview:_contentView];
    
    [_contentView setFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, self.contnetHeight)];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0;
        [_contentView setFrame:CGRectMake(0, self.frame.size.height - self.contnetHeight, self.frame.size.width, self.contnetHeight)];
    } completion:nil];
}

//移除从上向底部弹下去的UIView（包含遮罩）
- (void)closeView{
    [_contentView setFrame:CGRectMake(0, self.frame.size.height - self.contnetHeight, self.frame.size.width, self.contnetHeight)];
    [UIView animateWithDuration:0.3f
                     animations:^{
                         self.alpha = 0.0;
                         [_contentView setFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, self.contnetHeight)];
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                         [_contentView removeFromSuperview];
                         if(self.blockCloseViewAction){
                             self.blockCloseViewAction();
                         }
                     }];
}


- (void)closeViewNoBlock{
    [_contentView setFrame:CGRectMake(0, self.frame.size.height - self.contnetHeight, self.frame.size.width, self.contnetHeight)];
    [UIView animateWithDuration:0.3f
                     animations:^{
                         self.alpha = 0.0;
                         [_contentView setFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, self.contnetHeight)];
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                         [_contentView removeFromSuperview];
                     }];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
