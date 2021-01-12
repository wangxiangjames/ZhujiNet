//
//  ContentViewController.m
//  ZhujiNet
//
//  Created by zhujiribao on 2017/7/25.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//
#import "ContentViewController.h"
#import "DetailViewController.h"
#import "SliderModel.h"
#import "WKWebViewController.h"
#import "WKWebViewController.h"
#import "ShangModel.h"
#import "RootViewController.h"
#import "HomeViewController.h"
#import "MenuModel.h"
#import <ShareSDKUI/ShareSDKUI.h>
#import <SJVideoPlayer.h>


static const NSInteger          TAG_BASE=2000;

@interface ContentViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,SDCycleScrollViewDelegate,CjwGridMenuDelegate,CjwGridMenuDataSource>{
    AppDelegate                 *_app;
    CjwNewsCell                 *_newsCell;
    CjwVedioCell                *_vedioCell;
    UITableView                 *_tableView;
    MJRefreshAutoNormalFooter   *_refeshFooter;
    
    NSMutableArray              *_data;
    NSInteger                   _page;
    NSInteger                   _pageCount;
    BOOL                        _isLoading;
    
    CGFloat                     _cellHeaderHeight;
    CGFloat                     _videoTop;
    CGFloat                     _contentOffsetY;
    
    BOOL                        _isShowSlider;
    BOOL                        _isShowGridMenu;
    NSMutableArray              *_slider;
    NSMutableArray              *_gridMenu;
    NSInteger                   _videoIndex;
}
@property (strong, nonatomic, nullable) SJVideoPlayer *player;
@end



@implementation ContentViewController

