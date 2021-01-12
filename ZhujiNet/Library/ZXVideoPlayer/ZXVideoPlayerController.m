//
//  ZXVideoPlayerController.m
//  ZXVideoPlayer
//
//  Created by Shawn on 16/4/21.
//  Copyright © 2016年 Shawn. All rights reserved.
//

#import "ZXVideoPlayerController.h"
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, ZXPanDirection){
    ZXPanDirectionHorizontal, // 横向移动
    ZXPanDirectionVertical,   // 纵向移动
};

/// 播放器显示和消失的动画时长
//static const CGFloat kVideoPlayerControllerAnimationTimeInterval = 0.3f;

@interface ZXVideoPlayerController () <UIGestureRecognizerDelegate>

/// 播放器视图
@property (nonatomic, strong) ZXVideoPlayerControlView *videoControlView;
/// 是否已经全屏模式
@property (nonatomic, assign) BOOL isFullscreenMode;
/// 是否锁定
@property (nonatomic, assign) BOOL isLocked;
/// 设备方向
@property (nonatomic, assign, readonly, getter=getDeviceOrientation) UIDeviceOrientation deviceOrientation;
/// player duration timer
@property (nonatomic, strong) NSTimer *durationTimer;
/// pan手势移动方向
@property (nonatomic, assign) ZXPanDirection panDirection;
/// 快进退的总时长
@property (nonatomic, assign) CGFloat sumTime;
/// 是否在调节音量
@property (nonatomic, assign) BOOL isVolumeAdjust;
/// 系统音量slider
@property (nonatomic, strong) UISlider *volumeViewSlider;

@end

@implementation ZXVideoPlayerController

#pragma mark - life cycle

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.view.frame = frame;
        self.view.backgroundColor = [UIColor blackColor];
        self.controlStyle = MPMovieControlStyleNone;
        [self.view addSubview:self.videoControlView];
        self.videoControlView.frame = self.view.bounds;
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
        pan.delegate = self;
        [self.videoControlView addGestureRecognizer:pan];
        
        [self configObserver];
        [self configControlAction];
        [self configDeviceOrientationObserver];
        [self configVolume];
    }
    return self;
}

