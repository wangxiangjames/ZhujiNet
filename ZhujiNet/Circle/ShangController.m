//
//  ShangController.m
//  ZhujiNet
//
//  Created by zhujiribao on 2018/3/26.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//

#import "ShangController.h"
#import "AppDelegate.h"
#import "MJRefresh.h"
#import "CommonCell.h"
#import "CjwItem.h"
#import "ShangModel.h"
#import "CjwFun.h"

@interface ShangController ()<UITableViewDelegate,UITableViewDataSource>{
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
}

@end

@implementation ShangController

- (void)viewWillAppear:(BOOL)animated{
    self.navigationItem.title = @"系统消息";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
    
    _app = [AppDelegate getApp];
    _isLoading=NO;
    _page=1;
    _pageCount=1;
    _data = [NSMutableArray arrayWithCapacity:20];
    _url=[NSString stringWithFormat:@"%@?tid=%@",URL_reward_list,self.tid];
    
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
    title.text=@"打赏作者";
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
    [self dismissViewControllerAnimated:YES completion:^{
        if (self.bYiShang) {
            [self.delegate passValue:@"1"];
        }
    }];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
}

-(void)addTableView{
    CGRect rect=CGRectMake(0, Height_NavBar, self.view.frame.size.width,  self.view.frame.size.height-Height_NavBar);
    _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.backgroundColor=_app.skin.colorTableBg;
    _tableView.separatorColor =_app.skin.colorCellSeparator;
    _refeshFooter=[MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if(_isLoading==NO){
            _isLoading=YES;
            NSDictionary *param=@{@"page":[NSNumber numberWithLong:_page+1]};
            [_app.net request:self url:_url param:param];
        }
    }];
    _tableView.mj_footer =_refeshFooter;
    [self.view addSubview:_tableView];
    
    [_app.net request:self url:_url param:nil];
}

- (void)registerCell{
    _cell=[[CommonCell alloc]init];
    [_cell makeCellType:CELL_SHANG];
    [_tableView registerClass:[CommonCell class] forCellReuseIdentifier:NSStringFromClass([CommonCell class])];
}

- (void)requestCallback:(id)response status:(id)status{
    if ([status[@"stat"] isEqual:@0]) {
        
        NSDictionary *dict = (NSDictionary *)response;
        if(dict[@"data"]!=nil){
            NSDictionary *digest=dict[@"data"];
            _page=[dict[@"page"] intValue];
            _pageCount=[dict[@"pagecount"] intValue];
            
            for(id item in digest){
                CjwItem *cjwItem=[[CjwItem alloc]init];
                cjwItem.title=item[@"username"];
                cjwItem.dateline=item[@"dateline"];
                cjwItem.subtitle=[NSString stringWithFormat:@"打赏了 %@ 个金币，并附言：%@", item[@"credit"],item[@"msg"]];
                cjwItem.authorid=item[@"uid"];
                [_data addObject:cjwItem];
            }
        }
        
        [_tableView reloadData];
        
        if(_page>=[dict[@"pagecount"] intValue]){
            [_refeshFooter setTitle:@"没有更多数据了" forState:MJRefreshStateNoMoreData];
            [_tableView.mj_footer endRefreshingWithNoMoreData];
            if (_page==1) {
                [_tableView.mj_header endRefreshing];
            }
        }
        else{
            [_tableView.mj_footer endRefreshing];
        }
    }
    else{
        [_tableView.mj_footer endRefreshing];
        [_refeshFooter setTitle:@"网络连接失败" forState:MJRefreshStateIdle];
    }
    _isLoading=NO;
}

