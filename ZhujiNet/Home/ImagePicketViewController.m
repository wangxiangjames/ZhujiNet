//
//  ImagePicketViewController.m
//  ZhujiNet
//
//  Created by zhujiribao on 2017/8/9.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import "ImagePicketViewController.h"
#import "TZImagePickerController.h"
#import "UIView+Layout.h"
#import "ImagePicketCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "LxGridViewFlowLayout.h"
#import "TZImageManager.h"
#import "TZVideoPlayerController.h"
#import "TZPhotoPreviewController.h"
#import "TZGifPhotoPreviewController.h"
#import "TZLocationManager.h"
#import "ArtMicroVideoViewController.h"
#import "CjwSheetView.h"
#import "Masonry.h"
#import "HexColor.h"
#import "Define.h"

@interface ImagePicketViewController ()<TZImagePickerControllerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate,UINavigationControllerDelegate,UITextViewDelegate> {
    CjwSheetView    *_sheet;
    UIView          *_navView;
    UIButton        *_navMenuItem;
    NSMutableArray  *_selectedPhotos;
    NSMutableArray  *_selectedAssets;
    BOOL            _isSelectOriginalPhoto;
    
    CGFloat _itemWH;
    CGFloat _margin;
    
    BOOL    _isInCellClick;         //是否内部选择图片按钮点击
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (strong, nonatomic) LxGridViewFlowLayout *layout;
@property (strong, nonatomic) CLLocation *location;
@property (nonatomic, strong) UIImagePickerController *imagePickerVc;

@property(nonatomic,strong)UILabel *titlePlaceHolderLabel;
@property(nonatomic,strong)UILabel *placeHolderLabel;
@property(nonatomic,strong)UILabel *residueLabel;// 输入文本时剩余字数
@property (nonatomic ,strong) NSMutableArray    *menuItemArray;             /** 栏目数组*/

@end

@implementation ImagePicketViewController

- (void)viewWillAppear:(BOOL)animated{
    if (self.type==ImagePicket_bbs || self.type==ImagePicket_shop || self.type==ImagePicket_reply) {
        self.navigationController.navigationBar.barTintColor=[UIColor colorWithWhite:0.2 alpha:1];
        [_navMenuItem setTitleEdgeInsets:UIEdgeInsetsMake(0, -25, 0, 25)];
        NSInteger len=_navMenuItemTitle.length==2?50:(_navMenuItemTitle.length==3?70:90);
        [_navMenuItem setImageEdgeInsets:UIEdgeInsetsMake(0,  len, 0, -len)];
    }
    if (self.type==ImagePicket_reply && self.textCont.length>0) {
        self.textView.text=self.textCont;
        self.placeHolderLabel.text=@"";
    }
}

-(void)viewDidAppear:(BOOL)animated{
    if(self.type==ImagePicket_shop){
        return;
    }
    
    if (self.type==ImagePicket_reply) {
        [self.textView becomeFirstResponder];
    }
    else{
        [_titleTextView becomeFirstResponder];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.type==ImagePicket_bbs) {
        _sheet = [[CjwSheetView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-Height_NavBar_HomeIndicator)];
    }
    else{
        _sheet = [[CjwSheetView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-Height_HomeIndicator)];
    }

    
    __weak typeof(self) weakSelf = self;
    _sheet.blockCloseViewAction=^(){
        if(_isInCellClick==NO){
            [weakSelf dismissViewControllerAnimated:NO completion:nil];
            [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
        }

    };

    _menuItemArray= [NSMutableArray array];
    
    _selectedPhotos = [NSMutableArray array];
    _selectedAssets = [NSMutableArray array];
    
    self.columnNumber=4;
    self.allowPickingImage=YES;
    [self configCollectionView];
    
    if(self.type==ImagePicket_selectMenu || self.type==ImagePicket_circle){
        self.collectionView.hidden=YES;
    }
    
    if (self.type==ImagePicket_circle) {
        [self createNavView];
        _navView.hidden=YES;
        
        self.collectionView.contentInset = UIEdgeInsetsMake(200, 0, 0, 0);
        //先创建个方便多行输入的textView
        self.textView =[ [UITextView alloc]initWithFrame:CGRectMake(10, -132, self.view.frame.size.width-20, 120)];
        self.textView.font=[UIFont systemFontOfSize:18];
        
        //[self.textView resignFirstResponder];
        //self.textView.backgroundColor=[UIColor lightGrayColor];
        self.textView.delegate = self;
        self.textView.tag=21;
        [self.collectionView addSubview :self.textView];
        
        //再创建个可以放置默认字的lable
        self.placeHolderLabel = [[UILabel alloc]initWithFrame:CGRectMake(6, 13, self.view.frame.size.width-12, 12)];
        self.placeHolderLabel.numberOfLines=0;
        self.placeHolderLabel.font=[UIFont systemFontOfSize:18];
        self.placeHolderLabel.text = @"分享新鲜事";
        self.placeHolderLabel.textColor= [UIColor colorWithWhite:0 alpha:0.3];
        self.placeHolderLabel.backgroundColor=[UIColor clearColor];
        [self.textView addSubview:self.placeHolderLabel];
    }
    
    if (self.type==ImagePicket_reply) {
        _isInCellClick=YES;
        [_sheet addContentView:[self createMenuView]];
        //[self createNavView];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        UIButton *btnRight =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
        [btnRight setTitle:@"发送" forState:normal];
        [btnRight setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [btnRight addTarget:self action:@selector(actionPublish:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
        self.navigationItem.rightBarButtonItem = rightButtonItem;
        
        self.collectionView.contentInset = UIEdgeInsetsMake(160, 0, 0, 0);
        //先创建个方便多行输入的textView
        self.textView =[ [UITextView alloc]initWithFrame:CGRectMake(10, -150, self.view.frame.size.width-20, 120)];
        self.textView.font=[UIFont systemFontOfSize:18];
        
        //[self.textView resignFirstResponder];
        //self.textView.backgroundColor=[UIColor lightGrayColor];
        self.textView.delegate = self;
        self.textView.tag=21;
        [self.collectionView addSubview :self.textView];
        
        //再创建个可以放置默认字的lable
        self.placeHolderLabel = [[UILabel alloc]initWithFrame:CGRectMake(6, 13, self.view.frame.size.width-12, 12)];
        self.placeHolderLabel.numberOfLines=0;
        self.placeHolderLabel.font=[UIFont systemFontOfSize:18];
        self.placeHolderLabel.text = @"输入回复内容";
        self.placeHolderLabel.textColor= [UIColor colorWithWhite:0 alpha:0.3];
        self.placeHolderLabel.backgroundColor=[UIColor clearColor];
        [self.textView addSubview:self.placeHolderLabel];
    }
    
    if(self.type==ImagePicket_bbs || self.type==ImagePicket_shop){
        
        if (self.type==ImagePicket_bbs) {
            _navMenuItem=[[UIButton alloc]init];
            [_navMenuItem setTitle:self.navMenuItemTitle forState:UIControlStateNormal];
            [_navMenuItem setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
            _navMenuItem.titleLabel.font = [UIFont systemFontOfSize:22];
            UIImage* image=[UIImage imageNamed:@"arrow_down_white"];
            [_navMenuItem setImage:image forState:UIControlStateNormal];
            
            [_navMenuItem addTarget:self action:@selector(actionMenuItem:) forControlEvents:UIControlEventTouchDown];
            _navMenuItem.frame=CGRectMake(0,0,200,44);
            self.navigationItem.titleView=_navMenuItem;
        }
        
        _isInCellClick=YES;
        [_sheet addContentView:[self createMenuView]];
        //[self createNavView];
    
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        UIButton *btnRight =[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 44, 44)];
        [btnRight setTitle:@"发送" forState:normal];
        [btnRight setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [btnRight addTarget:self action:@selector(actionPublish:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
        self.navigationItem.rightBarButtonItem = rightButtonItem;
        
        self.collectionView.contentInset = UIEdgeInsetsMake(163, 0, 0, 0);
        //先创建个方便多行输入的textView
        self.titleTextView =[ [UITextView alloc]initWithFrame:CGRectMake(10, -160, self.view.frame.size.width-20, 30)];
        self.titleTextView.font=[UIFont systemFontOfSize:18];
        self.titleTextView.delegate = self;
        self.titleTextView.tag=20;
        //[self.titleTextView resignFirstResponder];
        [self.collectionView addSubview :self.titleTextView];
        
        //再创建个可以放置默认字的lable
        self.titlePlaceHolderLabel = [[UILabel alloc]initWithFrame:CGRectMake(6, 13, self.view.frame.size.width-12, 12)];
        self.titlePlaceHolderLabel.numberOfLines=0;
        self.titlePlaceHolderLabel.font=[UIFont systemFontOfSize:18];
        self.titlePlaceHolderLabel.text = @"标题(必填)";
        self.titlePlaceHolderLabel.textColor= [UIColor colorWithWhite:0 alpha:0.3];
        self.titlePlaceHolderLabel.backgroundColor=[UIColor clearColor];
        [self.titleTextView addSubview:self.titlePlaceHolderLabel];
        
        UIView *line=[[UIView alloc]initWithFrame:CGRectMake(10, -120, self.view.frame.size.width-20, 1)];
        line.backgroundColor=[UIColor colorWithWhite:0.95 alpha:1];
        [self.collectionView addSubview :line];
        
        //先创建个方便多行输入的textView
        self.textView =[ [UITextView alloc]initWithFrame:CGRectMake(10, -117, self.view.frame.size.width-20, 116)];
        self.textView.font=[UIFont systemFontOfSize:18];
        
        //self.textView.backgroundColor=[UIColor lightGrayColor];
        self.textView.delegate = self;
        self.textView.tag=21;
        [self.collectionView addSubview :self.textView];
        
        //再创建个可以放置默认字的lable
        self.placeHolderLabel = [[UILabel alloc]initWithFrame:CGRectMake(6, 13, self.view.frame.size.width-12, 12)];
        self.placeHolderLabel.numberOfLines=0;
        self.placeHolderLabel.font=[UIFont systemFontOfSize:18];
        self.placeHolderLabel.text = @"输入内容";
        self.placeHolderLabel.textColor= [UIColor colorWithWhite:0 alpha:0.3];
        self.placeHolderLabel.backgroundColor=[UIColor clearColor];
        [self.textView addSubview:self.placeHolderLabel];
    }
    return;
}

-(void)setMenuItem:(NSString *)navMenuItemTitle{
    [_navMenuItem setTitle:navMenuItemTitle forState:UIControlStateNormal];
    self.navMenuItemTitle=navMenuItemTitle;
    [_navMenuItem setTitleEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 25)];
    [_navMenuItem setImageEdgeInsets:UIEdgeInsetsMake(0, 24*self.navMenuItemTitle.length, 0, -55)];
}

-(void)showSelectMenu{
    [_sheet.contentView removeFromSuperview];
    [_sheet addContentView:[self createMenuView]];
    [_sheet showInView:self.view];
}

-(void)createNavView{
    if(_navView==nil){
        _navView=[[UIView alloc] init];
        _navView.backgroundColor=[UIColor colorWithWhite:0.2 alpha:1];
        [self.view addSubview:_navView];
        
        UIButton* btnOk=[[UIButton alloc]init];
        [btnOk setTitle:@"发表" forState:UIControlStateNormal];
        [btnOk setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        btnOk.titleLabel.font=[UIFont systemFontOfSize:17];
        [btnOk addTarget:self action:@selector(actionPublish:) forControlEvents:UIControlEventTouchUpInside];
        [_navView addSubview:btnOk];
        
        UIButton* btnCancel=[[UIButton alloc]init];
        [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btnCancel.titleLabel.font=[UIFont systemFontOfSize:17];
        [btnCancel addTarget:self action:@selector(actionNavCancel:) forControlEvents:UIControlEventTouchUpInside];
        [_navView addSubview:btnCancel];
        
        [_navView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view);
            make.left.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 64));
        }];
        [btnCancel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_navView).offset(10);
            make.left.equalTo(_navView);
            make.size.mas_equalTo(CGSizeMake(80, 60));
        }];
        
        [btnOk mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_navView).offset(10);
            make.right.equalTo(_navView);
            make.size.mas_equalTo(CGSizeMake(80, 60));
        }];
        
        if(self.type==ImagePicket_bbs){
            UIButton *btn=[[UIButton alloc]init];
            [btn setTitle:@"" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithWhite:1 alpha:1] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont systemFontOfSize:22];
            [btn setImage:[UIImage imageNamed:@"arrow_down_white"] forState:UIControlStateNormal];
            [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -25, 0, 25)];
            NSInteger len=_navMenuItemTitle.length==2?50:(_navMenuItemTitle.length==3?70:90);
            [btn setImageEdgeInsets:UIEdgeInsetsMake(0,  len, 0, -len)];
            [btn addTarget:self action:@selector(actionMenuItem:) forControlEvents:UIControlEventTouchDown];
            [_navView addSubview:btn];
            
            [btn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(_navView).offset(10);
                make.centerX.equalTo(_navView);
                make.width.mas_greaterThanOrEqualTo(200);
            }];
        }
    }
}

