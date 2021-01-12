//
//  BBSMenuViewController.m
//  ZhujiNet
//
//  Created by chenjinwei on 17/6/11.
//  Copyright © 2017年 zhuji.net. All rights reserved.
//

#import "BBSMenuViewController.h"
#import "Common.h"
#import "ForumViewController.h"
#import "ImagePicketViewController.h"
#import "BbsForumModel.h"

#define kCellIdentifier_Left @"LeftTableViewCell"
#define kCellIdentifier_Right @"RightTableViewCell"

@interface BBSMenuViewController ()<UITableViewDelegate, UITableViewDataSource>{
    AppDelegate                 *_app;
    UITableView                 *_leftTableView;
    UITableView                 *_rightTableView;
    CjwCell                     *_cjwCell;
    NSMutableArray              *_leftData;
    NSMutableArray              *_rightData;
    NSUInteger                  _selctLeftRow;
    NSMutableArray              *_arrayShoucangMenu;
    NSInteger                   _btnTagBase;
}

@end

@implementation BBSMenuViewController

- (void)viewWillAppear:(BOOL)animated{
    _app = [AppDelegate getApp];
    [_app.skin setSkin:self];
    self.navigationItem.title = self.navTitle;
    
    NSIndexPath * selIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    [_leftTableView selectRowAtIndexPath:selIndex animated:YES scrollPosition:UITableViewScrollPositionTop];
    [self tableView:_leftTableView didSelectRowAtIndexPath:selIndex];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigation];
    
    _app = [AppDelegate getApp];
    
    [self.view addSubview:self.leftTableView];
    [self.view addSubview:self.rightTableView];

    _arrayShoucangMenu=[ForumSubModel mj_objectArrayWithKeyValuesArray:[CjwFun getLocaionDict:kBbsForumMenu]];
    if (_arrayShoucangMenu==nil) {
        _arrayShoucangMenu=[NSMutableArray arrayWithCapacity:20];
    }
    
    _btnTagBase=20000;
    _cjwCell=[[CjwCell alloc]init];
    _selctLeftRow=0;
    _leftData = [NSMutableArray arrayWithCapacity:20];
    _rightData = [NSMutableArray arrayWithCapacity:20];
    [self loadData];
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

- (void)loadData{
    [_leftData removeAllObjects];
    [_rightData removeAllObjects];
    for (BbsForumModel *item in self.arrayBbsForum) {
        if ([item.name isEqualToString:@"固定"]) {
            continue;
        }
        CjwItem *cjwItem=[[CjwItem alloc]init];
        cjwItem.type=cell_type_menu_bbs_left;
        cjwItem.title=item.name;
        [_leftData addObject:cjwItem];
        
        id sublist=item.sublist;
        if ([item.name isEqualToString:@"收藏"]) {
            sublist=_arrayShoucangMenu;
        }
        NSMutableArray   *temp=[NSMutableArray arrayWithCapacity:20];
        for (ForumSubModel* sub in sublist) {
            CjwItem *cjwItem=[[CjwItem alloc]init];
            cjwItem.type=cell_type_menu_bbs_right;
            cjwItem.title=sub.name;
            cjwItem.url_pic0=sub.image;
            cjwItem.tid=sub.fid;
            
            if ([item.name isEqualToString:@"收藏"]) {
                cjwItem.isReplies=YES;
            }
            else{
                cjwItem.isReplies=NO;
                for (ForumSubModel *sc in _arrayShoucangMenu) {
                    if([sc.fid isEqualToString:sub.fid]){
                        cjwItem.isReplies=YES;
                    }
                }
            }
            [temp addObject:cjwItem];
        }
        [_rightData addObject:temp];
    }
    [_rightTableView reloadData];
    
    NSArray *array = [ForumSubModel mj_keyValuesArrayWithObjectArray:_arrayShoucangMenu];
    [CjwFun putLocaionDict:kBbsForumMenu value:array];
}

- (UITableView *)leftTableView
{
    if (!_leftTableView)
    {
        _leftTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 90, SCREEN_HEIGHT-Height_NavBar)];
        _leftTableView.delegate = self;
        _leftTableView.dataSource = self;
        //_leftTableView.rowHeight = 55;
        _leftTableView.tableFooterView = [UIView new];
        _leftTableView.showsVerticalScrollIndicator = NO;
        _leftTableView.separatorColor = [UIColor clearColor];
        _leftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_leftTableView registerClass:[CjwCell class] forCellReuseIdentifier:kCellIdentifier_Left];
    }
    return _leftTableView;
}