- (void)viewWillAppear:(BOOL)animated{
    _app = [AppDelegate getApp];
    [_app.skin setSkin:self];
    self.tabBarController.navigationItem.title=@"掌上诸暨";
    if (self.dmode==2) {
        [_tableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.player vc_viewDidAppear];
}

- (void)viewWillDisappear:(BOOL)animated{
    [self onTabMenuClick];
    [self.player vc_viewDidDisappear];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (BOOL)prefersPointerLocked {
    return [self.player vc_prefersStatusBarHidden];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.player vc_preferredStatusBarStyle];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _app = [AppDelegate getApp];
    _isLoading=NO;
    _page=1;
    _pageCount=1;
    _data = [NSMutableArray arrayWithCapacity:20];
    
    [self setTableView];
    [self loadSlider];
    [self loadGridMenu];
}

-(void)loadSlider{
    [_app.net request:[NSString stringWithFormat:@"%@?channel=%ld&stype=1",URL_slider,_fid] param:nil withMethod:@"POST"
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        if([dict[@"code"] integerValue]==0){
            //NSLog(@"loadSlider:%@",responseObject);
            _slider=[SliderModel mj_objectArrayWithKeyValuesArray:dict[@"data"]];
            if([_slider count]>0){
                _isShowSlider=YES;
                NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
                [_tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

-(void)loadGridMenu{
    [_app.net request:[NSString stringWithFormat:@"%@?channel=%ld&stype=2",URL_slider,_fid] param:nil withMethod:@"POST"
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        if([dict[@"code"] integerValue]==0){
            _gridMenu=[SliderModel mj_objectArrayWithKeyValuesArray:dict[@"data"]];
            if([_gridMenu count]>0){
                _isShowGridMenu=YES;
                NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
                [_tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}


-(void)setTableView{
    _newsCell=[[CjwNewsCell alloc]init];
    _vedioCell=[[CjwVedioCell alloc]init];
    
    CGRect rect=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 20-44-40-49);
    _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStyleGrouped];
    _tableView.delegate=self;
    _tableView.dataSource=self;
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
        if(_isLoading==NO){
            _isLoading=YES;
            [_app.net request:self url:_url param:nil callTag:0];
        }
    }];
    
    _refeshFooter=[MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if(_isLoading==NO){
            _isLoading=YES;
            NSDictionary *param=@{@"page":[NSNumber numberWithLong:_page+1]};
            [_app.net request:self url:_url param:param callTag:1];
        }
    }];
    
    _tableView.mj_footer =_refeshFooter;
    [_tableView.mj_header beginRefreshing];
    
    [self.view addSubview:_tableView];
    
    NSLog(@"ispost:%ld",self.ispost);
    if (self.ispost==1) {
        UIImageView * writeImg =[[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-60, SCREEN_HEIGHT - 25-44-40-49-Height_NavBar_HomeIndicator, 45, 45)];
        [writeImg setImage:[UIImage imageNamed:@"post"]];
        [self.view addSubview: writeImg];
        writeImg.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [writeImg addGestureRecognizer:singleTap];
    }
}

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"ImageView");
    RootViewController* root=(RootViewController*)self.tabBarController;
    root.imagePicketPageType=ImagePicket_bbs;
    root.selectForumTitle=self.title;
    [root navBbsCircleShop:nil];
}

-(SDCycleScrollView*)setSycleScollView:(CGRect)rect{
    NSMutableArray *titles=[NSMutableArray arrayWithCapacity:10];
    NSMutableArray *imgUrl=[NSMutableArray arrayWithCapacity:10];
    for (SliderModel* item in _slider) {
        if ([item.url isEqualToString:@"weather"]) {
            [titles addObject:@""];
            [imgUrl addObject:@"weather:"];
        }
        else{
            [titles addObject:item.title];
            [imgUrl addObject:item.image];
        }
    }
    
    SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:rect delegate:nil placeholderImage:[UIImage imageNamed:kImgHolder]];
    cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentRight;
    cycleScrollView.titlesGroup = titles;
    cycleScrollView.alpha=_app.skin.floatImgAlpha;
    cycleScrollView.currentPageDotColor = [UIColor whiteColor]; // 自定义分页控件小圆标颜色
    cycleScrollView.autoScrollTimeInterval = 5;
    cycleScrollView.autoScroll=YES;
    cycleScrollView.bannerImageViewContentMode=UIViewContentModeScaleAspectFill;
    cycleScrollView.delegate=self;
    // --- 模拟加载延迟
    /*dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
     cycleScrollView.imageURLStringsGroup = imagesURLStrings;
     });*/
    cycleScrollView.imageURLStringsGroup = imgUrl;
    return cycleScrollView;
}

-(CjwGridMenu*)setGridMenu:(CGRect)rect{
    NSMutableArray *titles=[NSMutableArray arrayWithCapacity:10];
    NSMutableArray *imgUrl=[NSMutableArray arrayWithCapacity:10];
    for (SliderModel* item in _gridMenu) {
        [titles addObject:item.title];
        [imgUrl addObject:item.image];
        
    }
    
    CjwGridMenu *cjwGridMenu= [[CjwGridMenu alloc]initWithFrame:rect];
    cjwGridMenu.backgroundColor=_app.skin.colorCellBg;
    cjwGridMenu.iconAlpha=_app.skin.floatImgAlpha;
    cjwGridMenu.colorText=_app.skin.colorGridMenuText;
    cjwGridMenu.iconWidth=42;
    cjwGridMenu.cornerRadius=21;
    cjwGridMenu.dataSource = self;
    cjwGridMenu.delegate = self;
    [cjwGridMenu reloadData];
    return cjwGridMenu;
}

-(void)setVideoView{
    if(!self.video){
        if(self.dmode){
            self.video=[[ZXVideoPlayerController alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH*9/16)];
        }
        else{
            self.video=[[ZXVideoPlayerController alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-28, (SCREEN_WIDTH-28)*9/16)];
        }
    }
    self.video.view.hidden=NO;
    [self.view addSubview:self.video.view];
}

- (void)requestCallback:(id)response status:(id)status{
    //NSLog(@"cccc__%@", response);
    if ([status[@"stat"] isEqual:@0]) {
        
        if([status[@"tag"] isEqual:@0]){
            [_data removeAllObjects];
            _page=1;
        }
        
        NSDictionary *dict = (NSDictionary *)response;
        if(dict[@"data"]!=nil){
            NSDictionary *digest=dict[@"data"];
            _page=[dict[@"page"] intValue];
            _pageCount=[dict[@"pagecount"] intValue];
            
            for(id item in digest){
                CjwItem *cjwItem=[[CjwItem alloc]init];
                cjwItem.tid=item[@"tid"];
                cjwItem.title=item[@"title"];
                cjwItem.flag=item[@"flag"];
                cjwItem.url=item[@"url"];
                NSString *kongge=@"    ";
                
                cjwItem.dateline=item[@"dateline"];
                cjwItem.flagcolor=item[@"flagcolor"];
                cjwItem.videourl=item[@"videourl"];
                cjwItem.videocover=item[@"videocover"];
                cjwItem.praise=[NSString stringWithFormat:@"%@",item[@"recommend_add"]];
                cjwItem.replies=[NSString stringWithFormat:@"%@",item[@"replies"]];
                
                if ([NSNull null] !=item[@"contmode"]) {
                    cjwItem.contmode=[item[@"contmode"] intValue];
                    if (cjwItem.contmode==3) {
                        cjwItem.tid=item[@"id"];
                    }
                }
                
                cjwItem.author=item[@"author"];
                cjwItem.shareurl=item[@"shareurl"];
                cjwItem.sharepic=@"";
                int imgnum=[item[@"imgnum"] intValue];
                if (imgnum>0 && imgnum<3) {
                    cjwItem.url_pic0=item[@"imglist"][0];
                    cjwItem.sharepic=item[@"imglist"][0];
                    if (cjwItem.flag.length>0) {
                        kongge=@"  ";
                    }
                }
                if (imgnum>=3) {
                    cjwItem.url_pic0=item[@"imglist"][0];
                    cjwItem.url_pic1=item[@"imglist"][1];
                    cjwItem.url_pic2=item[@"imglist"][2];
                    cjwItem.sharepic=item[@"imglist"][0];
                }
                
                int dmode=[item[@"dmode"] intValue];
                switch (dmode) {
                    case 1:
                        cjwItem.type=cell_type_news_text;
                        break;
                    case 2:
                        cjwItem.type=cell_type_news_pic_one_ad;
                        break;
                    case 3:
                        cjwItem.type=cell_type_news_pic_one_big;
                        break;
                    case 4:
                        cjwItem.type=cell_type_news_pic_one;
                        break;
                    case 5:
                        if (imgnum>3) {
                            cjwItem.imginfo=[NSString stringWithFormat:@"%@图",item[@"imgnum"]];
                        }
                        cjwItem.type=cell_type_news_pic_three;
                        break;
                    case 6:
                        cjwItem.isVideo=YES;
                        cjwItem.imginfo=item[@"videotime"];
                        cjwItem.type=cell_type_news_pic_one_big;
                        break;
                }
                if(dmode==0){
                    if(imgnum>0 && imgnum<3){
                        cjwItem.type=cell_type_news_pic_one;
                        cjwItem.imginfo=[NSString stringWithFormat:@"%@图",item[@"imgnum"]];
                    }
                    else if(imgnum>=3){
                        cjwItem.imginfo=[NSString stringWithFormat:@"%@图",item[@"imgnum"]];
                        cjwItem.type=cell_type_news_pic_three;
                    }
                    else{
                        cjwItem.type=cell_type_news_text;
                    }
                }
                
                //-----------------------------------------
                if (_istype==1 && [NSString stringWithFormat:@"%@",item[@"typename"]].length>0) {
                    cjwItem.flag=item[@"typename"];
                    cjwItem.flagcolor=@"ff0000";
                    NSLog(@"cjw:%@",item[@"typename"]);
                }
                if(self.dmode==3){      //问答版式
                    cjwItem.subtitle=[NSString stringWithFormat:@"%@人回答%@%@阅读",item[@"replies"],kongge,item[@"hits"]];
                }
                else if(self.dmode==2){ //视频版式
                    cjwItem.islike=[item[@"islike"] intValue];
                    cjwItem.url_pic1=item[@"avatar"];
                    cjwItem.subtitle=[NSString stringWithFormat:@"%@次播放",item[@"hits"]];
                }
                else if(self.dmode==1){ //论坛版式
                    cjwItem.subtitle=[NSString stringWithFormat:@"%@%@%@阅读",item[@"author"],kongge,item[@"hits"]];
                }
                else{
                    cjwItem.subtitle=[NSString stringWithFormat:@"%@%@%@阅读",item[@"forumname"],kongge,item[@"hits"]];
                }
                //-----------------------------------------
                [_data addObject:cjwItem];
            }
        }
        
        [_tableView reloadData];
        
        NSLog(@"ccc:_page=%d,page=%@,pagecount=%@",_page, dict[@"page"],dict[@"pagecount"]);
        
        if(_page>=[dict[@"pagecount"] intValue]){
            [_refeshFooter setTitle:@"没有更多数据了" forState:MJRefreshStateNoMoreData];
            [_tableView.mj_footer endRefreshingWithNoMoreData];
            if (_page==1) {
                [_tableView.mj_header endRefreshing];
            }
        }
        else{
            if([status[@"tag"] isEqual:@0]){
                [_tableView.mj_header endRefreshing];
            }
            //2019.05.05 下面都要执行，否则2页的话，不能加载第2页
            [_tableView.mj_footer endRefreshing];
        }
    }
    else{
        NSLog(@"网络失败");
        [_tableView.mj_header endRefreshing];
        [_tableView.mj_footer endRefreshing];
        [_refeshFooter setTitle:@"网络连接失败" forState:MJRefreshStateIdle];
    }
    
    //-------------------------------------
    _isLoading=NO;
    NSLog(@"page:%li",(long)_page);
    
}

//-------------------------------------------------------------
-(void) scrollViewDidScroll:(UIScrollView *) scrollView{
    if(self.dmode==2){
        self.video.view.frame=CGRectMake(0,_videoTop-scrollView.contentOffset.y,SCREEN_WIDTH,SCREEN_WIDTH*9/16);
    }
    else{
        self.video.view.frame=CGRectMake(14,_videoTop-scrollView.contentOffset.y,SCREEN_WIDTH-28,(SCREEN_WIDTH-28)*9/16);
    }
    _contentOffsetY=scrollView.contentOffset.y;
    
    if(_videoTop-scrollView.contentOffset.y<-SCREEN_WIDTH*9/16 || _videoTop-scrollView.contentOffset.y>SCREEN_HEIGHT-64-40){
        [self.video stop];
        self.video.view.hidden=YES;
    }
    
    /*if(_isLoading==NO && (scrollView.contentOffset.y+scrollView.frame.size.height)/scrollView.contentSize.height >0.95 && scrollView.contentSize.height>100){
     if (_page>=_pageCount) {
     return;
     }
     _isLoading=YES;
     _page++;
     NSDictionary *param=@{@"page":[NSNumber numberWithLong:_page]};
     [_app.net request:self url:_url param:param callTag:1];
     NSLog(@"加载数据UIScrollView");
     }*/
    
    //NSLog(@"cjw:%f",_videoTop-scrollView.contentOffset.y);
    // 滑動時觸發
    //NSLog(@"cjw:%f,%f",scrollView.contentOffset.x,scrollView.contentOffset.y+scrollView.frame.size.height);
    //NSLog(@"w:%f,h:%f",scrollView.contentSize.width,scrollView.contentSize.height);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSLog(@"cjw--:%f",scrollView.contentOffset.y);
}

//-------------------------------------------------------------
#pragma mark -
#pragma mark - UITableView dateSource

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    _cellHeaderHeight=0;
    UIView *view=[[UIView alloc]init];
    
    //-------------------------------------
    if(_isShowSlider==YES){
        CGFloat sycleScollHeight=150;
        CGRect rect=CGRectMake(0, 0, SCREEN_WIDTH, sycleScollHeight);
        [view addSubview:[self setSycleScollView:rect]];
        _cellHeaderHeight+=sycleScollHeight;
    }
    
    //-------------------------------------
    if(_isShowGridMenu==YES){
        CGFloat gridMenHeight=_gridMenu.count<=5 ? 95: 170;
        CGRect rect=CGRectMake(0, _cellHeaderHeight, SCREEN_WIDTH,  gridMenHeight);
        [view addSubview:[self setGridMenu:rect]];
        _cellHeaderHeight+=gridMenHeight;
    }
    
    //-------------------------------------
    view.frame=CGRectMake(0, 0, SCREEN_WIDTH, _cellHeaderHeight);
    view.backgroundColor=_app.skin.colorTableBg;
    return view;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(_isShowGridMenu==YES){
        return _cellHeaderHeight+_app.skin.floatSeparatorSpaceHeight;
    }
    return _cellHeaderHeight+0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _data.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CjwItem *item=_data[indexPath.row];
    if (self.dmode==2) {
        static NSString  *identifier = @"identifierCellVedio";
        CjwVedioCell *cell = [_tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil){
            cell = [[CjwVedioCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            cell.playerImg.userInteractionEnabled=YES;
            UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickImage:)];
            [cell.playerImg addGestureRecognizer:singleTap];
            [cell.btnMore addTarget:self action:@selector(btnMoreAction:) forControlEvents:UIControlEventTouchUpInside];
            cell.btnMore.tag=TAG_BASE+indexPath.row;
            [cell.btnZan addTarget:self action:@selector(btnZanAction:) forControlEvents:UIControlEventTouchUpInside];
            cell.btnZan.tag=TAG_BASE+indexPath.row;
            [cell.btnReply addTarget:self action:@selector(btnReplyAction:) forControlEvents:UIControlEventTouchUpInside];
            cell.btnReply.tag=TAG_BASE+indexPath.row;
        }
        cell.playerImg.tag=indexPath.row;
        
        if (item.islike==0 && [_app.locationLike  objectForKey: [NSString stringWithFormat:@"%@", item.tid]]) {
            [cell.btnZan setImage:[UIImage imageNamed:@"btn_zan"] forState:UIControlStateNormal];
            [cell.btnZan setTitle:[NSString stringWithFormat:@"%d",[item.praise intValue]+1] forState:UIControlStateNormal];
        }
        else if(item.islike==1){
            [cell.btnZan setImage:[UIImage imageNamed:@"btn_zan"] forState:UIControlStateNormal];
            [cell.btnZan setTitle:item.praise forState:UIControlStateNormal];
        }
        else{
            [cell.btnZan setImage:[UIImage imageNamed:@"btn_no_zan"] forState:UIControlStateNormal];
            [cell.btnZan setTitle:item.praise forState:UIControlStateNormal];
        }
        cell.item=item;
        [cell.btnReply setTitle:item.replies forState:UIControlStateNormal];
        return cell;
    }
    else{
        static NSString  *identifier = @"identifierCell";
        CjwNewsCell *cell = [_tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil){
            cell = [[CjwNewsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            
            UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickImage:)];
            [cell.img0 addGestureRecognizer:singleTap];
        }
        if(item.isVideo){
            cell.img0.userInteractionEnabled=YES;
        }
        else{
            cell.img0.userInteractionEnabled=NO;
        }
        cell.img0.tag=indexPath.row;
        cell.item=item;
        return cell;
    }
}

#pragma mark 设置每行高度（每行高度可以不一样）
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.dmode==2){
        _vedioCell.item=_data[indexPath.row];
        return _vedioCell.height+_app.skin.floatSeparatorSpaceHeight;
    }
    else{
        _newsCell.item=_data[indexPath.row];
        return _newsCell.height;
    }
}

