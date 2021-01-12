//
//  CjwSheetView.h
//  ZhujiNet
//
//  Created by zhujiribao on 2017/9/2.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CjwSheetView : UIView

@property (nonatomic,assign) CGFloat contnetHeight;
@property (nonatomic,strong) UIView  *contentView;
@property (nonatomic,copy) void(^blockCloseViewAction)();

- (void)showInView:(UIView *)view;
- (void)closeView;
- (void)closeViewNoBlock;
- (void)addContentView:(UIView *)view;

@end
