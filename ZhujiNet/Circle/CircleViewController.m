//
//  ForumViewController.m
//  ZhujiNet
//
//  Created by chenjinwei on 17/6/11.
//  Copyright © 2017年 zhuji.net. All rights reserved.
//

#import "CircleViewController.h"
#import <ShareSDKUI/ShareSDKUI.h>
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
#import "CjwSheetView.h"
#import "SelectDataController.h"

@interface CircleViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,NavMenuDelegate,PBViewControllerDataSource, PBViewControllerDelegate,UIGestureRecognizerDelegate>{
    AppDelegate                 *_app;
    
    UITableView                 *_tableView;
    CircleHeaderCell            *_headerCell;
    CircleCell                  *_circleCell;
    MJRefreshAutoNormalFooter   *_refeshFooter;
    CjwNavMenu                  *_navMenu;
    LayoutTextView              *_writeView;
    
    NSMutableArray              *_arrayCircleNav;
    NSMutableArray              *_arrayCircleHot;
    NSMutableArray              *_data;
    NSMutableArray              *_dataFriend;
    
    NSInteger                   _page;
    NSInteger                   _pageCount;
    NSInteger                   _pageFriend;
    NSInteger                   _pageFriendCount;
    BOOL                        _isSelectFriend;    //当前是否选中好友动态
    NSInteger                   _isLoading;         //0没有加载，1正在加载，2加载完成
    BOOL                        _isEnd;             //是否触到底部
    CGPoint                     _offetFriend;
    CGPoint                     _offet;
    
    CGFloat                     _cellHeaderHeight;
    NSUInteger                  _curNavMenu;
    NSUInteger                  _curRow;
    NSString                    *_post_tid;         //回复时记录tid
    CjwSheetView               *_sheet;
    NSIndexPath                *_indexPathSelect;
}

@end

@implementation CircleViewController

- (void)viewWillAppear:(BOOL)animated{
    _app = [AppDelegate getApp];
    [_app.skin setSkin:self];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.parentViewController.navigationItem.backBarButtonItem = backItem;
    
    [self loadCircleHot];
    [_tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _app = [AppDelegate getApp];
    
    _arrayCircleNav=[NSMutableArray arrayWithCapacity:20];
    _arrayCircleHot=[NSMutableArray arrayWithCapacity:20];
    _data = [NSMutableArray arrayWithCapacity:20];
    _dataFriend = [NSMutableArray arrayWithCapacity:20];
    
    _isSelectFriend=NO;
    _isLoading=0;
    _isEnd=NO;
    _page=0;
    _pageFriend=0;
    
    [self addTableView];
    [self registerCell];
    [self loadCircleNav];
    [self loadCircleMenu];
    [self addWriteView];
}

-(void)addTableView{
    CGRect rect=CGRectMake(0, 0, self.view.frame.size.width,  self.view.frame.size.height -Height_NavBar-Height_TabBar);
    _tableView =  [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
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
    
    /*
     _refeshFooter.triggerAutomaticallyRefreshPercent=0;
    _refeshFooter.ignoredScrollViewContentInsetBottom=0;
    _refeshFooter.pullingPercent=0;
    _refeshFooter.scrollView.bounces = NO;
    */
    
    [self.view addSubview:_tableView];
}

- (void)registerCell{
    _headerCell=[[CircleHeaderCell alloc]init];
    _circleCell=[[CircleCell alloc]init];
    [_tableView registerClass:[CircleHeaderCell class] forCellReuseIdentifier:NSStringFromClass([CircleHeaderCell class])];
    [_tableView registerClass:[CircleCell class] forCellReuseIdentifier:NSStringFromClass([CircleCell class])];
}

//诸暨圈话题
-(void)loadCircleMenu{
    [_app.net request:URL_circle_forum param:nil withMethod:@"POST"
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSDictionary *dict = (NSDictionary *)responseObject;
                  if([dict[@"code"] integerValue]==0){
                      _app.circleMenu=[ForumSubModel mj_objectArrayWithKeyValuesArray:dict[@"data"]];
                  }
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              }];
}

-(void)loadCircleNav{
    [_app.net request:URL_circle_nav param:nil withMethod:@"POST"
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSDictionary *dict = (NSDictionary *)responseObject;
                  if([dict[@"code"] integerValue]==0){
                      _arrayCircleNav=[ForumSubModel mj_objectArrayWithKeyValuesArray:dict[@"data"]];
                      //[_tableView reloadData];
                  }
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              }];
}

