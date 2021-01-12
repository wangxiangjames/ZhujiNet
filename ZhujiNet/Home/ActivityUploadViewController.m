//
//  ActivityUploadViewController.m
//  ZhujiNet
//
//  Created by zhujiribao on 2019/1/18.
//  Copyright © 2019 zhujiribao. All rights reserved.
//

#import "ActivityUploadViewController.h"
#import "TZImagePickerController.h"
#import "LxGridViewFlowLayout.h"
#import "ImagePicketCell.h"
#import "UIView+Layout.h"
#import "Masonry.h"
#import "HexColor.h"
#import "AppDelegate.h"
#import "TZImageManager.h"

@interface ActivityUploadViewController ()<TZImagePickerControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate>{
    CGFloat         _itemWH;
    CGFloat         _margin;
    NSInteger       _curSection;
    NSMutableArray  *_selectedPhotos;
    NSMutableArray  *_selectedAssets;
    NSMutableArray  *_selectedPhotos1;
    NSMutableArray  *_selectedAssets1;
    NSMutableArray  *_selectedPhotos2;
    NSMutableArray  *_selectedAssets2;
    NSString        *_videoPath;
    NSInteger       _section;
    NSInteger       _section1;
    NSInteger       _section2;
}
@property (assign, nonatomic) NSUInteger            maxImagesCount;
@property (nonatomic, strong) UICollectionView      *collectionView;
@property (strong, nonatomic) LxGridViewFlowLayout  *layout;
@end

@implementation ActivityUploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _selectedPhotos = [NSMutableArray array];
    _selectedAssets = [NSMutableArray array];
    _selectedPhotos1 = [NSMutableArray array];
    _selectedAssets1 = [NSMutableArray array];
    _selectedPhotos2 = [NSMutableArray array];
    _selectedAssets2 = [NSMutableArray array];
    [self configCollectionView];
    
    UIButton *btnPublish=[[UIButton alloc]initWithFrame:CGRectMake(0,5, 45,35)];
    [btnPublish setTitle:@"发布"forState:UIControlStateNormal];
    [btnPublish setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnPublish setTitleColor:[UIColor orangeColor]forState:UIControlStateHighlighted];
    [btnPublish addTarget:self action:@selector(actionPublish:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rigth = [[UIBarButtonItem alloc]initWithCustomView:btnPublish];
    self.navigationItem.rightBarButtonItem = rigth;
    _section=0;
    _section1=0;
    _section2=0;
    for (int i = 0; i<[self.attach length]; i++) {
        NSString *s = [self.attach substringWithRange:NSMakeRange(i, 1)];
        if ([s isEqualToString:@"1"]) {
            if(i==0){
                _section=1;
            }
            if(i==1){
                _section1=1;
            }
            if(i==2){
                _section2=1;
            }
        }
    }
    NSLog(@"%d,%d,%d",_section,_section1,_section2);
}

- (void)actionPublish:(id)sender
{
    if(_section==1 && _selectedPhotos.count==0){
        [MBProgressHUD showError:@"您还未选择封面图！"];
        return;
    }
    
    /*if(_section1==1 && _selectedPhotos1.count==0){
        [MBProgressHUD showError:@"您还未选择展示图！"];
        return;
    }
    
    if(_section2==1 && _selectedPhotos2.count==0){
        [MBProgressHUD showError:@"您还未选择视频！"];
        return;
    }*/
    
    [MBProgressHUD showMessage:@"请稍候"];
    AppDelegate* _app = [AppDelegate getApp];
    NSDictionary *dict=@{@"auid":self.auid};
    [_app.net upload:@"http://tp.zhuji.net/index/json/upload_activity" param:dict
        constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if (_selectedPhotos.count>0) {
                NSLog(@"CHINA");
                NSData *data = UIImageJPEGRepresentation(_selectedPhotos[0], 0.8);       //将UIImage转为NSData，1.0表示不压缩图片质量。
                [formData appendPartWithFileData:data name:@"cover" fileName:@"test.png" mimeType:@"image/png"];
            }
            
            for (int i=0; i<self->_selectedPhotos1.count; i++) {
                NSLog(@"CHINA1");
                NSData *data = UIImageJPEGRepresentation(self->_selectedPhotos1[i], 0.8);
                [formData appendPartWithFileData:data name:[NSString stringWithFormat:@"image[%d]",i] fileName:@"test.png" mimeType:@"image/png"];
            }
            
            if (_selectedPhotos2.count>0 && _videoPath!=nil) {
                NSLog(@"CHINA2");
                NSData *data = UIImageJPEGRepresentation(_selectedPhotos2[0], 0.8);
                [formData appendPartWithFileData:data name:@"poster" fileName:@"test.png" mimeType:@"image/png"];
                [formData appendPartWithFileURL:[NSURL fileURLWithPath:_videoPath] name:@"mp4" error:nil];
            }
        }
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"请求成功（图片）%@",responseObject);
            [MBProgressHUD hideHUD];
            [MBProgressHUD showSuccess:@"上传成功"];
            int index = (int)[[self.navigationController viewControllers]indexOfObject:self];
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:(index -2)] animated:YES];
        }
        failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"请求失败（图片）——%@",error);
            [MBProgressHUD hideHUD];
            [MBProgressHUD showSuccess:@"上传失败"];
        }];
}