-(void)tableView:(UITableView* )tableView willDisplayCell:(UITableViewCell* )cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 15)];
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[self triggerMenu:@"abc"];
    //return;
    
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CjwItem *item=_data[indexPath.row];
    
    DetailViewController *detail=[[DetailViewController alloc]init];
    
    detail.contmode=item.contmode;
    if (item.contmode==3 && item.url.length>0) {    //外链
        //        WKWebViewController  *webView=[[WKWebViewController alloc] init];
        //        webView.webUrl=item.url;
        //        NSLog(@"cjw:%@",webView.webUrl);
        //        [self.navigationController pushViewController:webView animated:TRUE];
        
        WKWebViewController  *webView=[[WKWebViewController alloc] init];
        webView.webUrl=item.url;
        
        ShareModel * share=[ShareModel alloc];
        share.thumbUrl=item.sharepic;
        share.title=item.title;
        share.descr=item.title;
        share.webpageUrl=item.url;
        webView.share=share;
        
        [self.navigationController pushViewController:webView animated:TRUE];
        [self pageCount:item.tid];
        return;
    }
    
    detail.webUrl=[NSString stringWithFormat:URL_web_detail,item.tid];
    detail.artTitle=item.title;
    detail.tid=item.tid;
    detail.video=self.video;
    detail.videoCover=item.videocover;
    detail.vedioUrl=item.videourl;
    detail.videoTime=item.imginfo;
    self.video=nil;
    
    detail.sharepic=item.sharepic;
    
    [self.navigationController pushViewController:detail animated:TRUE];
    NSLog(@"row:%@",item);
}