-(void)loadCircleHot{
    [_app.net request:URL_circle_hot param:nil withMethod:@"POST"
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"hot:%@",responseObject);
                  NSDictionary *dict = (NSDictionary *)responseObject;
                  if([dict[@"code"] integerValue]==0){
                      _arrayCircleHot=[CircleHotModel mj_objectArrayWithKeyValuesArray:dict[@"data"]];
                      //[_tableView reloadData];
                  }
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              }];
}

-(void)loadData:(BOOL)isHeader{
    if (isHeader) {
        [_refeshFooter resetNoMoreData];    //页数全部加载完成后，重新涮新需重置
        [_refeshFooter setTitle:@"努力加载中……" forState:MJRefreshStateIdle];
        
        if (_isSelectFriend) {
            _pageFriend=0;
            [_dataFriend removeAllObjects];
        }
        else{
            _page=0 ;
            [_data removeAllObjects];
        }
        _isLoading=0;
        _isEnd=0;
    }
    
    NSLog(@"--1---isLoading:%ld,sEnd=%ld,isHeader=%ld",_isLoading,_isEnd,isHeader);
    if (_isLoading==0 && _isEnd==NO) {
        _isLoading=1;
        
        NSLog(@"cccccc");
        if(_page % 10==0){
            [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
        }
        
        NSString* url=_isSelectFriend ? URL_follow_post : URL_circle;
        NSDictionary *param=_isSelectFriend ? @{@"page":@(_pageFriend+1)}:@{@"page":@(_page+1)};
        [_app.net request:url param:param withMethod:@"POST"
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"--2---isLoading:%ld,isEnd=%ld,isHeader=%ld",_isLoading,_isEnd,isHeader);
              NSDictionary *dict = (NSDictionary *)responseObject;
              if([dict[@"code"] integerValue]==0){
                  if (_isSelectFriend) {
                      _pageFriend=[dict[@"page"] intValue];
                      _pageFriendCount=[dict[@"pagecount"] intValue];
                  }
                  else{
                      _page=[dict[@"page"] intValue];
                      _pageCount=[dict[@"pagecount"] intValue];
                  }
                  NSMutableArray *circlelist = [CircleModel mj_objectArrayWithKeyValuesArray:dict[@"data"]];
                  //-------------------------过滤-------------------------------
                  if(self->_app.user.uid>0){
                      NSString *uid=[NSString stringWithFormat:@"%ld",(long)self->_app.user.uid];
                      NSString *strArray=[self->_app.locationBlacklist objectForKey:uid];
                      if([strArray length]>0){
                          NSEnumerator *enumerator = [circlelist reverseObjectEnumerator];
                          for (CircleModel *model in enumerator) {
                              NSString *authorid=[NSString stringWithFormat:@"%ld",(long)model.authorid];
                              if ([strArray rangeOfString:authorid].location != NSNotFound && model.authorid>0){
                                  [circlelist removeObject:model];
                              }
                          }
                      }
                  }
                  //--------------------------------------------------------
                  if (_isSelectFriend) {
                      [_dataFriend addObjectsFromArray:circlelist];
                  }
                  else{
                      [_data addObjectsFromArray:circlelist];
                  }
                  
                  NSLog(@"testest:%ld",circlelist.count);
              }
              _isLoading=2;
              if (isHeader){
                  NSLog(@"--3---isLoading:%ld,isEnd=%ld,isHeader=%ld",_isLoading,_isEnd,isHeader);
                  [_tableView reloadData];
                  [_tableView.mj_header endRefreshing];
                  _isLoading=0;
                  if (_isSelectFriend) {
                      if (_dataFriend.count==0) {
                          [_refeshFooter setTitle:@"很遗憾没有数据！" forState:MJRefreshStateIdle];
                      }
                  }
                  else{
                      if (_data.count==0) {
                          [_refeshFooter setTitle:@"很遗憾没有数据！" forState:MJRefreshStateIdle];
                      }
                  }
                  

              }
              else if (_isEnd) {
                  NSLog(@"--4---isLoading:%ld,isEnd=%ld,isHeader=%ld",_isLoading,_isEnd,isHeader);
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
        NSLog(@"--5---isLoading:%ld,isEnd=%ld,isHeader=%ld",_isLoading,_isEnd,isHeader);
        [self loadDataFooterEnd];
        return;
    }
}

-(void)loadDataFooterEnd{
    [_tableView reloadData];
    NSInteger tempPage=_isSelectFriend?_pageFriend:_page;
    NSInteger tempPageCount=_isSelectFriend?_pageFriendCount:_pageCount;
    if(tempPage>=tempPageCount){
        if (_isSelectFriend? [_dataFriend count]==0 : [_data count]==0) {
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

-(void) scrollViewDidScroll:(UIScrollView *) scrollView{
    if (_writeView.hidden==NO) {
        [_writeView.textView resignFirstResponder];
    }
    if((scrollView.contentOffset.y+scrollView.frame.size.height)/scrollView.contentSize.height >0.85 && scrollView.contentSize.height>100){
        _isEnd=NO;
        [self loadData:NO];
     }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if(_isSelectFriend) {
        _offetFriend=scrollView.contentOffset;
    }
    else{
        _offet=scrollView.contentOffset;
    }
}

#pragma mark -
#pragma mark - UITableView dateSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(section==0){
        return nil;
    }
    
    _cellHeaderHeight=44;
    UIView *view=[[UIView alloc]init];
    //--------------------------
    _navMenu=[[CjwNavMenu alloc]initWithFrame:CGRectMake(30,0,SCREEN_WIDTH-60,_cellHeaderHeight) array:@[@"最新动态",@"好友动态"] menuColor:_app.skin.colorCellTitle];
    _navMenu.lineColor=_app.skin.colorMain;
    _navMenu.backgroundColor=_app.skin.colorCellSelectBg;
    _navMenu.menuSelectColor=_app.skin.colorTabbarSelected;
    _navMenu.delegate=self;
    [_navMenu setCurrentIndex:_curNavMenu];
    [view addSubview:_navMenu];
    //--------------------------
    view.frame=CGRectMake(0, 0, SCREEN_WIDTH, _cellHeaderHeight+0.5);
    view.backgroundColor=_app.skin.colorCellSelectBg;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section==0)
        return 0.1;
    
    return _cellHeaderHeight+0.5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section==0){
        return 1;
    }
    else{
        return _isSelectFriend ? _dataFriend.count : _data.count;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0){
        CircleHeaderCell *cell = [_tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CircleHeaderCell class])];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        __weak typeof(&*self)weakSelf = self;
        [cell.menuPicScroll setBlockTapImageViewAction:^(UITapGestureRecognizer *gesture){
            [weakSelf actionMenuPicScrollTap:gesture];
        }];
        
        [cell.hotPicScroll setBlockLikeAction:^(UIButton *button){
            [weakSelf actionHotPicScrollLike:button];
        }];
        
        [cell.hotPicScroll setBlockTapImageViewAction:^(UITapGestureRecognizer *gesture){
            [weakSelf actionHotPicScrollTap:gesture];
        }];
        
        [cell.menuPicScroll updateMenuPic:_arrayCircleNav];
        [cell.hotPicScroll updateHotPic:_arrayCircleHot];
        
        return cell;
    }
    else{
        CircleCell *cell = [_tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CircleCell class])];
        cell.circleModel=_isSelectFriend ? _dataFriend[indexPath.row] : _data[indexPath.row];
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
        [cell setBlockMoreAction:^(UIButton *button){
            [weakSelf actionMore:button];
        }];
        return cell;
    }
}