-(UIView*)createMenuView{
    UIView *viewBg=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 108+78)];
    [self.view addSubview:viewBg];
    
    UIButton* btnCancel=[[UIButton alloc]init];
    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    [btnCancel setTitleColor:[UIColor colorWithHexString:@"222222"] forState:UIControlStateNormal];
    btnCancel.titleLabel.font=[UIFont systemFontOfSize:18];
    [btnCancel addTarget:self action:@selector(actionSelectMenu:) forControlEvents:UIControlEventTouchUpInside];
    [viewBg addSubview:btnCancel];
    
    UIView *line=[[UIView alloc] init];
    line.backgroundColor=[UIColor colorWithWhite:0.8 alpha:0.4];
    [viewBg addSubview:line];
    
    UILabel* subtitle=[[UILabel alloc]init];
    subtitle.textColor=[UIColor colorWithHexString:@"999999"];
    subtitle.font=[UIFont systemFontOfSize:12];
    [viewBg addSubview:subtitle];
    
    UIButton* btnPhoto=[[UIButton alloc]init];
    btnPhoto.tag=10;
    if (self.isOnlyTakePhoto) {
        [btnPhoto setTitle:@"拍照" forState:UIControlStateNormal];
    }
    else{
        subtitle.text=@"照片或视频";
        [btnPhoto setTitle:@"拍摄" forState:UIControlStateNormal];
    }

    [btnPhoto setTitleColor:[UIColor colorWithHexString:@"222222"] forState:UIControlStateNormal];
    btnPhoto.titleLabel.font=[UIFont systemFontOfSize:18];
    [btnPhoto addTarget:self action:@selector(actionSelectMenu:) forControlEvents:UIControlEventTouchUpInside];
    [viewBg addSubview:btnPhoto];
    
    UIView *line2=[[UIView alloc] init];
    line2.backgroundColor=[UIColor colorWithWhite:0.8 alpha:0.4];
    [viewBg addSubview:line2];
    
    UIButton* btnAlbum=[[UIButton alloc]init];
    btnAlbum.tag=11;
    [btnAlbum setTitle:@"从手机相册选择" forState:UIControlStateNormal];
    [btnAlbum setTitleColor:[UIColor colorWithHexString:@"222222"] forState:UIControlStateNormal];
    btnAlbum.titleLabel.font=[UIFont systemFontOfSize:18];
    [btnAlbum addTarget:self action:@selector(actionSelectMenu:) forControlEvents:UIControlEventTouchUpInside];
    [viewBg addSubview:btnAlbum];
    
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
    
    [btnAlbum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(btnCancel.mas_top).offset(-8);
        make.centerX.equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 54));
    }];
    
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(btnAlbum.mas_top);
        make.centerX.equalTo(viewBg);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 1));
    }];

    if (self.isOnlyTakePhoto) {
        [btnPhoto mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(btnAlbum.mas_top);
            make.centerX.equalTo(viewBg);
            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 60));
        }];
    }
    else{
        [btnPhoto mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(btnAlbum.mas_top).offset(-8);
            make.centerX.equalTo(viewBg);
            make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 60));
        }];
        
        [subtitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(btnPhoto.mas_bottom).offset(-1);
            make.centerX.equalTo(viewBg);
        }];
    }
    return viewBg;
}

