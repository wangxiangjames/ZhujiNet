//
//  ShangController.m
//  ZhujiNet
//
//  Created by zhujiribao on 2018/3/26.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//

#import "FollowController.h"
#import "AppDelegate.h"
#import "MJRefresh.h"
#import "CommonCell.h"
#import "CjwItem.h"
#import "ShangModel.h"
#import "CjwFun.h"
#import "OtherViewController.h"

@interface FollowController ()<UITableViewDelegate,UITableViewDataSource>{
    AppDelegate                 *_app;
    CommonCell                  *_cell;
    CjwItem                     *_cjwItem;
    UITableView                 *_tableView;
    MJRefreshAutoNormalFooter   *_refeshFooter;
    
    NSString                    *_url;
    NSMutableArray              *_data;
    NSInteger                   _page;
    NSInteger                   _pageCount;
    BOOL                        _isLoading;
    
    UITextView                  *_tvMoney;
    UITextView                  *_tvMsg;
    NSInteger                   _curRow;
}

@end

@implementation FollowController

- (void)viewWillAppear:(BOOL)animated{
    self.navigationItem.title = @"我的关注";
}

-(void)setNavigation{
    UIButton *navBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [navBack setFrame:CGRectMake(0, 0, 28, 28)];
    [navBack setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [navBack addTarget:self action:@selector(onNavBackClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navBack];
}

- (void)onNavBackClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
    [self setNavigation];
    
    _app = [AppDelegate getApp];
    _isLoading=NO;
    _page=1;
    _pageCount=1;
    _data = [NSMutableArray arrayWithCapacity:20];
    _url=URL_follow_user;
    
    _tvMoney=[[UITextView alloc] init];
    _tvMsg=[[UITextView alloc] init];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGesture.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGesture];
    
    [self addTableView];
    [self registerCell];
    [self createNavView];
}

-(void)viewTapped:(UITapGestureRecognizer*)tap {
    [_tvMoney resignFirstResponder];
    [_tvMsg resignFirstResponder];
}

-(void)createNavView{
    if (self.isHeadNone) {
        return;
    }
    
    UIView *viewBg=[[UIView alloc] init];
    viewBg.backgroundColor=[UIColor colorWithWhite:0.95 alpha:1];
    [self.view addSubview:viewBg];
    
    UIView *line=[[UIView alloc] init];
    line.backgroundColor=[UIColor colorWithWhite:0.8 alpha:0.4];
    [self.view addSubview:line];
    
    UIButton* btnOk=[[UIButton alloc]init];
    //[btnOk setTitle:@"保存" forState:UIControlStateNormal];
    [btnOk setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    btnOk.titleLabel.font=[UIFont systemFontOfSize:18];
    //[btnOk addTarget:self action:@selector(actionOK:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnOk];
    
    UILabel* title=[[UILabel alloc]init];
    title.text=@"我的关注";
    title.textAlignment=NSTextAlignmentCenter;
    title.textColor=[UIColor colorWithHexString:@"222222"];
    title.font=[UIFont systemFontOfSize:19];
    [self.view addSubview:title];
    
    UIButton* btnCancel=[[UIButton alloc]init];
    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    [btnCancel setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    btnCancel.titleLabel.font=[UIFont systemFontOfSize:18];
    [btnCancel addTarget:self action:@selector(actionCancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnCancel];
    
    //----------------------------------------
    [viewBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, Height_NavBar));
    }];
    
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(viewBg).offset(Height_StatusBar);
        make.centerX.equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(120, 44));
    }];
    
    [btnOk mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(title);
        make.right.mas_equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(80, 44));
    }];
    
    [btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(title);
        make.left.mas_equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(80, 44));
    }];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(btnCancel.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 1));
    }];
}

-(void)actionCancel:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
}

-(void)addTableView{
    CGFloat top=Height_NavBar;
    if (self.isHeadNone) {
        top=0;
    }
    CGRect rect=CGRectMake(0, top, self.view.frame.size.width,  self.view.frame.size.height-top);
    _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.separatorStyle = NO;
    _tableView.backgroundColor=_app.skin.colorTableBg;
    _tableView.separatorColor =_app.skin.colorCellSeparator;
    /*_refeshFooter=[MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if(_isLoading==NO){
            _isLoading=YES;
            NSDictionary *param=@{@"page":[NSNumber numberWithLong:_page+1]};
            [_app.net request:self url:_url param:param];
        }
    }];
    _tableView.mj_footer =_refeshFooter;
     */
    [self.view addSubview:_tableView];
    
    [_app.net request:self url:_url param:nil];
}

