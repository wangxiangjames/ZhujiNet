//
//  SysinfoViewController.m
//  ZhujiNet
//
//  Created by zhujiribao on 2018/3/7.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//

#import "SysinfoViewController.h"
#import "AppDelegate.h"
#import "MJRefresh.h"
#import "CommonCell.h"
#import "CjwItem.h"

@interface SysinfoViewController ()<UITableViewDelegate,UITableViewDataSource>{
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
}

@end

@implementation SysinfoViewController

- (void)viewWillAppear:(BOOL)animated{
    self.navigationItem.title = @"系统消息";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigation];
    
    _app = [AppDelegate getApp];
    _isLoading=NO;
    _page=1;
    _pageCount=1;
    _data = [NSMutableArray arrayWithCapacity:20];
    _url=URL_sysinfo_list;

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
    [_cell makeCellType:CELL_SYSINFO];
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
                cjwItem.title=item[@"title"];
                cjwItem.subtitle=item[@"content"];
                cjwItem.dateline=item[@"dateline"];
                cjwItem.from=item[@"forumname"];
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
    CjwItem *item=_data[indexPath.row];
    _cell = [_tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CommonCell class])];
    [_cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [_cell makeCellType:CELL_SYSINFO];
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