//-------------------------------------------------------------
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    SliderModel* slide=_slider[index];
    if (slide.jumpchannel>0) {
        [self triggerMenu:slide.jumpchannel];
        return;
    }
    
    if (slide.dmode==0) {
        if(![slide.url isEqualToString:@""]){
            WKWebViewController  *webView=[[WKWebViewController alloc] init];
            webView.webUrl=slide.url;
            [self.navigationController pushViewController:webView animated:TRUE];
        }
        return;
    }
    if (slide.dmode==1) {
        DetailViewController *detail=[[DetailViewController alloc]init];
        detail.contmode=slide.contmode;
        detail.artTitle=slide.title;
        detail.webUrl=[NSString stringWithFormat:URL_web_detail,NSString(slide.tid)];
        detail.tid=NSString(slide.tid);
        [self.navigationController pushViewController:detail animated:TRUE];
        return;
    }
    if (slide.dmode==2) {
        WKWebViewController  *webView=[[WKWebViewController alloc] init];
        webView.webUrl=URL_weatherContent;
        [self.navigationController pushViewController:webView animated:TRUE];
        return;
    }
}

//-------------------------------------------------------------
#pragma mark - CjwGridMenuDataSource -
- (NSInteger)numberOfItemsInCjwGridMenu:(CjwGridMenu *)cjwGridMenu {
    return [_gridMenu count];
}

