//
//  UIImage+Tint.h
//  CjwSchool
//
//  Created by chenjinwei on 16/3/22.
//  Copyright © 2016年 chenjinwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Mycategory)

- (UIImage *) imageWithTintColor:(UIColor *)tintColor ;
- (UIImage *) imageWithGradientTintColor:(UIColor *)tintColor ;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
- (UIImage *)normalizedImage;

@end
