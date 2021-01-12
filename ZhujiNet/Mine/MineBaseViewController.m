//
//  MineViewController.m
//  ZhujiNet
//
//  Created by chenjinwei on 17/6/19.
//  Copyright © 2017年 zhuji.net. All rights reserved.
//

#import "MineBaseViewController.h"
#import "Common.h"
#import "ImagePicketViewController.h"
#import "CjwAlertView.h"
#import "RadioButton.h"
#import "SelectDataController.h"
#import "ResetPasswordController.h"
#import "SDImageCache.h"
#import "UpdatePhoneController.h"

@interface MineBaseViewController ()<UITableViewDelegate,UITableViewDataSource>{
    AppDelegate                 *_app;
    CjwItem                     *_cjwItem;          //加载的单项数据
    CjwCell                     *_cjwCell;
    UITableView                 *_tableView;
    UIView                      *_footerView;
    NSMutableArray              *_data;
    CGFloat                     _cellHeaderHeight;
    NSArray                     *_subTitle;
    NSString                    *_selectStr;
}

@end

@implementation MineBaseViewController

- (void)viewWillAppear:(BOOL)animated{
    _app = [AppDelegate getApp];
    [_app.skin setSkin:self];
    self.title = @"基本资料";
    [self updateData];
    [_tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavigation];
    
    _app = [AppDelegate getApp];

    _data = [NSMutableArray arrayWithCapacity:8];
    [self updateData];
    
    [self addTableView];
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

-(void)updateData{
    [_data removeAllObjects];
    NSArray *title = @[@"头像",@"用户名",@"手机",@"性别",@"生日",@"区域",@"个性签名",@"我的密码"];
    NSString *sightml=[_app.user.sightml isEqualToString:@""] ? @"暂无个性签名":_app.user.sightml;
    _subTitle = @[@"",_app.user.username,_app.user.mobile,_app.user.gender,_app.user.birth,_app.user.area,sightml,@"修改密码"];
    for(int i=0;i<[title count];i++){
        CjwItem *cjwItem=[[CjwItem alloc]init];
        cjwItem.title=title[i];
        cjwItem.subtitle=_subTitle[i];
        if(i==0){
            cjwItem.url_pic0=_app.user.avatar;
            cjwItem.type=cell_type_mine_base_pic;
        }
        else{
            cjwItem.type=cell_type_mine_base_text;
        }
        [_data addObject:cjwItem];
    }
}

-(void)addTableView{
    _cjwCell=[[CjwCell alloc]init];
    
    CGRect rect=CGRectMake(0, 0, self.view.frame.size.width,  self.view.frame.size.height - Height_NavBar);
    _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.backgroundColor=_app.skin.colorTableBg;
    _tableView.separatorColor =_app.skin.colorCellSeparator;
    [self.view addSubview:_tableView];
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
    CjwItem *item=_data[indexPath.row];
    static NSString  *identifier = @"identifierCell";
    CjwCell *cell = [_tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil){
        cell = [[CjwCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    if (indexPath.row!=1) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    cell.item=item;
    return cell;
}

#pragma mark 设置每行高度（每行高度可以不一样）
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    _cjwCell.item=_data[indexPath.row];
    if(indexPath.row==3 || indexPath.row==6)
    {
        return _cjwCell.height+_app.skin.floatSeparatorSpaceHeight;
    }
    return _cjwCell.height;
}

-(void)tableView:(UITableView* )tableView willDisplayCell:(UITableViewCell* )cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==3 || indexPath.row==6|| indexPath.row==7){
        cell.separatorInset=UIEdgeInsetsMake(0, cell.bounds.size.width/2, 0, cell.bounds.size.width/2);
        //[cell setLayoutMargins:UIEdgeInsetsZero];
    }
    else{
        cell.separatorInset=UIEdgeInsetsMake(0, 15, 0, 15);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SelectDataController *selectData = [[SelectDataController alloc] init];
    selectData.modalPresentationStyle = UIModalPresentationOverFullScreen;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
        {
            /*ImagePicketViewController *imagePicket=[[ImagePicketViewController alloc]init];
            imagePicket.isOnlyPhoto=YES;
            imagePicket.showTakePhotoBtn=YES;
            imagePicket.navRightTitle=@"更新头像";
            [self.navigationController pushViewController:imagePicket animated:TRUE];*/
            
            ImagePicketViewController *imagePicket = [[ImagePicketViewController alloc] init];
            imagePicket.type=ImagePicket_selectMenu;
            imagePicket.isOnlyTakePhoto=YES;
            imagePicket.maxImagesCount=1;
            imagePicket.allowCrop=YES;
            imagePicket.modalPresentationStyle = UIModalPresentationOverFullScreen;
            [self presentViewController:imagePicket animated:NO completion:^{[imagePicket showSelectMenu];}];
            [imagePicket setBlockSelectedPhotoAction:^(NSMutableArray  *photos,NSMutableArray  *assets){
                if (photos.count>0) {
                        [MBProgressHUD showMessage:@"请稍候"];
                        [_app.net upload:@"http://bbs.zhuji.net/zjapp/json/upload_avatar" param:nil
                        constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                        UIImage *image = photos[0];
                        NSData *data = UIImageJPEGRepresentation(image, 1.0);//将UIImage转为NSData，1.0表示不压缩图片质量。
                        [formData appendPartWithFileData:data name:@"Filedata" fileName:@"test.png" mimeType:@"image/png"];
                    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        [[SDImageCache sharedImageCache] removeImageForKey:_app.user.avatar withCompletion:nil];
                        [_tableView reloadData];
                        NSLog(@"获取用户名称请求成功（图片）%@",responseObject);
                        [MBProgressHUD hideHUD];
               
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"获取用户名称请求失败（图片）——%@",error);
                        [MBProgressHUD hideHUD];
                    }];
                }
            }];
            
        }

            break;
            
        case 2:
        {
            UpdatePhoneController* updatePhone=[UpdatePhoneController new];
            [self.navigationController pushViewController:updatePhone animated:TRUE];
            
        }
            break;
            
        case 3:
        {
            selectData.inputData=_subTitle[indexPath.row];
            selectData.type=select_data_sex;
            [selectData setBlockResultAction:^(NSString *szResult){
                NSLog(@"actionResult:%@",szResult);
                _selectStr=szResult;
                [MBProgressHUD showMessage:@"请稍候"];
                NSString *gender=[szResult isEqualToString:@"男"]?@"1":@"2";
                NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"gender",@"type",gender,@"gender", nil];
                [_app.net request:self url:URL_userinfo_update param:paramDic callTag:3];
            }];
            [self presentViewController:selectData animated:NO completion:nil];
            
        }
            break;
        case 4:
        {
            if ([_subTitle[indexPath.row] isEqualToString:@""]) {
                NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"YYYY-MM-dd"];
                selectData.inputData=[dateFormatter stringFromDate:[NSDate date]];
            }
            else{
                selectData.inputData=_subTitle[indexPath.row];
            }
            
            selectData.type=select_data_date;
            [selectData setBlockResultAction:^(NSString *szResult){
                NSLog(@"actionResult:%@",szResult);
                _selectStr=szResult;
                [MBProgressHUD showMessage:@"请稍候"];
                NSArray *array = [szResult componentsSeparatedByString:@"-"];
                NSString *birthyear=array[0];
                NSString *birthmonth=array[1];
                NSString *birthday=array[2];
                NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"birth",@"type",birthyear,@"birthyear",birthmonth,@"birthmonth",birthday,@"birthday",nil];
                [_app.net request:self url:URL_userinfo_update param:paramDic callTag:4];
            }];
            [self presentViewController:selectData animated:NO completion:nil];
        }
            break;
        case 5:
        {
            selectData.inputData=_subTitle[indexPath.row];
            selectData.type=select_data_area;
            [selectData setBlockResultAction:^(NSString *szResult){
                NSLog(@"actionResult:%@",szResult);
                _selectStr=szResult;
                [MBProgressHUD showMessage:@"请稍候"];
                NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"area",@"type",szResult,@"area", nil];
                [_app.net request:self url:URL_userinfo_update param:paramDic callTag:5];
            }];
            [self presentViewController:selectData animated:NO completion:nil];
            
        }
            break;
        case 6:
        {
            if ([_subTitle[indexPath.row] isEqualToString:@"暂无个性签名"]) {
                selectData.inputData=@"";
            }
            else{
                selectData.inputData=_subTitle[indexPath.row];
            }
            selectData.type=select_data_sign;
            [selectData setBlockResultAction:^(NSString *szResult){
                NSLog(@"actionResult:%@",szResult);
                _selectStr=szResult;
                if (![szResult isEqualToString:@""]) {
                    [MBProgressHUD showMessage:@"请稍候"];
                    NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"sightml",@"type",szResult,@"sightml", nil];
                    [_app.net request:self url:URL_userinfo_update param:paramDic callTag:6];
                }
            }];
            [self presentViewController:selectData animated:YES completion:nil];
        }
            break;

        case 7:
        {
            ResetPasswordController *resetPass=[[ResetPasswordController alloc]init];
            [self.navigationController pushViewController:resetPass animated:TRUE];
        }
            break;
            
        default:
            break;
    }
}


