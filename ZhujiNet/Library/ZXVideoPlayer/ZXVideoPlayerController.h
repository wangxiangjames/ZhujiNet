//
//  ZXVideoPlayerController.h
//  ZXVideoPlayer
//
//  Created by Shawn on 16/4/21.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZXVideoPlayerControlView.h"
@import MediaPlayer;

#define kZXVideoPlayerOriginalWidth  MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)
//#define kZXVideoPlayerOriginalHeight (kZXVideoPlayerOriginalWidth * (11.0 / 16.0))
#define kZXVideoPlayerOriginalHeight (kZXVideoPlayerOriginalWidth * (9.0 / 16.0))

@interface ZXVideoPlayerController : MPMoviePlayerController

@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) CGRect oldRectVideo;                                          //原来高度
@property (nonatomic, strong) UIView *supView;

- (instancetype)initWithFrame:(CGRect)frame;
@property (nonatomic, copy) void(^videoPlayerGoBackBlock)(void);                            //竖屏模式下点击返回
@property (nonatomic, copy) void(^videoPlayerWillChangeToOriginalScreenModeBlock)();        //将要切换到竖屏模式
@property (nonatomic, copy) void(^videoPlayerWillChangeToFullScreenModeBlock)();            //将要切换到全屏模式
- (ZXVideoPlayerControlView *)videoControlView;

@property (nonatomic, assign) BOOL isStatusHide;

@property (nonatomic,copy) void(^videoPlaybackDidFinishBlock)(void);
@end