- (NSString *)cjwGridMenu:(CjwGridMenu *)cjwGridMenu titleForItemAtIndex:(NSInteger)index {
    SliderModel* gridMenu=[_gridMenu objectAtIndex:index];
    return  [gridMenu title];
}

- (NSURL *)cjwGridMenu:(CjwGridMenu *)cjwGridMenu iconURLForItemAtIndex:(NSInteger)index {
    SliderModel* gridMenu=[_gridMenu objectAtIndex:index];
    return [NSURL URLWithString:gridMenu.image];
    /*
     NSString* str=[_arrayGridMenuPic objectAtIndex:index];
     if([str hasPrefix:@"http"]){
     return [NSURL URLWithString:[_arrayGridMenuPic objectAtIndex:index]];
     }
     else{
     NSString *path = [[NSBundle mainBundle] pathForResource:[_arrayGridMenuPic objectAtIndex:index] ofType:@"png"];
     NSURL* url = [NSURL fileURLWithPath:path];
     return url;
     }
     */
}

#pragma mark - CjwGridMenuDelegate -
- (NSInteger)numberOfRowsPerPageInCjwGridMenu:(CjwGridMenu *)cjwGridMenu {
    return _gridMenu.count<=5 ? 1: 2;
}

- (NSInteger)numberOfColumnsPerPageInCjwGridMenu:(CjwGridMenu *)cjwGridMenu {
    return 5;
}

