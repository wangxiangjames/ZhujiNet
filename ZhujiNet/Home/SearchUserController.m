//
//  SearchUserController.m
//  ZhujiNet
//
//  Created by zhujiribao on 2018/5/14.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//

#import "SearchUserController.h"
#import "AppDelegate.h"
#import "MJRefresh.h"
#import "CommonCell.h"
#import "CjwItem.h"
#import "ShangModel.h"
#import "CjwFun.h"
#import "OtherViewController.h"

@interface SearchUserController ()<UITableViewDelegate,UITableViewDataSource>{
    AppDelegate                 *_app;
    CommonCell                  *_cell;
    CjwItem                     *_cjwItem;
    UITableView                 *_tableView;
    MJRefreshAutoNormalFooter   *_refeshFooter;
    
    NSInteger                   _page;
    NSInteger                   _pageCount;
    NSInteger                   _isLoading; //0没有加载，1正在加载，2加载完成
    BOOL                        _isEnd;     //是否触到底部
}

@end

@implementation SearchUserController

- (void)viewWillAppear:(BOOL)animated{
    self.navigationItem.title = @"相关列表";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault];
    [self setNavigation];
    
    _app = [AppDelegate getApp];
    _isLoading=0;
    _isEnd=NO;
    _page=1;
    _pageCount=1;

    [self addTableView];
    [self registerCell];
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

-(void)addTableView{
    CGRect rect=CGRectMake(0, 0, self.view.frame.size.width,  self.view.frame.size.height-Height_NavBar);
    _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.separatorStyle = NO;
    _tableView.backgroundColor=_app.skin.colorTableBg;
    _tableView.separatorColor =_app.skin.colorCellSeparator;
    if (@available(iOS 11.0, *)) {
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        //_tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    _refeshFooter=[MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _isEnd=YES;
        [self loadData:NO];
    }];
    _tableView.mj_footer =_refeshFooter;
    [self.view addSubview:_tableView];
}

- (void)registerCell{
    _cell=[[CommonCell alloc]init];
    [_cell makeCellType:CELL_SEARCH_USER_MORE];
    [_tableView registerClass:[CommonCell class] forCellReuseIdentifier:NSStringFromClass([CommonCell class])];
}

-(void)loadData:(BOOL)isHeader{
    if (isHeader) {
        [_refeshFooter resetNoMoreData];    //页数全部加载完成后，重新涮新需重置
        [_refeshFooter setTitle:@"努力加载中……" forState:MJRefreshStateIdle];
        _page=0 ;
        [_data removeAllObjects];
        _isLoading=0;
        _isEnd=0;
    }
    
    //NSLog(@"----1------- isLoading:%ld , isEnd=%ld",_isLoading,_isEnd);
    if (_isLoading==0 && _isEnd==NO) {
        _isLoading=1;
        
        NSDictionary *param=@{@"search":self.searchCont,@"type":@1,@"page":@(_page+1)};
        [_app.net request:URL_search param:param withMethod:@"POST"
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 NSLog(@"----2------- isLoading:%ld , isEnd=%ld",_isLoading,_isEnd);
                  NSDictionary *dict = (NSDictionary *)responseObject;
                  if([dict[@"code"] integerValue]==0){
                      _page=[dict[@"page"] intValue];
                      _pageCount=[dict[@"pagecount"] intValue];
                      
                      NSDictionary *users=dict[@"data"][@"users"];
                      for(id item in users){
                          CjwItem *cjwItem=[[CjwItem alloc]init];
                          cjwItem.authorid=item[@"uid"];
                          cjwItem.img=item[@"avatar"];
                          cjwItem.author=item[@"username"];
                          cjwItem.flag=_searchCont;
                          [_data addObject:cjwItem];
                      }
                  }
                  _isLoading=2;
                  if (isHeader){
                      [_tableView reloadData];
                      [_tableView.mj_header endRefreshing];
                      _isLoading=0;
                  }
                  if (_isEnd) {
                      NSLog(@"----3------- isLoading:%ld , isEnd=%ld",_isLoading,_isEnd);
                      [self loadDataFooterEnd];
                  }
              }
              failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"网络失败");
                  _isLoading=2;
                  [_refeshFooter setTitle:@"网络连接失败" forState:MJRefreshStateIdle];
                  [_tableView.mj_header endRefreshing];
              }];
    }
    
    if (_isEnd==YES && _isLoading==2) {
        NSLog(@"----4------- isLoading:%ld , isEnd=%ld",_isLoading,_isEnd);
        [self loadDataFooterEnd];
        return;
    }
}

-(void)loadDataFooterEnd{
    [_tableView reloadData];
    if(_page>=_pageCount){
        if ([_data count]==0) {
            [_refeshFooter setTitle:@"很遗憾没有数据！" forState:MJRefreshStateNoMoreData];
        }
        else{
            [_refeshFooter setTitle:@"没有更多数据了" forState:MJRefreshStateNoMoreData];
        }
        [_tableView.mj_footer endRefreshingWithNoMoreData];
    }
    else{
        [_tableView.mj_footer endRefreshing];
    }
    _isLoading=0;
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
    CjwItem *item=_data[indexPath.row];
    _cell = [_tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CommonCell class])];
    [_cell makeCellType:CELL_SEARCH_USER_MORE];
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
    _isEnd=NO;
    if (indexPath.row>_data.count*0.7) {
        [self loadData:NO];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    OtherViewController* other=[[OtherViewController alloc]init];
    CjwItem *item=_data[indexPath.row];
    other.uid=item.authorid;
    other.author=item.author;
    [self.navigationController pushViewController:other animated:YES];
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
