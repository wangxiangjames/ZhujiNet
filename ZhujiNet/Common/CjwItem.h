//
//  CjwItem.h
//  CjwSchool
//
//  Created by chenjinwei on 16/3/20.
//  Copyright © 2016年 chenjinwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CjwItem : NSObject

#pragma mark - 属性
@property (nonatomic,copy)      NSString        *img;           //图片
@property (nonatomic,copy)      NSString        *title;         //标题
@property (nonatomic,copy)      NSString        *author;        //作者
@property (nonatomic,copy)      NSString        *authorid;      //作者id
@property (nonatomic,copy)      NSString        *from;          //来源
@property (nonatomic,copy)      NSString        *dateline;      //时间
@property (nonatomic,assign)    NSInteger       tag;            //标记
@property (nonatomic,copy)      NSString        *url;           //网址
@property(nonatomic,strong)     NSMutableArray  *imagelist;     //图片集
@property(nonatomic,strong)     NSMutableArray  *comment;       //评论
@property (nonatomic,copy)      NSString        *tid;           //帖子id
@property (nonatomic,copy)      NSString        *praise;        //点赞数
@property (nonatomic,copy)      NSString        *replies;       //回复数
@property (nonatomic,copy)      NSString        *level;         //级别
@property (nonatomic,copy)      NSString        *rank;          //军衔
@property (nonatomic,assign)    BOOL            isReplies;      //是否已回复
@property (nonatomic,assign)    NSInteger       islike;         //是否点赞
@property (nonatomic,assign)    float           height;         //存储Cell高度

@property (nonatomic,copy)      NSString *  subtitle;           //副标题
@property (nonatomic,assign)    NSInteger   type;               //新闻类型
@property (nonatomic,copy)      NSString *  flag;               //标记
@property (nonatomic,copy)      NSString *  flagcolor;          //标记颜色
@property (nonatomic,copy)      NSString *  url_pic0;           //新闻图片0
@property (nonatomic,copy)      NSString *  url_pic1;           //新闻图片1
@property (nonatomic,copy)      NSString *  url_pic2;           //新闻图片2
@property (nonatomic,copy)      NSString *  imginfo;            //图片附加信息
@property (nonatomic,assign)    BOOL        isVideo;            //是否视频
@property (nonatomic,copy)      NSString    *videourl;          //视频地址
@property (nonatomic,copy)      NSString    *videocover;        //视频封面图
@property (nonatomic,assign)    NSInteger   contmode;           //内容页类别

@property (nonatomic,copy)      NSString *  sharepic;
@property (nonatomic,copy)      NSString *  shareurl;

#pragma mark - 方法
-(CjwItem *)initWithDictionary:(NSDictionary *) dic;
-(void)setImagelist:(NSMutableArray *)imagelist;

#pragma mark 初始化对象（静态方法）
+(CjwItem *)staticWithDictionary:(NSDictionary *) dic;

@end