- (void)cjwGridMenu:(CjwGridMenu *)cjwGridMenu didSelectItemAtIndex:(NSInteger)index {
    /*
     SliderModel* gridMenu=[_gridMenu objectAtIndex:index];
     WKWebViewController  *webView=[[WKWebViewController alloc] init];
     webView.webUrl=gridMenu.url;
     NSLog(@"cjw:%@",webView.webUrl);
     [self.navigationController pushViewController:webView animated:TRUE];
     */
    
    
    SliderModel* gridMenu=[_gridMenu objectAtIndex:index];
    WKWebViewController  *webView=[[WKWebViewController alloc] init];
    webView.webUrl=gridMenu.url;
    
    ShareModel * share=[ShareModel alloc];
    share.thumbUrl=gridMenu.image;
    share.title=gridMenu.title;
    share.webpageUrl=gridMenu.url;
    webView.share=share;
    
    //webView.webUrl=@"http://wap.zhujirc.com/jobApp/";
    //webView.webUrl=@"http://m.zhuji.net:9201/newhouse/index_cjw.html";
    //webView.webUrl=@"http://m.zhuji.net:9201/newhouse/fangchan_list_chushou_cjw.html";
    //NSLog(@"cjw:%@",webView.webUrl);
    [self.navigationController pushViewController:webView animated:TRUE];
}

