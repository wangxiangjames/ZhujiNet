//
//  HotCircleController.m
//  ZhujiNet
//
//  Created by zhujiribao on 2018/3/18.
//  Copyright © 2018年 zhujiribao. All rights reserved.
//

#import "CircleNavController.h"
#import <ShareSDKUI/ShareSDKUI.h>
//#import <UShareUI/UShareUI.h>
#import "MJExtension.h"
#import "AppDelegate.h"
#import "PhotoBrowser.h"
#import "MJRefresh.h"
#import "NSObject+MJKeyValue.h"
#import "CircleNavController.h"
#import "CircleDetailController.h"
#import "CircleCell.h"
#import "CircleHeaderCell.h"
#import "CircleModel.h"
#import "ForumSubModel.h"
#import "CircleHotModel.h"
#import "LikeModel.h"
#import "UITextView+placeholder.h"
#import "LayoutTextView.h"
#import "CircleReplyModel.h"
#import "ArtPlayerView.h"

@interface CircleNavController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,PBViewControllerDataSource, PBViewControllerDelegate,UIGestureRecognizerDelegate,TXVideoPublishListener>{
    AppDelegate                 *_app;
    MJRefreshAutoNormalFooter   *_refeshFooter;
    UITableView                 *_tableView;
    CircleCell                  *_circleCell;
    LayoutTextView              *_writeView;
    NSString                    *_url;
    
    NSMutableArray              *_data;
    NSInteger                   _page;
    NSInteger                   _pageCount;
    NSInteger                   _isLoading; //0没有加载，1正在加载，2加载完成
    BOOL                        _isEnd;     //是否触到底部
    
    NSUInteger                  _curRow;
    NSString                    *_post_tid;     //回复时记录tid
    
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
}

@end

@implementation CircleNavController

- (void)viewWillAppear:(BOOL)animated{
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
    [self addWriteView];
    
    UIBarButtonItem *item=[[UIBarButtonItem alloc]
                           initWithImage:[UIImage imageNamed:@"nav_photo"]
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

-(void)addWriteView {
    CGFloat layoutTextHeight = 50;
    _writeView = [[LayoutTextView alloc] initWithFrame:CGRectMake(0, Main_Screen_Height-layoutTextHeight-64,
                                                                  Main_Screen_Width, layoutTextHeight) withCameraHide:YES];
    _writeView.textView.placeholder = @"请输入内容";
    [self.view addSubview:_writeView];
    _writeView.hidden=YES;
    @WeakObj(self);
    [_writeView setSendBlock:^(UITextView *textView) {
        NSLog(@"textView:%@",textView.text);
        [selfWeak newpost:textView.text];
    }];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGesture.cancelsTouchesInView = YES;
    tapGesture.delegate=self;
    [self.view addGestureRecognizer:tapGesture];
}

-(void)viewTapped:(UITapGestureRecognizer*)tap {
    [_writeView.textView resignFirstResponder];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (!_writeView.isHidden) {
        return YES;
    }
    return NO;
}

-(void) scrollViewDidScroll:(UIScrollView *) scrollView{
    if (_writeView.hidden==NO) {
        [_writeView.textView resignFirstResponder];
    }
}

//-------------------------------------------------
-(void)newpost:(NSString*)message {
    NSDictionary *param=@{  @"action":@"reply",
                            @"tid":_post_tid,
                            @"message":message,
                            @"mobiletype":@"ios"
                            };
    
    [_app.net request:URL_newpost param:param withMethod:@"POST"
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"cjw:%@",responseObject);
                  NSDictionary *dict = (NSDictionary *)responseObject;
                  if([dict[@"code"] integerValue]==0){
                      _writeView.textView.text=@"";
                      
                      //------------------更新回复列表--------------
                      NSString* tempurl=[NSString stringWithFormat:@"%@?tid=%@",URL_replay,_post_tid];
                      [_app.net request:tempurl param:nil withMethod:@"POST"
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    NSLog(@"cjw:%@",responseObject);
                                    NSDictionary *dict = (NSDictionary *)responseObject;
                                    if([dict[@"code"] integerValue]==0){
                                        
                                        CircleModel* circle=_data[_curRow];
                                        NSLog(@"replay:--%@,",dict[@"data"][@"replay"]);
                                        [CircleReplyModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
                                            return @{
                                                     @"authorid":@"authorid",
                                                     @"username":@"author",
                                                     @"comment":@"message"
                                                     };
                                        }];
                                        circle.postlist=[CircleReplyModel mj_objectArrayWithKeyValuesArray:dict[@"data"][@"replay"]];
                                        circle.postnum=circle.postlist.count;
                                        circle.cellHeight=0;
                                        _data[_curRow]=circle;
                                        
                                        [_tableView reloadData];
                                        
                                        [CircleReplyModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
                                            return @{
                                                     @"authorid":@"authorid",
                                                     @"username":@"username",
                                                     @"comment":@"comment"
                                                     };
                                        }];
                                    }
                                    else{
                                        [MBProgressHUD showError:dict[@"msg"] toView:self.view];
                                    }
                                    
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                }];
                      
                      //--------------------------------
                      
                  }
                  else{
                      [MBProgressHUD showError:dict[@"msg"] toView:self.view];
                  }
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              }];
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
    
  [_tableView.mj_header beginRefreshing];
}