-(void)actionSelectMenu:(id)sender{
    if ([sender tag]==10) {
        if (self.isOnlyTakePhoto) {
            [self takePhoto];
        }
        else{
            ArtMicroVideoViewController *art=[[ArtMicroVideoViewController alloc]init];
            art.savePhotoAlbum=YES;
            art.recordComplete=^(NSString * aVideoUrl,NSString *aThumUrl){
                PHFetchOptions *options = [[PHFetchOptions alloc]init];
                options.sortDescriptors=@[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
                PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:options];
                TZAssetModel *model = [TZAssetModel modelWithAsset:[assetsFetchResults firstObject]  type:TZAssetModelMediaTypeVideo timeLength:@""];
                //model.videoUrl=aVideoUrl;
                UIImage* image=[UIImage imageNamed:aThumUrl];
                [self refreshCollectionViewWithAddedAsset:model.asset image:image];
            };
            
            art.takePhotoComplete=^(UIImage *image){
                // save photo and get asset / 保存图片，获取到asset
                [[TZImageManager manager] savePhotoWithImage:image location:self.location completion:^(PHAsset *asset, NSError *error) {
                    if (error) {
                        NSLog(@"图片保存失败 %@",error);
                    }else {
                        [self refreshCollectionViewWithAddedAsset:asset image:image];

                    }
                }];
//                [[TZImageManager manager] savePhotoWithImage:image location:self.location completion:^(NSError *error){
//                    if (error) {
//                        NSLog(@"图片保存失败 %@",error);
//                    } else {
//                        [[TZImageManager manager] getCameraRollAlbum:NO allowPickingImage:YES completion:^(TZAlbumModel *model) {
//                            [[TZImageManager manager] getAssetsFromFetchResult:model.result allowPickingVideo:NO allowPickingImage:YES completion:^(NSArray<TZAssetModel *> *models) {
//                                TZAssetModel *assetModel = [models firstObject];
//                                [self refreshCollectionViewWithAddedAsset:assetModel.asset image:image];
//                            }];
//                        }];
//                    }
//                }];
            };
            [self presentViewController:art animated:YES completion:nil];
        }
    }
    else if([sender tag]==11){
        self.columnNumber=4;
        self.allowPickingImage=YES;
        [self pushTZImagePickerController];
    }
    else{
        [_sheet closeView];
    }
}

