//
//  CjwNavMenu.h
//  CjwSchool
//
//  Created by chenjinwei on 16/1/24.
//  Copyright © 2016年 chenjinwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NavMenuDelegate <UIScrollViewDelegate>
@optional - (void)navMeunDidSelectedWithIndex:(NSInteger)index;
@end

@interface CjwNavMenu : UIScrollView
@property (nonatomic, weak) id<NavMenuDelegate> delegate;
@property (nonatomic, assign) NSInteger         currentIndex;
@property (nonatomic, assign) CGFloat           eachSpace;
@property(nonatomic,copy)NSArray                *items;
@property(nonatomic,strong)UIColor              *lineColor;
@property(nonatomic,strong)UIColor              *menuColor;
@property(nonatomic,strong)UIColor              *menuSelectColor;
@property(nonatomic,strong)UIFont               *menuFont;
@property(nonatomic,strong)UIFont               *menuSelectFont;

- (id)initWithFrame:(CGRect)frame array:(NSArray*)items menuColor:(UIColor*)menucolor;
- (void)setCurrentIndex:(NSInteger)currentIndex;
@end
