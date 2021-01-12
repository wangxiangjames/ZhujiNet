//
//  CjwTabViewController.m
//  ZhujiNet
//
//  Created by zhujiribao on 2017/7/19.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import "CjwTabViewController.h"
#import "ContentViewController.h"
#import "MenuModel.h"

static CGFloat const MaxScale = 1.12;    /** 选中文字放大  */
#define BtnInitialTag          10000

@interface CjwTabViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView      *contentScrollView;     /** 控制器scrollView */
@property (nonatomic, strong) UIScrollView      *menuScrollView;        /** 文字scrollView */
@property (nonatomic, strong) UIView            *menuLine;              /** 顶部下边的线条 */
@property (nonatomic ,strong) UIButton          *selectedBtn;           /** 选中的按钮 */
@property (nonatomic, strong) UIView            *selectBtnLine;         /** 选中的按钮下边的线条 */
@property (nonatomic, strong) NSMutableArray    *btArray;               /** 标签按钮 */
@property (nonatomic, assign) CGFloat           moreBtnWith;            /** 右边最多按钮宽度 */
@property (nonatomic, assign) CGFloat           tabBarHeight;           /** 底部高度 */
@property (nonatomic, assign) BOOL              isShowMidLine;          /** 是否中间线 》未实现 */
@end

@implementation CjwTabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBarHeight=self.tabBarController.tabBar.frame.size.height;
    self.menuHeight=40;
    
    self.minButtonWidth=56.0;
    self.moreBtnWith=0;
    self.titleFontSize=17;
    self.colorSelectBtnLine=[UIColor colorWithHexString:@"F32477"];
    self.colorMidLine=[UIColor colorWithHexString:@"F6F6F6"];
    self.colorMenuBackground=[UIColor colorWithHexString:@"FFFFFF"];
    self.colorMenuTitle=[UIColor colorWithHexString:@"222222"];
    self.colorMenuTitleSelect=[UIColor colorWithHexString:@"FF0000"];
    self.colorMenuLine=[UIColor colorWithHexString:@"F1F1F1"]; 
    
    [self addChildViewController];      /** 调用子控制器方法，初始标签，子视图  */
    [self setScrollView];
    [self setMenu];
}

-(void)addChildViewController{

}

#pragma mark lazy loading
- (NSMutableArray *)buttons
{
    if (!_btArray)
    {
        _btArray = [NSMutableArray array];
    }
    return _btArray;
}

-(void)setScrollView{
    //NSLog(@"view:%@",NSStringFromCGRect(self.view.frame));
    
    if(!self.menuScrollView){
        self.menuScrollView = [[UIScrollView alloc] init];
        self.menuScrollView.backgroundColor=self.colorMenuBackground;
        self.menuScrollView.showsHorizontalScrollIndicator = NO;
        [self.view addSubview:self.menuScrollView];
        
        if(self.btnMore){
            [self.view addSubview:self.btnMore];
        }
        
        self.menuLine = [[UIScrollView alloc] init];
        self.menuLine.backgroundColor=self.colorMenuLine;
        [self.view addSubview:self.menuLine];
        
        self.contentScrollView = [[UIScrollView alloc] init];
        self.contentScrollView.pagingEnabled = YES;
        self.contentScrollView.showsHorizontalScrollIndicator  = NO;
        self.contentScrollView.delegate = self;
        [self.view addSubview:self.contentScrollView];
    }
    //-----------------------------------------------
    self.menuScrollView.frame =CGRectMake(0, 0, SCREEN_WIDTH, self.self.menuHeight);
    
    //-----------------------------------------------
    if(self.btnMore){
        CGSize moreSize=self.btnMore.frame.size;
        self.moreBtnWith=moreSize.width;
        self.btnMore.frame=CGRectMake(SCREEN_WIDTH-moreSize.width,self.menuScrollView.frame.origin.y+(self.menuHeight-moreSize.height)/2,moreSize.width, moreSize.height);
        self.menuScrollView.frame =CGRectMake(0, 0, SCREEN_WIDTH-moreSize.width/2, self.self.menuHeight);
    }
    
    self.menuLine.frame =CGRectMake(0, self.menuHeight-1, SCREEN_WIDTH,1);
    //-----------------------------------------------
    CGFloat y  = CGRectGetMaxY(self.menuScrollView.frame);
    CGRect rectOfStatusbar = [[UIApplication sharedApplication] statusBarFrame];
    //NSLog(@"statusbar height: %f", rectOfStatusbar.size.height);   // 高度
    CGRect rectOfNavigationbar = self.navigationController.navigationBar.frame;
    //NSLog(@"navigationbar height: %f", rectOfNavigationbar.size.height);   // 高度
    
    self.contentScrollView.frame= CGRectMake(0, y, SCREEN_WIDTH, SCREEN_HEIGHT - self.menuHeight-rectOfStatusbar.size.height-rectOfNavigationbar.size.height-self.tabBarHeight);
    
    int num=0;
    for (int i = 0; i < self.menuArray.count; i++) {
        MenuModel* menu=self.menuArray[i];
        if(menu.ishide==1){
            num++;
        }
    }
    
    self.contentScrollView.contentSize = CGSizeMake((self.menuArray.count-num) * SCREEN_WIDTH, 0);

    /*if(self.childViewControllers.count>2){
        [self setOneChildController:1];
    }*/
}

