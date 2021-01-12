//
//  CircleDetailController.m
//  ZhujiNet
//
//  Created by zhujiribao on 2018/3/19.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//
#import "CircleDetailController.h"
//#import <UShareUI/UShareUI.h>
#import <ShareSDKUI/ShareSDKUI.h>
#import "AppDelegate.h"
#import "PhotoBrowser.h"
#import "MJRefresh.h"
#import "Masonry.h"
#import "LayoutTextView.h"
#import "UITextView+placeholder.h"
#import "ReplyCell.h"
#import "ShareView.h"
#import "ShangModel.h"
#import "ReplyModel.h"
#import "CircleModel.h"
#import "CircleDetailCell.h"
#import "ShangController.h"
#import "FollowController.h"
#import "ArtPlayerView.h"
#import "PassValueDelegate.h"
#import "SelectDataController.h"

const NSInteger   TAG_BASE=2000;

@interface CircleDetailController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,PBViewControllerDataSource, PBViewControllerDelegate,PassValueDelegate>{
    AppDelegate                 *_app;
    
    UITableView                 *_tableView;
    CircleDetailCell            *_circleDetailCell;
    ReplyCell                   *_replyCell;
    MJRefreshAutoNormalFooter   *_refeshFooter;
    ShareView                   *_shangView;
    ShareModel                  *_shareModel;
    CircleModel                 *_circleModel;
    
    NSString                    *_url;
    NSInteger                   _page;
    NSInteger                   _pagecount;
    BOOL                        _isLoading;
    NSMutableArray              *_dataReply;
    NSMutableArray              *_dataReplyImages;
    BOOL                        _bTapReplyImg;
    
    UIButton                    *_btnReply;
    UIButton                    *_btnLike;
    UIButton                    *_btnWrite;
    UIButton                    *_btnShare;
    
    NSString                    *_artTitle;
    NSString                    *_footMsg;
    NSString                    *_likeNum;
    NSString                    *_replyNum;
    CGFloat                     _cellHeaderHeight;
    BOOL                        _isreward;
    
    NSInteger                   _currUploadNum;
    NSString                    *_imgid;
}

@property (nonatomic,copy) NSString             *pid;
@property (nonatomic,copy) NSString             *message;
@property (nonatomic,strong) LayoutTextView     *writeView;
@property (nonatomic,strong) NSMutableArray     *selectPhoto;
@end

@implementation CircleDetailController

- (void)viewWillAppear:(BOOL)animated{
    _app = [AppDelegate getApp];
    [_app.skin setSkin:self];
    self.view.backgroundColor=_app.skin.colorCellBg;
    [_tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _app = [AppDelegate getApp];
    
    _isLoading=NO;
    _page=1;
    _pagecount=1;
    
    _selectPhoto= [NSMutableArray arrayWithCapacity:9];
    _currUploadNum=0;
    _imgid=@"";
    
    _dataReply = [NSMutableArray arrayWithCapacity:10];
    _dataReplyImages= [NSMutableArray arrayWithCapacity:3];
    _btnReply=[[UIButton alloc]init];
    _shareModel=[[ShareModel alloc]init];
    _shangView=[[ShareView alloc]init];
    
    [self setNavigation];
    [self addTableView];
    [self registerCell];
    [self addWriteView];
    [self loadLike];
    [self setBottomView:YES commentWithNum:@"" likeWithNum:@"" isLike:NO];
    
    _url=[NSString stringWithFormat:@"%@?tid=%@",URL_replay,self.tid];
    [_app.net request:self url:_url];
}

//-------------------------------------------------
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
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onNavMoreClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

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

-(void)addTableView{
    CGRect rect=CGRectMake(0, 0, self.view.frame.size.width,  self.view.frame.size.height-Height_NavBar_HomeIndicator-50);
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
        }
    }];
    
    _tableView.mj_footer =_refeshFooter;
    [self.view addSubview:_tableView];
}

- (void)registerCell{
    _circleDetailCell=[[CircleDetailCell alloc]init];
    [_tableView registerClass:[CircleDetailCell class] forCellReuseIdentifier:NSStringFromClass([CircleDetailCell class])];
    
    _replyCell=[[ReplyCell alloc]init];
    [_tableView registerClass:[ReplyCell class] forCellReuseIdentifier:NSStringFromClass([ReplyCell class])];
}

