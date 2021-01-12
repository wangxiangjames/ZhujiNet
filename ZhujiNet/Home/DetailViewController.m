//
//  DetailViewController.m
//  ZhujiNet
//
//  Created by zhujiribao on 2017/7/28.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//
#import <WebKit/WebKit.h>
#import <Photos/Photos.h>
#import <ShareSDKUI/ShareSDKUI.h>
#import "DetailViewController.h"
#import "ReplyCell.h"
#import "ShareView.h"
#import "ShangModel.h"
#import "ShareModel.h"
#import "LayoutTextView.h"
#import "UITextView+placeholder.h"
#import "ShangController.h"
#import "FollowController.h"
#import "PBViewController.h"
#import "PassValueDelegate.h"
#import "CommonCell.h"
#import "WKWebViewController.h"
#import "SelectDataController.h"

static const NSInteger          TAG_BASE=2000;

@interface DetailViewController ()<UITableViewDelegate,UITableViewDataSource,WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler,
                                UIScrollViewDelegate,UIGestureRecognizerDelegate,PBViewControllerDataSource, PBViewControllerDelegate,PassValueDelegate>{
                                    
    AppDelegate                 *_app;
    WKWebView                   *_webView;
    UIView                      *_mediaView;
    CjwCell                     *_cjwCell;
    ReplyCell                   *_replyCell;
    MJRefreshAutoNormalFooter   *_refeshFooter;
    NSMutableArray              *_dataNews;
    NSMutableArray              *_dataReply;
    NSMutableArray              *_dataImages;
    NSMutableArray              *_dataReplyImages;
    BOOL                        _bTapReplyImg;
    NSString                    *_url;
    NSInteger                   _page;
    NSInteger                   _pagecount;
    BOOL                        _isLoading;
    NSInteger                   _webviewLiubai;         //webview留白
    
    ShareView                   *_shangView;
    ShareModel                  *_shareModel;
    
    NSString                    *_authorid;
    NSString                    *_authName;
    NSString                    *_authAvatar;
    NSString                    *_authLevel;
    NSString                    *_dateline;
    NSString                    *_hits;
    
    UIButton                    *_btnFollow;
    UIButton                    *_btnReply;
    UIButton                    *_btnLike;
    UIButton                    *_btnWrite;
    UIButton                    *_btnShare;
    
    NSString                    *_footMsg;
    NSString                    *_likeNum;
    NSString                    *_replyNum;
    CGFloat                     _cellHeaderHeight;
    CGFloat                     _videoHeight;
    CGFloat                     _statusNavHeight;
    BOOL                        _isreward;
                                    
    NSInteger                   _currUploadNum;
    NSString                    *_imgid;
    UIView                      *_bottomView;
    BOOL                        _isPlaying;
    UIActivityIndicatorView     *_progress;
}

@property (nonatomic,copy) NSString             *pid;
@property (nonatomic,copy) NSString             *message;
@property (nonatomic,strong) LayoutTextView     *writeView;
@property (nonatomic,strong) NSMutableArray     *selectPhoto;
@end

@implementation DetailViewController

- (void)viewWillAppear:(BOOL)animated{
    _app = [AppDelegate getApp];
    [_app.skin setSkin:self];
    self.view.backgroundColor=_app.skin.colorCellBg;
    if (_contmode==2) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }
    [self isFollow];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (self.video != nil) {
        [self.video stop];
        self.video = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _app = [AppDelegate getApp];
    
    _videoHeight= _contmode==2? (SCREEN_WIDTH) * (9.0 / 16.0): (SCREEN_WIDTH-28) * (9.0 / 16.0);

    _selectPhoto= [NSMutableArray arrayWithCapacity:9];
    _currUploadNum=0;
    _imgid=@"";
    _isPlaying=NO;
    
    _isLoading=NO;
    _page=1;
    _pagecount=1;
    _dataNews = [NSMutableArray arrayWithCapacity:10];
    _dataReply = [NSMutableArray arrayWithCapacity:10];
    _dataImages= [NSMutableArray arrayWithCapacity:10];
    _dataReplyImages= [NSMutableArray arrayWithCapacity:3];
    
    _dateline=@"";
    _hits=@"";
    _authorid=@"";
    _authName=@"";
    _authAvatar=@"";
    _authLevel=@"";
    _webviewLiubai=10.0;
    
    _btnFollow=[[UIButton alloc]init];
    _btnFollow.backgroundColor=_app.skin.colorMainLight;
    [_btnFollow setTitle: @"关注" forState: UIControlStateNormal];
    
    _shareModel=[[ShareModel alloc]init];
    _shangView=[[ShareView alloc]init];
    
    _btnReply=[[UIButton alloc]init];
    _statusNavHeight=_contmode==2 ? 0:Height_NavBar;
    
    [self setNavigation];
    if (self.contmode!=2){
        [self addWebView];
    }
    [self addProgress];
    [self addTableView];
    [self registerCell];
    [self loadLike];
    [self addWriteView];
    [self setBottomView:YES commentWithNum:@"" likeWithNum:@"" isLike:NO];
    
    _url=[NSString stringWithFormat:@"%@?tid=%@",URL_replay,self.tid];
    NSDictionary *param=@{@"type":[NSNumber numberWithLong:self.contmode==0?1:2]};
    [_app.net request:self url:_url param:param callTag:0];
    
    if(_contmode!=2){
        [_progress startAnimating];
        _bottomView.hidden=YES;
        _tableView.hidden=YES;
        
        if (self.video!=nil && self.video.playbackState == MPMoviePlaybackStatePlaying ) {
            [self.video stop];
        }
    }
}

-(void)addProgress{
    
    /*UIImageView* logow=[[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width-120)/2, (self.view.frame.size.height-40)/2-100,120,40)];
     logow.layer.opacity=0.1;
     logow.image=[UIImage imageNamed:@"logow"];
     [self.view addSubview:logow];*/
    
    _progress=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _progress.color=[UIColor colorWithHexString:@"aaaaaa"];
    _progress.center=CGPointMake(self.view.center.x,self.view.center.y-50);
    [self.view addSubview:_progress];
}

