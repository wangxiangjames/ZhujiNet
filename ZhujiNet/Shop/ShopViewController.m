//
//  ShopViewController.m
//  ZhujiNet
//
//  Created by zhujiribao on 2017/8/4.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import "ShopViewController.h"
#import "CjwGridMenu.h"
#import "ShopCell.h"
#import "PhotoBrowser.h"
#import "ForumSubModel.h"
#import "DetailViewController.h"
#import "ForumViewController.h"
#import "ThreadModel.h"

@interface ShopViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,CjwGridMenuDelegate,CjwGridMenuDataSource>{
    AppDelegate                 *_app;
    UITableView                 *_tableView;
    CjwNewsCell                 *_newsCell;
    MJRefreshAutoNormalFooter   *_refeshFooter;
    CjwGridMenu                 *_gridMenu;
    
    NSMutableArray              *_data;
    NSInteger                   _page;
    NSInteger                   _pageCount;
    NSInteger                   _isLoading; //0没有加载，1正在加载，2加载完成
    BOOL                        _isEnd;     //是否触到底部
    
    NSMutableArray              *_arrayGridMenu;
    NSString                    *_url;
    CGFloat                     _cellHeaderHeight;
    NSUInteger                  _curRow;
}

@end

@implementation ShopViewController

- (void)viewWillAppear:(BOOL)animated{
    _app = [AppDelegate getApp];
    [_app.skin setSkin:self];
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
    
    _url=URL_shop_post;
    
    [self addTableView];
    [self registerCell];
    [self loadGridMenu];
    [self loadShopMenu];
}

-(void)loadGridMenu{
    [_app.net request:URL_shop_forum param:nil withMethod:@"POST"
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSDictionary *dict = (NSDictionary *)responseObject;
                  if([dict[@"code"] integerValue]==0){
                      _arrayGridMenu=[ForumSubModel mj_objectArrayWithKeyValuesArray:dict[@"data"]];
                      [_gridMenu reloadData];
                  }
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              }];
}

//诸暨圈话题
-(void)loadShopMenu{
    [_app.net request:URL_shop_forum param:nil withMethod:@"POST"
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSDictionary *dict = (NSDictionary *)responseObject;
                  if([dict[@"code"] integerValue]==0){
                      _app.shopMenu=[ForumSubModel mj_objectArrayWithKeyValuesArray:dict[@"data"]];
                  }
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              }];
}

-(void)addTableView{
    CGRect rect=CGRectMake(0, 0, self.view.frame.size.width,  self.view.frame.size.height - Height_NavBar-Height_TabBar);
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
        NSLog(@"-----footer-----");
        _isEnd=YES;
        [self loadData:NO];
    }];
    _tableView.mj_footer =_refeshFooter;
    //_refeshFooter.scrollView.bounces = NO;
    //_refeshFooter.triggerAutomaticallyRefreshPercent=0;
    [self.view addSubview:_tableView];
}

-(void) reloadData{
    [_tableView reloadData];
    
    //[_tableView reloadSections:[NSIndexSet indexSetWithIndex:[_data count]] withRowAnimation:UITableViewRowAnimationNone];
    
    /*if (@available(iOS 11.0, *)) {
        [_tableView reloadData];
    }
    else{
        _tableView.hidden = YES;
        [_tableView reloadData];
        if ([_data count] > 1){
            // 动画之前先滚动到倒数第二个消息
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_data count] - 2 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
        _tableView.hidden = NO;
        // 添加向上顶出最后一个消息的动画
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[_data count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }*/
}

- (void)registerCell{
    _newsCell=[[CjwNewsCell alloc]init];
    [_tableView registerClass:[CjwNewsCell class] forCellReuseIdentifier:NSStringFromClass([_newsCell class])];
}

-(CjwGridMenu*)addGridMenu{
    if(!_gridMenu){
        _gridMenu= [[CjwGridMenu alloc]init];
        _gridMenu.backgroundColor=_app.skin.colorCellBg;
        _gridMenu.iconAlpha=_app.skin.floatImgAlpha;
        _gridMenu.colorText=_app.skin.colorGridMenuText;
        _gridMenu.iconWidth=48;
        _gridMenu.cornerRadius=5;
        _gridMenu.dataSource = self;
        _gridMenu.delegate = self;
        [_gridMenu reloadData];
    }
    return _gridMenu;
}

