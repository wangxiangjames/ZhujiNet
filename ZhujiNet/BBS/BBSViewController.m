//
//  ShopViewController.m
//  ZhujiNet
//
//  Created by zhujiribao on 2017/8/4.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import "BBSViewController.h"
#import "CjwGridMenu.h"
#import "ForumViewController.h"
#import "BBSMenuViewController.h"
#import "DetailViewController.h"
#import "BbsForumModel.h"
#import "SearchViewController.h"
#import "ThreadModel.h"

@interface BBSViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,CjwGridMenuDelegate,CjwGridMenuDataSource,NavMenuDelegate>{
    AppDelegate                 *_app;
    UITableView                 *_tableView;
    CjwNewsCell                 *_newsCell;
    MJRefreshAutoNormalFooter   *_refeshFooter;
    CjwGridMenu                 *_gridMenu;
    CjwNavMenu                  *_navMenu;
    
    NSMutableArray              *_arrayGridMenu;
    NSMutableArray              *_arrayShoucangMenu;

    NSMutableArray              *_data;
    NSInteger                   _page;
    NSInteger                   _pageCount;
    NSInteger                   _isLoading; //0没有加载，1正在加载，2加载完成
    BOOL                        _isEnd;     //是否触到底部
    
    NSString                    *_url;
    CGFloat                     _cellHeaderHeight;
    NSUInteger                  _curNavMenu;
    NSUInteger                  _curRow;
}

@end

@implementation BBSViewController

- (void)viewWillAppear:(BOOL)animated{
    self.navigationItem.title=@"诸暨圈";
    _app = [AppDelegate getApp];
    [_app.skin setSkin:self];
    [self loadGridMenuData];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _app = [AppDelegate getApp];
    _arrayGridMenu=[NSMutableArray arrayWithCapacity:20];
    _data = [NSMutableArray arrayWithCapacity:20];
    _page=0;
    _pageCount=0;
    _isLoading=NO;
    _isEnd=NO;
    
    _curNavMenu=0;
    _url=[NSString stringWithFormat:@"%@?fid=%ld",URL_bbs_thread,_curNavMenu];
    
    [self addTableView];
    [self registerCell];
}

-(void)addTableView{
    CGRect rect=CGRectMake(0, 0, self.view.frame.size.width,  self.view.frame.size.height - 20-44-49);
    _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStyleGrouped];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.separatorStyle=NO;
    _tableView.backgroundColor=_app.skin.colorTableBg;
    _tableView.separatorColor =_app.skin.colorCellSeparator;
    _tableView.separatorInset=UIEdgeInsetsZero;
    _tableView.layoutMargins=UIEdgeInsetsZero;
    
    if (@available(iOS 11.0, *)) {
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        //_tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self loadData:YES];
    }];
    [_tableView.mj_header beginRefreshing];
    
    _refeshFooter=[MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _isEnd=YES;
        [self loadData:NO];
    }];
    _tableView.mj_footer =_refeshFooter;
    
    [self.view addSubview:_tableView];
}

- (void)registerCell{
    _newsCell=[[CjwNewsCell alloc]init];
    [_tableView registerClass:[CjwNewsCell class] forCellReuseIdentifier:NSStringFromClass([CjwNewsCell class])];
}

-(CjwGridMenu*)addGridMenu{
    if(!_gridMenu){
        _gridMenu= [[CjwGridMenu alloc]init];
        _gridMenu.backgroundColor=_app.skin.colorCellBg;
        _gridMenu.iconAlpha=_app.skin.floatImgAlpha;
        _gridMenu.colorText=_app.skin.colorGridMenuText;
        _gridMenu.iconWidth=52;
        _gridMenu.cornerRadius=5;
        _gridMenu.dataSource = self;
        _gridMenu.delegate = self;
        [_gridMenu reloadData];
    }
    return _gridMenu;
}