-(void)actionPublish:(id)sender{
    UIButton *btn=(UIButton*)sender;
    btn.enabled=NO;
    
    UIImage* coverImage=nil;
    
    NSInteger m=0;
    NSMutableArray *video=[NSMutableArray arrayWithCapacity:9];
    for (PHAsset *asset in _selectedAssets) {
        if(asset.mediaType==PHAssetMediaTypeVideo){
            [video addObject:asset];
            if (!coverImage) {
                coverImage=[_selectedPhotos[m] copy];
                [_selectedPhotos removeObjectAtIndex:m];
            }
        }
        m++;
    }
    if([video count]>0){
        [[TZImageManager manager] getVideoOutputPathWithAsset:video[0] completion:^(NSString *outputPath) {
            if(self.blockPublishAction){
                NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
                self.blockPublishAction(sender,_selectedPhotos,outputPath,[video count],coverImage);
                btn.enabled=YES;
            }
        }];
    }
    else{
        if(self.blockPublishAction){
            self.blockPublishAction(sender,_selectedPhotos,nil,0,coverImage);
            btn.enabled=YES;
        }
    }
}

-(void)actionNavCancel:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleLightContent];
}

-(void)textViewDidChange:(UITextView*)textView
{
    if (textView.tag==20) {
        if([_titleTextView.text length] == 0){
            self.titlePlaceHolderLabel.text = @"标题(必填)";
        }else{
            self.titlePlaceHolderLabel.text = @"";
        }
    }
    if (textView.tag==21) {
        if([textView.text length] == 0){
            if (self.type==ImagePicket_reply) {
                self.placeHolderLabel.text = @"输入回复内容";
            }
            else{
                self.placeHolderLabel.text = @"分享新鲜事";
            }
        }else{
            self.placeHolderLabel.text = @"";//这里给空
        }
    }
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (UIImagePickerController *)imagePickerVc {
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
        // set appearance / 改变相册选择页的导航栏外观
        _imagePickerVc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        _imagePickerVc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        UIBarButtonItem *tzBarItem, *BarItem;
        if (@available(iOS 9.0, *)) {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TZImagePickerController class]]];
            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        } else {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedIn:[TZImagePickerController class], nil];
            BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
        }
        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
    }
    return _imagePickerVc;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //NSInteger contentSizeH = 12 * 35 + 20;
    NSInteger contentSizeH = 0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //self.scrollView.contentSize = CGSizeMake(0, contentSizeH + 5);
    });
    
    _margin = 4;
    _itemWH = (self.view.tz_width -28) / 4 - _margin;
    _layout.itemSize = CGSizeMake(_itemWH, _itemWH);
    _layout.minimumInteritemSpacing = _margin;
    _layout.minimumLineSpacing = 1.5*_margin;
    _layout.sectionInset = UIEdgeInsetsMake(0, 14, 14, 14);
    //self.collectionView.backgroundColor=[UIColor darkGrayColor];
    [self.collectionView setCollectionViewLayout:_layout];
    self.collectionView.frame = CGRectMake(0, contentSizeH, self.view.tz_width, self.view.tz_height - contentSizeH);
    
    if (self.menuArray.count>0) {
        CGFloat padding=14;
        CGFloat btnHeight=36;
        CGFloat titleHeight=45;
        _layout.footerReferenceSize = CGSizeMake(self.view.tz_width, titleHeight+(1+self.menuArray.count/4)*(btnHeight+padding)+20);
    }
    else{
        _layout.footerReferenceSize = CGSizeMake(self.view.tz_width, 20);
    }
}

- (void)configCollectionView {
    // 如不需要长按排序效果，将LxGridViewFlowLayout类改成UICollectionViewFlowLayout即可
    _layout = [[LxGridViewFlowLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:_layout];
    CGFloat rgb = 255 / 255.0;
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.backgroundColor = [UIColor colorWithRed:rgb green:rgb blue:rgb alpha:1.0];
    _collectionView.contentInset = UIEdgeInsetsMake(4, 4, 4, 4);
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[ImagePicketCell class] forCellWithReuseIdentifier:@"ImagePicketCell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
}

#pragma mark UICollectionView

- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{

    UICollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
    
    if (self.menuArray.count>0){
        UILabel *title=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.tz_width, 45)];
        if (self.type==ImagePicket_shop) {
            title.text=@"   商品类型";
        }
        else{
            title.text=@"   热门话题";
        }

        title.textColor=[UIColor colorWithWhite:0.2 alpha:1];
        title.backgroundColor=[UIColor colorWithWhite:0.95 alpha:1];
        [footerView addSubview:title];
        
        CGFloat padding=14;
        CGFloat btnWidth=76;
        CGFloat btnHeight=36;
        CGFloat btnSapce=((self.view.tz_width-2*padding)-4*btnWidth)/3;
        for (int i=0; i<self.menuArray.count; i++) {
            UIButton *btn=[[UIButton alloc]init];
            [btn setTitle:self.menuArray[i] forState:UIControlStateNormal];
            if(i==self.nSelectMenuItem){
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                btn.backgroundColor=[UIColor colorWithHexString:@"FF8070"];
            }
            else{
                [btn setTitleColor:[UIColor colorWithHexString:@"FF8070"] forState:UIControlStateNormal];
            }

            btn.titleLabel.font = [UIFont systemFontOfSize:16];
            btn.layer.borderColor=[UIColor colorWithHexString:@"FF8070"].CGColor;
            btn.layer.borderWidth=1;
            btn.layer.cornerRadius=5;
            btn.tag=i;
            [btn addTarget:self action:@selector(actionMenuItem:) forControlEvents:UIControlEventTouchDown];
            btn.frame=CGRectMake(padding+(i%4)*(btnWidth+btnSapce), title.tz_bottom+padding+(i/4)*(btnHeight+padding), btnWidth, btnHeight);
            [footerView addSubview:btn];
            [_menuItemArray addObject:btn];
        }
        UIView* line=[[UIView alloc]initWithFrame:CGRectMake(0, title.tz_bottom+padding+(self.menuArray.count/4)*(btnHeight+padding)+btnHeight+14, self.view.tz_width,14)];
        line.backgroundColor=[UIColor colorWithWhite:0.95 alpha:1];
        [footerView addSubview:line];
    }
    else{
        UIView* line=[[UIView alloc]initWithFrame:CGRectMake(0, 14, self.view.tz_width,14)];
        line.backgroundColor=[UIColor colorWithWhite:0.95 alpha:1];
        [footerView addSubview:line];
    }

    return footerView;
}

