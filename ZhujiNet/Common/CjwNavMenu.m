//
//  CjwNavMenu.m
//  CjwSchool
//
//  Created by chenjinwei on 16/1/24.
//  Copyright © 2016年 chenjinwei. All rights reserved.
//

#import "CjwNavMenu.h"

@interface CjwNavMenu (){
    UIView          *_line;                 //滚动下划线
    NSMutableArray  *_buttoms;              //所有的Button集合
    NSArray         *_itemWidths;           //所有的Button的宽度集合
    CGFloat         _selectedWidth;         //被选中前面的宽度合（用于计算是否进行超过一屏，没有一屏则进行平分）
}
@end

@implementation CjwNavMenu
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame array:(NSArray*)items menuColor:(UIColor*)menucolor{
    self = [super initWithFrame:frame];
    if (self) {
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
    
        _menuSelectColor=[UIColor whiteColor];
        _menuColor=menucolor;
        _menuFont=[UIFont systemFontOfSize:17.f];
        _menuSelectFont=[UIFont systemFontOfSize:17.f];
        _eachSpace=30.f;

        
        //初始化数组
        /*if (!self.items) {
            self.items=@[@"新闻",@"财经",@"科技"];
        }*/
        self.items=items;
    
        _itemWidths=[[NSArray alloc]init];
        _itemWidths=[self calculateItemWidth];

        _buttoms=[[NSMutableArray alloc]init];
        CGFloat contentWidth =[self addButtoms];
        self.contentSize = CGSizeMake(contentWidth, 0);
        
        //self.contentInset = UIEdgeInsetsMake(0, 10, 0, 10); 相当于padding
    }
    return self;
}

-(NSArray *)calculateItemWidth{
    NSMutableArray *widths = [@[] mutableCopy];
    _selectedWidth = 0;
    for (NSString *item in _items)
    {
        CGSize size = [item boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : _menuFont} context:nil].size;
        CGFloat eachButtonWidth = size.width + _eachSpace;
        _selectedWidth += eachButtonWidth;
        NSNumber *width = [NSNumber numberWithFloat:eachButtonWidth];
        [widths addObject:width];
    }
    if (_selectedWidth < self.frame.size.width) {
        [widths removeAllObjects];
        NSNumber *width = [NSNumber numberWithFloat:self.frame.size.width / _items.count];
        for (int index = 0; index < _items.count; index++) {
            [widths addObject:width];
        }
    }
    return widths;
}

-(CGFloat)addButtoms{
    
    CGFloat buttonX = 0;
    for (NSInteger index = 0; index < self.items.count; index++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(buttonX, 0, [_itemWidths[index] floatValue], self.frame.size.height);
        button.titleLabel.font = _menuFont;
        button.backgroundColor = [UIColor clearColor];
        [button setTitle:self.items[index] forState:UIControlStateNormal];
        [button setTitleColor:self.menuColor forState:UIControlStateNormal];
        [button addTarget:self action:@selector(itemPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        [_buttoms addObject:button];
        buttonX += [_itemWidths[index] floatValue];
    }
    if (_itemWidths.count) {
        [self addLineWithButtonWidth:[_itemWidths[0] floatValue]];
    }
    return buttonX;
}

- (void)addLineWithButtonWidth:(CGFloat)width {
    _line = [[UIView alloc] initWithFrame:CGRectMake(2.0f, self.frame.size.height - 2.0f, width, 2.0f)];
    [self addSubview:_line];
}

-(void)setLineColor:(UIColor*)color{
    _lineColor=color;
    _line.backgroundColor = _lineColor;
}

-(void)setMenuFont:(UIFont *)font{
    _menuFont=font;
    _itemWidths=[self calculateItemWidth];
    CGFloat buttonX = 0;
    for (NSInteger index = 0; index < self.items.count; index++){
        UIButton* bt=(UIButton*)_buttoms[index];
        bt.frame=CGRectMake(buttonX, 0, [_itemWidths[index] floatValue], self.frame.size.height);
        bt.titleLabel.font=_menuFont;
        [bt setTitleColor:self.menuColor forState:UIControlStateNormal];
        buttonX += [_itemWidths[index] floatValue];
    }
    self.contentSize = CGSizeMake(buttonX, 0);
}

-(void)setEachSpace:(CGFloat)eachSpace{
    _eachSpace=eachSpace;
    _itemWidths=[self calculateItemWidth];
    CGFloat buttonX = 0;
    for (NSInteger index = 0; index < self.items.count; index++){
        UIButton* bt=(UIButton*)_buttoms[index];
        bt.frame=CGRectMake(buttonX, 0, [_itemWidths[index] floatValue], self.frame.size.height);
        buttonX += [_itemWidths[index] floatValue];
    }
    self.contentSize = CGSizeMake(buttonX, 0);
}

- (void)setCurrentIndex:(NSInteger)currentIndex
{
    _currentIndex = currentIndex;
    UIButton *button = nil;
    button = _buttoms[currentIndex];
    [button setTitleColor:_menuSelectColor forState:UIControlStateNormal];
    button.titleLabel.font=_menuSelectFont;
    CGFloat offsetX = button.center.x - self.frame.size.width* 0.5;
    CGFloat offsetMax = _selectedWidth - self.frame.size.width;
    if (offsetX < 0 || offsetMax < 0) {
        offsetX = 0;
    } else if (offsetX > offsetMax){
        offsetX = offsetMax;
    }
    [self setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    [UIView animateWithDuration:.2f animations:^{
        //_line.frame = CGRectMake(button.frame.origin.x + 2.0f+30, _line.frame.origin.y, [_itemWidths[currentIndex] floatValue] - 4.0f-60, _line.frame.size.height);
        //CGFloat w=[_itemWidths[currentIndex] floatValue]/4;
        CGFloat w=15;
        _line.frame = CGRectMake(button.frame.origin.x + 2.0f+w, _line.frame.origin.y, [_itemWidths[currentIndex] floatValue] - 4.0f-2*w, _line.frame.size.height);
    }];
}

- (void)itemPressed:(UIButton *)button
{
    NSInteger index = [_buttoms indexOfObject:button];
    self.currentIndex=index;
    
    if ([self.delegate respondsToSelector:@selector(navMeunDidSelectedWithIndex:)]) {
        [self.delegate navMeunDidSelectedWithIndex:index];
    }
    
    //修改选中跟没选中的Button字体颜色
    for (int i=0; i<_buttoms.count; i++) {
        if (i==index) {
            [button setTitleColor:_menuSelectColor forState:UIControlStateNormal];
            button.titleLabel.font = _menuSelectFont;
        }
        else {
            [_buttoms[i] setTitleColor:_menuColor forState:UIControlStateNormal];
            ((UIButton*)_buttoms[i]).titleLabel.font = _menuFont;
        }
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        button.transform = CGAffineTransformMakeScale(1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            button.transform = CGAffineTransformIdentity;
        }completion:^(BOOL finished) {
            
        }];
    }];
}

-(void)dealloc{
    self.delegate=nil;
    [_buttoms removeAllObjects];
    _buttoms=nil;
    _items=nil;
}

@end