-(void)setMenu{
    NSUInteger count = self.childViewControllers.count;
    CGFloat w =56;
    /*CGFloat w = SCREEN_WIDTH/self.menuArray.count;
    if (w < self.minButtonWidth) {
        w= self.minButtonWidth;
    }*/
    
    /*self.imageBackView  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, w, self.menuHeight-10)];
     self.imageBackView.image = [UIImage imageNamed:@"b1"];
     self.imageBackView.backgroundColor = [UIColor whiteColor];
     self.imageBackView.userInteractionEnabled = YES;
     [self.titleScrollView addSubview:self.imageBackView];*/
    
    self.menuScrollView.contentSize = CGSizeZero;
    if([self.buttons count]==0){
        for (int i = 0; i < count; i++){
            UIViewController *vc = self.childViewControllers[i];
            UIButton *btn = [[UIButton alloc] init];
            btn.tag = i+BtnInitialTag;
            [btn setTitle:vc.title forState:UIControlStateNormal];
            [btn setTitleColor:self.colorMenuTitle forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:self.titleFontSize];
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchDown];
            [self.buttons addObject:btn];
            [self.menuScrollView addSubview:btn];
            
            if (i == 0){
                [self btnClick:btn];
            }
        }
    }
    
    /*CGFloat x = 0;
    CGFloat padding_left=10;
    
    for (int i = 0; i < [self.buttons count]; i++){
        x = i * w+padding_left;
        
        CGRect rect = CGRectMake(x, 0, w, self.menuHeight);
        UIButton *bt=[self.buttons objectAtIndex:i];
        bt.frame=rect;
    }
    
    if (self.curIndex< self.buttons.count) {
        [self setBottomLine:[self.buttons objectAtIndex:self.curIndex]];
        self.menuScrollView.contentSize = CGSizeMake(count * w+self.moreBtnWith+padding_left, 0);
    }*/


    CGFloat totalWidth=10;
    CGFloat tempW=0;
    for (int i = 0; i < [self.buttons count]; i++){
        UIButton *bt=[self.buttons objectAtIndex:i];
        if ([bt.titleLabel.text length]>2) {
            tempW=[bt.titleLabel.text length]*20;
        }
        else{
            tempW=w;
        }
        
        CGRect rect = CGRectMake(totalWidth, 0, tempW, self.menuHeight);
        bt.frame=rect;
        totalWidth+=tempW;
    }

    if (self.curIndex< self.buttons.count) {
        [self setBottomLine:[self.buttons objectAtIndex:self.curIndex]];
        self.menuScrollView.contentSize = CGSizeMake(totalWidth+self.moreBtnWith*0.8, 0);
    }
    
    /*增加下边的下划线（视具体情况可省略）
     UIView * covertView = [[UIView alloc] initWithFrame:CGRectMake(0, self.menuHeight - 1, self.menuScrollView.contentSize.width, 1)];
     covertView.layer.backgroundColor=ColorRGBA(0, 0, 0, 0.5).CGColor;
     [self.view addSubview:covertView];
     */
    /*if (self.isShowMidLine) {
        //中间竖线
        for (int i = 0; i < self.menuArray.count; i++) {
            if(i==0){
                continue;
            }
            UIView * midselectBtnLine = [[UIView alloc] initWithFrame:CGRectMake((self.menuScrollView.contentSize.width-self.moreBtnWith)/self.menuArray.count * i, 7, 0.5, self.minButtonWidth/2)];
            midselectBtnLine.backgroundColor = self.colorMidLine;
            [self.menuScrollView addSubview:midselectBtnLine];
        }
    }*/
}