-(void)addWriteView {
    CGFloat layoutTextHeight = 50;
    _writeView = [[LayoutTextView alloc] initWithFrame:CGRectMake(0, Main_Screen_Height-layoutTextHeight-Height_NavBar_HomeIndicator,
                                                                  Main_Screen_Width, layoutTextHeight)];
    if (_contmode==2) {
        _writeView.isNavHide=YES;
    }
    
    _writeView.textView.placeholder = @"请输入内容";
    [self.view addSubview:_writeView];
    _writeView.hidden=YES;
    
    @WeakObj(self);
    [_writeView setSendBlock:^(UITextView *textView) {
        //[MBProgressHUD showMessage:@"请稍候"];
        if (selfWeak.writeView.textView.text.length==0) {
            [MBProgressHUD showError:@"内容不能为空！"];
            return ;
        }
        
        selfWeak.message=selfWeak.writeView.textView.text;
        [selfWeak sendReply:NO];
    }];
    
    [_writeView setBlockCanmeraAction:^(id sender){
        [CjwFun selectImgCont:ImagePicket_reply
                          fid:0
                     topTitle:@""
                 withTextCont:selfWeak.writeView.textView.text
               viewController:selfWeak
                  resultAcion:^(NSInteger fid,NSString *title,NSString *contnet,NSMutableArray *photos,NSString *videoUrl,NSInteger videoNum,UIImage* coverImg){
                      //[MBProgressHUD showMessage:@"请稍候"];
                      
                      [selfWeak.selectPhoto removeAllObjects];
                      [selfWeak.selectPhoto addObjectsFromArray:photos];
                      _currUploadNum=0;
                      _imgid=@"";                      //NSLog(@"%ld,%@,%ld",fid,contnet,photos.count);
                      selfWeak.message=contnet;
                      if (_selectPhoto.count>_currUploadNum) {
                          _currUploadNum=1;
                          [selfWeak uploadImages:selfWeak.selectPhoto[_currUploadNum-1]];
                      }
                      else{
                          [selfWeak sendReply:YES];
                      }
                  }];
    }];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGesture.cancelsTouchesInView = YES;
    tapGesture.delegate=self;
    [self.view addGestureRecognizer:tapGesture];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (!_writeView.isHidden) {
        return YES;
    }
    return NO;
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
                [self sendReply:YES];
            }
        }
    }];
}

-(void)sendReply:(BOOL)isPop{
    [MBProgressHUD showSuccess:@"你的信息已发送，请稍后下拉刷新查看！" toView:self.view];
    
    //[MBProgressHUD showMessage:@"请稍候"];
    [CjwFun sendReply:self.message withTid:self.tid withRequote:self.pid withImages:_imgid resultAcion:^(id responseObject){
        NSLog(@"cjw:%@",responseObject);
        //[MBProgressHUD hideHUD];
        NSDictionary *dict = (NSDictionary *)responseObject;
        if([dict[@"code"] integerValue]==0){
            self.writeView.textView.text=@"";
            self.pid=nil;
            _page=1;
            NSDictionary *param=@{@"page":[NSNumber numberWithLong:_page]};
            [_app.net request:self url:_url param:param callTag:0];
            
            //[MBProgressHUD showSuccess:dict[@"msg"] toView:self.view];
            
            if (isPop) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        else{
            [MBProgressHUD showError:dict[@"msg"] toView:self.view];
        }
    }];
}

-(void)viewTapped:(UITapGestureRecognizer*)tap {
    [_writeView.textView resignFirstResponder];
}

-(void)setNavigation{
    UIButton *navBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [navBack setFrame:CGRectMake(0, 0, 28, 28)];
    [navBack setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [navBack addTarget:self action:@selector(onNavBackClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navBack];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"举报" style:UIBarButtonItemStylePlain target:self action:@selector(onRightClick:)];
}

- (void)onNavBackClick:(id)sender
{
    [self.video stop];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onNavMoreClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//-------------------------------------------------

-(void)addTableView{
    CGFloat bottomHeight=Height_NavBar_HomeIndicator;
    
    CGFloat top=0;
    if (self.contmode==2) {
        top=_videoHeight;
        if (iPhoneX) {
            top=_videoHeight+Height_StatusBar;
        }
        bottomHeight=Height_HomeIndicator;
    }
    
    CGRect rect=CGRectMake(0, top, self.view.frame.size.width,  self.view.frame.size.height-bottomHeight-50-top);
    _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStyleGrouped];
    _tableView.separatorStyle = NO;
    _tableView.backgroundColor=_app.skin.colorTableBg;
    _tableView.separatorColor =_app.skin.colorCellSeparator;
    _tableView.delegate=self;
    _tableView.dataSource=self;
    if (@available(iOS 11.0, *)) {
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        //_tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _refeshFooter=[MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if(_isLoading==NO){
            _isLoading=YES;
            NSDictionary *param=@{@"page":[NSNumber numberWithLong:_page+1],@"type":@0};
            [_app.net request:self url:_url param:param callTag:0];
            NSLog(@"chenj:%@",_url);
        }
    }];
    
    _tableView.mj_footer =_refeshFooter;
    [self.view addSubview:_tableView];
}

- (void)registerCell{
    _replyCell=[[ReplyCell alloc]init];
    [_tableView registerClass:[ReplyCell class] forCellReuseIdentifier:NSStringFromClass([ReplyCell class])];
    
    _cjwCell=[[CjwCell alloc]init];
    [_tableView registerClass:[CjwCell class] forCellReuseIdentifier:NSStringFromClass([CjwCell class])];
}

//-------------------------------------------------------------
-(void) scrollViewDidScroll:(UIScrollView *) scrollView{
    /*if(_isLoading==NO && (scrollView.contentOffset.y+scrollView.frame.size.height)/scrollView.contentSize.height >0.95 && scrollView.contentSize.height>100){
        if (_page>=_pagecount) {
            return;
        }
        _isLoading=YES;
        
        NSDictionary *param=@{@"page":[NSNumber numberWithLong:_page+1],@"type":@0};
        [_app.net request:self url:_url param:param callTag:0];
    }*/
    if (_writeView.hidden==NO) {
        [_writeView.textView resignFirstResponder];
    }
}