-(void)loadGridMenuData{
    [_arrayGridMenu removeAllObjects];
    
    _arrayShoucangMenu=[ForumSubModel mj_objectArrayWithKeyValuesArray:[CjwFun getLocaionDict:kBbsForumMenu]];
    if (_arrayShoucangMenu==nil) {
        _arrayShoucangMenu=[NSMutableArray arrayWithCapacity:20];
    }
    
    NSMutableArray *gudingMenu=[NSMutableArray arrayWithCapacity:20];
    for (BbsForumModel* item in _app.forumMenu) {
        if ([item.name isEqualToString:@"固定"]) {
            for (int i=0; i<[item.sublist count]; i++) {
                [gudingMenu addObject:[item.sublist objectAtIndex:i]];
            }
        }
        NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
        id obj=[ud objectForKey:kBbsForumMenu];
        if (!obj && [_arrayShoucangMenu count]==0 )
        {
            if ([item.name isEqualToString:@"收藏"]) {
                for (int i=0; i<[item.sublist count]; i++) {
                    [_arrayShoucangMenu addObject:[item.sublist objectAtIndex:i]];
                }
                NSArray *array = [ForumSubModel mj_keyValuesArrayWithObjectArray:_arrayShoucangMenu];
                [CjwFun putLocaionDict:kBbsForumMenu value:array];
            }
        }
    }
    
    NSLog(@"china:%ld",[_arrayShoucangMenu count]);
    [gudingMenu addObjectsFromArray:_arrayShoucangMenu];
    
    for (ForumSubModel* forumsub in gudingMenu) {
        if (([_arrayGridMenu count]+1)%8==0) {
            ForumSubModel *forumsub= [[ForumSubModel alloc]init];
            forumsub.name=@"全部版块";
            forumsub.image=@"grid_menu_more";
            [_arrayGridMenu addObject:forumsub];
        }
        [_arrayGridMenu addObject:forumsub];
    }
    
    if (_arrayGridMenu.count<=7) {
        ForumSubModel *forumsub= [[ForumSubModel alloc]init];
        forumsub.name=@"全部版块";
        forumsub.image=@"grid_menu_more";
        [_arrayGridMenu addObject:forumsub];
    }
    [_gridMenu reloadData];
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
    
    NSLog(@"--1---isLoading:%ld,sEnd=%ld,isHeader=%ld",_isLoading,_isEnd,isHeader);
    if (_isLoading==0 && _isEnd==NO) {
        _isLoading=1;
        
        NSDictionary *param=@{@"page":@(_page+1)};
        [_app.net request:_url param:param withMethod:@"POST"
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      NSLog(@"--2---isLoading:%ld,sEnd=%ld,isHeader=%ld",_isLoading,_isEnd,isHeader);
                      NSDictionary *dict = (NSDictionary *)responseObject;
                      if([dict[@"code"] integerValue]==0){
                          _page=[dict[@"page"] intValue];
                          _pageCount=[dict[@"pagecount"] intValue];
                          
                          NSDictionary *digest=dict[@"data"];
                          NSArray *threadArray = [ThreadModel mj_objectArrayWithKeyValuesArray:digest];
                          for(ThreadModel* item in threadArray){
                              CjwItem *cjwItem=[[CjwItem alloc]init];
                              cjwItem.tid=NSString(item.tid);
                              cjwItem.title=item.title;
                              cjwItem.subtitle=[NSString stringWithFormat:@"%@    %ld阅读",item.author,item.hits];
                              cjwItem.dateline=item.dateline;
                              //cjwItem.flag=item[@"flag"];
                              //cjwItem.flagcolor=item[@"flagcolor"];
                              switch (item.imglist.count) {
                                  case 1:
                                  case 2:
                                      cjwItem.sharepic=item.imglist[0];
                                      cjwItem.url_pic0=item.imglist[0];
                                      cjwItem.type=cell_type_news_pic_one;
                                      break;
                                  default:
                                      cjwItem.type=cell_type_news_text;
                                      break;
                              }
                              
                              if(item.imglist.count>=3){
                                  cjwItem.sharepic=item.imglist[0];
                                  cjwItem.url_pic0=item.imglist[0];
                                  cjwItem.url_pic1=item.imglist[1];
                                  cjwItem.url_pic2=item.imglist[2];
                                  cjwItem.type=cell_type_news_pic_three;
                                  if (item.imglist.count>3) {
                                      cjwItem.imginfo=[NSString stringWithFormat:@"%ld图",item.imgnum];
                                  }
                              }
                              [_data addObject:cjwItem];
                          }
                      }
                      _isLoading=2;
                      if (isHeader){
                          NSLog(@"--3---isLoading:%ld,sEnd=%ld,isHeader=%ld",_isLoading,_isEnd,isHeader);
                          [_tableView reloadData];
                          [_tableView.mj_header endRefreshing];
                          _isLoading=0;
                      }
                      else if (_isEnd) {
                          NSLog(@"--4---isLoading:%ld,sEnd=%ld,isHeader=%ld",_isLoading,_isEnd,isHeader);
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
        NSLog(@"--5---isLoading:%ld,sEnd=%ld,isHeader=%ld",_isLoading,_isEnd,isHeader);
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    _cellHeaderHeight=200;
    CGFloat searchH=45;
    UIView *view=[[UIView alloc]init];
    UIButton* search=[[UIButton alloc]initWithFrame:CGRectMake(5, 5, SCREEN_WIDTH-10, searchH-10)];
    [search setTitle:@"请输入关键词搜索相关帖子或用户" forState:UIControlStateNormal];
    search.titleEdgeInsets=UIEdgeInsetsMake(0, 20, 0, 0);
    [search setTitleColor:[UIColor colorWithHexString:@"444444"] forState:UIControlStateNormal];
    [search setImage:[UIImage imageNamed:@"ic_search"] forState:UIControlStateNormal];
    search.backgroundColor=[UIColor whiteColor];
    search.titleLabel.font=[UIFont systemFontOfSize:13];
    search.layer.cornerRadius=16;
    [search addTarget:self action:@selector(actionSearch:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:search];
    
    [view addSubview:[self addGridMenu]];
    _gridMenu.frame=CGRectMake(0, searchH, SCREEN_WIDTH, _cellHeaderHeight);
    
    _cellHeaderHeight+=_app.skin.floatSeparatorSpaceHeight;
    //--------------------------
    _navMenu=[[CjwNavMenu alloc]initWithFrame:CGRectMake(0,_cellHeaderHeight+searchH,SCREEN_WIDTH,44) array:@[@"最新发布",@"每周热帖",@"最后回复"] menuColor:_app.skin.colorCellTitle];
    _navMenu.lineColor=_app.skin.colorMain;
    _navMenu.backgroundColor=[UIColor colorWithHexString:@"ffffff"];
    _navMenu.menuSelectColor=_app.skin.colorTabbarSelected;
    _navMenu.delegate=self;
    _navMenu.eachSpace=0;
    [_navMenu setCurrentIndex:_curNavMenu];
    [view addSubview:_navMenu];
    //--------------------------
    _cellHeaderHeight+=44+searchH;
    view.frame=CGRectMake(0, 0, SCREEN_WIDTH, _cellHeaderHeight+0.5);
    view.backgroundColor=_app.skin.colorCellSelectBg;
    return view;
}

-(void)actionSearch:(id)sender{
    SearchViewController *search=[[SearchViewController alloc]init];
    [self.navigationController pushViewController:search animated:TRUE];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return _cellHeaderHeight+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _data.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CjwItem *item=_data[indexPath.row];
    CjwNewsCell *cell = [_tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CjwNewsCell class])];
    cell.item=item;
    return cell;
}

#pragma mark 设置每行高度（每行高度可以不一样）
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    _newsCell.item=_data[indexPath.row];
    return _newsCell.height+1;
}

-(void)tableView:(UITableView* )tableView willDisplayCell:(UITableViewCell* )cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 15)];
    [cell setLayoutMargins:UIEdgeInsetsZero];
    _isEnd=NO;
    if (indexPath.row>_data.count*0.7) {
        [self loadData:NO];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CjwItem *item=_data[indexPath.row];
    DetailViewController *detail=[[DetailViewController alloc]init];
    detail.contmode=1;
    detail.artTitle=item.title;
    detail.webUrl=[NSString stringWithFormat:URL_web_detail,item.tid];
    detail.tid=item.tid;
    detail.sharepic=item.sharepic;
    [self.navigationController pushViewController:detail animated:TRUE];
    NSLog(@"row:%@",item);
}

