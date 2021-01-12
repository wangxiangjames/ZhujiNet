//
//  ForumViewController.m
//  ZhujiNet
//
//  Created by chenjinwei on 17/6/11.
//  Copyright © 2017年 zhuji.net. All rights reserved.
//

#import "ForumViewController.h"
#import "Common.h"
#import "MJRefresh.h"
#import "DetailViewController.h"
#import "ThreadModel.h"

@interface ForumViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,NavMenuDelegate,TXVideoPublishListener>{
    AppDelegate                 *_app;
    UITableView                 *_tableView;
    CjwNewsCell                 *_newsCell;
    MJRefreshAutoNormalFooter   *_refeshFooter;
    
    NSMutableArray              *_data;
    NSInteger                   _page;
    NSInteger                   _pageCount;
    NSInteger                   _isLoading; //0没有加载，1正在加载，2加载完成
    BOOL                        _isEnd;     //是否触到底部
    
    CGFloat                     _cellHeaderHeight;
    NSUInteger                  _curNavMenu;
    
    
    NSMutableDictionary         *_newPost;
    NSMutableArray              *_selectPhoto;
    NSInteger                   _currUploadNum;
    NSString                    *_imgid;
    //--------------------------------
    NSString                    *_title;
    NSString                    *_message;
    NSMutableArray              *_photos;
    BOOL                        _bUploadVideo;
    TXPublishResult             *_videoResult;
    
    //CjwNavMenu                  *_navMenu;
}

@end

@implementation ForumViewController

- (void)viewWillAppear:(BOOL)animated{
    _app = [AppDelegate getApp];
    [_app.skin setSkin:self];
    self.navigationItem.title = self.navTitle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigation];
    
    _app = [AppDelegate getApp];
    
    _newPost= [NSMutableDictionary dictionary];
    _selectPhoto= [NSMutableArray arrayWithCapacity:9];
    _currUploadNum=0;
    _imgid=@"";
    _title=@"";
    _message=@"";
    _videoResult=[[TXPublishResult alloc]init];
    
    _data = [NSMutableArray arrayWithCapacity:20];
    _page=0;
    _pageCount=0;
    _isLoading=NO;
    _isEnd=NO;
    
    [self addTableView];
    [self registerCell];
    
    UIBarButtonItem *item=[[UIBarButtonItem alloc]
                           initWithImage:[UIImage imageNamed:@"nav_write"]
                           style:UIBarButtonItemStylePlain
                           target:self
                           action:@selector(navBbsCircleShop:)];
    item.imageInsets = UIEdgeInsetsMake(2, 2, 2, 2);
    self.navigationItem.rightBarButtonItem =item;
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
    CGRect rect=CGRectMake(0, 0, self.view.frame.size.width,  self.view.frame.size.height - Height_NavBar);
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
        
        NSString* url=[NSString stringWithFormat:@"%@?fid=%ld",URL_bbs_thread,(long)self.fid];
        NSDictionary *param=@{@"page":@(_page+1)};
        [_app.net request:url param:param withMethod:@"POST"
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
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
     UIView *view=[[UIView alloc]init];
     /*
     _cellHeaderHeight=44;
     //--------------------------
     if (self.isNewsType) {
        _navMenu=[[CjwNavMenu alloc]initWithFrame:CGRectMake(0,0,SCREEN_WIDTH,_cellHeaderHeight) array:@[@"最新回复",@"最新发布",@"精华热帖"] menuColor:_app.skin.colorCellTitle];
     }
     else{
        _navMenu=[[CjwNavMenu alloc]initWithFrame:CGRectMake(0,0,SCREEN_WIDTH,_cellHeaderHeight) array:@[@"24小时热点",@"最新发布",@"最后回复"] menuColor:_app.skin.colorCellTitle];
     }
     _navMenu.lineColor=_app.skin.colorMain;
     _navMenu.backgroundColor=Color(0xffffff);
     _navMenu.menuSelectColor=_app.skin.colorTabbarSelected;
     _navMenu.delegate=self;
     [_navMenu setCurrentIndex:_curNavMenu];
     [view addSubview:_navMenu];
      */
     //--------------------------
     view.frame=CGRectMake(0, 0, SCREEN_WIDTH, _cellHeaderHeight+0.5);
     view.backgroundColor=_app.skin.colorCellSelectBg;
     return view;
}