//-------------------------------------------------------------
-(void)onClickImage:(UITapGestureRecognizer *)sender{
    UIImageView* iv=(UIImageView*)sender.view;
    NSLog(@"图片被点击%@",NSStringFromCGRect(iv.frame));
    
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:iv.tag inSection:0];
//    CGRect rectInTableView = [_tableView rectForRowAtIndexPath:indexPath];
    
    
    CjwItem *item=_data[indexPath.row];
    if (self.dmode!=2) {
        CjwNewsCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
        cell.video.hidden = YES;
    }
    
    if ([item.videourl isEqualToString:@""]) {
        if (item.contmode==3 && item.url.length>0) {    //外链
            WKWebViewController  *webView=[[WKWebViewController alloc] init];
            webView.webUrl=item.url;
            [self.navigationController pushViewController:webView animated:TRUE];
            [self pageCount:item.tid];
        }
        return;
    }
    
    

    if ( _player == nil ) {
        SJVideoPlayer.update(^(SJVideoPlayerSettings * _Nonnull commonSettings) {
            ///         commonSettings.placeholder = [UIImage imageNamed:@"placeholder"];
            ///         commonSettings.more_trackColor = [UIColor whiteColor];
                     commonSettings.progress_traceColor = [UIColor redColor];
//                     commonSettings.progress_bufferColor = [UIColor whiteColor];
        });
        _player = [SJVideoPlayer player];

        _player.allowHorizontalTriggeringOfPanGesturesInCells = YES;
        _player.resumePlaybackWhenScrollAppeared = NO;
        _player.defaultEdgeControlLayer.hiddenBottomProgressIndicator = YES;
        _player.playbackObserver.playbackStatusDidChangeExeBlock = ^(SJBaseVideoPlayer *_Nonnull player){
            if (player.isPlaying) {
                if (self.dmode!=2) {
                    CjwNewsCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
                    cell.video.hidden = YES;
                }
            }
        };

    }

    SJPlayModel *cellModel = [SJPlayModel playModelWithTableView:_tableView indexPath:indexPath];
    _player.URLAsset = [[SJVideoPlayerURLAsset alloc] initWithURL:[NSURL URLWithString:item.videourl] playModel:cellModel];
    
    //    [self setVideoView];
    //    if(self.dmode==2){
    //        _videoTop=rectInTableView.origin.y;
    //        _video.view.frame=CGRectMake(0,_videoTop-_contentOffsetY,SCREEN_WIDTH,(SCREEN_WIDTH)*9/16);
    //    }
    //    else{
    //        _videoTop=rectInTableView.origin.y+rectInTableView.size.height- (SCREEN_WIDTH-28)*9/16-16-20;
    //        _video.view.frame=CGRectMake(14,_videoTop-_contentOffsetY,SCREEN_WIDTH-28,(SCREEN_WIDTH-28)*9/16);
    //    }
    //
    //    _video.contentURL=[NSURL URLWithString:item.videourl];
    //    [_video play];
}
//-------------------------------------------------------------

-(void)onTabMenuClick{
    NSLog(@"onTabMenuClick1");
    [_video stop];
    self.video.view.hidden=YES;
}


