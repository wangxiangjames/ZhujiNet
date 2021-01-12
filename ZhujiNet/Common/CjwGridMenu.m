//
//  CjwGridMenu.m
//  ZhujiNet
//
//  Created by chenjinwei on 2017/6/2.
//  Copyright © 2017年 zhuji.net. All rights reserved.
//

#import "CjwGridMenu.h"
#import "Masonry.h"
#import "UIImageView+WebCache.h"

@interface CjwGridMenuLayout: UICollectionViewLayout

@property (assign,nonatomic) NSInteger rowCount;
@property (assign,nonatomic) NSInteger columCount;
/**
 获取当前的页数
 @return 页数
 */
-(NSInteger)pageCount;

/**
 预计算 contentSize 大小
 */
@property (assign,nonatomic) CGSize contentSize;
/**
 预计算所有的 cell 布局属性
 */
@property (strong,nonatomic) NSMutableArray<UICollectionViewLayoutAttributes *> *layoutAttributes;

@end

@implementation CjwGridMenuLayout

-(NSMutableArray<UICollectionViewLayoutAttributes *> *)layoutAttributes{
    if (_layoutAttributes == nil) {
        _layoutAttributes = [NSMutableArray array];
    }
    return _layoutAttributes;
}

/**
 获取每页最多有多少个选项
 @return 返回选项数
 */
-(NSInteger)maxNumberOfItemsPerPage{
    return self.rowCount * self.columCount;
}

-(NSInteger)pageCount{
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    NSInteger maxCountPerPage = [self maxNumberOfItemsPerPage];
    return ((count % maxCountPerPage) == 0) ? (count / maxCountPerPage) : ((int)(count * 1.0 / maxCountPerPage) + 1);
}

/**
 准备layout
 */
-(void)prepareLayout{
    //清理工作
    [self.layoutAttributes removeAllObjects];
    self.contentSize = CGSizeZero;
    //预先计算好所有的 layout 属性
    //预计算 contentSize
    //先要拿到 到底有多少个 item
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    NSInteger maxCountPerPage = [self maxNumberOfItemsPerPage];
    //计算一共多少页
    NSInteger pageCount = [self pageCount];
    //预计算了 contentSize
    self.contentSize = CGSizeMake(pageCount * self.collectionView.frame.size.width, self.collectionView.frame.size.height);
    //与计算每个cell的属性大小
    for(NSInteger i = 0; i < count;i++){
        // 创建索引
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        // 通过索引创建 cell 布局属性
        // UICollectionViewLayoutAttributes 这个内部应该保存 cell 布局以及一些位置信息等等
        UICollectionViewLayoutAttributes *layoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        [self.layoutAttributes addObject:layoutAttribute];
    }
    
    NSInteger index = 0;
    NSInteger itemWidth = self.collectionView.frame.size.width / self.columCount;
    NSInteger itemHeight = self.collectionView.frame.size.height / self.rowCount;
    
    // 具体计算每个布局属性到底是多少
    for (NSInteger i = 0; i < pageCount; i++) {
        for (NSInteger j = 0; j < self.rowCount; j++) {
            for (NSInteger k = 0; k < self.columCount; k++) {
                index = i * maxCountPerPage + j * self.columCount + k;
                if(index >= count) {break;}
                // 当前获取的布局属性
                UICollectionViewLayoutAttributes *currentLayoutAttribute = self.layoutAttributes[i * maxCountPerPage + j * self.columCount + k];
                CGFloat x = i * self.collectionView.frame.size.width + k * itemWidth;
                CGFloat y = j * (itemHeight-8);
                currentLayoutAttribute.frame = CGRectMake(x, y, itemWidth, itemHeight);
            }
            if(index >= count) {break;}
        }
        if(index >= count) {break;}
    }
}

-(CGSize)collectionViewContentSize{
    return self.contentSize;
}

/**
 在指定区域范围内需要提供cell信息
 @param rect 执行区域
 @return 属性列表
 */
-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    NSMutableArray<UICollectionViewLayoutAttributes *> *visibledAttributes = [NSMutableArray array];
    [self.layoutAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectIntersectsRect(obj.frame, rect)) {
            [visibledAttributes addObject:obj];
        }
    }];
    return visibledAttributes;
}

@end

//------------------------------------------------------------
@interface CjwGridMenuCell : UICollectionViewCell
@property (strong, nonatomic) UILabel       *titleLabel;
@property (strong, nonatomic) UIImageView   *iconImageView;
@property (assign, nonatomic) NSUInteger    iconWidth;
@property (assign, nonatomic) CGFloat       cornerRadius;
- (void)setFrame;
@end