- (void)registerCell{
    _circleCell=[[CircleCell alloc]init];
    [_tableView registerClass:[CircleCell class] forCellReuseIdentifier:NSStringFromClass([CircleCell class])];
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
                          [_data addObjectsFromArray:[CircleModel mj_objectArrayWithKeyValuesArray:dict[@"data"]]];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _data.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CircleCell *cell = [_tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CircleCell class])];
    [cell setCircleModel:_data[indexPath.row]];
    
    __weak typeof(&*self)weakSelf = self;
    [cell setBlockTapImageViewAction:^(UITapGestureRecognizer *gesture){
        [weakSelf tapImageViewAction:gesture];
    }];

    [cell setBlockLikeAction:^(UIButton *button){
        [weakSelf actionCellLike:button];
    }];
    [cell setBlockShareAction:^(UIButton *button){
        [weakSelf actionCellShare:button];
    }];
    [cell setBlockReplyAction:^(UIButton *button){
        [weakSelf actionCellReply:button];
    }];
    [cell setBlockLookAllAction:^(UIButton *button){
        [weakSelf actionLookAll:button];
    }];
    
    return cell;
}

#pragma mark 设置每行高度（每行高度可以不一样）
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CircleModel *model = _data[indexPath.row];
    if (model.cellHeight == 0) {
        [_circleCell setCircleModel:model];
        model.cellHeight = _circleCell.height+_app.skin.floatSeparatorSpaceHeight/2;
    }
    return model.cellHeight+2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CircleModel *item=_data[indexPath.row];
    CircleDetailController *detail=[[CircleDetailController alloc]init];
    detail.title=item.forumname;
    detail.tid=NSString(item.tid);
    [self.navigationController pushViewController:detail animated:TRUE];
}

-(void)tableView:(UITableView* )tableView willDisplayCell:(UITableViewCell* )cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    _isEnd=NO;
    if (indexPath.row>_data.count*0.7) {
        [self loadData:NO];
    }
}

//-------------------------------------------------------------
-(void)actionCellLike:(UIButton*)sender{
    NSLog(@"actionCellLike:%lu",[sender tag]);
    if(![_app.user checkUserLogin:self]){
        return;
    }
    
    [MBProgressHUD showMessage:@"请稍候"];
    NSIndexPath* cellPath = [_tableView indexPathForCell:(UITableViewCell*)sender.superview.superview];
    _curRow=cellPath.row;
    CircleModel* circle=_data[_curRow];
    //------------------添加赞--------------
    NSDictionary *param=@{@"tid":NSString(circle.tid)};
    [_app.net request:URL_recommend_add param:param withMethod:@"POST"
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"cjw:%@",responseObject);
                  [MBProgressHUD hideHUD];
                  NSDictionary *dict = (NSDictionary *)responseObject;
                  if([dict[@"code"] integerValue]==0){
                      [_app.locationLike setObject:[NSDate date] forKey:NSString(circle.tid)];
                      [CjwFun putLocaionDict:kLocationLike value:_app.locationLike];
                      
                      //------------------更新赞列表--------------
                      NSDictionary *param=@{@"tid":NSString(circle.tid)};
                      [_app.net request:URL_replay_recommend param:param withMethod:@"POST"
                                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                    NSLog(@"cjw:%@",responseObject);
                                    NSDictionary *dict = (NSDictionary *)responseObject;
                                    if([dict[@"code"] integerValue]==0){
                                        circle.likelist=[LikeModel mj_objectArrayWithKeyValuesArray:dict[@"data"]];
                                        circle.cellHeight=0;
                                        
                                        /*NSIndexPath *indexPath=[NSIndexPath indexPathForRow:_curRow inSection:0];
                                        [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
                                        */
                                        [_tableView reloadData];
                                        [MBProgressHUD showError:@"回帖成功" toView:self.view];
                                    }
                                    else{
                                        [MBProgressHUD showError:dict[@"msg"] toView:self.view];
                                    }
                                    
                                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                }];
                      
                      //--------------------------------
                  }
                  else{
                      [MBProgressHUD showError:dict[@"msg"] toView:self.view];
                  }
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  [MBProgressHUD hideHUD];
              }];
    
}

