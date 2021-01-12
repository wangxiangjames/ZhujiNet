//
//  UILabel+LineWordSpace.h
//  ZjzxApp
//
//  Created by chenjinwei on 2017/3/27.
//  Copyright © 2017年 zhuji.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (LineWordSpace)
/**
 *  改变行间距
 */
+ (void)setLineSpaceForLabel:(UILabel *)label withSpace:(float)space;

/**
 *  改变字间距
 */
+ (void)setWordSpaceForLabel:(UILabel *)label withSpace:(float)space;

/**
 *  改变行间距和字间距
 */
+ (void)setSpaceForLabel:(UILabel *)label withLineSpace:(float)lineSpace wordSpace:(float)wordSpace;

@end
