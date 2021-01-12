//
//  SearchViewController.m
//  ZhujiNet
//
//  Created by zhujiribao on 2018/3/7.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//

#import "SearchViewController.h"
#import "AppDelegate.h"
#import "MJRefresh.h"
#import "CommonCell.h"
#import "CjwItem.h"
#import "DetailViewController.h"
#import "SearchUserController.h"
#import "OtherViewController.h"

@interface SearchViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UISearchBarDelegate>{
    AppDelegate                 *_app;
    CommonCell                  *_cell;
    CommonCell                  *_cellUser;
    CjwItem                     *_cjwItem;
    UITableView                 *_tableView;
    MJRefreshAutoNormalFooter   *_refeshFooter;
    UISearchBar                 *_searchBar;
    
    NSString                    *_url;
    NSMutableArray              *_data;
    NSMutableArray              *_dataUser;
    NSInteger                   _page;
    NSInteger                   _pageCount;
    BOOL                        _isLoading;
    NSString                    *_searchCont;
}

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigation];
    
    _app = [AppDelegate getApp];
    _isLoading=NO;
    _page=1;
    _pageCount=1;
    _data = [NSMutableArray arrayWithCapacity:20];
    _dataUser = [NSMutableArray arrayWithCapacity:20];
    _url=URL_search;
    
    [self addSearchBar];
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

-(void)addSearchBar{
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.view.width-110, 35)];
    UIColor *color =  self.navigationController.navigationBar.barTintColor;
    [titleView setBackgroundColor:color];
    
    _searchBar = [[UISearchBar alloc] init];
    _searchBar.delegate = self;
    _searchBar.frame = CGRectMake(2, 0, titleView.width-10, 35);

    _searchBar.backgroundColor = color;
    _searchBar.layer.cornerRadius = 18;
    _searchBar.layer.masksToBounds = YES;
    [_searchBar.layer setBorderWidth:8];
    [_searchBar.layer setBorderColor:[UIColor whiteColor].CGColor];  //设置边框为白色
    _searchBar.placeholder = @"搜索你想要的东西";
    [titleView addSubview:_searchBar];
    self.navigationItem.titleView = titleView;
    [self.navigationItem.titleView sizeToFit];

    UIButton *btnSearch=[[UIButton alloc]initWithFrame:CGRectMake(0,5, 45,35)];
    [btnSearch setTitle:@"搜索"forState:UIControlStateNormal];
    [btnSearch setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnSearch setTitleColor:[UIColor orangeColor]forState:UIControlStateHighlighted];
    [btnSearch addTarget:self action:@selector(actionSearch:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rigth = [[UIBarButtonItem alloc]initWithCustomView:btnSearch];
    self.navigationItem.rightBarButtonItem = rigth;
}

-(void)addTableView{
    CGRect rect=CGRectMake(0, 0, self.view.frame.size.width,  self.view.frame.size.height-Height_NavBar);
    _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStyleGrouped];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.separatorStyle = NO;
    _tableView.backgroundColor=_app.skin.colorTableBg;
    _tableView.separatorColor =_app.skin.colorCellSeparator;
    
    _refeshFooter=[MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self searchContent:NO];
    }];
    [_refeshFooter setTitle:@"" forState:MJRefreshStateIdle];
    _tableView.mj_footer =_refeshFooter;
    [self.view addSubview:_tableView];
}

- (void)registerCell{
    _cell=[[CommonCell alloc]init];
    [_cell makeCellType:CELL_SEARCH];
    [_tableView registerClass:[CommonCell class] forCellReuseIdentifier:@"CELL_SEARCH"];
    
    _cellUser=[[CommonCell alloc]init];
    [_cellUser makeCellType:CELL_SEARCH_USER];
    [_tableView registerClass:[CommonCell class] forCellReuseIdentifier:@"CELL_SEARCH_USER"];
}

