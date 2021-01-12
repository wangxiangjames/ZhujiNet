//
//  ArtPlayerView.m
//  ArtStudio
//
//  Created by lbq on 2017/2/8.
//  Copyright © 2017年 kimziv. All rights reserved.
//

#import "ArtPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@implementation ArtPlayerView {
    AVPlayer        *_player;
    AVPlayerLayer   *_playerLayer;
    BOOL            _isPlaying;
}

- (instancetype)initWithFrame:(CGRect)frame videoUrl:(NSURL *)videoUrl {
    if (self = [super initWithFrame:frame]) {
        _autoReplay = YES;
        _videoUrl = videoUrl;
        [self setupSubViews];
        self.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:0.93];
    }
    return self;
}

- (void)putVidewH:(BOOL)isH{
    if (isH) {
        CGFloat videoH=self.bounds.size.width* (9.0 / 16.0);
        _playerLayer.frame = CGRectMake(0, (self.bounds.size.height-videoH)/2, self.bounds.size.width, videoH);
    }
    else{
        _playerLayer.frame = self.bounds;
    }
}

- (void)play {
    if (_isPlaying) {
        return;
    }
    [self tapAction];
}

- (void)stop {
    if (_isPlaying) {
        [self tapAction];
    }
}


- (void)setupSubViews {
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:_videoUrl];
    _player = [AVPlayer playerWithPlayerItem:playerItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame = self.bounds;
    //CGFloat videoH=self.bounds.size.width* (9.0 / 16.0);
    //playerLayer.frame = CGRectMake(0, (self.bounds.size.height-videoH)/2, self.bounds.size.width, videoH);
    
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.layer addSublayer:_playerLayer];
}

- (void)tapAction {
    if (_isPlaying) {
        [_player pause];
    }
    else {
        [_player play];
    }
    _isPlaying = !_isPlaying;
}

- (void)playEnd {
    
    if (!_autoReplay) {
        return;
    }
    [_player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
        [_player play];
    }];
}

- (void)removeFromSuperview {
    [_player.currentItem cancelPendingSeeks];
    [_player.currentItem.asset cancelLoading];
    [[NSNotificationCenter defaultCenter] removeObserver:self ];
    [super removeFromSuperview];
}

- (void)dealloc {
    //    NSLog(@"player dalloc");
}

@end