- (void)viewDidLayoutSubviews {
    _margin = 4;
    _itemWH = (self.view.tz_width -28) / 4 - _margin;
}

- (void)configCollectionView {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 10, self.view.tz_width, self.view.tz_height-64) collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerClass:[ImagePicketCell class] forCellWithReuseIdentifier:@"MyCollectionViewCell"];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MyCollectionViewHeaderView"];
//    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"MyCollectionViewFooterView"];
    [self.view addSubview:_collectionView];
}

#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return _section+_section1+_section2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if ((section==1 && _section==1 && _section1==1) || (section==0 && _section==0 && _section1==1)){
        if(_selectedPhotos1.count<=9){
            return _selectedPhotos1.count+1;
        }
        return _selectedPhotos1.count;
    }
    return 1;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ImagePicketCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MyCollectionViewCell" forIndexPath:indexPath];
    cell.videoImageView.hidden = YES;
    if (indexPath.section==0 && _section==1) {
        if (_selectedPhotos.count== 0) {
            cell.imageView.image = [UIImage imageNamed:@"photo_btnAdd"];
            cell.deleteBtn.hidden = YES;
            cell.gifLable.hidden = YES;
        }
        else{
            cell.imageView.image = _selectedPhotos[indexPath.row];
            cell.asset = _selectedAssets[indexPath.row];
            cell.deleteBtn.hidden = NO;
        }
        cell.deleteBtn.tag =1000+indexPath.row;
    }
    
    if ((indexPath.section==1 && _section==1 && _section1==1) || (indexPath.section==0 && _section==0 && _section1==1)) {
        if (indexPath.row == _selectedPhotos1.count) {
            cell.imageView.image = [UIImage imageNamed:@"photo_btnAdd"];
            cell.deleteBtn.hidden = YES;
            cell.gifLable.hidden = YES;
        }
        else{
            cell.imageView.image = _selectedPhotos1[indexPath.row];
            cell.asset = _selectedAssets1[indexPath.row];
            cell.deleteBtn.hidden = NO;
        }
        cell.deleteBtn.tag =2000+indexPath.row;
    }
    
    if ((indexPath.section==2 && _section==1 && _section1==1 && _section2==1) ||
        (indexPath.section==1 && _section==0 && _section1==1 &&  _section2==1)  ||
        (indexPath.section==1 && _section==1 && _section1==0 &&  _section2==1) ||
        (indexPath.section==0 && _section==0 && _section1==0 &&  _section2==1)) {
        if (_selectedPhotos2.count==0) {
            cell.imageView.image = [UIImage imageNamed:@"photo_btnAdd"];
            cell.deleteBtn.hidden = YES;
            cell.gifLable.hidden = YES;
        }
        else{
            cell.imageView.image = _selectedPhotos2[indexPath.row];
            cell.asset = _selectedAssets2[indexPath.row];
            cell.deleteBtn.hidden = NO;
        }
        cell.deleteBtn.tag =3000+indexPath.row;
    }

//    if (!self.allowPickingGif) {
//        cell.gifLable.hidden = YES;
//    }
    
    //cell.deleteBtn.tag =1000*indexPath.section+indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(deleteBtnClik:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (kind == UICollectionElementKindSectionHeader){
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"MyCollectionViewHeaderView" forIndexPath:indexPath];
        headerView.backgroundColor = [UIColor colorWithHexString:@"eaeaea"];
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 200, 50)];
        NSString *title=@"封面图";
        
        if ((indexPath.section==1 && _section==1 && _section1==1) || (indexPath.section==0 && _section==0 && _section1==1)) {
            title=@"展示图";
        }
        
        if ((indexPath.section==2 && _section==1 && _section1==1 && _section2==1) ||
            (indexPath.section==1 && _section==0 && _section1==1 &&  _section2==1)  ||
            (indexPath.section==1 && _section==1 && _section1==0 &&  _section2==1) ||
            (indexPath.section==0 && _section==0 && _section1==0 &&  _section2==1)) {
            title=@"视频";
        }
        
        titleLabel.text =title;
        titleLabel.backgroundColor=[UIColor colorWithHexString:@"eaeaea"];
        [headerView addSubview:titleLabel];
        return headerView;
    }