-(void)actionMenuItem:(id)sender{
    //UIButton *oldBtn = (UIButton *)[self.view viewWithTag:self.nSelectMenuItem];
    for (UIButton* btn in _menuItemArray) {
        [btn setTitleColor:[UIColor colorWithHexString:@"FF8070"] forState:UIControlStateNormal];
        btn.backgroundColor=[UIColor whiteColor];
    }
    if (self.type==ImagePicket_circle || self.type==ImagePicket_shop) {
        UIButton* btn=(UIButton*)sender;
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.backgroundColor=[UIColor colorWithHexString:@"FF8070"];
    }

    if(self.blockMenuItemClickAction){
        self.blockMenuItemClickAction(sender);
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.maxImagesCount==_selectedPhotos.count) {
        return _selectedPhotos.count;
    }
    return _selectedPhotos.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImagePicketCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImagePicketCell" forIndexPath:indexPath];
    cell.videoImageView.hidden = YES;
    if (indexPath.row == _selectedPhotos.count) {
        cell.imageView.image = [UIImage imageNamed:@"photo_btnAdd"];
        cell.deleteBtn.hidden = YES;
        cell.gifLable.hidden = YES;
    } else {
        cell.imageView.image = _selectedPhotos[indexPath.row];
        cell.asset = _selectedAssets[indexPath.row];
        cell.deleteBtn.hidden = NO;
    }
    if (!self.allowPickingGif) {
        cell.gifLable.hidden = YES;
    }
    cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(deleteBtnClik:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.titleTextView resignFirstResponder];
    [self.textView resignFirstResponder];
    
    if (indexPath.row == _selectedPhotos.count) {
        BOOL showSheet = self.showSheet;
        if (showSheet) {
            [_sheet showInView:self.view];
            
            /*UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"录制视频",@"去相册选择", nil];
            [sheet showInView:self.view];*/
        } else {
            [self pushTZImagePickerController];
        }
    } else { // preview photos or video / 预览照片或者视频
        id asset = _selectedAssets[indexPath.row];
        BOOL isVideo = NO;
        if ([asset isKindOfClass:[PHAsset class]]) {
            PHAsset *phAsset = asset;
            isVideo = phAsset.mediaType == PHAssetMediaTypeVideo;
        } else if ([asset isKindOfClass:[ALAsset class]]) {
            ALAsset *alAsset = asset;
            isVideo = [[alAsset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo];
        }
        if ([[asset valueForKey:@"filename"] containsString:@"GIF"] && self.allowPickingGif && !self.allowPickingMuitlpleVideo) {
            TZGifPhotoPreviewController *vc = [[TZGifPhotoPreviewController alloc] init];
            TZAssetModel *model = [TZAssetModel modelWithAsset:asset type:TZAssetModelMediaTypePhotoGif timeLength:@""];
            vc.model = model;
            [self presentViewController:vc animated:YES completion:nil];
        } else if (isVideo && !self.allowPickingMuitlpleVideo) { // perview video / 预览视频
            /*TZVideoPlayerController *vc = [[TZVideoPlayerController alloc] init];
            if ([_selectedAssetModel[indexPath.row] isKindOfClass:[TZAssetModel class]]) {
                TZAssetModel *model=_selectedAssetModel[indexPath.row];
                vc.videoUrl=model.videoUrl;
                vc.model = model;
            }
            else{
                TZAssetModel *model = [TZAssetModel modelWithAsset:asset type:TZAssetModelMediaTypeVideo timeLength:@""];
                vc.model = model;
            }*/
            
            TZVideoPlayerController *vc = [[TZVideoPlayerController alloc] init];
            TZAssetModel *model = [TZAssetModel modelWithAsset:asset type:TZAssetModelMediaTypeVideo timeLength:@""];
            vc.model = model;
            [self presentViewController:vc animated:YES completion:nil];
        } else { // preview photos / 预览照片
            TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithSelectedAssets:_selectedAssets selectedPhotos:_selectedPhotos index:indexPath.row];
            imagePickerVc.maxImagesCount = self.maxImagesCount;
            imagePickerVc.allowPickingGif = self.allowPickingGif;
            imagePickerVc.allowPickingOriginalPhoto = self.allowPickingOriginalPhoto;
            imagePickerVc.allowPickingMultipleVideo = self.allowPickingMuitlpleVideo;
            imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
            [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
                //_selectedAssetModel=[NSMutableArray arrayWithArray:assets];
                _selectedPhotos = [NSMutableArray arrayWithArray:photos];
                _selectedAssets = [NSMutableArray arrayWithArray:assets];
                _isSelectOriginalPhoto = isSelectOriginalPhoto;
                [_collectionView reloadData];
                _collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
            }];
            [self presentViewController:imagePickerVc animated:YES completion:nil];
        }
    }
}

#pragma mark - LxGridViewDataSource

/// 以下三个方法为长按排序相关代码
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.item < _selectedPhotos.count;
}