- (void)requestCallback:(id)response status:(id)status{

    if ([status[@"stat"] isEqual:@0]) {
        
        if([status[@"tag"] isEqual:@3]){
            NSDictionary *dict = (NSDictionary *)response;
            if([dict[@"code"] intValue]==0){
                _app.user.gender=_selectStr;
                [self updateData];
                [_tableView reloadData];
            }
        }
        
        if([status[@"tag"] isEqual:@4]){
            NSDictionary *dict = (NSDictionary *)response;
            if([dict[@"code"] intValue]==0){
                _app.user.birth=_selectStr;
                [self updateData];
                [_tableView reloadData];
            }
        }
        
        if([status[@"tag"] isEqual:@5]){
            NSDictionary *dict = (NSDictionary *)response;
            if([dict[@"code"] intValue]==0){
                _app.user.area=_selectStr;
                [self updateData];
                [_tableView reloadData];
            }
        }
        
        if([status[@"tag"] isEqual:@6]){
            NSDictionary *dict = (NSDictionary *)response;
            if([dict[@"code"] intValue]==0){
                [MBProgressHUD showSuccess:@"个性签名已修改"];
                _app.user.sightml=_selectStr;
                [self updateData];
                [_tableView reloadData];
            }
        }
        
        [MBProgressHUD hideHUD];
        
    }
    else{
        NSLog(@"网络失败");
    }
    
}

//--------------------------------------------------------

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