-(void) btnZanAction:(UIButton*)sender{
    if(![_app.user checkUserLogin:self]){
        return;
    }
    
    NSIndexPath* cellPath = [_tableView indexPathForCell:(UITableViewCell*)sender.superview.superview];
    CjwItem *item=_data[cellPath.row];
    NSDictionary *param=@{@"tid":item.tid};
    [_app.net request:URL_recommend_add param:param withMethod:@"POST"
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"cjw:%@",responseObject);
        NSDictionary *dict = (NSDictionary *)responseObject;
        if([dict[@"code"] integerValue]==0){
            [sender setTitle:[NSString stringWithFormat:@"%d",[item.praise intValue]+1] forState:UIControlStateNormal];
            [sender setImage:[UIImage imageNamed:@"btn_zan"] forState:UIControlStateNormal];
            
            [_app.locationLike setObject:[NSDate date] forKey:[NSString stringWithFormat:@"%@", item.tid]];
            [CjwFun putLocaionDict:kLocationLike value:[_app.locationLike copy]];
        }
        else{
            [MBProgressHUD showError:dict[@"msg"] toView:self.view];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

-(void) btnReplyAction:(UIButton*)sender{
    NSInteger row =sender.tag - TAG_BASE;
    CjwItem *item=_data[row];
    DetailViewController *detail=[[DetailViewController alloc]init];
    
    detail.contmode=item.contmode;
    if(self.dmode==2){
        detail.contmode=2;
    }
    detail.artTitle=item.title;
    if([item.url length]>0){
        detail.webUrl=item.url;
        detail.tid=0;
    }
    else{
        detail.webUrl=[NSString stringWithFormat:URL_web_detail,item.tid];
        detail.tid=item.tid;
    }
    if(item.isVideo){
        detail.video=self.video;
        detail.vedioUrl=item.videourl;
        self.video=nil;
    }
    [self.navigationController pushViewController:detail animated:TRUE];
}

-(void) btnMoreAction:(UIButton*)sender{
    NSInteger row =sender.tag - TAG_BASE;
    
    ShareModel *shareModel=[[ShareModel alloc]init];
    CjwItem* item=_data[row];
    shareModel.title=item.title;
    shareModel.descr=item.author;
    shareModel.thumbUrl=item.sharepic;
    shareModel.webpageUrl=item.shareurl;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params SSDKSetupShareParamsByText:shareModel.descr
                                images:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:shareModel.thumbUrl]]]
                                   url:[NSURL URLWithString:shareModel.webpageUrl]
                                 title:shareModel.title
                                  type:SSDKContentTypeAuto];
    SSUIShareSheetConfiguration *config = [SSUIShareSheetConfiguration new];
    
    [ShareSDK showShareActionSheet:self.view customItems:@[@(SSDKPlatformSubTypeWechatSession),@(SSDKPlatformSubTypeWechatTimeline),@(SSDKPlatformSubTypeWechatFav),@(SSDKPlatformTypeQQ),@(SSDKPlatformSubTypeQZone),@(SSDKPlatformTypeSinaWeibo)] shareParams:params sheetConfiguration:config onStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
        
    }];
    
    //    [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_WechatTimeLine),@(UMSocialPlatformType_WechatFavorite),
    //                                               @(UMSocialPlatformType_QQ),@(UMSocialPlatformType_Qzone ),@(UMSocialPlatformType_Sina)]];
    //    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
    //        [CjwFun shareWebPageToPlatformType:platformType currentViewController:self shareCont:shareModel];
    //    }];
}

-(void)pageCount:(NSString*)nid{
    [_app.net request:[NSString stringWithFormat:@"%@?id=%@",URL_pagecount,nid] param:nil withMethod:@"POST"
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        if([dict[@"code"] integerValue]==0){
            NSLog(@"pagecount is add+1");
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    }];
}

-(void)triggerMenu:(NSInteger)channel{
    HomeViewController* vc=(HomeViewController*)[self parentViewController];
    int n=0;
    BOOL bFind=NO;
    NSString *channelName=@"";
    for (MenuModel* item in _app.menu) {
        if (item.fid==channel) {
            if(item.ishide==NO){
                //NSLog(@"menu:%@,%ld",item.title,item.fid);
                bFind=YES;
                [vc setTabMenu:n];
                break;
            }
            channelName=item.title;
        }
        n++;
    }
    //NSLog(@"menu:%@,%ld",item.title,item.fid);
    if (bFind==NO) {
        NSString *temp=[NSString stringWithFormat:@"%@频道已被您隐藏，请点击右上角加号，将该频道移到我的频道。",channelName];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:temp  preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"OK Action");
        }];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
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