//-------------------------------------------------
-(void)loadLike{
    [_app.net request:[NSString stringWithFormat:@"%@?tid=%@",URL_replay_recommend,self.tid] param:nil withMethod:@"POST"
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSDictionary *dict = (NSDictionary *)responseObject;
                  if([dict[@"code"] integerValue]==0){
                      NSString *userlist=@"";
                      NSString *flag=@"，";
                      NSArray* shanglist=[ShangModel mj_objectArrayWithKeyValuesArray:dict[@"data"]];
                      
                      BOOL islike=NO;
                      for (NSInteger i=0; i<[shanglist count];i++ ) {
                          if(i==([shanglist count]-1)){
                              flag=@"";
                          }
                          ShangModel* shang=[shanglist objectAtIndex:i];
                          userlist=[NSString stringWithFormat:@"%@%@%@",userlist, shang.username,flag];
                          if (_app.user.uid==shang.uid) {
                              islike=YES;
                          }
                      }
                      if ([userlist isEqualToString:@""]) {
                          [_shangView likeList:@""];
                      }
                      else{
                          [_shangView likeList: [NSString stringWithFormat:@"赞列表：%@等%ld人点赞",userlist,[shanglist count]]];
                      }
                      
                      [self setBottomView:NO commentWithNum:_replyNum likeWithNum:NSString([shanglist count]) isLike:islike];
                  }
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              }];
}
//-------------------------------------------------
- (void)requestCallback:(id)response status:(id)status{
    NSDictionary *dict = (NSDictionary *)response;
    if ([status[@"stat"] isEqual:@0]) {
        NSLog(@"chen:%@",response);
        
        _page=[dict[@"page"] intValue];
        _pagecount=[dict[@"pagecount"] intValue];
        
        if([status[@"tag"] isEqual:@0]){
            if (_page==1) {
                //[_dataNews removeAllObjects];
                [_dataReply removeAllObjects];
            }
            
            if(dict[@"data"]!=nil && _page==1){
                _artTitle= dict[@"data"][@"title"];
                _authorid=dict[@"data"][@"authorid"];
                
                self.vedioUrl=dict[@"data"][@"videourl"];
                self.videoCover=dict[@"data"][@"videocover"];
                
                self.title=dict[@"data"][@"forumname"];
                if (self.contmode==0) {
                    _dateline=[NSString stringWithFormat:@"%@   %@",dict[@"data"][@"source"],dict[@"data"][@"dateline"]];
                    _hits=[NSString stringWithFormat:@"%@阅读",dict[@"data"][@"hits"]];
                }
                else{
                    if(self.contmode==2){
                        _hits=[NSString stringWithFormat:@"%@次播放",dict[@"data"][@"hits"]];
                    }
                    _dateline=[NSString stringWithFormat:@"%@  %@阅读",dict[@"data"][@"dateline"],dict[@"data"][@"hits"]];
                    _authName=dict[@"data"][@"author"];
                    _authAvatar=dict[@"data"][@"avatar"];
                    _authLevel=dict[@"data"][@"level"];
                    
                    [self isFollow];

                }
                [self setBottomView:NO commentWithNum:[NSString stringWithFormat:@"%@",dict[@"data"][@"replaynum"]]
                        likeWithNum:[NSString stringWithFormat:@"%@",dict[@"data"][@"likenum"]] isLike:[dict[@"data"][@"islike"] integerValue]==1?YES:NO];
                
                if (self.contmode==2) {
                    _shareModel.title=dict[@"data"][@"title"];
                    _shareModel.descr=_authName;
                    _shareModel.thumbUrl=dict[@"data"][@"videocover"];;
                    _shareModel.webpageUrl= dict[@"data"][@"shareurl"];
                }
                else{
                    _shareModel.title=dict[@"data"][@"title"];
                    _shareModel.descr=dict[@"data"][@"sharemsg"];
                    _shareModel.webpageUrl= dict[@"data"][@"shareurl"];
                    if ([dict[@"data"][@"sharepic"] isEqualToString:@""]) {
                        _shareModel.thumbUrl=self.sharepic;
                    }
                    else{
                         _shareModel.thumbUrl=dict[@"data"][@"sharepic"];
                    }
                }
                _isreward=[dict[@"data"][@"isreward"] intValue]==1? YES:NO;
                if (_isreward) {
                    [_shangView yiShangForBtn];
                }
                
            }
            
            if(dict[@"data"][@"news"]!=nil && _page==1 && _contmode!=2){
                NSDictionary *digest=dict[@"data"][@"news"];
                for(id item in digest){
                    CjwItem *cjwItem=[[CjwItem alloc]init];
                    cjwItem.tid=item[@"tid"];
                    cjwItem.title=item[@"title"];
                    cjwItem.flag=item[@"flag"];
                    cjwItem.flagcolor=item[@"flagcolor"];
                    cjwItem.subtitle=[NSString stringWithFormat:@"%@    %@阅读",item[@"forumname"],item[@"hits"]];
                    cjwItem.dateline=item[@"dateline"];
                    NSArray *imgs=item[@"imglist"];
                    cjwItem.imginfo=[NSString stringWithFormat:@"%ld图",imgs.count];
                    switch ([imgs count]) {
                        case 0:
                            cjwItem.type=CELL_NEWS_TEXT;
                            break;
                            
                        case 1:
                        case 2:
                            cjwItem.url_pic0=imgs[0];
                            cjwItem.type=CELL_NEWS_ONE_IMG;
                            break;
                            
                        default:
                            cjwItem.url_pic0=imgs[0];
                            cjwItem.url_pic1=imgs[1];
                            cjwItem.url_pic2=imgs[2];
                            cjwItem.type=CELL_NEWS_THREE_IMG;
                            break;
                    }
                    [_dataNews addObject:cjwItem];
                }
            }
     
            if(dict[@"data"][@"replay"]!=nil){
                [_dataReply addObjectsFromArray:[ReplyModel mj_objectArrayWithKeyValuesArray:dict[@"data"][@"replay"]]];
                if([_dataReply count]==0){
                    _footMsg=@"暂无评论";
                    _tableView.mj_footer.hidden = YES;
                    [_tableView.mj_footer endRefreshingWithNoMoreData];
                }
            }
            //
            [CATransaction setDisableActions:YES];
            [_tableView reloadData];
            [CATransaction commit];
            
            if (_page==[dict[@"pagecount"] intValue]) {
                _footMsg=@"已显示全部评论";
                _tableView.mj_footer.hidden = YES;
                [_tableView.mj_footer endRefreshingWithNoMoreData];
            }
            else{
                [_tableView.mj_footer endRefreshing];
            }
        }
    }
    else{
        NSLog(@"网络失败");
        [_tableView.mj_footer endRefreshing];
        [_refeshFooter setTitle:@"网络连接失败" forState:MJRefreshStateIdle];
    }
    //-------------------------------------
    _isLoading=NO;
}

-(void)isFollow{
    NSLog(@"%@",_authorid);
    for (CjwItem* item in _app.followUser) {
        NSLog(@"%@",item.authorid);
        if ([item.authorid intValue]== [_authorid intValue]) {
            [_btnFollow setTitle:@"已关注" forState:UIControlStateNormal];
            _btnFollow.backgroundColor=[UIColor lightGrayColor];
            break;
        }
    }
}

-(void)setVideoView{
    if(!self.video){
        if(self.contmode==2){
            CGFloat vedioHeight=(SCREEN_WIDTH) * (9.0 / 16.0);
            self.video=[[ZXVideoPlayerController alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,vedioHeight)];
        }
        else{
            CGFloat vedioHeight=(SCREEN_WIDTH-28) * (9.0 / 16.0);
            self.video=[[ZXVideoPlayerController alloc] initWithFrame:CGRectMake(14, 0, SCREEN_WIDTH-28,vedioHeight)];
        }
        self.video.contentURL=[NSURL URLWithString:self.vedioUrl];
    }
    if (!(self.video.playbackState == MPMoviePlaybackStatePlaying ||self.video.playbackState == MPMoviePlaybackStatePaused)) {
        self.video.view.hidden=YES;
    }
    
    if (self.contmode!=2) {
        if (self.video.playbackState == MPMoviePlaybackStatePlaying ) {
            _isPlaying=YES;
        }
        else{
            _isPlaying=NO;
        }
    }

    NSLog(@"video.playbackState:%ld",(long)_video.playbackState);
    
    __weak typeof(self) weakSelf = self;
    self.video.videoPlayerGoBackBlock = ^{
        //__strong typeof(self) strongSelf = weakSelf;
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [weakSelf.navigationController popViewControllerAnimated:YES];
        [weakSelf.navigationController setNavigationBarHidden:NO animated:YES];
        [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"ZXVideoPlayer_DidLockScreen"];
        [weakSelf.video stop];
        //strongSelf.video = nil;
    };
}