//    else if(kind == UICollectionElementKindSectionFooter){
//        UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"MyCollectionViewFooterView" forIndexPath:indexPath];
//        footerView.backgroundColor = [UIColor blueColor];
//        UILabel *titleLabel = [[UILabel alloc]initWithFrame:footerView.bounds];
//        titleLabel.text = [NSString stringWithFormat:@"第%ld个分区的区尾",indexPath.section];
//        [footerView addSubview:titleLabel];
//        return footerView;
//    }
    return nil;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"点击了第%ld分item",(long)indexPath.item);
    NSInteger imgnum=1;
    if ((indexPath.section==1 && _section==1 && _section1==1) || (indexPath.section==0 && _section==0 && _section1==1)) {
        imgnum=9;
    }

    //TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithSelectedAssets:_selectedAssets selectedPhotos:_selectedPhotos index:indexPath.row];
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:imgnum delegate:self];
    if ((indexPath.section==2 && _section==1 && _section1==1 && _section2==1) ||
        (indexPath.section==1 && _section==0 && _section1==1 &&  _section2==1)  ||
        (indexPath.section==1 && _section==1 && _section1==0 &&  _section2==1) ||
        (indexPath.section==0 && _section==0 && _section1==0 &&  _section2==1)) {
        
        imagePickerVc.allowPickingMultipleVideo = YES;
        imagePickerVc.allowPickingImage = NO;
    }
    else{
        imagePickerVc.allowPickingVideo=NO;
        imagePickerVc.allowPickingMultipleVideo = NO;
        imagePickerVc.allowPickingImage = YES;
    }
    
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto){
    if (indexPath.section==0 && _section==1) {
            self->_selectedPhotos = [NSMutableArray arrayWithArray:photos];
            self->_selectedAssets = [NSMutableArray arrayWithArray:assets];
            self->_collectionView.contentSize = CGSizeMake(0, ((self->_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
        }
        if ((indexPath.section==1 && _section==1 && _section1==1) || (indexPath.section==0 && _section==0 && _section1==1)) {
            self->_selectedPhotos1 = [NSMutableArray arrayWithArray:photos];
            self->_selectedAssets1 = [NSMutableArray arrayWithArray:assets];
            self->_collectionView.contentSize = CGSizeMake(0, ((self->_selectedPhotos1.count + 2) / 3 ) * (_margin + _itemWH));
        }
        if ((indexPath.section==2 && _section==1 && _section1==1 && _section2==1) ||
            (indexPath.section==1 && _section==0 && _section1==1 &&  _section2==1)  ||
            (indexPath.section==1 && _section==1 && _section1==0 &&  _section2==1) ||
            (indexPath.section==0 && _section==0 && _section1==0 &&  _section2==1)) {
            self->_selectedPhotos2 = [NSMutableArray arrayWithArray:photos];
            self->_selectedAssets2 = [NSMutableArray arrayWithArray:assets];
            self->_collectionView.contentSize = CGSizeMake(0, ((self->_selectedPhotos2.count + 2) / 3 ) * (_margin + _itemWH));
        }
        [self->_collectionView reloadData];
    }];
    _curSection=indexPath.section;
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger width=(self.view.tz_width-25)/4;
    return CGSizeMake(width, width);
}

//每个分区的内边距（上左下右）
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

//分区内cell之间的最小行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}

//分区内cell之间的最小列间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 5;
}

//区头大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(770, 50);
}

//区尾大小
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
//    return CGSizeMake(770, 65);
//}

//- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
//    ImagePicketCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImagePicketCell" forIndexPath:indexPath];
//    cell.videoImageView.hidden = YES;
//    if (indexPath.row == _selectedPhotos.count) {
//        cell.imageView.image = [UIImage imageNamed:@"photo_btnAdd"];
//        cell.deleteBtn.hidden = YES;
//        cell.gifLable.hidden = YES;
//    } else {
//        cell.imageView.image = _selectedPhotos[indexPath.row];
//        cell.asset = _selectedAssets[indexPath.row];
//        cell.deleteBtn.hidden = NO;
//    }
//    NSLog(@"ccccc");
//    cell.deleteBtn.tag = indexPath.row;
//    [cell.deleteBtn addTarget:self action:@selector(deleteBtnClik:) forControlEvents:UIControlEventTouchUpInside];
//    return cell;
//}
//
////定义每个UICollectionView 的大小
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return CGSizeMake(96, 100);
//}
//
//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//
//}

#pragma mark - LxGridViewDataSource