-(void)setTabMenu:(NSInteger)index{
    if (self.btArray.count==1) {
        return;
    }
    
    
    UIButton *myButton1 = (UIButton *)[self.menuScrollView viewWithTag:index+BtnInitialTag];
    [self btnClick:myButton1];
    
    /*CGFloat x  = index *SCREEN_WIDTH;
     self.contentScrollView.contentOffset = CGPointMake(x, 0);
     [self setOneChildController:index];*/
}

-(void)updateTabMenu{
    self.curIndex=0;
    //外部更新标签的时候，先要移除之前添加的控制器和视图
    [self.menuScrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.childViewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromParentViewController];
    }];
    
    [self.btArray removeAllObjects];
    [self addChildViewController];      /** 调用子控制器方法，初始标签，子视图  */
    
    //[self setScrollView]; 执行这条语句有错误
    
    //-----------------------------------------------
    int num=0;
    for (int i = 0; i < self.menuArray.count; i++) {
        MenuModel* menu=self.menuArray[i];
        if(menu.ishide==1){
            num++;
        }
    }
    self.contentScrollView.contentSize = CGSizeMake((self.menuArray.count-num) * SCREEN_WIDTH, 0);
    //-----------------------------------------------
    
    [self setMenu];
}


-(void)btnClick:(UIButton *)sender{
    UIViewController *vc  =  self.childViewControllers[_curIndex];
    if ([vc isKindOfClass:[ContentViewController class]]) {
        [(ContentViewController*)vc onTabMenuClick];
    }
    
    [self selectTitleBtn:sender];
    NSInteger i = sender.tag-BtnInitialTag;
    CGFloat x  = i *SCREEN_WIDTH;
    self.contentScrollView.contentOffset = CGPointMake(x, 0);
    
    [self setBottomLine:sender];
    [self setOneChildController:i];
}

-(void)selectTitleBtn:(UIButton *)btn{
    [self.selectedBtn setTitleColor:self.colorMenuTitle forState:UIControlStateNormal];
    self.selectedBtn.transform = CGAffineTransformIdentity;

    [btn setTitleColor:self.colorMenuTitleSelect forState:UIControlStateNormal];
    btn.transform = CGAffineTransformMakeScale(MaxScale, MaxScale);
    self.selectedBtn = btn;
    self.curIndex=btn.tag-BtnInitialTag;
    
    [self setTitleCenter:btn];
    [self setBottomLine:btn];
}

-(void)setBottomLine:(UIButton*)selectBtn{
    if (self.isShowSelectBtnLine) {
        if(!self.selectBtnLine){
            self.selectBtnLine=[[UIView alloc]init];
            self.selectBtnLine.backgroundColor = self.colorSelectBtnLine;
            [self.menuScrollView addSubview:self.selectBtnLine];
        }
        self.selectBtnLine.frame=CGRectMake(selectBtn.frame.origin.x, self.menuHeight-2, selectBtn.frame.size.width, 2);
    }
}