- (void)registerCell{
    _cell=[[CommonCell alloc]init];
    [_cell makeCellType:CELL_FOLLOW];
    [_tableView registerClass:[CommonCell class] forCellReuseIdentifier:NSStringFromClass([CommonCell class])];
}

- (void)requestCallback:(id)response status:(id)status{
    NSLog(@"%@",response);
    if ([status[@"stat"] isEqual:@0]) {
        NSDictionary *dict = (NSDictionary *)response;
        
        if([status[@"tag"] isEqual:@1]){
            if([dict[@"code"] integerValue]==0){
                [_data removeObjectAtIndex:_curRow];
                [MBProgressHUD showSuccess:@"成功取消关注"];
            }
        }
        else{
            if(dict[@"data"]!=nil){
                NSDictionary *digest=dict[@"data"];
                _page=[dict[@"page"] intValue];
                _pageCount=[dict[@"pagecount"] intValue];
                
                for(id item in digest){
                    CjwItem *cjwItem=[[CjwItem alloc]init];
                    cjwItem.title=item[@"fusername"];
                    cjwItem.dateline=item[@"dateline"];
                    cjwItem.authorid=item[@"followuid"];
                    [_data addObject:cjwItem];
                }
            }
        }
        _app.followUser=_data;
        [_tableView reloadData];
        
        /*if(_page>=[dict[@"pagecount"] intValue]){
            [_refeshFooter setTitle:@"没有更多数据了" forState:MJRefreshStateNoMoreData];
            [_tableView.mj_footer endRefreshingWithNoMoreData];
            if (_page==1) {
                [_tableView.mj_header endRefreshing];
            }
        }
        else{
            [_tableView.mj_footer endRefreshing];
        }*/
    }
    else{
        [_tableView.mj_footer endRefreshing];
        [_refeshFooter setTitle:@"网络连接失败" forState:MJRefreshStateIdle];
    }
    _isLoading=NO;
}

-(void) scrollViewDidScroll:(UIScrollView *) scrollView{
    /*if(_isLoading==NO && (scrollView.contentOffset.y+scrollView.frame.size.height)/scrollView.contentSize.height >0.95 && scrollView.contentSize.height>100){
        _isLoading=YES;
        NSDictionary *param=@{@"page":[NSNumber numberWithLong:_page+1]};
        [_app.net request:self url:_url param:param];
    }*/
}

#pragma mark -
#pragma mark - UITableView dateSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak typeof(&*self)weakSelf = self;
    CjwItem *item=_data[indexPath.row];
    _cell = [_tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CommonCell class])];
    [_cell setBlockBtnAction:^(UIButton *button){
        [weakSelf btnAction:button];
    }];
    _cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [_cell makeCellType:CELL_FOLLOW];
    _cell.item=item;
    return _cell;
}

#pragma mark 设置每行高度（每行高度可以不一样）
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CjwItem *item=_data[indexPath.row];
    if (item.height==0) {
        _cell.item=_data[indexPath.row];
        item.height=_cell.height;
    }
    return item.height+8;
}

-(void)tableView:(UITableView* )tableView willDisplayCell:(UITableViewCell* )cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.separatorInset=UIEdgeInsetsMake(0, 15, 0, 15);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)btnAction:(UIButton *)sender {
    NSIndexPath* cellPath = [_tableView indexPathForCell:(UITableViewCell*)sender.superview.superview];
    _curRow=cellPath.row;
    
    if([sender.titleLabel.text isEqualToString:@"取消关注"]){
        CjwItem *item=_data[_curRow];
        NSLog(@"%@",item.authorid);
        NSDictionary* dict=@{@"fuid":item.authorid};
        [_app.net request:self url:URL_follow_del param:dict callTag:1];
    }
    else{
        OtherViewController* other=[[OtherViewController alloc]init];
        CjwItem *item=_data[_curRow];
        other.uid=item.authorid;
        other.author=item.title;
        [self.navigationController pushViewController:other animated:YES];
    }
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