- (UITableView *)rightTableView
{
    if (!_rightTableView)
    {
        _rightTableView = [[UITableView alloc] initWithFrame:CGRectMake(90, 0, SCREEN_WIDTH - 90, SCREEN_HEIGHT - Height_NavBar)];
        _rightTableView.delegate = self;
        _rightTableView.dataSource = self;
        _rightTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _rightTableView.separatorColor =_app.skin.colorCellSeparator;
        //_rightTableView.rowHeight = 80;
        _rightTableView.showsVerticalScrollIndicator = NO;
        [_rightTableView registerClass:[CjwCell class] forCellReuseIdentifier:kCellIdentifier_Right];
    }
    return _rightTableView;
}

#pragma mark - TableView DataSource Delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_leftTableView == tableView)
    {
        CjwItem *item=_leftData[indexPath.row];
        CjwCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Left forIndexPath:indexPath];
        cell.item=item;
        return cell;
    }
    else
    {
        CjwItem *item=_rightData[_selctLeftRow][indexPath.row];
        static NSString  *identifier = @"kCellIdentifier_Right";
        CjwCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil){
            cell = [[CjwCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            if(self.isHaveAddButton){
                UIButton* btn=[[UIButton alloc]init];
                btn.alpha=_app.skin.floatImgAlpha;
                btn.layer.cornerRadius = 5.0;
                btn.titleLabel.font = [UIFont systemFontOfSize: 14.0];
                btn.layer.borderColor = [UIColor colorWithHexString:@"ffffff"].CGColor;
                [btn setTitleColor:[UIColor whiteColor]forState:UIControlStateNormal];
                btn.layer.borderWidth = 0.8f;
                //btn.frame=CGRectMake(cell.contentView.bounds.size.width-85,20,70, 30);
                btn.frame=CGRectMake(SCREEN_WIDTH-80-90,19,60, 28);
                [btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
                btn.tag = indexPath.row+_btnTagBase;
                [cell.contentView addSubview:btn];
            }
        }
        UIButton* btn = (UIButton*)[cell.contentView viewWithTag:indexPath.row+_btnTagBase];
        if (item.isReplies==NO) {
            [btn setTitle:@"+ 加入" forState:UIControlStateNormal];
            btn.backgroundColor=_app.skin.colorMainLight;
        }
        else{
            [btn setTitle:@"取消" forState:UIControlStateNormal];
            btn.backgroundColor=[UIColor colorWithHexString:@"999999"];
        }
        
        cell.item=item;
        return cell;
    }
}

- (void)buttonClicked:(UIButton *)sender{
    NSLog(@"buttonClicked:%ld",(long)sender.tag);
    CjwItem *item=_rightData[_selctLeftRow][(long)sender.tag-_btnTagBase];
    if (item.isReplies==NO) {
        for (int i=0;i<[_arrayBbsForum count];i++) {
            BbsForumModel* bbsForum=_arrayBbsForum[i];
            for (int m=0;m<[bbsForum.sublist count];m++) {
                ForumSubModel* sub=bbsForum.sublist[m];
                if ([sub.fid isEqualToString:item.tid]) {
                    [_arrayShoucangMenu insertObject:sub atIndex:0];
                    [self loadData];
                    return;
                }
            }
        }
    }
    else{
        for (int i=0;i<[_arrayShoucangMenu count];i++) {
            ForumSubModel* sub=_arrayShoucangMenu[i];
            if ([sub.fid isEqualToString:item.tid]) {
                [_arrayShoucangMenu removeObjectAtIndex:i];
                break;
            }
        }
    }
    
    [self loadData];
}

#pragma mark 设置每行高度（每行高度可以不一样）
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_leftTableView == tableView)
    {
        _cjwCell.item=_leftData[indexPath.row];
    }
    else
    {
        _cjwCell.item=_rightData[_selctLeftRow][indexPath.row];
    }
    return _cjwCell.height;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_leftTableView == tableView)
    {
        return [_leftData count];
    }
    else
    {
        return [_rightData[_selctLeftRow] count];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{

    if (_leftTableView == tableView)
    {
        _selctLeftRow=indexPath.row;
        [_rightTableView reloadData];
    }
    else{
        CjwItem *cjwItem=_rightData[_selctLeftRow][indexPath.row];
        if(self.pushController){
            if ([self.pushController isMemberOfClass:[ImagePicketViewController class]]) {
                ImagePicketViewController* imagePicket=(ImagePicketViewController*)self.pushController;
                imagePicket.fid=[cjwItem.tid integerValue];
                [imagePicket setMenuItem:cjwItem.title];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            ForumViewController *forum=[[ForumViewController alloc]init];
            forum.imgPicketType=ImagePicket_bbs;
            forum.navTitle=cjwItem.title;
            forum.fid=[cjwItem.tid intValue];
            [self.navigationController pushViewController:forum animated:TRUE];
        }
    }
}

-(void)tableView:(UITableView* )tableView willDisplayCell:(UITableViewCell* )cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_leftTableView == tableView)
    {

    }
    else{
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 85, 0, 0)];
        [cell setLayoutMargins:UIEdgeInsetsZero];
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
