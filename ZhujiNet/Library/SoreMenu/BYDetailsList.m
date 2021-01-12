//
//  BYSelectionDetails.m
//  BYDailyNews
//
//  Created by bassamyan on 15/1/18.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "BYDetailsList.h"
#import "BYListItem.h"


@interface BYDetailsList()

@property (nonatomic,strong) UIView *sectionHeaderView;

@property (nonatomic,strong) NSMutableArray *allItems;

@property (nonatomic,strong) BYListItem *itemSelect;

@property (nonatomic,strong) UILabel  *topText;

@property (nonatomic,strong) UIButton *btnEdit;
@property (nonatomic,assign) BOOL  isLongPressed;

@property (nonatomic,strong) UILabel *bottomSection;
@property (nonatomic,strong) UILabel *moreText;

@end

@implementation BYDetailsList

-(void)setListAll:(NSMutableArray *)listAll{
    _listAll = listAll;
    self.showsVerticalScrollIndicator = NO;
    self.contentInset = UIEdgeInsetsMake(70, 0, 20, 0);
    self.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1];
    
    NSArray *listTop = listAll[0];
    NSArray *listBottom = listAll[1];
    
#pragma 更多频道标签
    self.sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0,padding+(padding + kItemH)*((listTop.count -1)/itemPerLine+1),kScreenW, 30)];
    //self.sectionHeaderView.backgroundColor = RGBColor(238.0, 238.0, 238.0);
    self.bottomSection=[[UILabel alloc] initWithFrame:CGRectMake(20, 10, 80, 40)];
    self.bottomSection.text=@"频道推荐";
    self.bottomSection.font = [UIFont systemFontOfSize:19];
    [self.sectionHeaderView addSubview:self.bottomSection];
    
    self.moreText = [[UILabel alloc] initWithFrame:CGRectMake(112, 13, 100, 40)];
    self.moreText.textColor=[UIColor darkGrayColor];
    self.moreText.text = @"点击添加频道";
    self.moreText.font = [UIFont systemFontOfSize:12];
    [self.sectionHeaderView addSubview:self.moreText];
    [self addSubview:self.sectionHeaderView];
    
    //UIButton *btnClose=[[UIButton alloc]initWithFrame:CGRectMake(kScreenW-45, -65, 30, 30)];
    UIButton *btnClose=[[UIButton alloc]initWithFrame:CGRectMake(10, -65, 40, 40)];
    [btnClose setImage:[UIImage imageNamed:@"btn_close"] forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(actionClose:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btnClose];
    
    UILabel *topSection=[[UILabel alloc] initWithFrame:CGRectMake(20, -25, 80, 40)];
    topSection.text=@"我的频道";
    topSection.font = [UIFont systemFontOfSize:19];
    [self  addSubview:topSection];
    
    self.topText = [[UILabel alloc] initWithFrame:CGRectMake(112, -22, 100, 40)];
    self.topText.text = @"点击进入频道";
    self.topText.textColor=[UIColor darkGrayColor];
    self.topText.font = [UIFont systemFontOfSize:12];
    [self addSubview:self.topText];

    self.btnEdit=[[UIButton alloc] initWithFrame:CGRectMake(kScreenW-75, -16, 55, 26)];
    [self.btnEdit setTitle:@"编辑" forState:UIControlStateNormal];
    [self.btnEdit addTarget:self action:@selector(actionEdit:) forControlEvents:1<<6];
    [self.btnEdit setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.btnEdit.titleLabel.font=[UIFont systemFontOfSize:14];
    self.btnEdit.layer.cornerRadius=13;
    self.btnEdit.layer.borderColor=[UIColor redColor].CGColor;
    self.btnEdit.layer.borderWidth=0.5;
    
    [self addSubview:self.btnEdit];
    
     __weak typeof(self) unself = self;
    NSInteger count1 = listTop.count;
    for (int i =0; i <count1; i++) {
        BYListItem *item = [[BYListItem alloc] initWithFrame:CGRectMake(padding+(padding+kItemW)*(i% itemPerLine), padding+(kItemH + padding)*(i/itemPerLine)+10, kItemW, kItemH)];
        item.longPressBlock = ^(){
            if (unself.longPressedBlock) {
                unself.longPressedBlock();
                
                unself.isLongPressed=YES;
                [unself actionEdit:unself.btnEdit];
            }
        };
        item.operationBlock = ^(animateType type, NSString *itemName, int index){
            if (self.opertionFromItemBlock) {
                self.opertionFromItemBlock(type,itemName,index);
            }
            
           [self setBottomSectionText];

        };
        item.itemName = listTop[i];
        item.location = top;
        [self.topView addObject:item];
        item->locateView = self.topView;
        item->topView = self.topView;
        item->bottomView = self.bottomView;
        item.hitTextLabel = self.sectionHeaderView;
        [self addSubview:item];
        [self.allItems addObject:item];
        
        if (!self.itemSelect) {
            [item setTitleColor:[UIColor redColor] forState:0];
            self.itemSelect = item;
        }
    }
    
    NSInteger count2 = listBottom.count;
    for (int i=0; i<count2; i++) {
        BYListItem *item = [[BYListItem alloc] initWithFrame:CGRectMake(padding+(padding+kItemW)*(i%itemPerLine),CGRectGetMaxY(self.sectionHeaderView.frame)+padding+(kItemH+padding)*(i/itemPerLine)+10, kItemW, kItemH)];
        item.operationBlock = ^(animateType type, NSString *itemName, int index){
            if (self.opertionFromItemBlock) {
                self.opertionFromItemBlock(type,itemName,index);
                [self setBottomSectionText];
            }
        };
        item.itemName = listBottom[i];
        item.location = bottom;
        item.hitTextLabel = self.sectionHeaderView;
        [self.bottomView addObject:item];
        item->locateView = self.bottomView;
        item->topView = self.topView;
        item->bottomView = self.bottomView;
        [self addSubview:item];
        [self.allItems addObject:item];
    }
    [self setBottomSectionText];
    self.contentSize = CGSizeMake(kScreenW, CGRectGetMaxY(self.sectionHeaderView.frame)+padding+(kItemH+padding)*((count2-1)/4+1) + 50);
}

-(void)itemRespondFromListBarClickWithItemName:(NSString *)itemName{
    for (int i = 0 ; i<self.allItems.count; i++) {
        BYListItem *item = (BYListItem *)self.allItems[i];
        if ([itemName isEqualToString:item.itemName]) {
            [self.itemSelect setTitleColor:RGBColor(111.0, 111.0, 111.0) forState:0];
            [item setTitleColor:[UIColor redColor] forState:0];
            self.itemSelect = item;
        }
    }
}

-(NSMutableArray *)allItems{
    if (_allItems == nil) {
        _allItems = [NSMutableArray array];
    }
    return _allItems;
}

-(NSMutableArray *)topView{
    if (_topView == nil) {
        _topView = [NSMutableArray array];
    }
    return _topView;
}

-(NSMutableArray *)bottomView{
    if (_bottomView == nil) {
        _bottomView = [NSMutableArray array];
    }
    return _bottomView;
}

-(void)actionEdit:(UIButton*)sender{
    if (sender.selected) {
        self.isEdit=NO;
        [sender setTitle:@"编辑" forState:0];
        self.topText.text=@"点击进入频道";
    }
    else{
        self.isEdit=YES;
        [sender setTitle:@"完成" forState:0];
        self.topText.text=@"拖拽可以排序";
    }
    sender.selected = !sender.selected;
    if(self.isLongPressed==NO){
        self.longPressedBlock();
    }
    self.isLongPressed=NO;
}

-(void)actionClose:(id)sender{
    if(self.blockCloseAction){
        self.blockCloseAction(sender);
    }
}

-(void) setBottomSectionText
{
    /*if([self.bottomView count]>0){
        self.bottomSection.text=@"频道推荐";
        self.moreText.text=@"点击添加频道";
    }
    else{
        self.bottomSection.text=@"";
        self.moreText.text=@"";
    }*/
}

@end