-(void)addWebView{
    if(!_webView){
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        config.preferences = [[WKPreferences alloc] init];
        config.preferences.minimumFontSize = 10;
        config.preferences.javaScriptEnabled = YES;
        config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
        config.userContentController = [[WKUserContentController alloc] init];
        [config.userContentController addScriptMessageHandler:self name:@"app_pay"];
        _webView = [[WKWebView alloc]initWithFrame:CGRectZero configuration:config];
        [_webView addObserver:self forKeyPath:@"scrollView.contentSize" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:@"DJWebKitContext"];
        _webView .UIDelegate = self;
        _webView .navigationDelegate =self;
        _webView.scrollView.scrollEnabled = NO;
        _webView.alpha=_app.skin.floatImgAlpha;
    }
    [_webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.webUrl]]];
}

-(CGFloat)addPageHead:(UIView*)view atPos:(CGFloat)posY{
    posY+=14;
    UILabel *title=[[UILabel alloc]init];
    title.text=_artTitle;
    title.textColor=_app.skin.colorCellTitle;
    title.numberOfLines=0;
    CGSize titleSize=[CjwFun sizeForText:title width:SCREEN_WIDTH-28 font:[UIFont boldSystemFontOfSize:22] lineSapce:3];
    title.frame=CGRectMake(14,posY,SCREEN_WIDTH-28,titleSize.height);
    [view addSubview:title];
    
    posY+=titleSize.height+14;
    
    if (self.contmode==0) {     //新闻版式
        UILabel *from=[[UILabel alloc]init];
        from.text=_dateline;
        from.font=[UIFont systemFontOfSize:14];
        CGSize fromSize = [from.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
        from.frame=CGRectMake(14,posY,fromSize.width,fromSize.height);
        from.textColor=[UIColor colorWithHexString:@"888888"];
        [view addSubview:from];
        
        UILabel *viewNum=[[UILabel alloc]init];
        viewNum.text=_hits;
        viewNum.font=[UIFont systemFontOfSize:14];
        CGSize viewNumSize = [viewNum.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
        viewNum.frame=CGRectMake(SCREEN_WIDTH-13-viewNumSize.width,posY,viewNumSize.width,fromSize.height);
        viewNum.textColor=[UIColor colorWithHexString:@"888888"];
        [view addSubview:viewNum];
        
        posY+=fromSize.height;
    }
    if (self.contmode==1) {     //论坛版式
        UIImageView *ivUser=[[UIImageView alloc] initWithFrame:CGRectMake(14, posY, 40, 40)];
        [ivUser sd_setImageWithURL:[NSURL URLWithString:_authAvatar]];
        ivUser.layer.cornerRadius=20;
        ivUser.layer.masksToBounds=YES;
        [view addSubview:ivUser];
        
        CGSize textSize=[CjwFun sizeForText:_authName font:[UIFont systemFontOfSize:16]];
        UIButton* btUser=[[UIButton alloc]initWithFrame:CGRectMake(5+60, posY-3, textSize.width, 30)];
        [btUser setTitle: _authName forState: UIControlStateNormal];
        btUser.titleLabel.font=[UIFont systemFontOfSize:16];
        btUser.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [btUser setTitleColor:_app.skin.colorButton forState:UIControlStateNormal];
        [view addSubview:btUser];
        
        UILabel *level=[[UILabel alloc]initWithFrame:CGRectMake(btUser.frame.origin.x+btUser.frame.size.width+8, posY+5, 40, 14)];
        level.textColor=[UIColor redColor];
        level.text=[NSString stringWithFormat:@"LV%@",_authLevel];
        level.font=[UIFont systemFontOfSize:10];
        level.textAlignment=NSTextAlignmentCenter;
        level.layer.cornerRadius=3;
        level.layer.masksToBounds=YES;
        level.textColor=_app.skin.colorMainLight;
        level.backgroundColor=_app.skin.colorMainLight;
        level.textColor=_app.skin.colorNavbar;
        [view addSubview:level];
        
        UILabel *viewNum=[[UILabel alloc]init];
        viewNum.text=_dateline;
        viewNum.font=[UIFont systemFontOfSize:11];
        //CGSize viewNumSize = [viewNum.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}];
        viewNum.frame=CGRectMake(5+60, posY+18, 220, 30);
        viewNum.textColor=[UIColor colorWithHexString:@"888888"];
        [view addSubview:viewNum];
        
        _btnFollow.frame=CGRectMake(SCREEN_WIDTH-60-14, posY+5, 50, 28);
        [_btnFollow addTarget:self action:@selector(followAction:) forControlEvents:UIControlEventTouchUpInside];
        _btnFollow.titleLabel.font=[UIFont systemFontOfSize:14];
        [_btnFollow setTitleColor:_app.skin.colorNavMenu forState:UIControlStateNormal];
        _btnFollow.alpha=_app.skin.floatImgAlpha;
        _btnFollow.layer.cornerRadius=3;
        [view addSubview:_btnFollow];
        posY+=ivUser.height;
    }
    
    if (self.contmode==2){  //视频版式
        UILabel *viewNum=[[UILabel alloc]init];
        viewNum.text=_hits;
        viewNum.font=[UIFont systemFontOfSize:14];
        CGSize viewNumSize = [viewNum.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
        viewNum.frame=CGRectMake(14,posY,viewNumSize.width,viewNumSize.height);
        viewNum.textColor=[UIColor colorWithHexString:@"888888"];
        [view addSubview:viewNum];
        
        posY+=viewNumSize.height+15;
        
        UIImageView *ivUser=[[UIImageView alloc] initWithFrame:CGRectMake(14, posY, 46, 46)];
        [ivUser sd_setImageWithURL:[NSURL URLWithString:_authAvatar]];
        ivUser.layer.cornerRadius=23;
        ivUser.layer.masksToBounds=YES;
        [view addSubview:ivUser];
        
        UIButton* btUser=[[UIButton alloc]initWithFrame:CGRectMake(14+60, posY+6, 80, 30)];
        [btUser setTitle: _authName forState: UIControlStateNormal];
        btUser.titleLabel.font=[UIFont systemFontOfSize:17];
        btUser.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [btUser setTitleColor:_app.skin.colorButton forState:UIControlStateNormal];
        [view addSubview:btUser];
        
        _btnFollow=[[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-60-14, posY+6, 60, 30)];
        [_btnFollow addTarget:self action:@selector(followAction:) forControlEvents:UIControlEventTouchUpInside];
        [_btnFollow setTitle: @"关注" forState: UIControlStateNormal];
        _btnFollow.titleLabel.font=[UIFont systemFontOfSize:14];
        _btnFollow.backgroundColor=_app.skin.colorMainLight;
        [_btnFollow setTitleColor:_app.skin.colorNavMenu forState:UIControlStateNormal];
        _btnFollow.alpha=_app.skin.floatImgAlpha;
        _btnFollow.layer.cornerRadius=3;
        [view addSubview:_btnFollow];
        posY+=ivUser.height;
    }
    
    if (self.contmode==2) {
        //_webviewLiubai=-10;
        [self setVideoView];
        CGFloat top=0;
        if (iPhoneX) {
            top=Height_StatusBar;
        }
        else{
            self.video.isStatusHide=YES;
        }
        self.video.view.frame=CGRectMake(0, top, SCREEN_WIDTH,_videoHeight);
        [self.view addSubview:self.video.view];
        
        self.video.view.hidden=NO;
        [self.video play];
    }
    else if([self.vedioUrl length]>0){
        posY+=14;
        [self setVideoView];
        self.video.view.frame=CGRectMake(14, posY, SCREEN_WIDTH-28, _videoHeight);
        __weak typeof(&*self)weakSelf = self;
        [self.video setVideoPlaybackDidFinishBlock:^(void){
            weakSelf.video.view.hidden=YES;
        }];
        //-------------------------------------
        UIImageView *videocover=[[UIImageView alloc] initWithFrame:self.video.view.frame];
        videocover.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPlay:)];
        [videocover addGestureRecognizer:singleTap];
        [videocover sd_setImageWithURL:[NSURL URLWithString:self.videoCover]];
        [view addSubview:videocover];
        
        CGFloat x=self.video.view.frame.size.width/2;
        CGFloat y=self.video.view.frame.size.height/2;
        UIImageView *videoPlay=[[UIImageView alloc] initWithFrame:CGRectMake(x-20, posY+y-24, 48, 48)];
        videoPlay.image=[UIImage imageNamed:@"play"];
        [view addSubview:videoPlay];
        
        if (self.videoTime.length>0) {
            UILabel *videotime=[[UILabel alloc]init];
            videotime.font=[UIFont systemFontOfSize:10];
            videotime.textColor=[UIColor whiteColor];
            videotime.layer.backgroundColor=[UIColor colorWithHexString:@"000000" alpha:0.6].CGColor;
            videotime.layer.cornerRadius=8;
            videotime.textAlignment=NSTextAlignmentCenter;
            videotime.text=self.videoTime;
            CGSize size = [videotime.text sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:11]}];
            x=self.video.view.frame.size.width;
            y=self.video.view.frame.size.height;
            videotime.frame=CGRectMake(x-size.width-8, posY+y-30, size.width+12, 20);
            [view addSubview:videotime];
        }
        //-------------------------------------
        [view addSubview:self.video.view];
        posY+=_videoHeight;
    }

    return posY;
}