#pragma mark 设置每行高度（每行高度可以不一样）
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0){
        return _headerCell.height;
    }
    else{
        CircleModel *model=_isSelectFriend ? _dataFriend[indexPath.row] : _data[indexPath.row];
        _circleCell.circleModel=model;
        if (model.cellHeight == 0) {
            _circleCell.circleModel=model;
            model.cellHeight = _circleCell.height+_app.skin.floatSeparatorSpaceHeight/2;
        }
        return model.cellHeight+2;
    }
}

-(void)tableView:(UITableView* )tableView willDisplayCell:(UITableViewCell* )cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1) {
        _isEnd=NO;
        if (indexPath.row>(_isSelectFriend ? _dataFriend.count*0.7: _data.count*0.7)) {
            [self loadData:NO];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==0){
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CircleModel *item=_isSelectFriend ? _dataFriend[indexPath.row] : _data[indexPath.row];
    CircleDetailController *detail=[[CircleDetailController alloc]init];
    detail.title=item.forumname;
    detail.tid=NSString(item.tid);
    [self.navigationController pushViewController:detail animated:TRUE];
}

- (void)navMeunDidSelectedWithIndex:(NSInteger)index{
    _curNavMenu=index;
    if (index==1) {
        if(![_app.user checkUserLogin:self]){
            return;
        }
        _isSelectFriend=YES;
    }
    else{
        _isSelectFriend=NO;
    }

    _isLoading=0;;
    _isEnd=NO;
    if (_dataFriend.count==0 || _data.count==0) {
        [_tableView.mj_header beginRefreshing];
    }

    _tableView.alpha=0;
    [_tableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        //刷新完成
        _tableView.contentOffset=_isSelectFriend ? _offetFriend : _offet;
        [UIView animateWithDuration:0.5 animations:^{
            _tableView.alpha = 0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.7 animations:^{
                _tableView.alpha = 1;
            }];
        }];
    });
}

