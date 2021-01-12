//
//  MenuEditController.m
//  ZhujiNet
//
//  Created by zhujiribao on 2017/8/30.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import "MenuEditController.h"
#import "BYDetailsList.h"
#import "MenuModel.h"

@interface MenuEditController (){
    AppDelegate                 *_app;
}

@property (nonatomic,strong) BYDetailsList *menuList;
@property (nonatomic,strong) NSMutableArray *listBottom;
@property (nonatomic,strong) NSMutableArray *listTop;
@end

@implementation MenuEditController

- (void)viewWillAppear:(BOOL)animated{

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.listTop=[NSMutableArray arrayWithCapacity:5];
    self.listBottom=[NSMutableArray arrayWithCapacity:5];
    
    for (MenuModel* item in self.menuArray) {
        if(item.ishide==1){
            [self.listBottom addObject:item.title];
        }
        else{
            [self.listTop addObject:item.title];
        }
    }
    
    __weak typeof(self) unself = self;
    
    if (!self.menuList) {
        self.menuList = [[BYDetailsList alloc] initWithFrame:CGRectMake(0, Height_StatusBar, kScreenW, kScreenH-Height_StatusBar)];
        self.menuList.layer.cornerRadius=6;
        self.menuList.layer.masksToBounds=YES;
        
        self.menuList.listAll = [NSMutableArray arrayWithObjects:self.listTop,self.listBottom, nil];
        self.menuList.longPressedBlock = ^(){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"sortBtnClick" object:unself userInfo:nil];
        };
        self.menuList.opertionFromItemBlock = ^(animateType type, NSString *itemName, int index){
            [unself.menuList itemRespondFromListBarClickWithItemName:itemName];
            if(unself.menuList.isEdit==NO && type==0){
                [unself refeshTabMenu:index withName:itemName];
                NSLog(@"tests2");
            }
        };
        self.menuList.blockCloseAction = ^(id sender){
            [unself refeshTabMenu:0 withName:@""];
             NSLog(@"tests");
        };
        
        [self.view addSubview:self.menuList];
    }
    
    if (self.tabViewController.curIndex<self.menuList.topView.count) {
        MenuModel* menu=self.menuArray[self.tabViewController.curIndex];
        [self.menuList itemRespondFromListBarClickWithItemName:menu.title];
    }

}

-(void)refeshTabMenu:(NSInteger)index withName:(NSString*) itemName{
    [self dismissViewControllerAnimated:YES completion:nil];
    //调整后的新菜单
    NSMutableArray *newMenuArray=[NSMutableArray arrayWithCapacity:20];
    for (int i=0; i<[self.menuList.topView count]; i++){
        UIButton* bt=self.menuList.topView[i];
        for (MenuModel* item in self.menuArray) {
            if([item.title isEqualToString:bt.titleLabel.text]){
                item.ishide=0;
                [newMenuArray addObject:item];
                break;
            }
        }
    }
    
    for (int i=0; i<[self.menuList.bottomView count]; i++){
        UIButton* bt=self.menuList.bottomView[i];
        for (MenuModel* item in self.menuArray) {
            if([item.title isEqualToString:bt.titleLabel.text]){
                item.ishide=1;
                [newMenuArray addObject:item];
                break;
            }
        }
    }
 
    _app = [AppDelegate getApp];
    _app.menu=newMenuArray;
    
    //判断新菜单与旧菜单是否相同，若不同更新菜单
    /*BOOL isArrayEqual=YES;
    /*if ([_app.menu count]==[self.menuArray count]) {
        for (int i=0; i<[_app.menu count]; i++) {
            if (_app.menu[i]!=self.menuArray[i]) {
                isArrayEqual=NO;
                break;
            }
        }
    }
    else{
        isArrayEqual=NO;
    }*/
    
    //-------------
    BOOL isArrayEqual=NO;
    if(isArrayEqual==NO){
        self.menuArray=_app.menu;
        NSArray *array = [MenuModel mj_keyValuesArrayWithObjectArray:_app.menu];    //菜单转换json保存
        [CjwFun putLocaionDict:kHomeTopMenu value:array];
        [self.tabViewController updateTabMenu];
    }

    
    //NSLog(@"chen:%@",itemName);
    //选取的点击的菜单
    for (int i=0; i<[self.menuList.topView count]; i++){
        UIButton* bt=self.menuList.topView[i];
        if([bt.titleLabel.text isEqualToString:itemName]){
            index=i;
            break;
        }
    }
    [self.tabViewController setTabMenu:index];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