- (void)tapPlay:(UIGestureRecognizer *)gestureRecognizer {
    [self.video play];
    self.video.view.hidden=NO;
}

-(void)setBottomView:(Boolean)bInit commentWithNum:(NSString*)replyNum likeWithNum:(NSString*)likeNum isLike:(BOOL)isLike{
    _likeNum=likeNum;
    _replyNum=replyNum;
    
    if (bInit) {
        CGFloat bottomHeight=Height_NavBar_HomeIndicator;
        if (self.contmode==2) {
            bottomHeight=Height_HomeIndicator;
        }
        
        _bottomView=[[UIView alloc]initWithFrame:CGRectMake(-1, self.view.frame.size.height-bottomHeight-50, SCREEN_WIDTH+2, 51)];
        _bottomView.backgroundColor=_app.skin.colorCellBg;
        _bottomView.alpha=0.96;
        _bottomView.layer.borderColor=_app.skin.colorCellSeparator.CGColor;
        _bottomView.layer.borderWidth=_app.skin.floatImgBorderWidth;
        
        _btnShare = [[UIButton alloc]init];
        _btnShare.imageEdgeInsets=UIEdgeInsetsMake(2, 2, 2, 2);
        [_btnShare setImage:[UIImage imageNamed:@"fenxiang"] forState:UIControlStateNormal];
        [_btnShare addTarget:self action:@selector(actionShare:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:_btnShare];
        
        _btnLike=[UIButton buttonWithType:UIButtonTypeCustom];
        _btnLike.imageEdgeInsets=UIEdgeInsetsMake(2, 2, 2, 2);
        _btnLike.titleEdgeInsets=UIEdgeInsetsMake(0, 5, 3, 0);
        _btnLike.titleLabel.font = [UIFont systemFontOfSize:13.f];
        [_btnLike addTarget:self action:@selector(actionLike:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:_btnLike];
        
        _btnReply=[UIButton buttonWithType:UIButtonTypeCustom];
        _btnReply.imageEdgeInsets=UIEdgeInsetsMake(2, 2, 2, 2);
        _btnReply.titleEdgeInsets=UIEdgeInsetsMake(0, 5, 3, 0);
        _btnReply.titleLabel.font = [UIFont systemFontOfSize:13.f];
        [_bottomView addSubview:_btnReply];
        
        _btnWrite=[[UIButton alloc]init];
        [_btnWrite setTitle: @"写跟帖…" forState: UIControlStateNormal];
        [_btnWrite addTarget:self action:@selector(actionWrite:) forControlEvents:UIControlEventTouchUpInside];
        _btnWrite.backgroundColor=_app.skin.colorTableBg;
        _btnWrite.layer.cornerRadius=17;
        _btnWrite.layer.borderWidth=0.5;
        _btnWrite.layer.borderColor=_app.skin.colorCellSeparator.CGColor;
        _btnWrite.layer.masksToBounds=YES;
        _btnWrite.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _btnWrite.titleEdgeInsets=UIEdgeInsetsMake(0, 10, 0, 0);
        _btnWrite.titleLabel.font=[UIFont systemFontOfSize:14];
        [_btnWrite setTitleColor:_app.skin.colorCellTitle forState:UIControlStateNormal];
        [_btnWrite setImage:[UIImage imageNamed:@"write"] forState:UIControlStateNormal];
        _btnWrite.imageView.contentMode = UIViewContentModeScaleAspectFit;
        //write.imageView.frame=CGRectMake(0, 0, 20, 20);
        _btnWrite.imageEdgeInsets=UIEdgeInsetsMake(1, 12, 0, 3);
        [_bottomView addSubview:_btnWrite];
        [self.view addSubview:_bottomView];
    }
    
    CGFloat rightPos=30+14;
    _btnShare.frame=CGRectMake(SCREEN_WIDTH-rightPos,8, 30, 30);
    
    CGSize likeSize = [likeNum sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13.f]}];
    rightPos+=likeSize.width+35+14;
    _btnLike.frame = CGRectMake(SCREEN_WIDTH-rightPos,8, likeSize.width+35, 30);
    UIImage *likeImg=nil;
    if(isLike){
        likeImg=[UIImage imageNamed:@"like_blue"];
    }
    else{
        likeImg=[UIImage imageNamed:@"like"];
    }
    if ([likeNum isEqualToString:@"0"]) {
        likeNum=@"";
    }
    [_btnLike setTitle:likeNum forState:UIControlStateNormal];
    [_btnLike setTitleColor:_app.skin.colorMainDark forState:UIControlStateNormal];
    [_btnLike setImage:likeImg forState:UIControlStateNormal];
    
    CGSize commentSize = [replyNum sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13.f]}];
    rightPos+=commentSize.width+35+14;
    _btnReply.frame = CGRectMake(SCREEN_WIDTH-rightPos,8, commentSize.width+35, 30);
    UIImage *imgReply=nil;
    if([replyNum length]>0 && ![replyNum isEqualToString:@"0"]){
        imgReply=[UIImage imageNamed:@"comment_red"];
    }
    else{
        imgReply=[UIImage imageNamed:@"comment"];
        replyNum=@"";
    }
    [_btnReply setTitle:replyNum forState:UIControlStateNormal];
    [_btnReply setTitleColor:_app.skin.colorButtonMain forState:UIControlStateNormal];
    [_btnReply setImage:imgReply forState:UIControlStateNormal];
    
    rightPos+=14+10;
    _btnWrite.frame=CGRectMake(14,8, SCREEN_WIDTH-rightPos, 34);
}