- (BOOL)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)sourceIndexPath canMoveToIndexPath:(NSIndexPath *)destinationIndexPath {
    return (sourceIndexPath.item < _selectedPhotos.count && destinationIndexPath.item < _selectedPhotos.count);
}

- (void)collectionView:(UICollectionView *)collectionView itemAtIndexPath:(NSIndexPath *)sourceIndexPath didMoveToIndexPath:(NSIndexPath *)destinationIndexPath {
    UIImage *image = _selectedPhotos[sourceIndexPath.item];
    [_selectedPhotos removeObjectAtIndex:sourceIndexPath.item];
    [_selectedPhotos insertObject:image atIndex:destinationIndexPath.item];
    
    id asset = _selectedAssets[sourceIndexPath.item];
    [_selectedAssets removeObjectAtIndex:sourceIndexPath.item];
    [_selectedAssets insertObject:asset atIndex:destinationIndexPath.item];
    
    [_collectionView reloadData];
}

#pragma mark - TZImagePickerController

- (void)pushTZImagePickerController {
    if (self.maxImagesCount <= 0) {
        return;
    }
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:self.maxImagesCount columnNumber:self.columnNumber delegate:self pushPhotoPickerVc:YES];
    // imagePickerVc.navigationBar.translucent = NO;
    
#pragma mark - 五类个性化设置，这些参数都可以不传，此时会走默认设置
    imagePickerVc.isSelectOriginalPhoto = _isSelectOriginalPhoto;
    
    if (self.maxImagesCount> 1) {
        // 1.设置目前已经选中的图片数组
        imagePickerVc.selectedAssets = _selectedAssets; // 目前已经选中的图片数组
    }
    imagePickerVc.allowTakePicture = self.showTakePhotoBtn; // 在内部显示拍照按钮
    
    // imagePickerVc.photoWidth = 1000;
    
    // 2. Set the appearance
    // 2. 在这里设置imagePickerVc的外观
    // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    // imagePickerVc.navigationBar.translucent = NO;
    
    // 3. Set allow picking video & photo & originalPhoto or not
    // 3. 设置是否可以选择视频/图片/原图
    imagePickerVc.allowPickingVideo = self.allowPickingVideo;
    imagePickerVc.allowPickingImage = self.allowPickingImage;
    imagePickerVc.allowPickingOriginalPhoto = self.allowPickingOriginalPhoto;
    imagePickerVc.allowPickingGif = self.allowPickingGif;
    imagePickerVc.allowPickingMultipleVideo = self.allowPickingMuitlpleVideo; // 是否可以多选视频
    
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = self.sortAscending;
    
    // imagePickerVc.minImagesCount = 3;
    // imagePickerVc.alwaysEnableDoneBtn = YES;
    
    // imagePickerVc.minPhotoWidthSelectable = 3000;
    // imagePickerVc.minPhotoHeightSelectable = 2000;
    
    /// 5. Single selection mode, valid when maxImagesCount = 1
    /// 5. 单选模式,maxImagesCount为1时才生效
    imagePickerVc.showSelectBtn = NO;
    imagePickerVc.allowCrop = self.allowCrop;
    imagePickerVc.needCircleCrop = self.needCircleCrop;
    // 设置竖屏下的裁剪尺寸
    NSInteger left = 30;
    NSInteger widthHeight = self.view.tz_width - 2 * left;
    NSInteger top = (self.view.tz_height - widthHeight) / 2;
    imagePickerVc.cropRect = CGRectMake(left, top, widthHeight, widthHeight);
    // 设置横屏下的裁剪尺寸
    // imagePickerVc.cropRectLandscape = CGRectMake((self.view.tz_height - widthHeight) / 2, left, widthHeight, widthHeight);
    /*
     [imagePickerVc setCropViewSettingBlock:^(UIView *cropView) {
     cropView.layer.borderColor = [UIColor redColor].CGColor;
     cropView.layer.borderWidth = 2.0;
     }];*/
    
    //imagePickerVc.allowPreview = NO;
    
    imagePickerVc.isStatusBarDefault = NO;
#pragma mark - 到这里为止
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
    }];
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark - UIImagePickerController

- (void)takePhoto {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if ((authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) && @available(iOS 7.0, *)) {
        // 无相机权限 做一个友好的提示
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法使用相机" message:@"请在iPhone的""设置-隐私-相机""中允许访问相机" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        [alert show];
    } else if (authStatus == AVAuthorizationStatusNotDetermined) {
        // fix issue 466, 防止用户首次拍照拒绝授权时相机页黑屏
        if (@available(iOS 7.0, *)) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self takePhoto];
                    });
                }
            }];
        } else {
            [self takePhoto];
        }
        // 拍照之前还需要检查相册权限
    } else if ([PHPhotoLibrary authorizationStatus] == 2) { // 已被拒绝，没有相册权限，将无法保存拍的照片
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"无法访问相册" message:@"请在iPhone的""设置-隐私-相册""中允许访问相册" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"设置", nil];
        alert.tag = 1;
        [alert show];
    } else if ([PHPhotoLibrary authorizationStatus] == 0) { // 未请求过相册权限
        [[TZImageManager manager] requestAuthorizationWithCompletion:^{
            [self takePhoto];
        }];
    } else {
        [self pushImagePickerController];
    }
}

// 调用相机
- (void)pushImagePickerController {
    // 提前定位
    __weak typeof(self) weakSelf = self;
    [[TZLocationManager manager] startLocationWithSuccessBlock:^(NSArray<CLLocation *> *locations) {
        weakSelf.location = locations[0];
    } failureBlock:^(NSError *error) {
        weakSelf.location = nil;
    }];
    
//    [[TZLocationManager manager] startLocationWithSuccessBlock:^(CLLocation *location, CLLocation *oldLocation) {
//        weakSelf.location = location;
//    } failureBlock:^(NSError *error) {
//        weakSelf.location = nil;
//    }];
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
        self.imagePickerVc.sourceType = sourceType;
        if(@available(iOS 8, *)) {
            _imagePickerVc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }
        [self presentViewController:_imagePickerVc animated:YES completion:nil];
    } else {
        NSLog(@"模拟器中无法打开照相机,请在真机中使用");
        
    }
    
}

- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        TZImagePickerController *tzImagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
        tzImagePickerVc.sortAscendingByModificationDate = self.sortAscending;
        [tzImagePickerVc showProgressHUD];
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        // save photo and get asset / 保存图片，获取到asset
        [[TZImageManager manager] savePhotoWithImage:image location:self.location completion:^(PHAsset *asset, NSError *error) {
            if (error) {
                [tzImagePickerVc hideProgressHUD];
                NSLog(@"图片保存失败 %@",error);
            } else {
                if (self.allowCrop) { // 允许裁剪,去裁剪
                    TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initCropTypeWithAsset:asset photo:image completion:^(UIImage *cropImage, id asset) {
                        [self refreshCollectionViewWithAddedAsset:asset image:cropImage];
                    }];
                    imagePicker.needCircleCrop = self.needCircleCrop;
                    imagePicker.circleCropRadius = 100;
                    [self presentViewController:imagePicker animated:YES completion:nil];
                } else {
                    [self refreshCollectionViewWithAddedAsset:asset image:image];
                }
            }
        }];
//        [[TZImageManager manager] savePhotoWithImage:image location:self.location completion:^(NSError *error){
//            if (error) {
//                [tzImagePickerVc hideProgressHUD];
//                NSLog(@"图片保存失败 %@",error);
//            } else {
//                [[TZImageManager manager] getCameraRollAlbum:NO allowPickingImage:YES completion:^(TZAlbumModel *model) {
//                    [[TZImageManager manager] getAssetsFromFetchResult:model.result allowPickingVideo:NO allowPickingImage:YES completion:^(NSArray<TZAssetModel *> *models) {
//                        [tzImagePickerVc hideProgressHUD];
//                        TZAssetModel *assetModel = [models firstObject];
//                        if (tzImagePickerVc.sortAscendingByModificationDate) {
//                            assetModel = [models lastObject];
//                        }
//                        if (self.allowCrop) { // 允许裁剪,去裁剪
//                            TZImagePickerController *imagePicker = [[TZImagePickerController alloc] initCropTypeWithAsset:assetModel.asset photo:image completion:^(UIImage *cropImage, id asset) {
//                                [self refreshCollectionViewWithAddedAsset:assetModel.asset image:cropImage];
//                            }];
//                            imagePicker.needCircleCrop = self.needCircleCrop;
//                            imagePicker.circleCropRadius = 100;
//                            [self presentViewController:imagePicker animated:YES completion:nil];
//                        } else {
//                            [self refreshCollectionViewWithAddedAsset:assetModel.asset image:image];
//                        }
//                    }];
//                }];
//            }
//        }];
    }
}

- (void)refreshCollectionViewWithAddedAsset:(id)asset image:(UIImage *)image {
    [_selectedAssets addObject:asset];
    [_selectedPhotos addObject:image];
    [_collectionView reloadData];
    
    if ([asset isKindOfClass:[PHAsset class]]) {
        PHAsset *phAsset = asset;
        NSLog(@"location:%@",phAsset.location);
    }
    if (self.type==ImagePicket_selectMenu) {
        [_sheet closeView];
        NSLog(@"拍照后关闭");
        if(self.blockSelectedPhotoAction){
            self.blockSelectedPhotoAction(_selectedPhotos,_selectedAssets);
        }
    }
    else{
        _isInCellClick=YES;
        _navView.hidden=NO;
        self.collectionView.hidden=NO;
        [_sheet closeViewNoBlock];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if ([picker isKindOfClass:[UIImagePickerController class]]) {
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) { // take photo / 去拍照
        [self takePhoto];
    } else if (buttonIndex == 1) {
        
        ArtMicroVideoViewController *art=[[ArtMicroVideoViewController alloc]init];
        art.savePhotoAlbum=YES;
        art.recordComplete=^(NSString * aVideoUrl,NSString *aThumUrl){
            NSLog(@"%@,%@",aVideoUrl,aThumUrl);
            
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
            PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:options];
            /*for(NSInteger i = 0; i < assetsFetchResults.count; i++) {
             PHAsset *asset = assetsFetchResults[i];
             NSLog(@"%@",asset);
             }*/
            
            /*TZVideoPlayerController *vc = [[TZVideoPlayerController alloc] init];
             TZAssetModel *model = [TZAssetModel modelWithAsset:assetsFetchResults[0] type:TZAssetModelMediaTypeVideo timeLength:@""];
             vc.model = model;
             [self presentViewController:vc animated:YES completion:nil];
             */
            
            TZAssetModel *model = [TZAssetModel modelWithAsset:[assetsFetchResults lastObject]  type:TZAssetModelMediaTypeVideo timeLength:@""];
            UIImage* image=[UIImage imageNamed:aThumUrl];
            [self refreshCollectionViewWithAddedAsset:model.asset image:image];
            
        };
        [self presentViewController:art animated:YES completion:nil];
        //[self.navigationController pushViewController:art animated:TRUE];
    }
    else if(buttonIndex==2){
        [self pushTZImagePickerController];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) { // 去设置界面，开启相机访问权限
//        if (iOS8Later) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
//        } else {
//            NSURL *privacyUrl;
//            if (alertView.tag == 1) {
//                privacyUrl = [NSURL URLWithString:@"prefs:root=Privacy&path=PHOTOS"];
//            } else {
//                privacyUrl = [NSURL URLWithString:@"prefs:root=Privacy&path=CAMERA"];
//            }
//            if ([[UIApplication sharedApplication] canOpenURL:privacyUrl]) {
//                [[UIApplication sharedApplication] openURL:privacyUrl];
//            } else {
//                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"抱歉" message:@"无法跳转到隐私设置页面，请手动前往设置页面，谢谢" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//                [alert show];
//            }
//        }
    }
}

#pragma mark - TZImagePickerControllerDelegate

/// User click cancel button
/// 用户点击了取消
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    // NSLog(@"cancel");
}