-(void)setTitleCenter:(UIButton *)sender
{
    if (self.menuScrollView.contentSize.width <= SCREEN_WIDTH) {
        return;
    }
    //以上这一句代码保证数量较少时不会产生异常的偏移！！！！！！！！！
    CGFloat offset = sender.center.x - SCREEN_WIDTH * 0.5;
    if (offset < 0) {
        offset = 0;
    }
    CGFloat maxOffset  = self.menuScrollView.contentSize.width - SCREEN_WIDTH;
    if (offset > maxOffset) {
        offset = maxOffset;
    }
    [self.menuScrollView setContentOffset:CGPointMake(offset, 0) animated:YES];
    
}

-(void)setOneChildController:(NSInteger)index{
    CGFloat x  = index * SCREEN_WIDTH;
    UIViewController *vc  =  self.childViewControllers[index];
    if (vc.view.superview) {
        return;
    }
    vc.view.frame = CGRectMake(x,0, self.contentScrollView.frame.size.width, self.contentScrollView.frame.size.height);
    [self.contentScrollView addSubview:vc.view];
}

#pragma mark - UIScrollView  delegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger i  = self.contentScrollView.contentOffset.x / SCREEN_WIDTH;
    [self selectTitleBtn:self.buttons[i]];
    [self setOneChildController:i];

    if(i+1<self.childViewControllers.count){
        [self setOneChildController:i+1];
    }
    //如果需要检测视图滑动了，可以使用下边的通知。但是....
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"ViewControllerSlided" object:nil userInfo:@{@"currentIndex":@(i)}];
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetX  = scrollView.contentOffset.x;
    NSInteger leftIndex  = offsetX / SCREEN_WIDTH;
    NSInteger rightIdex  = leftIndex + 1;
    
    UIButton *leftButton = self.buttons[leftIndex];
    UIButton *rightButton  = nil;
    if (rightIdex < self.buttons.count) {
        rightButton  = self.buttons[rightIdex];
    }
    CGFloat scaleR  = offsetX / SCREEN_WIDTH - leftIndex;
    CGFloat scaleL  = 1 - scaleR;
    CGFloat transScale = MaxScale - 1;
    
    //self.imageBackView.transform  = CGAffineTransformMakeTranslation((offsetX*(self.titleScrollView.contentSize.width / self.contentScrollView.contentSize.width)), 0);
    
    leftButton.transform = CGAffineTransformMakeScale(scaleL * transScale + 1, scaleL * transScale + 1);
    rightButton.transform = CGAffineTransformMakeScale(scaleR * transScale + 1, scaleR * transScale + 1);
    
    if(self.selectBtnLine){
        //修改下划线的frame
        self.selectBtnLine.transform  = CGAffineTransformMakeTranslation((offsetX*((self.menuScrollView.contentSize.width-self.moreBtnWith) / self.contentScrollView.contentSize.width)), 0);
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [self setScrollView];
    [self setMenu];
    
    for (int i=0; i<[self.childViewControllers count]; i++) {
        CGFloat x  = i * SCREEN_WIDTH;
        UIViewController *vc = self.childViewControllers[i];
        vc.view.frame = CGRectMake(x,0, self.contentScrollView.frame.size.width, self.contentScrollView.frame.size.height);
    }
    
    UIButton* btn=[[self buttons] objectAtIndex:self.curIndex];
    [self btnClick:btn];
    
    //CGPoint position = CGPointMake(self.curIndex * SCREEN_WIDTH, 0);
    //[self.contentScrollView setContentOffset:position animated:YES];
}


/*-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    NSLog(@"view:%@",NSStringFromCGRect(self.view.frame));
    if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight){
        NSLog(@"cjw:横屏");
    }
    else{
        NSLog(@"cjw:竖屏");
    }
 }*/

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