-(void)loadData:(BOOL)isHeader{
    if (isHeader) {
        [_refeshFooter resetNoMoreData];    //页数全部加载完成后，重新涮新需重置
        //[_refeshFooter setTitle:@"努力加载中……" forState:MJRefreshStateIdle];
        _page=0 ;
        [_data removeAllObjects];
        _isLoading=0;
        _isEnd=0;
    }
   
    NSLog(@"--1---isLoading:%ld,sEnd=%ld,isHeader=%ld",_isLoading,_isEnd,isHeader);
    if (_isLoading==0 && _isEnd==NO) {
        _isLoading=1;
        
        if(_page % 10==0){
            [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
        }
        
        NSDictionary *param=@{@"page":@(_page+1)};
        [_app.net request:_url param:param withMethod:@"POST"
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      NSLog(@"--2---isLoading:%ld,sEnd=%ld,isHeader=%ld",_isLoading,_isEnd,isHeader);
                      NSDictionary *dict = (NSDictionary *)responseObject;
                      if([dict[@"code"] integerValue]==0){
                          _page=[dict[@"page"] intValue];
                          _pageCount=[dict[@"pagecount"] intValue];
                          
                          NSDictionary *digest=dict[@"data"];
                          NSArray *shopArray = [ThreadModel mj_objectArrayWithKeyValuesArray:digest];
                          for (ThreadModel *shop in shopArray) {
                              CjwItem *cjwItem=[[CjwItem alloc]init];
                              cjwItem.tid=NSString(shop.tid);
                              cjwItem.title=shop.title;
                              cjwItem.subtitle=[NSString stringWithFormat:@"%@    %ld阅读",shop.forumname,(long)shop.hits];
                              cjwItem.dateline=shop.dateline;
                              //cjwItem.flag=item[@"flag"];
                              //cjwItem.flagcolor=item[@"flagcolor"];
                              switch (shop.imglist.count) {
                                  case 1:
                                  case 2:
                                      if (shop.imglist[0]!=nil) {
                                          cjwItem.sharepic=shop.imglist[0];
                                          cjwItem.url_pic0=shop.imglist[0];
                                          cjwItem.type=cell_type_news_pic_one;
                                          cjwItem.imginfo=[NSString stringWithFormat:@"%ld图",shop.imgnum];
                                      }
                                      break;
                                  default:
                                      cjwItem.type=cell_type_news_text;
                                      break;
                              }
                              
                              if(shop.imglist.count>=3){
                                  if (shop.imglist[0]!=nil) {
                                      cjwItem.sharepic=shop.imglist[0];
                                      cjwItem.url_pic0=shop.imglist[0];
                                  }
                                  if (shop.imglist[1]!=nil) {
                                      cjwItem.url_pic1=shop.imglist[1];
                                  }
                                  if (shop.imglist[2]!=nil) {
                                      cjwItem.url_pic2=shop.imglist[2];
                                  }
                                  cjwItem.type=cell_type_news_pic_three;
                                  cjwItem.imginfo=[NSString stringWithFormat:@"%ld图",shop.imgnum];
                              }
                              
                              cjwItem.videocover=shop.videocover;
                              cjwItem.videourl=shop.videourl;
                              if (cjwItem.videocover.length>0) {
                                  cjwItem.url_pic0=shop.videocover;
                                  cjwItem.type=cell_type_news_pic_one;
                                  cjwItem.isVideo=YES;
                                  cjwItem.imginfo=[NSString stringWithFormat:@"视频"];
                              }
                              [_data addObject:cjwItem];
                          }
                      }
                      _isLoading=2;
                      if (isHeader){
                          NSLog(@"--3---isLoading:%ld,sEnd=%ld,isHeader=%ld",_isLoading,_isEnd,isHeader);
                          [self reloadData];
                          //[self reloadData];
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
    [self reloadData];
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
    UIView *view=[[UIView alloc]init];

    [view addSubview:[self addGridMenu]];
    _gridMenu.frame=CGRectMake(0, 0, SCREEN_WIDTH, _cellHeaderHeight);
    
    view.frame=CGRectMake(0, 0, SCREEN_WIDTH, _cellHeaderHeight+0.5-Height_TabBar);
    view.backgroundColor=_app.skin.colorCellSelectBg;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return _cellHeaderHeight+_app.skin.floatSeparatorSpaceHeight;
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
    detail.vedioUrl=item.videourl;
    detail.artTitle=item.title;
    detail.webUrl=[NSString stringWithFormat:URL_web_detail,item.tid];
    detail.tid=item.tid;
    detail.sharepic=item.sharepic;
    [self.navigationController pushViewController:detail animated:TRUE];
    NSLog(@"row:%@",item);
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
    return 5;
}

- (void)cjwGridMenu:(CjwGridMenu *)cjwGridMenu didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"item %zd 被点击",index);
    ForumSubModel* forumsub=[_arrayGridMenu objectAtIndex:index];
    ForumViewController *forum=[[ForumViewController alloc]init];
    forum.imgPicketType=ImagePicket_shop;
    forum.navTitle=forumsub.name;
    forum.fid=[forumsub.fid intValue];
    [self.navigationController pushViewController:forum animated:TRUE];
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