#pragma mark -
#pragma mark - UITableView dateSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger row=0;
    switch (section) {
        case 0:
            row=1;
            break;
            
        case 1:
            row=[_dataNews count];
            break;
            
        case 2:
            row=[_dataReply count];
            break;
    }
    return row;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view=[[UIView alloc]init];
    if (section==0) {
        CGFloat posY=0;
        posY=[self addPageHead:view atPos:posY];
        _webView.frame=CGRectMake(0, posY, SCREEN_WIDTH, _webView.frame.size.height);
        [view addSubview:_webView];
        
        view.frame=CGRectMake(0, 0, SCREEN_WIDTH,posY);
        view.backgroundColor=_app.skin.colorCellBg;
        _cellHeaderHeight=posY;
    }
    else{
        UILabel *columTitle=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH, 40)];
        [view addSubview:columTitle];
        if (section==1) {
            if (_contmode==2) {
                return nil;
            }
            columTitle.text=self.contmode==0? @"推荐阅读":@"近日热门帖子";
        }
        else if(section==2){
            columTitle.text=self.contmode==0? @"最新评论":@"最新跟贴";
        }
    }
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if(section==0){
        __weak typeof(&*self)weakSelf = self;
        [_shangView setBlockShangAction:^(UIButton *button){
            [weakSelf actionShang:button];
        }];
        [_shangView setBlockWeixinAction:^(UIButton *button){
            [weakSelf actionWeixin:button];
        }];
        [_shangView setBlockFriendAction:^(UIButton *button){
            [weakSelf actionFriend:button];
        }];
        [_shangView setBlockQQAction:^(UIButton *button){
            [weakSelf actionQQ:button];
        }];
        [_shangView setBlockWeiboAction:^(UIButton *button){
            [weakSelf actionWeibo:button];
        }];
        _shangView.backgroundColor=[UIColor whiteColor];
        return _shangView;
    }
    else if (section==2) {
        UIView *view=[[UIView alloc]init];
        view.backgroundColor=[UIColor whiteColor];
        
        UILabel *title=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
        title.textAlignment=NSTextAlignmentCenter;
        [view addSubview:title];
        title.text=_footMsg;
        return view;
    }
    else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    CGFloat height=40;
    if (section==0) {
        if (self.contmode==2) {
            height=_cellHeaderHeight+_webviewLiubai;
        }
        else{
            height=_cellHeaderHeight+_webView.frame.size.height+_webviewLiubai;
        }
    }
    if (section==1 && _contmode==2) {
        height=0.0001;
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section==0) {
        return _shangView.height;
    }
    if(section==2){
        if(_page<_pagecount){
            return 0.1;
        }
        else{
            return 80.0;
        }
    }
    else{
        return 0.1;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        static NSString *cellIdentify=@"cell";
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentify];
        if (cell==nil) {
            cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentify];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }
    else if (indexPath.section==1) {
        CommonCell *cell;
        CjwItem* item=_dataNews[indexPath.row];
        if(item.type==CELL_NEWS_ONE_IMG){
            static NSString *ID = @"CELL_NEWS_ONE_IMG";
            cell = [tableView dequeueReusableCellWithIdentifier:ID];
            if (!cell) {
                cell = [[CommonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID typeCell:CELL_NEWS_ONE_IMG];
            }
        }
        else if(item.type==CELL_NEWS_THREE_IMG){
            static NSString *ID = @"CELL_NEWS_THREE_IMG";
            cell = [tableView dequeueReusableCellWithIdentifier:ID];
            if (!cell) {
                cell = [[CommonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID typeCell:CELL_NEWS_THREE_IMG];
            }
        }
        else{
            static NSString *ID = @"CELL_NEWS_TEXT";
            cell = [tableView dequeueReusableCellWithIdentifier:ID];
            if (!cell) {
                cell = [[CommonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID typeCell:CELL_NEWS_TEXT];
            }
        }
        cell.item=_dataNews[indexPath.row];
        return cell;
    }
    else{
        __weak typeof(&*self)weakSelf = self;
        ReplyCell *cell = [_tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ReplyCell class])];
        ReplyModel* replyMode=_dataReply[indexPath.row];
        cell.replyModel=replyMode;
        [cell setBlockTapImageViewAction:^(UITapGestureRecognizer *gesture){
            [weakSelf tapImageViewAction:gesture];
        }];
        [cell setBlockLikeAction:^(UIButton *button){
            button.tag=TAG_BASE+indexPath.row;
            [weakSelf actionLikeForPost:button];
        }];
        [cell setBlockReplyAction:^(UIButton *button){
            button.tag=TAG_BASE+indexPath.row;
            [weakSelf actionReplyForPost:button];
        }];
        
        if (replyMode.islike==1) {
            [cell.btnLike setImage:[UIImage imageNamed:@"btn_zan"] forState:UIControlStateNormal];
        }
        else{
            [cell.btnLike setImage:[UIImage imageNamed:@"btn_no_zan"] forState:UIControlStateNormal];
        }
        
        return cell;
    }
}

#pragma mark 设置每行高度（每行高度可以不一样）
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return 0.1;
    }
    else if (indexPath.section==1) {
        if (self.contmode!=2) {
            CjwItem *item=_dataNews[indexPath.row];
            if (item.height==0) {
                CommonCell *cell;
                switch (item.type) {
                    case CELL_NEWS_ONE_IMG:
                        cell=[[CommonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell" typeCell:CELL_NEWS_ONE_IMG];
                        break;
                    case CELL_NEWS_THREE_IMG:
                        cell=[[CommonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell" typeCell:CELL_NEWS_THREE_IMG];
                        break;
                    default:
                        cell=[[CommonCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell" typeCell:CELL_NEWS_TEXT];
                        break;
                }
                
                cell.item=item;
                item.height=cell.height;
            }
            return item.height+1;
        }
        else{
            return 0.1;
        }
    }
    else {
        _replyCell.replyModel=_dataReply[indexPath.row];
        return _replyCell.height+1;
    }
}

-(void)tableView:(UITableView* )tableView willDisplayCell:(UITableViewCell* )cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width)];
    }
    else{
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 15)];
    }
    [cell setLayoutMargins:UIEdgeInsetsZero];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"china");
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section==1){

        CjwItem *item=_dataNews[indexPath.row];
        DetailViewController *detail=[[DetailViewController alloc]init];
        detail.contmode=self.contmode;
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
}


//-------------------------------------------------------------