-(void)addWriteView {
    CGFloat layoutTextHeight = 50;
    _writeView = [[LayoutTextView alloc] initWithFrame:CGRectMake(0, Main_Screen_Height-layoutTextHeight-
                                                                  -Height_NavBar_HomeIndicator,
                                                                  Main_Screen_Width, layoutTextHeight)];
    _writeView.textView.placeholder = @"请输入内容";
    [self.view addSubview:_writeView];
    _writeView.hidden=YES;
    @WeakObj(self);
    [_writeView setSendBlock:^(UITextView *textView) {
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
    [self.view addGestureRecognizer:tapGesture];
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
    _writeView.sendBtn.enabled=NO;
    
    [CjwFun sendReply:self.message withTid:self.tid withRequote:self.pid withImages:_imgid resultAcion:^(id responseObject){
        NSLog(@"cjw:%@",responseObject);
        NSDictionary *dict = (NSDictionary *)responseObject;
        if([dict[@"code"] integerValue]==0){
            //[MBProgressHUD hideHUD];
            
            self.writeView.textView.text=@"";
            self.pid=nil;
            _page=1;
            NSDictionary *param=@{@"page":[NSNumber numberWithLong:_page]};
            [_app.net request:self url:_url param:param callTag:0];
            if (isPop) {
                [self.navigationController popViewControllerAnimated:YES];
            }
            //[MBProgressHUD showSuccess:dict[@"msg"] toView:self.view];
            _writeView.sendBtn.enabled=YES;
        }
        else{
            [MBProgressHUD showError:dict[@"msg"] toView:self.view];
            _writeView.sendBtn.enabled=YES;
        }
    }];
}

-(void)viewTapped:(UITapGestureRecognizer*)tap {
    [_writeView.textView resignFirstResponder];
}

//-------------------------------------------------------------
-(void) scrollViewDidScroll:(UIScrollView *) scrollView{
    if(_isLoading==NO && (scrollView.contentOffset.y+scrollView.frame.size.height)/scrollView.contentSize.height >0.95 && scrollView.contentSize.height>100){
        if (_page>=_pagecount) {
            return;
        }
        _isLoading=YES;
        
        NSDictionary *param=@{@"page":[NSNumber numberWithLong:_page+1]};
        [_app.net request:self url:_url param:param callTag:0];
    }
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
                      BOOL isMylike=NO;
                      
                      for (NSInteger i=0; i<[shanglist count];i++ ) {
                          if(i==([shanglist count]-1)){
                              flag=@"";
                          }
                          ShangModel* shang=[shanglist objectAtIndex:i];
                          userlist=[NSString stringWithFormat:@"%@%@%@",userlist, shang.username,flag];
                          if (_app.user.uid==shang.uid) {
                              isMylike=YES;
                          }
                      }
                      if ([userlist isEqualToString:@""]) {
                          [_shangView likeList:@""];
                      }
                      else{
                          [_shangView likeList: [NSString stringWithFormat:@"赞列表：%@等%ld人点赞",userlist,[shanglist count]]];
                      }
                      
                      [self setBottomView:NO commentWithNum:_replyNum likeWithNum:NSString([shanglist count]) isLike:YES];
                  }
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              }];
}

//-------------------------------------------------