/*
 - (void)navMeunDidSelectedWithIndex:(NSInteger)index{
    //附加刷新网址
    _curNavMenu=index;
    [_tableView.mj_header beginRefreshing];
}
*/

//-------------------------------------------------------------
-(void)navBbsCircleShop:(id)sender{
    NSLog(@"chenjinwe-:%ld",self.fid);
    __weak typeof(&*self)weakSelf = self;
    [CjwFun selectImgCont:self.imgPicketType
                      fid:self.fid
                 topTitle:nil
             withTextCont:nil
           viewController:self
              resultAcion:^(NSInteger fid,NSString *title,NSString *contnet,NSMutableArray *photos,NSString *videoUrl,NSInteger videoNum,UIImage* coverImg){
                  
                  _photos=photos;
                  self.fid=fid;
                  _title=title;
                  _message=contnet;
                  _title=contnet;
                  
                  [MBProgressHUD showMessage:@"请稍候"];
                  
                  if(videoNum==1){
                      _bUploadVideo=YES;
                      [CjwFun uploadVideo:videoUrl coverImage:coverImg delegate:weakSelf];
                  }
                  else{
                      _bUploadVideo=NO;
                      [weakSelf uploadContent:_photos forumId:_fid forumTitle:_title forumContent:_message videoUrl:nil];
                  }
              }];
}

-(void)uploadContent:(NSMutableArray*)photos forumId:(NSInteger) fid forumTitle:(NSString*)title forumContent:(NSString*)content videoUrl:(NSString*)vUrl {
    
    [_newPost removeAllObjects];
    [_selectPhoto removeAllObjects];
    [_selectPhoto addObjectsFromArray:photos];
    _currUploadNum=0;
    _imgid=@"";
    
    [_newPost setObject:@"newthread" forKey:@"action"];
    [_newPost setObject:NSString(fid) forKey:@"fid"];
    [_newPost setObject:title forKey:@"subject"];
    [_newPost setObject:content forKey:@"message"];
    if(vUrl){
        [_newPost setObject:vUrl forKey:@"videourl"];
    }
    
    if (_selectPhoto.count>_currUploadNum) {
        _currUploadNum=1;
        [self uploadImages:_selectPhoto[_currUploadNum-1]];
    }
    else{
        [CjwFun sendPost:_newPost isUplodVideo:_bUploadVideo uploadVideoResult:_videoResult viewController:self
               closeType:NO];
    }
}

-(void)uploadImages:(UIImage*)image{
    [CjwFun uploadImage:image resultAcion:^(id responseObject){
        NSDictionary *dict = (NSDictionary *)responseObject;
        if ([dict objectForKey:@"data"]) {
            if ([_imgid isEqualToString:@""]) {
                _imgid=dict[@"data"][@"imgid"];
            }
            else{
                _imgid= [NSString stringWithFormat:@"%@|%@",_imgid,dict[@"data"][@"imgid"]];
            }
            
            if (_selectPhoto.count>_currUploadNum) {
                _currUploadNum++;
                [self uploadImages:_selectPhoto[_currUploadNum-1]];
            }
            else{
                [_newPost setObject:_imgid forKey:@"images"];
                [CjwFun sendPost:_newPost isUplodVideo:_bUploadVideo uploadVideoResult:_videoResult viewController:self
                       closeType:NO];
            }
            NSLog(@"cjw:%@",_newPost);
        }
    }];
}

//------------------------------------------------------------
#pragma mark - TXVideoPublishListener
-(void) onPublishProgress:(NSInteger)uploadBytes totalBytes: (NSInteger)totalBytes
{
    NSLog(@"onPublishProgress [%ld/%ld]", (long)uploadBytes, (long)totalBytes);
}

-(void) onPublishComplete:(TXPublishResult*)result
{
    if (result.retCode != 0) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD toast:result.descMsg toView:self.view];
    }
    else{
        _videoResult=result;
        [self uploadContent:_photos forumId:_fid forumTitle:_title forumContent:_message videoUrl:result.videoURL];
        
        NSLog(@"onPublishComplete %@,%@,%@", result.videoId,result.videoURL, result.coverURL);
    }
}

//------------------------------------------------------------
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