-(void)actionWrite:(id)sender{
    if(![_app.user checkUserLogin:self]){
        if (_contmode==2) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
            [self.navigationController setNavigationBarHidden:NO animated:NO];
        }
        return;
    }
    
    _writeView.hidden=NO;
    [_writeView.textView becomeFirstResponder];
}


-(void)actionLike:(id)sender{
    if(![_app.user checkUserLogin:self]){
        if (_contmode==2) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
            [self.navigationController setNavigationBarHidden:NO animated:NO];
        }
        return;
    }
    [MBProgressHUD showMessage:@"请稍候"];
    NSDictionary *param=@{@"tid":self.tid};
    [_app.net request:URL_recommend_add param:param withMethod:@"POST"
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  [MBProgressHUD hideHUD];
                  NSDictionary *dict = (NSDictionary *)responseObject;
                  if([dict[@"code"] integerValue]==0){
                      [_app.locationLike setObject:[NSDate date] forKey:[NSString stringWithFormat:@"%@",self.tid]];
                      [CjwFun putLocaionDict:kLocationLike value:[_app.locationLike copy]];
                      
                      [self loadLike];
                      [_btnLike setImage:[UIImage imageNamed:@"like_blue"] forState:UIControlStateNormal];
                  }
                  else{
                      [MBProgressHUD showError:dict[@"msg"] toView:self.view];
                  }
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  [MBProgressHUD hideHUD];
              }];
}

-(void)actionLikeForPost:(UIButton*)sender{
    if(![_app.user checkUserLogin:self]){
        if (_contmode==2) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
            [self.navigationController setNavigationBarHidden:NO animated:NO];
        }
        return;
    }
    
    NSInteger row =sender.tag - TAG_BASE;
    ReplyModel *reply= _dataReply[row];
    NSLog(@"%@",self.tid);
    
    NSDictionary *param=@{@"tid":self.tid,@"pid":reply.pid};
    [_app.net request:URL_recommend_add param:param withMethod:@"POST"
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"cjw:%@",responseObject);
                  NSDictionary *dict = (NSDictionary *)responseObject;
                  if([dict[@"code"] integerValue]==0){
                      reply.islike=1;
                      reply.support+=1;
                      [sender setTitle:NSString(reply.support) forState:UIControlStateNormal];
                      [sender setImage:[UIImage imageNamed:@"btn_zan"] forState:UIControlStateNormal];
                  }
                  else{
                      [MBProgressHUD showError:dict[@"msg"] toView:self.view];
                  }
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              }];
}

-(void)actionReplyForPost:(UIButton*)sender{
    if(![_app.user checkUserLogin:self]){
        if (_contmode==2) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
            [self.navigationController setNavigationBarHidden:NO animated:NO];
        }
        return;
    }
    
    NSInteger row =sender.tag - TAG_BASE;
    ReplyModel *reply= _dataReply[row];
    _pid=reply.pid;
    _writeView.hidden=NO;
    [_writeView.textView becomeFirstResponder];
}

-(void)actionShang:(id)sender{
    if (_contmode==2) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
    
    if(![_app.user checkUserLogin:self])
        return;
    
    ShangController *shang=[[ShangController alloc]init];
    shang.delegate=self;
    shang.tid=self.tid;
    shang.bYiShang=_isreward;
    shang.authorid=[_authorid intValue];
    shang.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    [self presentViewController:shang animated:YES completion:nil];
}

-(void)passValue:(NSString *)value{
    if ([value isEqualToString:@"1"]) {
        _isreward=YES;
        [_shangView yiShangForBtn];
    }
    NSLog(@"get backcall value=%@",value);
}

-(void)followAction:(UIButton*)sender{
    if (_contmode==2) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
        [self.navigationController setNavigationBarHidden:NO animated:NO];
    }
    
    if(![_app.user checkUserLogin:self])
        return;
    
    if ([sender.titleLabel.text isEqualToString:@"已关注"]) {
        FollowController *follow=[[FollowController alloc]init];
        follow.isHeadNone=YES;
        //[self presentViewController:follow animated:YES completion:nil];
        [self.navigationController pushViewController:follow animated:YES];
    }
    else{
        __weak typeof(&*self)weakSelf = self;
        NSDictionary *param=@{@"fuid":_authorid};
        [_app.net request:URL_follow_add param:param withMethod:@"POST"
                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                      NSDictionary *dict = (NSDictionary *)responseObject;
                      if([dict[@"code"] integerValue]==0){
                          [MBProgressHUD showSuccess:@"关注成功"];
                          FollowController *follow=[[FollowController alloc]init];
                          [weakSelf presentViewController:follow animated:YES completion:nil];
                      }
                      else{
                          [MBProgressHUD showSuccess:dict[@"msg"]];
                      }
                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  }];
    }
}

//-------------------------------------------------------------
-(void)actionShare:(id)sender{
    NSLog(@"actionShang:%lu",[sender tag]);
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params SSDKSetupShareParamsByText:_shareModel.descr
                                images:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_shareModel.thumbUrl]]]
                                   url:[NSURL URLWithString:_shareModel.webpageUrl]
                                 title:_shareModel.title
                                  type:SSDKContentTypeAuto];
    SSUIShareSheetConfiguration *config = [SSUIShareSheetConfiguration new];
    
    [ShareSDK showShareActionSheet:self.view customItems:@[@(SSDKPlatformSubTypeWechatSession),@(SSDKPlatformSubTypeWechatTimeline),@(SSDKPlatformSubTypeWechatFav),@(SSDKPlatformTypeQQ),@(SSDKPlatformSubTypeQZone),@(SSDKPlatformTypeSinaWeibo)] shareParams:params sheetConfiguration:config onStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
        
    }];
//    [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_WechatTimeLine),@(UMSocialPlatformType_WechatFavorite),
//                                               @(UMSocialPlatformType_QQ),@(UMSocialPlatformType_Qzone ),@(UMSocialPlatformType_Sina)]];
//    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
//        [CjwFun shareWebPageToPlatformType:platformType currentViewController:self shareCont:_shareModel];
//    }];
}

-(void)actionWeixin:(id)sender{
    [CjwFun shareWebPageToPlatformType:SSDKPlatformSubTypeWechatSession currentViewController:self shareCont:_shareModel];
    NSLog(@"actionWeixin:%lu",[sender tag]);
}

-(void)actionFriend:(id)sender{
    [CjwFun shareWebPageToPlatformType:SSDKPlatformSubTypeWechatTimeline currentViewController:self shareCont:_shareModel];
    NSLog(@"actionFriend:%lu",[sender tag]);
}

-(void)actionQQ:(id)sender{
    [CjwFun shareWebPageToPlatformType:SSDKPlatformTypeQQ currentViewController:self shareCont:_shareModel];
    NSLog(@"actionQQ:%lu",[sender tag]);
}

-(void)actionWeibo:(id)sender{
    [CjwFun shareWebPageToPlatformType:SSDKPlatformTypeSinaWeibo currentViewController:self shareCont:_shareModel];
    NSLog(@"actionWeibo:%lu",[sender tag]);
}