-(void)actionCellShare:(UIButton*)sender{
    NSLog(@"actionCellShare:%lu",[sender tag]);
    
    NSIndexPath* cellPath = [_tableView indexPathForCell:(UITableViewCell*)sender.superview.superview];
    _curRow=cellPath.row;
    CircleModel* circle=_data[_curRow];
    ShareModel  *shareModel=[[ShareModel alloc]init];
    shareModel.title=circle.title;
    shareModel.descr=circle.forumname;
    if (circle.imglist.count>0) {
        shareModel.thumbUrl=circle.imglist[0];
    }
    shareModel.webpageUrl=circle.shareurl;
    
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

-(void)actionLookAll:(UIButton*)sender{
    NSLog(@"actionCellReply:%lu",[sender tag]);
    NSIndexPath* cellPath = [_tableView indexPathForCell:(UITableViewCell*)sender.superview.superview];
    _curRow=cellPath.row;
    CircleModel* circle=_data[_curRow];
    CircleDetailController *detail=[[CircleDetailController alloc]init];
    detail.title=circle.forumname;
    detail.tid=NSString(circle.tid);
    [self.navigationController pushViewController:detail animated:TRUE];
}

-(void)actionCellReply:(UIButton*)sender{
    NSLog(@"actionCellReply:%lu",[sender tag]);
    if(![_app.user checkUserLogin:self]){
        return;
    }
    NSIndexPath* cellPath = [_tableView indexPathForCell:(UITableViewCell*)sender.superview.superview];
    _curRow=cellPath.row;
    CircleModel* circle=_data[_curRow];
    _post_tid=NSString(circle.tid);
    
    _writeView.hidden=NO;
    [_writeView.textView becomeFirstResponder];
}

//-------------------------------------------------------------
- (void)tapImageViewAction:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
    
    NSIndexPath* cellPath = [_tableView indexPathForCell:(UITableViewCell*)sender.view.superview.superview];
    _curRow=cellPath.row;
    CircleModel* circle=_data[_curRow];
    if([circle.videourl isEqualToString:@""]){
        [self _showPhotoBrowser:sender.view];
    }
    else{
        NSLog(@"video");
        
        ArtPlayerView* player=[[ArtPlayerView alloc]initWithFrame:CGRectMake(0,0,Main_Screen_Width,Main_Screen_Height)
                                                         videoUrl:[NSURL URLWithString:circle.videourl]];
        [player putVidewH:circle.img_width>circle.img_height];
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
    CircleModel *circle=_data[_curRow];
    return [circle.imglist count];
}

- (void)viewController:(PBViewController *)viewController presentImageView:(UIImageView *)imageView forPageAtIndex:(NSInteger)index progressHandler:(void (^)(NSInteger, NSInteger))progressHandler {
    CircleModel *circle=_data[_curRow];
    NSString *url = [circle.imglist objectAtIndex:index];
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
-(void)navBbsCircleShop:(id)sender{
    //NSLog(@"chenjinwe-:%ld",self.fid);
    [CjwFun selectImgCont:ImagePicket_circle
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
                      [CjwFun uploadVideo:videoUrl coverImage:coverImg delegate:self];
                  }
                  else{
                      _bUploadVideo=NO;
                      [self uploadContent:_photos forumId:_fid forumTitle:_title forumContent:_message videoUrl:nil];
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
               closeType:YES];
    }
}

-(void)uploadImages:(UIImage*)image{
    [CjwFun uploadImage:image resultAcion:^(id responseObject){
        NSDictionary *dict = (NSDictionary *)responseObject;
        if ([dict[@"code"] intValue]==0) {
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
                       closeType:YES];
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