- (void)requestCallback:(id)response status:(id)status{
    NSDictionary *dict = (NSDictionary *)response;
    if ([status[@"stat"] isEqual:@0]) {
        _page=[dict[@"page"] intValue];
        _pagecount=[dict[@"pagecount"] intValue];
        
        if([status[@"tag"] isEqual:@0]){
            if (_page==1) {
                [_dataReply removeAllObjects];
            }
            
            if(dict[@"data"]!=nil && _page==1){
                _circleModel= [CircleModel mj_objectWithKeyValues:dict[@"data"]];
                NSLog(@"chenjinwei-:%@",[_circleModel mj_JSONString]);
                
                [self setBottomView:NO commentWithNum:[NSString stringWithFormat:@"%@",dict[@"data"][@"replaynum"]]
                 likeWithNum:[NSString stringWithFormat:@"%@",dict[@"data"][@"likenum"]] isLike:[dict[@"data"][@"islike"] integerValue]==1?YES:NO];
                
                _shareModel.title=dict[@"data"][@"title"];
                _shareModel.descr=dict[@"data"][@"forumname"];
                _shareModel.thumbUrl=dict[@"data"][@"sharepic"];;
                _shareModel.webpageUrl= dict[@"data"][@"shareurl"];
                _isreward=[dict[@"data"][@"isreward"] intValue]==1? YES:NO;
                if (_isreward) {
                    [_shangView yiShangForBtn];
                }
            }
            
            if(dict[@"data"][@"replay"]!=nil){
                [_dataReply addObjectsFromArray: [ReplyModel mj_objectArrayWithKeyValuesArray:dict[@"data"][@"replay"]]];
                if([_dataReply count]==0){
                    _footMsg=@"暂无评论";
                    _tableView.mj_footer.hidden = YES;
                    [_tableView.mj_footer endRefreshingWithNoMoreData];
                }
            }
            [_tableView reloadData];
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

-(void)setBottomView:(Boolean)bInit commentWithNum:(NSString*)replyNum likeWithNum:(NSString*)likeNum isLike:(BOOL)isLike{
    _likeNum=likeNum;
    _replyNum=replyNum;
    
    if (bInit) {
        UIView *bottomView=[[UIView alloc]initWithFrame:CGRectMake(-1, self.view.frame.size.height-Height_NavBar_HomeIndicator+-50, SCREEN_WIDTH+2, 51)];
        bottomView.backgroundColor=_app.skin.colorCellBg;
        bottomView.alpha=0.96;
        bottomView.layer.borderColor=_app.skin.colorCellSeparator.CGColor;
        bottomView.layer.borderWidth=_app.skin.floatImgBorderWidth;
        
        _btnShare = [[UIButton alloc]init];
        _btnShare.imageEdgeInsets=UIEdgeInsetsMake(2, 2, 2, 2);
        [_btnShare setImage:[UIImage imageNamed:@"fenxiang"] forState:UIControlStateNormal];
        [_btnShare addTarget:self action:@selector(actionShare:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:_btnShare];
        
        _btnLike=[UIButton buttonWithType:UIButtonTypeCustom];
        _btnLike.imageEdgeInsets=UIEdgeInsetsMake(2, 2, 2, 2);
        _btnLike.titleEdgeInsets=UIEdgeInsetsMake(0, 5, 3, 0);
        _btnLike.titleLabel.font = [UIFont systemFontOfSize:13.f];
        [_btnLike addTarget:self action:@selector(actionLike:) forControlEvents:UIControlEventTouchUpInside];
        [bottomView addSubview:_btnLike];
        
        _btnReply=[UIButton buttonWithType:UIButtonTypeCustom];
        _btnReply.imageEdgeInsets=UIEdgeInsetsMake(2, 2, 2, 2);
        _btnReply.titleEdgeInsets=UIEdgeInsetsMake(0, 5, 3, 0);
        _btnReply.titleLabel.font = [UIFont systemFontOfSize:13.f];
        [bottomView addSubview:_btnReply];
        
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
        [bottomView addSubview:_btnWrite];
        [self.view addSubview:bottomView];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==1) {
        return [_dataReply count];
    }
    else{
        return 1;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section==1) {
        UIView *view=[[UIView alloc]init];
        UILabel *columTitle=[[UILabel alloc] initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH, 40)];
        columTitle.text=@"最新跟贴";
        [view addSubview:columTitle];
        return view;
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section==0) {
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
    else if (section==1) {
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
    if(section==1){
        return 40.0;
    }
    else{
        return 0.1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if(section==1){
        if(_page<_pagecount){
            return 0.1;
        }
        else{
            return 80.0;
        }
    }
    else{
        return _shangView.height;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(&*self)weakSelf = self;
    if (indexPath.section==0) {
        CircleDetailCell *cell = [_tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CircleDetailCell class])];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell setData:_circleModel];
        [cell setBlockTapImageViewAction:^(UITapGestureRecognizer *gesture){
            [weakSelf tapImageViewAction:gesture];
        }];
        [cell setBlockFollowAction:^(UIButton *sender){
            [weakSelf followAction:sender];
        }];
        for (CjwItem* item in _app.followUser) {
            if ([item.authorid isEqualToString:NSString(_circleModel.authorid)]) {
                [cell.btnFollow setTitle:@"已关注" forState:UIControlStateNormal];
                cell.btnFollow.backgroundColor=[UIColor lightGrayColor];
                break;
            }
        }
        return cell;
    }
    else{
        ReplyCell *cell = [_tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ReplyCell class])];
        ReplyModel* replyMode=_dataReply[indexPath.row];
        cell.replyModel=replyMode;
        [cell setBlockTapImageViewAction:^(UITapGestureRecognizer *gesture){
            [weakSelf tapReplyImageViewAction:gesture];
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
        return _circleModel.cellHeight;
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//-------------------------------------------------------------

-(void)actionWrite:(id)sender{
    if(![_app.user checkUserLogin:self]){
        return;
    }
    
    _writeView.hidden=NO;
    [_writeView.textView becomeFirstResponder];
}


-(void)actionLike:(id)sender{
    if(![_app.user checkUserLogin:self]){
        return;
    }
    
    [MBProgressHUD showMessage:@"请稍候"];
    NSDictionary *param=@{@"tid":self.tid};
    [_app.net request:URL_recommend_add param:param withMethod:@"POST"
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  [MBProgressHUD hideHUD];
                  NSLog(@"cjw:%@",responseObject);
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
        return;
    }
    
    NSInteger row =sender.tag - TAG_BASE;
    ReplyModel *reply= _dataReply[row];
    _pid=reply.pid;
    _writeView.hidden=NO;
    [_writeView.textView becomeFirstResponder];
}

-(void)actionShang:(id)sender{
    if(![_app.user checkUserLogin:self])
        return;
    
    ShangController *shang=[[ShangController alloc]init];
    shang.delegate=self;
    shang.bYiShang=_isreward;
    shang.tid=self.tid;
    shang.authorid=_circleModel.authorid;
    shang.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    [self presentViewController:shang animated:YES completion:nil];
}

-(void)passValue:(NSString *)value{
    if ([value isEqualToString:@"1"]) {
        _isreward=YES;
        if (_isreward) {
            [_shangView yiShangForBtn];
        }
    }
    NSLog(@"get backcall value=%@",value);
}

-(void)followAction:(UIButton*)sender{
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
        NSDictionary *param=@{@"fuid":NSString(_circleModel.authorid)};
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
-(void) tapReplyImageViewAction:(UITapGestureRecognizer *)sender {
    _bTapReplyImg=YES;
    NSIndexPath* cellPath = [_tableView indexPathForCell:(UITableViewCell*)sender.view.superview.superview];
    ReplyModel* reply=_dataReply[cellPath.row];
    _bTapReplyImg=YES;
    _dataReplyImages=[reply.imglist mutableCopy];
    [self _showPhotoBrowser:sender.view];
}

- (void)tapImageViewAction:(UITapGestureRecognizer *)sender {
    _bTapReplyImg=NO;
    
    if([_circleModel.videourl isEqualToString:@""]){
        [self _showPhotoBrowser:sender.view];
    }
    else{
        NSLog(@"video");
        ArtPlayerView* player=[[ArtPlayerView alloc]initWithFrame:CGRectMake(0,0,Main_Screen_Width,Main_Screen_Height)
                                                         videoUrl:[NSURL URLWithString:_circleModel.videourl]];
        [player putVidewH:_circleModel.img_width>_circleModel.img_height];
        [player play];
        
        UIApplication *ap = [UIApplication sharedApplication];
        [ap.keyWindow addSubview:player];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTappedForVideo:)];
        tapGesture.cancelsTouchesInView = YES;
        [player addGestureRecognizer:tapGesture];
        
        player.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
        [UIView animateWithDuration:0.5f animations:^{
            player.transform=CGAffineTransformMakeScale(1.0f, 1.0f);
        } completion:^(BOOL finished) {
            
        }];
    }
    
}

-(void)viewTappedForVideo:(UITapGestureRecognizer*)tap {
    [UIView animateWithDuration:0.3f animations:^{
        tap.view.alpha=0.01;
        tap.view.transform=CGAffineTransformMakeScale(0.01f, 0.01f);
    } completion:^(BOOL finished) {
        [tap.view removeFromSuperview];
    }];
}

- (void)_showPhotoBrowser:(UIView *)sender {
    PBViewController *pbViewController = [PBViewController new];
    pbViewController.pb_dataSource = self;
    pbViewController.pb_delegate = self;
    pbViewController.pb_startPage = sender.tag;
    [self presentViewController:pbViewController animated:YES completion:nil];
}

- (void)_clear {
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
        NSLog(@"Cache clear complete.");
    }];
}


#pragma mark - PBViewControllerDataSource

- (NSInteger)numberOfPagesInViewController:(PBViewController *)viewController {
    if (_bTapReplyImg) {
        return [_dataReplyImages count];
    }
    else{
        return [_circleModel.imglist count];
    }
}

- (void)viewController:(PBViewController *)viewController presentImageView:(UIImageView *)imageView forPageAtIndex:(NSInteger)index progressHandler:(void (^)(NSInteger, NSInteger))progressHandler {
    NSString *url=nil;
    if (_bTapReplyImg) {
        url = [_dataReplyImages objectAtIndex:index];
    }
    else{
        url = [_circleModel.imglist objectAtIndex:index];
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
    NSLog(@"didLongPressedPageAtIndex: %@", @(index));
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
