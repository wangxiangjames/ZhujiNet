//
//  CjwPicScroll.h
//  ZhujiNet
//
//  Created by zhujiribao on 2017/7/31.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PicScroll : UIScrollView
@property (nonatomic,assign)NSInteger contentHeight;
@property (nonatomic,copy) void(^blockTapImageViewAction)(UITapGestureRecognizer *gesture);
@property (nonatomic,copy) void(^blockLikeAction)(UIButton *sender);
- (id)initWithFrame:(CGRect)frame wihtHeight:(NSInteger)height;
-(void)updateHotPic:(NSArray*) array;
-(void)updateMenuPic:(NSArray*) array;
@end