- (void)requestCallback:(id)response status:(id)status{
    if ([status[@"stat"] isEqual:@0]) {
        NSDictionary *dict = (NSDictionary *)response;
        
        NSLog(@"search:%@",dict);
        
        if(dict[@"data"]!=nil){
            NSDictionary *digest=dict[@"data"][@"news"];
            _page=[dict[@"page"] intValue];
            _pageCount=[dict[@"pagecount"] intValue];
            
            for(id item in digest){
                CjwItem *cjwItem=[[CjwItem alloc]init];
                cjwItem.tid=item[@"tid"];
                cjwItem.contmode=item[@"contmode"]==[NSNull null] ? 0: [item[@"contmode"] intValue];
                cjwItem.title=item[@"title"];
                cjwItem.from=item[@"forumname"];
                cjwItem.dateline=item[@"dateline"];
                cjwItem.flag=_searchCont;
                [_data addObject:cjwItem];
            }
            
            NSDictionary *users=dict[@"data"][@"users"];
            for(id item in users){
                CjwItem *cjwItem=[[CjwItem alloc]init];
                cjwItem.authorid=item[@"uid"];
                cjwItem.img=item[@"avatar"];
                cjwItem.author=item[@"username"];
                cjwItem.flag=_searchCont;
                [_dataUser addObject:cjwItem];
            }
        }
        
        [_tableView reloadData];
        
        if(_page>=[dict[@"pagecount"] intValue]){
            if ([_data count]==0) {
                [_refeshFooter setTitle:@"很遗憾，未查到数据！" forState:MJRefreshStateNoMoreData];
            }
            else{
                [_refeshFooter setTitle:@"没有更多数据了" forState:MJRefreshStateNoMoreData];
            }
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
    [MBProgressHUD hideHUDForView:self.view];
    _isLoading=NO;
}

-(void) scrollViewDidScroll:(UIScrollView *) scrollView{
    if(_isLoading==NO && (scrollView.contentOffset.y+scrollView.frame.size.height)/scrollView.contentSize.height >0.95 && scrollView.contentSize.height>100){
        [self searchContent:NO];
    }
}

#pragma mark -
#pragma mark - UITableView dateSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        if(_dataUser.count>0){
            return 1;
        }
        else{
            return 0;
        }
    }
    else{
        return _data.count;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        __weak typeof(&*self)weakSelf = self;
        _cellUser = [_tableView dequeueReusableCellWithIdentifier:@"CELL_SEARCH_USER"];
        [_cellUser makeCellType:CELL_SEARCH_USER];
        [_cellUser setArray:_dataUser];
        _cellUser.selectionStyle = UITableViewCellSelectionStyleNone;
        [_cellUser setBlockBtnAction:^(UIButton *button){
            [weakSelf btnAction:button];
        }];
        [_cellUser setBlockImageAction:^(NSInteger row){
            [weakSelf imageAction:row];
        }];
        
        return _cellUser;
    }
    else{
        CjwItem *item=_data[indexPath.row];
        _cell = [_tableView dequeueReusableCellWithIdentifier:@"CELL_SEARCH"];
        [_cell makeCellType:CELL_SEARCH];
        _cell.item=item;
        return _cell;
    }
}

- (void)btnAction:(UIButton *)sender {
    SearchUserController* user=[[SearchUserController alloc]init];
    if(user.data==nil){
        user.data=[[NSMutableArray alloc]initWithCapacity:20];
    }
    user.searchCont=_searchCont;
    [user.data addObjectsFromArray:_dataUser.mutableCopy];
    [self.navigationController pushViewController:user animated:YES];
}

- (void)imageAction:(NSInteger)row {
    OtherViewController* other=[[OtherViewController alloc]init];
    CjwItem *item=_dataUser[row];
    other.uid=item.authorid;
    other.author=item.author;
    [self.navigationController pushViewController:other animated:YES];
}

#pragma mark 设置每行高度（每行高度可以不一样）
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return 100.0;
    }
    else{
        CjwItem *item=_data[indexPath.row];
        if (item.height==0) {
            _cell.item=_data[indexPath.row];
            item.height=_cell.height;
        }
        return item.height+1;
    }
}

// 自定义表头
- (UIView*) tableView:(UITableView *)_tableView viewForHeaderInSection:(NSInteger)section {
    if (_searchCont.length>0) {
        NSString *cont=section==0 ? [NSString stringWithFormat:@"     与“%@”有关的用户",_searchCont] :
                                    [NSString stringWithFormat:@"     与“%@”有关的帖子",_searchCont] ;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _tableView.frame.size.width, 40)];
        label.textColor = [UIColor colorWithHexString:@"444444"];
        label.text = cont;
        //label.textAlignment = NSTextAlignmentCenter;
        
        NSRange range =[cont rangeOfString:_searchCont];
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:label.text];
        [attrStr addAttribute:NSForegroundColorAttributeName value:[UIColor orangeColor] range:range];
        label.attributedText=attrStr;
        return label;
    }
    else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

-(void)tableView:(UITableView* )tableView willDisplayCell:(UITableViewCell* )cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.separatorInset=UIEdgeInsetsMake(0, 15, 0, 15);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==0){
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CjwItem *item=_data[indexPath.row];
    DetailViewController *detail=[[DetailViewController alloc]init];
    detail.contmode=item.contmode;
    detail.artTitle=item.title;
    if([item.url length]>0){
        detail.webUrl=item.url;
        detail.tid=0;
    }
    else{
        detail.webUrl=[NSString stringWithFormat:URL_web_detail,item.tid];
        detail.tid=item.tid;
    }
    [self.navigationController pushViewController:detail animated:TRUE];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self searchContent:YES];
}

-(void)actionSearch:(id)sender{
    [self searchContent:YES];
}

-(void)searchContent:(BOOL)isFirstPage{
    NSString *type=@"0";
    
    if (isFirstPage) {
        [_searchBar resignFirstResponder];
        [_dataUser removeAllObjects];
        [_data removeAllObjects];
        [_tableView reloadData];
        _page=0;
        type=@"2";
    }
    
    _searchCont = [_searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (_searchCont.length>0) {
        if(_isLoading==NO){
            if (isFirstPage) {
                [MBProgressHUD showMessage:@"努力为你搜索……"  toView:self.view];
            }
            _isLoading=YES;
            NSDictionary *param=@{@"search":_searchCont,@"type":type,@"page":[NSNumber numberWithLong:_page+1]};
            [_app.net request:self url:_url param:param];
        }
    }
    else{
        [_refeshFooter setTitle:@"" forState:MJRefreshStateNoMoreData];
        [_refeshFooter endRefreshingWithNoMoreData];
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