@implementation CjwGridMenuCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [UILabel new];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:_titleLabel];
        _iconImageView = [UIImageView new];
        [self.contentView addSubview:_iconImageView];
    }
    return self;
}

- (void)setFrame {
    self.iconImageView.layer.cornerRadius = self.cornerRadius;
    //self.iconImageView.layer.cornerRadius = width / 2;
    self.iconImageView.clipsToBounds = YES;
    
    [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(_iconWidth, _iconWidth));
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(@15);
        
    }];
    
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_iconImageView.mas_bottom);
        make.centerX.equalTo(self.contentView);
        make.height.mas_equalTo(25);
    }];
}

@end

//------------------------------------------------------------
@interface CjwGridMenu ()<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate>

@property (strong,nonatomic) UICollectionView   *collectionView;
@property (strong,nonatomic) UIPageControl      *pageControl;
@property (strong,nonatomic) CjwGridMenuLayout  *layout;

@end

@implementation CjwGridMenu

- (UIPageControl *)pageControl {
    if(_pageControl == nil) {
        _pageControl = [UIPageControl new];
        _pageControl.hidesForSinglePage=YES;
        _pageControl.enabled=NO;
        _pageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.5 alpha:0.2];
        if(self.delegate && [self.delegate respondsToSelector:@selector(colorForCurrentPageControlInCjwGridMenu:)]) {
            _pageControl.currentPageIndicatorTintColor = [self.delegate colorForCurrentPageControlInCjwGridMenu:self];
        } else {
            _pageControl.currentPageIndicatorTintColor = [UIColor grayColor];
        }
        [self addSubview:_pageControl];
        [_pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.bottom.equalTo(self).offset(6);
        }];
    }
    return _pageControl;
}

-(UICollectionView *)collectionView{
    
    if (_collectionView == nil) {
        self.layout = [CjwGridMenuLayout new];
        
        //设置行数
        if (self.delegate && [self.delegate respondsToSelector:@selector(numberOfRowsPerPageInCjwGridMenu:)]) {
            self.layout.rowCount = [self.delegate numberOfRowsPerPageInCjwGridMenu:self];
        }else{
            self.layout.rowCount = 2;
        }
        
        // 设置列数
        if(self.delegate && [self.delegate respondsToSelector:@selector(numberOfColumnsPerPageInCjwGridMenu:)]) {
            self.layout.columCount = [self.delegate numberOfColumnsPerPageInCjwGridMenu:self];
        } else {
            self.layout.columCount = 4;
        }
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        _collectionView.pagingEnabled = YES;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[CjwGridMenuCell class] forCellWithReuseIdentifier:@"CELL"];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [self addSubview:_collectionView];
        [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.bottom.equalTo(self.pageControl.mas_bottom).offset(-10);
        }];
        //_collectionView.backgroundColor=[UIColor redColor];
        [self bringSubviewToFront:_collectionView];
    }
    return _collectionView;
}

/**
 刷新
 */
-(void)reloadData{
    [self.collectionView reloadData];
    self.pageControl.numberOfPages = [self.layout pageCount];
    self.pageControl.currentPage = 0;
}

#pragma mark - UIScrollViewDelegate -
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.pageControl.currentPage = scrollView.contentOffset.x / scrollView.frame.size.width;
}


#pragma mark - UICollectionViewDataSource -
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = 0;
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfItemsInCjwGridMenu:)]) {
        count = [self.dataSource numberOfItemsInCjwGridMenu:self];
    }
    return count;
}

- (CjwGridMenuCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CjwGridMenuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
    NSString *title = @"";
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(cjwGridMenu:titleForItemAtIndex:)]) {
        title = [self.dataSource cjwGridMenu:self titleForItemAtIndex:indexPath.row];
    }
    cell.titleLabel.text = title;
    cell.titleLabel.textColor=self.colorText;
    cell.iconWidth=self.iconWidth;
    cell.iconImageView.alpha=self.iconAlpha;
    cell.cornerRadius=self.cornerRadius;
    [cell setFrame];
    
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(cjwGridMenu:iconURLForItemAtIndex:)]) {
        NSURL *url = [self.dataSource cjwGridMenu:self iconURLForItemAtIndex:indexPath.row];
        if(self.defaultImage) {
            [cell.iconImageView sd_setImageWithURL:url placeholderImage:self.defaultImage];
        } else {
            [cell.iconImageView sd_setImageWithURL:url];
        }
    }
    return cell;
}


#pragma mark - UICollectionViewDelegate -
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(self.delegate && [self.delegate respondsToSelector:@selector(cjwGridMenu:didSelectItemAtIndex:)]) {
        [self.delegate cjwGridMenu:self didSelectItemAtIndex:indexPath.row];
    }
}
@end