#pragma mark -
#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch
{
    // UISlider & UIButton & topBar 不需要响应手势
    if([touch.view isKindOfClass:[UISlider class]] || [touch.view isKindOfClass:[UIButton class]] || [touch.view.accessibilityIdentifier isEqualToString:@"TopBar"]) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark -
#pragma mark - Public Method

/// 展示播放器
/*- (void)showInView:(UIView *)view
{
    if ([UIApplication sharedApplication].statusBarStyle !=  UIStatusBarStyleLightContent) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    
    [view addSubview:self.view];
    
    self.view.alpha = 0.0;
    [UIView animateWithDuration:kVideoPlayerControllerAnimationTimeInterval animations:^{
        self.view.alpha = 1.0;
    } completion:^(BOOL finished) {}];
    
    if (self.getDeviceOrientation == UIDeviceOrientationLandscapeLeft || self.getDeviceOrientation == UIDeviceOrientationLandscapeRight) {
        [self changeToOrientation:self.getDeviceOrientation];
    } else {
        [self changeToOrientation:UIDeviceOrientationPortrait];
    }
}*/

#pragma mark -
#pragma mark - Private Method

/// 控件点击事件
- (void)configControlAction
{
    [self.videoControlView.playButton addTarget:self action:@selector(playButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControlView.pauseButton addTarget:self action:@selector(pauseButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControlView.fullScreenButton addTarget:self action:@selector(fullScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControlView.shrinkScreenButton addTarget:self action:@selector(shrinkScreenButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControlView.lockButton addTarget:self action:@selector(lockButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControlView.backButton addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    
    // slider
    [self.videoControlView.progressSlider addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.videoControlView.progressSlider addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    [self.videoControlView.progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside];
    [self.videoControlView.progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpOutside];
    [self.videoControlView.progressSlider addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchCancel];
    
    [self setProgressSliderMaxMinValues];
    [self monitorVideoPlayback];
}

/// 开始播放时根据视频文件长度设置slider最值
- (void)setProgressSliderMaxMinValues
{
    if (self.duration > 0) {
        CGFloat duration = self.duration;
        self.videoControlView.progressSlider.minimumValue = 0.f;
        self.videoControlView.progressSlider.maximumValue = floor(duration);
    }
    
}

/// 监听播放进度
- (void)monitorVideoPlayback
{
    double currentTime = floor(self.currentPlaybackTime);
    double totalTime = floor(self.duration);
    // 更新时间
    [self setTimeLabelValues:currentTime totalTime:totalTime];
    // 更新播放进度
    self.videoControlView.progressSlider.value = ceil(currentTime);
    // 更新缓冲进度
    self.videoControlView.bufferProgressView.progress = self.playableDuration / self.duration;
    
//    if (self.duration == self.playableDuration && self.playableDuration != 0.0) {
//        NSLog(@"缓冲完成");
//    }
//    int percentage = self.playableDuration / self.duration * 100;
//    NSLog(@"缓冲进度: %d%%", percentage);
}

/// 更新播放时间显示
- (void)setTimeLabelValues:(double)currentTime totalTime:(double)totalTime {
    double minutesElapsed = floor(currentTime / 60.0);
    double secondsElapsed = fmod(currentTime, 60.0);
    NSString *timeElapsedString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesElapsed, secondsElapsed];
    
    double minutesRemaining = floor(totalTime / 60.0);
    double secondsRemaining = floor(fmod(totalTime, 60.0));
    NSString *timeRmainingString = [NSString stringWithFormat:@"%02.0f:%02.0f", minutesRemaining, secondsRemaining];
    
    self.videoControlView.timeLabel.text = [NSString stringWithFormat:@"%@/%@",timeElapsedString,timeRmainingString];
}

/// 开启定时器
- (void)startDurationTimer
{
    if (self.durationTimer) {
        [self.durationTimer setFireDate:[NSDate date]];
    } else {
        self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(monitorVideoPlayback) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.durationTimer forMode:NSRunLoopCommonModes];
    }
}

/// 暂停定时器
- (void)stopDurationTimer
{
    if (_durationTimer) {
        [self.durationTimer setFireDate:[NSDate distantFuture]];
    }
}

/// MARK: 播放器状态通知

/// 监听播放器状态通知
- (void)configObserver
{
    // 播放状态改变，可配合playbakcState属性获取具体状态
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerPlaybackStateDidChangeNotification) name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
    
    // 媒体网络加载状态改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerLoadStateDidChangeNotification) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    
    // 视频显示状态改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerReadyForDisplayDidChangeNotification) name:MPMoviePlayerReadyForDisplayDidChangeNotification object:nil];
    
    // 确定了媒体播放时长后
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMovieDurationAvailableNotification) name:MPMovieDurationAvailableNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPayerControlViewHideNotification) name:kZXPlayerControlViewHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMPMoviePlayerPlaybackDidFinishNotification) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

/// 播放状态改变, 可配合playbakcState属性获取具体状态
- (void)onMPMoviePlayerPlaybackStateDidChangeNotification
{
    NSLog(@"MPMoviePlayer  PlaybackStateDidChange  Notification");
    
    if (self.playbackState == MPMoviePlaybackStatePlaying) {
        self.videoControlView.pauseButton.hidden = NO;
        self.videoControlView.playButton.hidden = YES;
        [self startDurationTimer];
        
        [self.videoControlView.indicatorView stopAnimating];
        [self.videoControlView autoFadeOutControlBar];
    } else {
        self.videoControlView.pauseButton.hidden = YES;
        self.videoControlView.playButton.hidden = NO;
        [self stopDurationTimer];
        if (self.playbackState == MPMoviePlaybackStateStopped) {
            [self.videoControlView animateShow];
        }
    }
}

-(void)onMPMoviePlayerPlaybackDidFinishNotification{
    [self shrinkScreenButtonClick];
    if (self.videoPlaybackDidFinishBlock) {
        self.videoPlaybackDidFinishBlock();
    }
    NSLog(@"cjw  onMPMoviePlayerPlaybackDidFinishNotification");
}

/// 媒体网络加载状态改变
- (void)onMPMoviePlayerLoadStateDidChangeNotification
{
    NSLog(@"MPMoviePlayer  LoadStateDidChange  Notification");
    
    if (self.loadState & MPMovieLoadStateStalled) {
        [self.videoControlView.indicatorView startAnimating];
    }
    else{
        [self.videoControlView.indicatorView stopAnimating];
    }
}

/// 视频显示状态改变
- (void)onMPMoviePlayerReadyForDisplayDidChangeNotification
{
    NSLog(@"MPMoviePlayer  ReadyForDisplayDidChange  Notification");
}

/// 确定了媒体播放时长
- (void)onMPMovieDurationAvailableNotification
{
    NSLog(@"MPMovie  DurationAvailable  Notification");
    [self startDurationTimer];
    [self setProgressSliderMaxMinValues];
    
    self.videoControlView.fullScreenButton.hidden = NO;
    self.videoControlView.shrinkScreenButton.hidden = YES;
}

/// 控制视图隐藏
- (void)onPayerControlViewHideNotification
{
    if (self.isFullscreenMode) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    } else {
        //[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
}

/// MARK: pan手势处理

/// pan手势触发
- (void)panDirection:(UIPanGestureRecognizer *)pan
{
    CGPoint locationPoint = [pan locationInView:self.videoControlView];
    CGPoint veloctyPoint = [pan velocityInView:self.videoControlView];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: { // 开始移动
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            
            if (x > y) { // 水平移动
                self.panDirection = ZXPanDirectionHorizontal;
                self.sumTime = self.currentPlaybackTime; // sumTime初值
                [self pause];
                [self stopDurationTimer];
            } else if (x < y) { // 垂直移动
                self.panDirection = ZXPanDirectionVertical;
                if (locationPoint.x > self.view.bounds.size.width / 2) { // 音量调节
                    self.isVolumeAdjust = YES;
                } else { // 亮度调节
                    self.isVolumeAdjust = NO;
                }
            }
        }
            break;
        case UIGestureRecognizerStateChanged: { // 正在移动
            switch (self.panDirection) {
                case ZXPanDirectionHorizontal: {
                    [self horizontalMoved:veloctyPoint.x];
                }
                    break;
                case ZXPanDirectionVertical: {
                    [self verticalMoved:veloctyPoint.y];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case UIGestureRecognizerStateEnded: { // 移动停止
            switch (self.panDirection) {
                case ZXPanDirectionHorizontal: {
                    [self setCurrentPlaybackTime:floor(self.sumTime)];
                    [self play];
                    [self startDurationTimer];
                    [self.videoControlView autoFadeOutControlBar];
                }
                    break;
                case ZXPanDirectionVertical: {
                    break;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

/// pan水平移动
- (void)horizontalMoved:(CGFloat)value
{
    // 每次滑动叠加时间
    self.sumTime += value / 200;
    
    // 容错处理
    if (self.sumTime > self.duration) {
        self.sumTime = self.duration;
    } else if (self.sumTime < 0) {
        self.sumTime = 0;
    }
    
    // 时间更新
    double currentTime = self.sumTime;
    double totalTime = self.duration;
    [self setTimeLabelValues:currentTime totalTime:totalTime];
    // 提示视图
    self.videoControlView.timeIndicatorView.labelText = self.videoControlView.timeLabel.text;
    // 播放进度更新
    self.videoControlView.progressSlider.value = self.sumTime;
    
    // 快进or后退 状态调整
    ZXTimeIndicatorPlayState playState = ZXTimeIndicatorPlayStateRewind;
    
    if (value < 0) { // left
        playState = ZXTimeIndicatorPlayStateRewind;
    } else if (value > 0) { // right
        playState = ZXTimeIndicatorPlayStateFastForward;
    }
    
    if (self.videoControlView.timeIndicatorView.playState != playState) {
        if (value < 0) { // left
            NSLog(@"------fast rewind");
            self.videoControlView.timeIndicatorView.playState = ZXTimeIndicatorPlayStateRewind;
            [self.videoControlView.timeIndicatorView setNeedsLayout];
        } else if (value > 0) { // right
            NSLog(@"------fast forward");
            self.videoControlView.timeIndicatorView.playState = ZXTimeIndicatorPlayStateFastForward;
            [self.videoControlView.timeIndicatorView setNeedsLayout];
        }
    }
}


/// pan垂直移动
- (void)verticalMoved:(CGFloat)value
{
    if (self.isVolumeAdjust) {
        // 调节系统音量
        // [MPMusicPlayerController applicationMusicPlayer].volume 这种简单的方式调节音量也可以，只是CPU高一点点
        self.volumeViewSlider.value -= value / 10000;
    }else {
        // 亮度
        [UIScreen mainScreen].brightness -= value / 10000;
    }
}

/// MARK: 系统音量控件

/// 获取系统音量控件
- (void)configVolume
{
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    volumeView.center = CGPointMake(-1000, 0);
    [self.view addSubview:volumeView];
    
    _volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeViewSlider = (UISlider *)view;
            break;
        }
    }
    
    // 使用这个category的应用不会随着手机静音键打开而静音，可在手机静音下播放声音
    NSError *error = nil;
    BOOL success = [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: &error];
    
    if (!success) {/* error */}
    
    // 监听耳机插入和拔掉通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:) name:AVAudioSessionRouteChangeNotification object:nil];
}

/// 耳机插入、拔出事件
- (void)audioRouteChangeListenerCallback:(NSNotification*)notification
{
    NSInteger routeChangeReason = [[notification.userInfo valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            NSLog(@"---耳机插入");
            break;
            
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable: {
            NSLog(@"---耳机拔出");
            // 拔掉耳机继续播放
            [self play];
        }
            break;
            
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            NSLog(@"AVAudioSessionRouteChangeReasonCategoryChange");
            break;
            
        default:
            break;
    }
}

/// MARK: 设备方向

/// 设置监听设备旋转通知
- (void)configDeviceOrientationObserver
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onDeviceOrientationDidChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

/// 设备旋转方向改变
- (void)onDeviceOrientationDidChange
{
    UIDeviceOrientation orientation = self.getDeviceOrientation;
    
    if (!self.isLocked)
    {
        switch (orientation) {
            case UIDeviceOrientationPortrait: {           // Device oriented vertically, home button on the bottom
                NSLog(@"home键在 下");
                [self restoreOriginalScreen];
                if (!self.isStatusHide) {
                    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
                }
            }
                break;
            case UIDeviceOrientationPortraitUpsideDown: { // Device oriented vertically, home button on the top
                NSLog(@"home键在 上");
            }
                break;
            case UIDeviceOrientationLandscapeLeft: {      // Device oriented horizontally, home button on the right
                NSLog(@"home键在 右");
                if (self.playbackState == MPMoviePlaybackStatePlaying ||self.playbackState == MPMoviePlaybackStatePaused) {
                    [self changeToFullScreenForOrientation:UIDeviceOrientationLandscapeLeft];
                    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
                }
            }
                break;
            case UIDeviceOrientationLandscapeRight: {     // Device oriented horizontally, home button on the left
                NSLog(@"home键在 左");
                if (self.playbackState == MPMoviePlaybackStatePlaying ||self.playbackState == MPMoviePlaybackStatePaused) {
                    [self changeToFullScreenForOrientation:UIDeviceOrientationLandscapeRight];
                    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
                }
            }
                break;
                
            default:
                break;
        }
    }
}

/// 切换到全屏模式
- (void)changeToFullScreenForOrientation:(UIDeviceOrientation)orientation
{
    if (self.isFullscreenMode) {
        return;
    }
    self.oldRectVideo=self.view.frame;

    //-----------------------------------------------------
    UIWindow * window = [UIApplication sharedApplication].windows[0];
    self.supView=self.view.superview;
    [self.view removeFromSuperview];
    [window addSubview:self.view];
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame=CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
        if(orientation==UIDeviceOrientationLandscapeLeft){
        self.view.transform =CGAffineTransformMakeRotation(M_PI_2);
        }
        else{
        self.view.transform =CGAffineTransformMakeRotation(-M_PI_2);
        }

    } completion:^(BOOL finished) {
        
    }];
    //-----------------------------------------------------
    if (self.videoPlayerWillChangeToFullScreenModeBlock) {
        self.videoPlayerWillChangeToFullScreenModeBlock();
    }
    
    CGRect rect=[UIScreen mainScreen].bounds;
    self.frame =rect;
    self.videoControlView.frame= CGRectMake(0,0, rect.size.height, rect.size.width);
    self.isFullscreenMode = YES;
    self.videoControlView.fullScreenButton.hidden = YES;
    self.videoControlView.shrinkScreenButton.hidden = NO;
}

/// 切换到竖屏模式
- (void)restoreOriginalScreen
{
    if (!self.isFullscreenMode) {
        return;
    }
    
    //-----------------------------------------------------
    [self.view removeFromSuperview];
    [self.supView addSubview:self.view];
    [self.supView bringSubviewToFront:self.view];
    [UIView animateWithDuration:0.3f animations:^{
        self.view.frame=self.oldRectVideo;
        self.view.transform =CGAffineTransformMakeRotation(0);
    } completion:^(BOOL finished) {
        NSLog(@"viewo:%@",NSStringFromCGRect(self.frame));
    }];
    //-----------------------------------------------------
    if (self.videoPlayerWillChangeToOriginalScreenModeBlock) {
        self.videoPlayerWillChangeToOriginalScreenModeBlock();
    }
    
    //self.frame = CGRectMake(0, 0, kZXVideoPlayerOriginalWidth, kZXVideoPlayerOriginalHeight);
    self.frame = self.oldRectVideo;
    self.videoControlView.frame= CGRectMake(0,0, self.oldRectVideo.size.width, self.oldRectVideo.size.height);
    self.isFullscreenMode = NO;
    self.videoControlView.fullScreenButton.hidden = NO;
    self.videoControlView.shrinkScreenButton.hidden = YES;
}

/// 手动切换设备方向
- (void)changeToOrientation:(UIDeviceOrientation)orientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}

#pragma mark -
#pragma mark - Action Code

/// 返回按钮点击
- (void)backButtonClick
{
    if (!self.isFullscreenMode) { // 如果是竖屏模式，返回关闭
        if (self) {
            [self.durationTimer invalidate];
            [self stop];
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
            
            if (self.videoPlayerGoBackBlock) {
                [self.videoControlView cancelAutoFadeOutControlBar];
                self.videoPlayerGoBackBlock();
            }
        }
    } else { // 全屏模式，返回到竖屏模式
        if (self.isLocked) { // 解锁
            [self lockButtonClick:self.videoControlView.lockButton];
        }
        [self changeToOrientation:UIDeviceOrientationPortrait];
    }
}

/// 播放按钮点击
- (void)playButtonClick
{
    [self play];
    self.videoControlView.playButton.hidden = YES;
    self.videoControlView.pauseButton.hidden = NO;
}

/// 暂停按钮点击
- (void)pauseButtonClick
{
    [self pause];
    self.videoControlView.playButton.hidden = NO;
    self.videoControlView.pauseButton.hidden = YES;
}

/// 锁屏按钮点击
- (void)lockButtonClick:(UIButton *)lockBtn
{
    lockBtn.selected = !lockBtn.selected;
    
    if (lockBtn.selected) { // 锁定
        self.isLocked = YES;
        [[NSUserDefaults standardUserDefaults] setObject:@1 forKey:@"ZXVideoPlayer_DidLockScreen"];
    } else { // 解除锁定
        self.isLocked = NO;
        [[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"ZXVideoPlayer_DidLockScreen"];
    }
}

/// 全屏按钮点击
- (void)fullScreenButtonClick
{
    if (self.isFullscreenMode) {
        return;
    }
    
    if (self.isLocked) { // 解锁
        [self lockButtonClick:self.videoControlView.lockButton];
    }
    
    // FIXME: ?
    [self changeToOrientation:UIDeviceOrientationLandscapeLeft];
}

/// 返回竖屏按钮点击
- (void)shrinkScreenButtonClick
{
    if (!self.isFullscreenMode) {
        return;
    }
    
    if (self.isLocked) { // 解锁
        [self lockButtonClick:self.videoControlView.lockButton];
    }
    
    [self changeToOrientation:UIDeviceOrientationPortrait];
}

/// slider 按下事件
- (void)progressSliderTouchBegan:(UISlider *)slider
{
    [self pause];
    [self stopDurationTimer];
    [self.videoControlView cancelAutoFadeOutControlBar];
}

/// slider 松开事件
- (void)progressSliderTouchEnded:(UISlider *)slider
{
    [self setCurrentPlaybackTime:floor(slider.value)];
    [self play];
    [self startDurationTimer];
    [self.videoControlView autoFadeOutControlBar];
}

/// slider value changed
- (void)progressSliderValueChanged:(UISlider *)slider
{
    double currentTime = floor(slider.value);
    double totalTime = floor(self.duration);
    [self setTimeLabelValues:currentTime totalTime:totalTime];
}

#pragma mark -
#pragma mark - getters and setters

- (void)setContentURL:(NSURL *)contentURL
{
    [self stop];
    [super setContentURL:contentURL];
    //[self play];
}

- (ZXVideoPlayerControlView *)videoControlView
{
    if (!_videoControlView) {
        _videoControlView = [[ZXVideoPlayerControlView alloc] init];
    }
    return _videoControlView;
}

- (void)setFrame:(CGRect)frame
{
    [self.view setFrame:frame];
    [self.videoControlView setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)];
    [self.videoControlView setNeedsLayout];
    [self.videoControlView layoutIfNeeded];
}

- (UIDeviceOrientation)getDeviceOrientation
{
    return [UIDevice currentDevice].orientation;
}

/*- (void)setVideo:(ZXVideo *)video
{
    _video = video;
    
    // 标题
    self.videoControlView.titleLabel.text = self.video.title;
    // play url
    self.contentURL = [NSURL URLWithString:self.video.playUrl];
}*/

@end