/// 以下三个方法为长按排序相关代码
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section==1){
        return indexPath.item < _selectedPhotos1.count;
    }
    else{
        return NO;
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)sourceIndexPath canMoveToIndexPath:(NSIndexPath *)destinationIndexPath {
    if(sourceIndexPath.section==1){
        return (sourceIndexPath.item < _selectedPhotos1.count && destinationIndexPath.item < _selectedPhotos1.count);
    }
    else{
        return NO;
    }
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)sourceIndexPath didMoveToIndexPath:(NSIndexPath *)destinationIndexPath {
    if(_curSection==0){
        UIImage *image = _selectedPhotos1[sourceIndexPath.item];
        [_selectedPhotos removeObjectAtIndex:sourceIndexPath.item];
        [_selectedPhotos insertObject:image atIndex:destinationIndexPath.item];
        
        id asset = _selectedAssets[sourceIndexPath.item];
        [_selectedAssets removeObjectAtIndex:sourceIndexPath.item];
        [_selectedAssets insertObject:asset atIndex:destinationIndexPath.item];
    }
    if(_curSection==1){
        UIImage *image = _selectedPhotos1[sourceIndexPath.item];
        [_selectedPhotos1 removeObjectAtIndex:sourceIndexPath.item];
        [_selectedPhotos1 insertObject:image atIndex:destinationIndexPath.item];
        
        id asset = _selectedAssets1[sourceIndexPath.item];
        [_selectedAssets1 removeObjectAtIndex:sourceIndexPath.item];
        [_selectedAssets1 insertObject:asset atIndex:destinationIndexPath.item];
    }
    if(_curSection==2){
        UIImage *image = _selectedPhotos2[sourceIndexPath.item];
        [_selectedPhotos2 removeObjectAtIndex:sourceIndexPath.item];
        [_selectedPhotos2 insertObject:image atIndex:destinationIndexPath.item];
        
        id asset = _selectedAssets2[sourceIndexPath.item];
        [_selectedAssets2 removeObjectAtIndex:sourceIndexPath.item];
        [_selectedAssets2 insertObject:asset atIndex:destinationIndexPath.item];
    }
    [_collectionView reloadData];
}

#pragma mark - Click Event
- (void)deleteBtnClik:(UIButton *)sender {
    [_collectionView performBatchUpdates:^{
        NSInteger n=sender.tag/1000;
        NSInteger m=sender.tag%1000;
        
        if (n==1) {
            [_selectedPhotos removeAllObjects];
            [_selectedAssets removeAllObjects];
        }
        
        if (n==2) {
            if (self.maxImagesCount!=_selectedPhotos1.count) {
                NSInteger tempSection=0;
                if(_section==1){
                    tempSection=1;
                }
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:m inSection:tempSection];
                [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
            }
            
            [_selectedPhotos1 removeObjectAtIndex:m];
            [_selectedAssets1 removeObjectAtIndex:m];
        }
        
        if (n==3) {
            [_selectedPhotos2 removeObjectAtIndex:m];
            [_selectedAssets2 removeObjectAtIndex:m];
        }
        
    } completion:^(BOOL finished) {
        [_collectionView reloadData];
    }];
}

#pragma mark - TZImagePickerControllerDelegate
/// 用户点击了取消
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    NSLog(@"cancel");
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    NSLog(@"ok");
    if(_curSection==0 && _section==1){
        _selectedPhotos = [NSMutableArray arrayWithArray:photos];
        _selectedAssets = [NSMutableArray arrayWithArray:assets];
    }
    if ((_curSection==1 && _section==1 && _section1==1) || (_curSection==0 && _section==0 && _section1==1)) {
        _selectedPhotos1 = [NSMutableArray arrayWithArray:photos];
        _selectedAssets1 = [NSMutableArray arrayWithArray:assets];
    }
    if ((_curSection==2 && _section==1 && _section1==1 && _section2==1) ||
        (_curSection==1 && _section==0 && _section1==1 &&  _section2==1)  ||
        (_curSection==1 && _section==1 && _section1==0 &&  _section2==1) ||
        (_curSection==0 && _section==0 && _section1==0 &&  _section2==1)) {
        _selectedPhotos2 = [NSMutableArray arrayWithArray:photos];
        _selectedAssets2 = [NSMutableArray arrayWithArray:assets];
        NSLog(@"cjw2");
        
        NSMutableArray *video=[NSMutableArray arrayWithCapacity:1];
        for (PHAsset *asset in _selectedAssets2) {
            if(asset.mediaType==PHAssetMediaTypeVideo){
                [video addObject:asset];
            }
        }
        if([video count]>0){
            [[TZImageManager manager] getVideoOutputPathWithAsset:video[0] completion:^(NSString *outputPath) {
                NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
                self->_videoPath=[NSString stringWithFormat:@"%@",outputPath];
            }];
        }
    }
    [_collectionView reloadData];
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