//-------------------------------------------------------------
-(void)actionMenuPicScrollTap:(UITapGestureRecognizer*) gesture{
    NSLog(@"actionMenuPicScrollTap:%lu",gesture.view.tag);
    
    CircleNavController *circleNav=[[CircleNavController alloc]init];
    if(gesture.view.tag<_arrayCircleNav.count){
        ForumSubModel* subModel=_arrayCircleNav[gesture.view.tag];
        circleNav.navTitle=subModel.name;
        circleNav.fid=[subModel.fid intValue];
        circleNav.url=[NSString stringWithFormat:@"%@?fid=%@",URL_circle,subModel.fid];
    }
    [self.navigationController pushViewController:circleNav animated:TRUE];
}

-(void)actionHotPicScrollTap:(UITapGestureRecognizer*) gesture{
    NSLog(@"actionPicScrollTap:%lu",gesture.view.tag);
    
    CircleHotModel *item=_arrayCircleHot[gesture.view.tag];
    CircleDetailController *detail=[[CircleDetailController alloc]init];
    detail.title=item.forumname;
    detail.tid=NSString(item.tid);
    [self.navigationController pushViewController:detail animated:TRUE];
}

-(void)actionHotPicScrollLike:(id)sender{
    NSLog(@"actionPicScrollLike:%lu",[sender tag]);
    if(![_app.user checkUserLogin:self]){
        return;
    }
    
    CircleHotModel *item=[_arrayCircleHot objectAtIndex:[sender tag]];
    NSDictionary *param=@{@"tid":NSString(item.tid)};
    [_app.net request:URL_recommend_add param:param withMethod:@"POST"
              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"cjw:%@",responseObject);
                  NSDictionary *dict = (NSDictionary *)responseObject;
                  if([dict[@"code"] integerValue]==0){
                      [sender setImage:[UIImage imageNamed:@"btn_zan"] forState:UIControlStateNormal];
                      item.islike=1;
                  }
                  else{
                      [MBProgressHUD showError:dict[@"msg"] toView:self.view];
                  }
                  
              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              }];
}

-(void)actionCellLike:(UIButton*)sender{
    NSLog(@"actionCellLike:%lu",[sender tag]);
    if(![_app.user checkUserLogin:self]){
        return;
    }
    
    [MBProgressHUD showMessage:@"请稍候"];
    NSIndexPath* cellPath = [_tableView indexPathForCell:(UITableViewCell*)sender.superview.superview];
    _curRow=cellPath.row;
    CircleModel* circle=_isSelectFriend ? _dataFriend[_curRow] : _data[_curRow];
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
                                        
                                        /*NSIndexPath *indexPath=[NSIndexPath indexPathForRow:_curRow inSection:1];
                                        [_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
                                        */
                                        [_tableView reloadData];
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
    CircleModel* circle=_isSelectFriend ? _dataFriend[_curRow] : _data[_curRow];
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

-(void)actionCellReply:(UIButton*)sender{
    NSLog(@"actionCellReply:%lu",[sender tag]);
    if(![_app.user checkUserLogin:self]){
        return;
    }
    
    NSIndexPath* cellPath = [_tableView indexPathForCell:(UITableViewCell*)sender.superview.superview];
    _curRow=cellPath.row;
    CircleModel* circle=_isSelectFriend ? _dataFriend[_curRow] : _data[_curRow];
    _post_tid=NSString(circle.tid);
    
    _writeView.hidden=NO;
    [_writeView.textView becomeFirstResponder];
}

-(void)actionLookAll:(UIButton*)sender{
    NSLog(@"actionCellReply:%lu",[sender tag]);
    NSIndexPath* cellPath = [_tableView indexPathForCell:(UITableViewCell*)sender.superview.superview];
    _curRow=cellPath.row;
    CircleModel* circle=_isSelectFriend ? _dataFriend[_curRow] : _data[_curRow];
    CircleDetailController *detail=[[CircleDetailController alloc]init];
    detail.title=circle.forumname;
    detail.tid=NSString(circle.tid);
    [self.navigationController pushViewController:detail animated:TRUE];
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
        
        if (textView.text.length==0) {
            [MBProgressHUD showError:@"内容不能为空！"];
            return ;
        }
        
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
        /*if ([touch.view isKindOfClass:[UIButton class]]) {
            return NO;
        }
        if ([touch.view isKindOfClass:[UITableViewCell class]]) {
            return NO;
        }
        if ([touch.view isKindOfClass:[UIScrollView class]]) {
            return YES;
        }*/
        return YES;
    }
    return NO;
}