- (void)navMeunDidSelectedWithIndex:(NSInteger)index{
    //附加刷新网址
    _curNavMenu=index;
    _url=[NSString stringWithFormat:@"%@?fid=%ld",URL_bbs_thread,_curNavMenu];
    [_tableView.mj_header beginRefreshing];
}
//-------------------------------------------------------------

#pragma mark - CjwGridMenuDataSource -
- (NSInteger)numberOfItemsInCjwGridMenu:(CjwGridMenu *)cjwGridMenu {
    return [_arrayGridMenu count];
}

- (NSString *)cjwGridMenu:(CjwGridMenu *)cjwGridMenu titleForItemAtIndex:(NSInteger)index {
    ForumSubModel* forumsub=[_arrayGridMenu objectAtIndex:index];
    return forumsub.name;
}

- (NSURL *)cjwGridMenu:(CjwGridMenu *)cjwGridMenu iconURLForItemAtIndex:(NSInteger)index {
    ForumSubModel* forumsub=[_arrayGridMenu objectAtIndex:index];
    if([forumsub.image hasPrefix:@"http"]){
        return [NSURL URLWithString:forumsub.image];
    }
    else{
        NSString *path = [[NSBundle mainBundle] pathForResource:forumsub.image ofType:@"png"];
        NSURL* url = [NSURL fileURLWithPath:path];
        return url;
    }
}