// The picker should dismiss itself; when it dismissed these handle will be called.
// If isOriginalPhoto is YES, user picked the original photo.
// You can get original photo with asset, by the method [[TZImageManager manager] getOriginalPhotoWithAsset:completion:].
// The UIImage Object in photos default width is 828px, you can set it by photoWidth property.
// 这个照片选择器会自己dismiss，当选择器dismiss的时候，会执行下面的代理方法
// 如果isSelectOriginalPhoto为YES，表明用户选择了原图
// 你可以通过一个asset获得原图，通过这个方法：[[TZImageManager manager] getOriginalPhotoWithAsset:completion:]
// photos数组里的UIImage对象，默认是828像素宽，你可以通过设置photoWidth属性的值来改变它
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    _isSelectOriginalPhoto = isSelectOriginalPhoto;
    [_collectionView reloadData];
    // _collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
    
    // 1.打印图片名字
    [self printAssetsName:assets];
    // 2.图片位置信息
    if (@available(iOS 8, *)) {
        for (PHAsset *phAsset in assets) {
            NSLog(@"location:%@",phAsset.location);
        }
    }
    
    if (self.type==ImagePicket_selectMenu) {
        [_sheet closeView];
         NSLog(@"选择照片后关闭 %@",_selectedPhotos[0]);
        if(self.blockSelectedPhotoAction){
            self.blockSelectedPhotoAction(_selectedPhotos,_selectedAssets);
        }
    }
    else{
        _isInCellClick=YES;
        _navView.hidden=NO;
        self.collectionView.hidden=NO;
        [_sheet closeViewNoBlock];
    }
}

// If user picking a video, this callback will be called.
// If system version > iOS8,asset is kind of PHAsset class, else is ALAsset class.
// 如果用户选择了一个视频，下面的handle会被执行
// 如果系统版本大于iOS8，asset是PHAsset类的对象，否则是ALAsset类的对象
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    _selectedPhotos = [NSMutableArray arrayWithArray:@[coverImage]];
    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
    // open this code to send video / 打开这段代码发送视频
    // [[TZImageManager manager] getVideoOutputPathWithAsset:asset completion:^(NSString *outputPath) {
    // NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
    // Export completed, send video here, send by outputPath or NSData
    // 导出完成，在这里写上传代码，通过路径或者通过NSData上传
    
    // }];
    //-------------------
    _isInCellClick=YES;
    _navView.hidden=NO;
    self.collectionView.hidden=NO;
    [_sheet closeViewNoBlock];
    //-------------------
    [_collectionView reloadData];
    // _collectionView.contentSize = CGSizeMake(0, ((_selectedPhotos.count + 2) / 3 ) * (_margin + _itemWH));
}

// If user picking a gif image, this callback will be called.
// 如果用户选择了一个gif图片，下面的handle会被执行
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(id)asset {
    _selectedPhotos = [NSMutableArray arrayWithArray:@[animatedImage]];
    _selectedAssets = [NSMutableArray arrayWithArray:@[asset]];
    [_collectionView reloadData];
}

// Decide album show or not't
// 决定相册显示与否
- (BOOL)isAlbumCanSelect:(NSString *)albumName result:(id)result {
    /*
     if ([albumName isEqualToString:@"个人收藏"]) {
     return NO;
     }
     if ([albumName isEqualToString:@"视频"]) {
     return NO;
     }*/
    return YES;
}

// Decide asset show or not't
// 决定asset显示与否
- (BOOL)isAssetCanSelect:(id)asset {
    /*
     if (iOS8Later) {
     PHAsset *phAsset = asset;
     switch (phAsset.mediaType) {
     case PHAssetMediaTypeVideo: {
     // 视频时长
     // NSTimeInterval duration = phAsset.duration;
     return NO;
     } break;
     case PHAssetMediaTypeImage: {
     // 图片尺寸
     if (phAsset.pixelWidth > 3000 || phAsset.pixelHeight > 3000) {
     // return NO;
     }
     return YES;
     } break;
     case PHAssetMediaTypeAudio:
     return NO;
     break;
     case PHAssetMediaTypeUnknown:
     return NO;
     break;
     default: break;
     }
     } else {
     ALAsset *alAsset = asset;
     NSString *alAssetType = [[alAsset valueForProperty:ALAssetPropertyType] stringValue];
     if ([alAssetType isEqualToString:ALAssetTypeVideo]) {
     // 视频时长
     // NSTimeInterval duration = [[alAsset valueForProperty:ALAssetPropertyDuration] doubleValue];
     return NO;
     } else if ([alAssetType isEqualToString:ALAssetTypePhoto]) {
     // 图片尺寸
     CGSize imageSize = alAsset.defaultRepresentation.dimensions;
     if (imageSize.width > 3000) {
     // return NO;
     }
     return YES;
     } else if ([alAssetType isEqualToString:ALAssetTypeUnknown]) {
     return NO;
     }
     }*/
    return YES;
}

#pragma mark - Click Event

- (void)deleteBtnClik:(UIButton *)sender {
    [_collectionView performBatchUpdates:^{
        if (self.maxImagesCount!=_selectedPhotos.count) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:sender.tag inSection:0];
            [_collectionView deleteItemsAtIndexPaths:@[indexPath]];
        }

        [_selectedPhotos removeObjectAtIndex:sender.tag];
        [_selectedAssets removeObjectAtIndex:sender.tag];
    } completion:^(BOOL finished) {
        [_collectionView reloadData];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - Private

/// 打印图片名字
- (void)printAssetsName:(NSArray *)assets {
    NSString *fileName;
    for (id asset in assets) {
        if ([asset isKindOfClass:[PHAsset class]]) {
            PHAsset *phAsset = (PHAsset *)asset;
            fileName = [phAsset valueForKey:@"filename"];
        } else if ([asset isKindOfClass:[ALAsset class]]) {
            ALAsset *alAsset = (ALAsset *)asset;
            fileName = alAsset.defaultRepresentation.filename;;
        }
        // NSLog(@"图片名字:%@",fileName);
    }
}

#pragma clang diagnostic pop


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