//-------------------------------------------------
-(void)newpost:(NSString*)message {
    [MBProgressHUD showSuccess:@"你的信息已发送，请稍后下拉刷新查看！" toView:self.view];
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
                                        
                                        CircleModel* circle=_isSelectFriend ? _dataFriend[_curRow] : _data[_curRow];
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
                                        if (circle.postlist.count>4) {
                                            circle.postlist=[circle.postlist subarrayWithRange:NSMakeRange(0, 4)];
                                        }
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
                                        
                                        //[MBProgressHUD showError:@"回帖成功" toView:self.view];
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


//-------------------------------------------------------------
- (void)tapImageViewAction:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
    
    NSIndexPath* cellPath = [_tableView indexPathForCell:(UITableViewCell*)sender.view.superview.superview];
    _curRow=cellPath.row;
    CircleModel* circle=_isSelectFriend ? _dataFriend[_curRow] : _data[_curRow];
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
    CircleModel *circle=_isSelectFriend ? _dataFriend[_curRow] : _data[_curRow];
    return [circle.imglist count];
}

- (void)viewController:(PBViewController *)viewController presentImageView:(UIImageView *)imageView forPageAtIndex:(NSInteger)index progressHandler:(void (^)(NSInteger, NSInteger))progressHandler {
    CircleModel *circle=_isSelectFriend ? _dataFriend[_curRow] : _data[_curRow];
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


-(UIView*)createMenuView{
    UIView *viewBg=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 108+78)];
    [self.view addSubview:viewBg];
    
    UIButton* btnCancel=[[UIButton alloc]init];
    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    [btnCancel setTitleColor:[UIColor colorWithHexString:@"222222"] forState:UIControlStateNormal];
    btnCancel.titleLabel.font=[UIFont systemFontOfSize:18];
    [btnCancel addTarget:self action:@selector(actionSheetCancel:) forControlEvents:UIControlEventTouchUpInside];
    [viewBg addSubview:btnCancel];
    
    UIView *line=[[UIView alloc] init];
    line.backgroundColor=[UIColor colorWithWhite:0.8 alpha:0.4];
    [viewBg addSubview:line];
    
    UILabel* subtitle=[[UILabel alloc]init];
    subtitle.textColor=[UIColor colorWithHexString:@"999999"];
    subtitle.font=[UIFont systemFontOfSize:12];
    [viewBg addSubview:subtitle];
    
    UIButton* btnBlacklist=[[UIButton alloc]init];
    btnBlacklist.tag=10;
    [btnBlacklist setTitle:@"加入黑名单" forState:UIControlStateNormal];
    
    [btnBlacklist setTitleColor:[UIColor colorWithHexString:@"222222"] forState:UIControlStateNormal];
    btnBlacklist.titleLabel.font=[UIFont systemFontOfSize:18];
    [btnBlacklist addTarget:self action:@selector(actionSheetBlacklist:) forControlEvents:UIControlEventTouchUpInside];
    [viewBg addSubview:btnBlacklist];
    
    UIView *line2=[[UIView alloc] init];
    line2.backgroundColor=[UIColor colorWithWhite:0.8 alpha:0.4];
    [viewBg addSubview:line2];
    
    UIButton* btnReport=[[UIButton alloc]init];
    btnReport.tag=11;
    [btnReport setTitle:@"举报" forState:UIControlStateNormal];
    [btnReport setTitleColor:[UIColor colorWithHexString:@"222222"] forState:UIControlStateNormal];
    btnReport.titleLabel.font=[UIFont systemFontOfSize:18];
    [btnReport addTarget:self action:@selector(actionSheetReport:) forControlEvents:UIControlEventTouchUpInside];
    [viewBg addSubview:btnReport];
    
    //----------------------------------------
    [btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(viewBg);
        make.centerX.equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 64));
    }];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(btnCancel.mas_top);
        make.centerX.equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 6));
    }];
    
    [btnReport mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(btnCancel.mas_top).offset(-8);
        make.centerX.equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 54));
    }];
    
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(btnReport.mas_top);
        make.centerX.equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 1));
    }];
    
    [btnBlacklist mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(btnReport.mas_top);
        make.centerX.equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 60));
    }];
    return viewBg;
}