#pragma mark - CjwGridMenuDelegate -

- (UIColor *)colorForCurrentPageControlInCjwGridMenu:(CjwGridMenu *)cjwGridMenu {
    return _app.skin.colorMainLight;
}

- (NSInteger)numberOfRowsPerPageInCjwGridMenu:(CjwGridMenu *)cjwGridMenu {
    return 2;
}

- (NSInteger)numberOfColumnsPerPageInCjwGridMenu:(CjwGridMenu *)cjwGridMenu {
    return 4;
}

- (void)cjwGridMenu:(CjwGridMenu *)cjwGridMenu didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"item %zd 被点击",index);
    ForumSubModel* forumsub=[_arrayGridMenu objectAtIndex:index];
    if([forumsub.name rangeOfString:@"全部版块"].location == NSNotFound){
        ForumViewController *forum=[[ForumViewController alloc]init];
        forum.navTitle=forumsub.name;
        forum.fid=[forumsub.fid intValue];
        forum.imgPicketType=ImagePicket_bbs;
        [self.navigationController pushViewController:forum animated:TRUE];
    }
    else{
        BBSMenuViewController *bbsmenu=[[BBSMenuViewController alloc]init];
        bbsmenu.isHaveAddButton=YES;
        bbsmenu.navTitle=forumsub.name;
        bbsmenu.arrayBbsForum=_app.forumMenu;
        [self.navigationController pushViewController:bbsmenu animated:TRUE];
    }
}

//-------------------------------------------------------------
-(void)actionCellLike:(id)sender{
    NSLog(@"actionCellLike:%lu",[sender tag]);
}


-(void)actionCellShare:(id)sender{
    NSLog(@"actionCellShare:%lu",[sender tag]);
}

-(void)actionCellReply:(id)sender{
    NSLog(@"actionCellReply:%lu",[sender tag]);
}

//-------------------------------------------------------------

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