//-------------------------------------------------------------
#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"app_pay"]) {
        // 打印所传过来的参数，只支持NSNumber, NSString, NSDate, NSArray,NSDictionary, and NSNull类型
        NSLog(@"%@, %ld", message.body,[message.body[@"arg0"] count]);
        _dataImages=message.body[@"arg0"];
        
        PBViewController *pbViewController = [PBViewController new];
        pbViewController.pb_dataSource = self;
        pbViewController.pb_delegate = self;
        pbViewController.pb_startPage = [message.body[@"arg1"] intValue];
        _bTapReplyImg=NO;
        [self presentViewController:pbViewController animated:YES completion:nil];
    }
}

#pragma mark - WKNavigationDelegate
// 页面加载开始  Provisional临时的
-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"页面开始加载");
}

// 加载内容
-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    NSLog(@"内容正在加载当中");
}

// 页面加载完成
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    NSLog(@"页面加载完成");
    //这个方法也可以计算出webView滚动视图滚动的高度
    [webView evaluateJavaScript:@"document.body.scrollWidth"completionHandler:^(id _Nullable result,NSError * _Nullable error){
        NSLog(@"scrollWidth高度：%.2f",[result floatValue]);
        CGFloat ratio =  CGRectGetWidth(_webView.frame) /[result floatValue];
        
        [webView evaluateJavaScript:@"document.body.scrollHeight"completionHandler:^(id _Nullable result,NSError * _Nullable error){
            NSLog(@"scrollHeight高度：%.2f",[result floatValue]);
            NSLog(@"scrollHeight计算高度：%.2f",[result floatValue]*ratio);
            
            CGFloat newHeight = [result floatValue]*ratio;
            //[self resetWebViewFrameWithHeight:newHeight];
            
            //KVO监听网页内容高度变化
            if (newHeight > CGRectGetHeight(_webView.frame)) {
                NSLog(@"KVO监听网页内容高度变化");
                //如果webView此时还不是满屏，就需要监听webView的变化  添加监听来动态监听内容视图的滚动区域大小
                [_webView addObserver:self forKeyPath:@"scrollView.contentSize" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:@"DJWebKitContext"];
            }
        }];
        
    }];
}

//使用KVO监听WKWebView的contentSize
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (!_webView.isLoading) {
        if([keyPath isEqualToString:@"scrollView.contentSize"])
        {
            CGRect frame = _webView.frame;
            frame.size.height = _webView.scrollView.contentSize.height;
            _webView.frame = frame;
            [_webView sizeToFit];
            
            [_tableView reloadData];
            [_webView removeObserver:self forKeyPath:@"scrollView.contentSize" context:@"DJWebKitContext"];
        }
        [_progress startAnimating];
        _bottomView.hidden=NO;
        _tableView.hidden=NO;
        
        if(_isPlaying && self.video!=nil){
            [self.video play];
        }
    }
}

-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    NSLog(@"createWebViewWithConfiguration：%@",navigationAction.request.URL);
    WKWebViewController  *webView2=[[WKWebViewController alloc] init];
    webView2.webUrl=[NSString stringWithFormat:@"%@",navigationAction.request.URL];
    [self.navigationController pushViewController:webView2 animated:TRUE];
    return nil;
}

//  页面加载失败
-(void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    NSLog(@"页面加载失败");
}
//-------------------------------------------------------------
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:([UIAlertAction actionWithTitle:@"完成" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(alertController.textFields[0].text?:@"");
    }])];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

//-------------------------------------------------------------
- (void)tapImageViewAction:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
    
    NSIndexPath* cellPath = [_tableView indexPathForCell:(UITableViewCell*)sender.view.superview.superview];
    ReplyModel* reply=_dataReply[cellPath.row];
    _bTapReplyImg=YES;
    _dataReplyImages=[reply.imglist mutableCopy];
    [self _showPhotoBrowser:sender.view];
}
//-------------------------------------------------------------

- (void)_showPhotoBrowser:(UIView *)sender {
    PBViewController *pbViewController = [PBViewController new];
    pbViewController.pb_dataSource = self;
    pbViewController.pb_delegate = self;
    pbViewController.pb_startPage = sender.tag;
    [self presentViewController:pbViewController animated:YES completion:nil];
}

#pragma mark - PBViewControllerDataSource

- (NSInteger)numberOfPagesInViewController:(PBViewController *)viewController {
    if (_bTapReplyImg) {
        return [_dataReplyImages count];
    }
    else{
        return [_dataImages count];
    }
}

- (void)viewController:(PBViewController *)viewController presentImageView:(UIImageView *)imageView forPageAtIndex:(NSInteger)index progressHandler:(void (^)(NSInteger, NSInteger))progressHandler {
    NSString *url=nil;
    if (_bTapReplyImg) {
        url = [_dataReplyImages objectAtIndex:index];
    }
    else{
        url = [_dataImages objectAtIndex:index];
    }

    [imageView sd_setImageWithURL:[NSURL URLWithString:url]
                 placeholderImage:[UIImage imageNamed:kImgHolder]
                          options:0
     //progress:progressHandler
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                        }];
}

#pragma mark - PBViewControllerDelegate

- (void)viewController:(PBViewController *)viewController didSingleTapedPageAtIndex:(NSInteger)index presentedImage:(UIImage *)presentedImage {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewController:(PBViewController *)viewController didLongPressedPageAtIndex:(NSInteger)index presentedImage:(UIImage *)presentedImage {
    
    /*NSLog(@"didLongPressedPageAtIndex: %@", @(index));
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:presentedImage];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        NSLog(@"success = %d, error = %@", success, error);
    }];*/
    //[MBProgressHUD showSuccess:@"图片存储成功" toView:self.view];
}
//-------------------------------------------------------------
- (void)onRightClick:(id)sender
{
    if(![_app.user checkUserLogin:self]){
        return;
    }
    
    SelectDataController *selectData = [[SelectDataController alloc] init];
    selectData.modalPresentationStyle = UIModalPresentationOverFullScreen;
    selectData.type=select_data_report;
    [selectData setBlockResultAction:^(NSString *szResult){
        NSLog(@"actionResult:%@",szResult);
        if (![szResult isEqualToString:@""]) {
            [MBProgressHUD showMessage:@"请稍候"];
            NSString* subject=[NSString stringWithFormat:@"%@(%ld)：%@",_app.user.username,_app.user.uid,szResult];
            NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"zhujiapp",@"userfrom", subject,@"subject", nil];
            [self->_app.net request: URL_report_add param:paramDic withMethod:@"POST"
                            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                [MBProgressHUD hideHUD];
                                NSLog(@"hot:%@",responseObject);
                                NSDictionary *dict = (NSDictionary *)responseObject;
                                if([dict[@"code"] integerValue]==0){
                                    [MBProgressHUD showSuccess:dict[@"msg"]];
                                }
                                else{
                                    [MBProgressHUD showError:dict[@"msg"]];
                                }
                            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                [MBProgressHUD hideHUD];
                            }];
        }
    }];
    [self presentViewController:selectData animated:YES completion:nil];
}

//-------------------------------------------------

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
