//
//  ImagePicketViewController.h
//  ZhujiNet
//
//  Created by zhujiribao on 2017/8/9.
//  Copyright © 2017年 zhujiribao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ImagePicket_type)
{
    //以下是枚举成员
    ImagePicket_selectMenu = 1,                     //菜单选择
    ImagePicket_bbs = 2,                            //论坛图片选择
    ImagePicket_circle = 3,                         //诸暨圈选择
    ImagePicket_shop = 4 ,                          //商圈选择
    ImagePicket_reply = 5                           //回复选择
};

@interface ImagePicketViewController : UIViewController

@property (nonatomic,assign)  ImagePicket_type  type;
@property (assign, nonatomic) BOOL              allowPickingGif ;
@property (assign, nonatomic) BOOL              showSheet;
@property (assign, nonatomic) BOOL              allowPickingMuitlpleVideo;
@property (assign, nonatomic) BOOL              allowPickingOriginalPhoto;
@property (assign, nonatomic) BOOL              showTakePhotoBtn;
@property (assign, nonatomic) BOOL              allowPickingVideo;
@property (assign, nonatomic) BOOL              allowPickingImage;
@property (assign, nonatomic) BOOL              sortAscending;
@property (assign, nonatomic) BOOL              allowCrop;
@property (assign, nonatomic) BOOL              needCircleCrop;
@property (assign, nonatomic) NSUInteger        maxImagesCount;
@property (assign, nonatomic) NSUInteger        columnNumber;
@property (assign, nonatomic) BOOL              isOnlyPhoto;
@property (copy, nonatomic) NSString            *navMenuItemTitle;
@property (assign, nonatomic) NSUInteger        nSelectMenuItem;

@property (nonatomic ,strong) NSMutableArray    *menuArray;             /** 栏目数组*/
@property (nonatomic,copy) void(^blockMenuItemClickAction)(UIButton *sender);
@property (nonatomic,copy) void(^blockPublishAction)(UIButton *sender,NSMutableArray *selectedPhotos,NSString* firstVideoUrl,NSInteger vidioNum,UIImage *coverImage);

@property (nonatomic,copy) void(^blockSelectedPhotoAction)(NSMutableArray *photos,NSMutableArray  *assets);
@property (assign, nonatomic) BOOL              isOnlyTakePhoto;

@property (assign, nonatomic)NSUInteger         fid;
@property(nonatomic,strong)UITextView           *titleTextView;
@property(nonatomic,strong)UITextView           *textView;
@property(nonatomic,copy)NSString               *textCont;

-(void)showSelectMenu;
-(void)setMenuItem:(NSString *)navMenuItemTitle;

@end