-(void) scrollViewDidScroll:(UIScrollView *) scrollView{
    if(_isLoading==NO && (scrollView.contentOffset.y+scrollView.frame.size.height)/scrollView.contentSize.height >0.95 && scrollView.contentSize.height>100){
        _isLoading=YES;
        NSDictionary *param=@{@"page":[NSNumber numberWithLong:_page+1]};
        [_app.net request:self url:_url param:param];
    }
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.bYiShang) {
        return nil;
    }
    UIView *view=[[UIView alloc]init];
    UILabel *moneyLabel=[[UILabel alloc] init];
    UILabel *msgLabel=[[UILabel alloc] init];
    UIButton *btn=[[UIButton alloc]init];
    btn=[[UIButton alloc]init];
    [view addSubview:moneyLabel];
    [view addSubview:msgLabel];
    [view addSubview:_tvMoney];
    [view addSubview:_tvMsg];
    [view addSubview:btn];
    view.backgroundColor=[UIColor colorWithHexString:@"eedddd"];
    moneyLabel.text=@"打赏金额：";
    msgLabel.text=@"说点什么：";
    [btn setTitle:@"打赏" forState:UIControlStateNormal];
    btn.titleLabel.font=[UIFont systemFontOfSize:14];
    btn.backgroundColor=[UIColor colorWithHexString:@"FF8070"];
    [btn addTarget:self action:@selector(shangAction:) forControlEvents:UIControlEventTouchUpInside];
    btn.layer.cornerRadius=6;
    _tvMoney.layer.cornerRadius=4;
    _tvMsg.layer.cornerRadius=4;
    
    [moneyLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(view).offset(14);
        make.top.equalTo(view).offset(10);
        make.height.equalTo(@30);
    }];
    
    [msgLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(view).offset(14);
        make.top.equalTo(moneyLabel.mas_bottom).offset(10);
        make.height.equalTo(@30);
    }];

    [btn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(view).offset(-14);
        make.top.equalTo(moneyLabel.mas_bottom).offset(-8);
        make.size.mas_equalTo(CGSizeMake(60, 30));
    }];
    
    [_tvMoney mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(btn.mas_left).offset(-14);
        make.top.equalTo(moneyLabel);
        make.left.equalTo(moneyLabel.mas_right);
        make.bottom.equalTo(moneyLabel);
    }];

    [_tvMsg mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(btn.mas_left).offset(-14);
        make.top.equalTo(msgLabel);
        make.left.equalTo(moneyLabel.mas_right);
        make.bottom.equalTo(msgLabel);
    }];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (self.bYiShang) {
        return 0.1;
    }
    return 90;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CjwItem *item=_data[indexPath.row];
    _cell = [_tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CommonCell class])];
    [_cell makeCellType:CELL_SHANG];
    _cell.item=item;
    return _cell;
}

#pragma mark 设置每行高度（每行高度可以不一样）
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    _cell.item=_data[indexPath.row];
    return _cell.height+8;
    
    /*CjwItem *item=_data[indexPath.row];
    if (item.height==0) {
        _cell.item=_data[indexPath.row];
        item.height=_cell.height;
    }
    return _cell.height+8;*/
}

-(void)tableView:(UITableView* )tableView willDisplayCell:(UITableViewCell* )cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.separatorInset=UIEdgeInsetsMake(0, 15, 0, 15);
}

-(void)shangAction:(UIButton*)sender{
    if (![CjwFun isNumber:_tvMoney.text ] || _tvMoney.text.length==0) {
        [MBProgressHUD showError:@"请输入正确的金币数量" toView:self.view];
        return;
    }
    if (_tvMsg.text.length==0) {
        [MBProgressHUD showError:@"请输入打赏说明" toView:self.view];
        return;
    }
    NSDictionary *param=@{@"tid":self.tid,@"creditMsg":_tvMsg.text,@"credit":_tvMoney.text,@"aid":NSString(self.authorid)};
    [_app.net request:URL_reward_add param:param withMethod:@"POST"
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"test:%@",responseObject);
                  NSDictionary *dict = (NSDictionary *)responseObject;
                  if([dict[@"code"] integerValue]==0){
                      [MBProgressHUD showSuccess:@"打赏成功" toView:self.view];
                      _tvMoney.text=@"";
                      _tvMsg.text=@"";
                      self.bYiShang=YES;
                      [_data removeAllObjects];
                      [_app.net request:self url:_url param:nil];
                  }
                  else{
                      [MBProgressHUD showError:dict[@"msg"] toView:self.view];
                  }
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              [MBProgressHUD showError:@"网络出错"];
    }];
    
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