-(void)actionMore:(UIButton*)sender{
    if(![_app.user checkUserLogin:self]){
        return;
    }
    
    _indexPathSelect = [_tableView indexPathForCell:(UITableViewCell*)sender.superview.superview];
    _sheet = [[CjwSheetView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-Height_HomeIndicator)];
    [_sheet.contentView removeFromSuperview];
    [_sheet addContentView:[self createMenuView]];
    [_sheet showInView:[[UIApplication  sharedApplication ]keyWindow ]];
}

-(void)actionSheetCancel:(id)sender{
    [_sheet closeView];
}

-(void)actionSheetBlacklist:(UIButton*)sender{
    [_sheet closeView];
    CircleModel* circle=_isSelectFriend ? _dataFriend[_indexPathSelect.row] : _data[_indexPathSelect.row];
    NSString* title=[NSString stringWithFormat:@"是否将用户：%@，添加到黑名单？",circle.author];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:@"加入黑名单后，你们彼此的互动将受到限制：互相不能看到对方的动态，互相不能评论、点赞、打赏等功能。" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }])];
    __weak typeof(self) weakSelf = self;
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(_isSelectFriend){
            NSString *authorid=[NSString stringWithFormat:@"%ld",(long)circle.authorid];
            NSDictionary* dict=@{@"fuid":authorid};
            [_app.net request:weakSelf url:URL_follow_del param:dict callTag:1];
        }
        else{
            NSString *uid=[NSString stringWithFormat:@"%ld",(long)self->_app.user.uid];
            NSString *authorid=[NSString stringWithFormat:@"%ld",(long)circle.authorid];
            NSLog(@"authorid:%@",authorid);
            NSString *strArray=[self->_app.locationBlacklist objectForKey:uid];
            if ([[self->_app.locationBlacklist allKeys] containsObject:uid]){
                NSArray * array= [strArray componentsSeparatedByString:@","];
                Boolean bHave=NO;
                for (NSString * string in array) {
                    if ([string isEqualToString:authorid]) {
                        bHave=YES;
                        break;
                    }
                }
                if(bHave==NO){
                    NSMutableArray *mArray = [NSMutableArray arrayWithArray:array];
                    [mArray addObject:authorid];
                    strArray=[mArray componentsJoinedByString:@","];
                }
                NSLog(@"___:%@",strArray);
            }
            else{
                NSMutableArray * array = [[NSMutableArray alloc]initWithCapacity:10];
                [array addObject:authorid];
                strArray=[array componentsJoinedByString:@","];
                NSLog(@"__:%@",strArray);
            }
            [self->_app.locationBlacklist setObject:strArray forKey:uid];
            NSLog(@"%@",self->_app.locationBlacklist);
            
            [CjwFun putLocaionDict:kLocationBlanklist value:[self->_app.locationBlacklist copy]];
            
            if(_isSelectFriend){
                if(self->_indexPathSelect.row<_dataFriend.count){
                    [self->_dataFriend removeObjectAtIndex:self->_indexPathSelect.row];
                }
            }
            else{
                if(self->_indexPathSelect.row<_data.count){
                    [self->_data removeObjectAtIndex:self->_indexPathSelect.row];
                }
            }
            [_tableView reloadData];
            
//            [self->_tableView beginUpdates];
//            [_tableView deleteRowsAtIndexPaths:@[_indexPathSelect] withRowAnimation:UITableViewRowAnimationBottom];
//            [self->_tableView endUpdates];
        }
        
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)requestCallback:(id)response status:(id)status{
    NSLog(@"%@",response);
    if ([status[@"stat"] isEqual:@0]) {
        NSDictionary *dict = (NSDictionary *)response;
        
        if([status[@"tag"] isEqual:@1]){
            if([dict[@"code"] integerValue]==0){
               [self loadData:YES];
            }
        }
    }
    else{
        [_tableView.mj_footer endRefreshing];
        [_refeshFooter setTitle:@"网络连接失败" forState:MJRefreshStateIdle];
    }
}


-(void)actionSheetReport:(id)sender{
    [_sheet closeView];
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


/*dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // 耗时的操作
    dispatch_async(dispatch_get_main_queue(), ^{
        // 更新界面
    });
});
*/
