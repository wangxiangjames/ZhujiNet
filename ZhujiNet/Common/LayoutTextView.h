//
//  LayoutTextView.h
//  LayoutTextView
//
//  Created by JiaHaiyang on 16/7/6.
//  Copyright © 2016年 PlutusCat. All rights reserved.
//

#import <UIKit/UIKit.h>

#define Main_Screen_Height      [[UIScreen mainScreen] bounds].size.height
#define Main_Screen_Width       [[UIScreen mainScreen] bounds].size.width

@interface LayoutTextView : UIView

@property (weak, nonatomic) UITextView *textView;
@property (weak, nonatomic) UIButton *sendBtn;
@property (assign, nonatomic) BOOL isNavHide;
@property (copy, nonatomic) void (^(sendBlock)) (UITextView *textView);
@property (nonatomic,copy) void(^blockCanmeraAction)(UIButton *sender);
- (instancetype)initWithFrame:(CGRect)frame withCameraHide:(BOOL)isCameraHide;
@end
