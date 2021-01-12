//
//  ArtMicroVideoViewController.m
//  ArtStudio
//
//  Created by lbq on 2017/2/7.
//  Copyright © 2017年 kimziv. All rights reserved.
//

#import "ArtMicroVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "ArtAnimationRecordView.h"
#import "ArtVideoModel.h"
#import "ArtVideoUtil.h"
#import "ArtPlayerView.h"
#import "Masonry.h"

#define WEAKSELF(weakSelf)  __weak __typeof(&*self)weakSelf = self;

//#import <YYText.h>
#define DataOutputType 1 //代表是通过AVAssetWriter导出视频

@interface ArtMicroVideoViewController ()<
//AVCaptureFileOutputRecordingDelegate,
AVCaptureVideoDataOutputSampleBufferDelegate,
AVCaptureAudioDataOutputSampleBufferDelegate>
{
    AVCaptureSession *_videoSession;
    AVCaptureVideoPreviewLayer *_videoPreLayer;
    AVCaptureDevice *_videoDevice;
    AVCaptureDevice *_audioDevice;
    AVCaptureDeviceInput        *_videoInput;
    AVCaptureDeviceInput        *_audioInput;
    
    //通过AVCaptureMovieFileOutput 导出视频
    AVCaptureMovieFileOutput    *_movieOutput;
    
    //通过AVAssetWriter 导出输出视频
    AVCaptureVideoDataOutput *_videoDataOut;
    AVCaptureAudioDataOutput *_audioDataOut;
    AVAssetWriter *_assetWriter;
    AVAssetWriterInputPixelBufferAdaptor *_assetWriterPixelBufferInput;
    AVAssetWriterInput *_assetWriterVideoInput;
    AVAssetWriterInput *_assetWriterAudioInput;
    CMTime _currentSampleTime;
    
    
    BOOL _isCancelRecord;
    
    NSString *_savePath;
    
    dispatch_queue_t _recoding_queue;
    
    BOOL    _isTakePhoto;
    UIImage *_imageOfTakePhoto;
    UIImageView *_previewTakePhoto;
    
    BOOL    _isSaveSuccess;
}

@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOut;
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioDataOut;
@property (nonatomic, strong) UIView *videoView;

@property (nonatomic, strong) UIButton *sendBtn;
@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) ArtAnimationRecordView *recordBtnView;

@property (nonatomic, assign) BOOL recoding;
@property (nonatomic, strong) ArtVideoModel *currentRecord;
@property (nonatomic, strong) ArtPlayerView *playerView;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UILabel *tipLabel;

@property (nonatomic, strong) UIButton *toggleCameraBtn;
@property (nonatomic, strong) AVCaptureStillImageOutput   * stillImageOutput;   //照片输出流对象

@end

@implementation ArtMicroVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self makeUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    [self setupVideo];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [_videoSession stopRunning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showBtn];
    _isSaveSuccess=NO;
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)makeUI
{
    
    [self.videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.recordBtnView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@120);
        make.bottom.equalTo(self.view).offset(-50);
        make.centerX.equalTo(self.view);
    }];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.recordBtnView.mas_top).offset(-22);
        make.centerX.equalTo(self.recordBtnView);
    }];
    
    [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.recordBtnView);
    }];
    
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.recordBtnView);
    }];
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.recordBtnView);
        make.bottom.equalTo(self.view).offset(-79.);
        make.left.equalTo(@58);
    }];
    
    [self.toggleCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(self.view).offset(35);
    }];
    
    WEAKSELF(weakSelf);
    self.recordBtnView.startRecord = ^(){
        [weakSelf startRecord];
        [weakSelf hideBtn];
    };
    
    self.recordBtnView.takePhoto = ^(){
        NSLog(@"takePhoto");
        _isTakePhoto=YES;
        //_videoSession.sessionPreset = AVCaptureSessionPresetPhoto;
        
        [weakSelf hideBtn];
        [weakSelf shutterCamera];
    };
    
    self.recordBtnView.completeRecord = ^(CFTimeInterval recordTime){
        weakSelf.recoding = NO;
        //        if (recordTime < 1.) {
        //            [weakSelf showErrorText:@"录制时间太短"];
        //            return ;
        //        }
        [weakSelf saveVideo:^(NSURL *outFileURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!outFileURL) {
                    //[ArtProgressHUD showInfoWithStatus:@"视频录制失败"];
                }
                [weakSelf stopRecord];
                [weakSelf addPlayerView];
            });
        }];
        [weakSelf remakeBtnLayout];
    };
}

- (void)addPlayerView {
    NSURL *videoURL = [NSURL fileURLWithPath:self.currentRecord.videoAbsolutePath];
    self.playerView = [[ArtPlayerView alloc] initWithFrame:[UIScreen mainScreen].bounds videoUrl:videoURL];
    [self.view addSubview:self.playerView];
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.playerView play];
    [self stopRunning];
    
    [self.view insertSubview:self.playerView aboveSubview:self.videoView];
}

- (void)remakeBtnLayout
{
    [self.sendBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@70.);
        make.centerX.equalTo(self.view).offset(35.+372./4.);
        make.bottom.equalTo(self.view).offset(-60.);
    }];
    
    [self.cancelBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@70.);
        make.centerX.equalTo(self.view).offset(-(35.+372./4.));
        make.bottom.equalTo(self.sendBtn);
    }];
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
        self.sendBtn.alpha = 1.;
        self.cancelBtn.alpha = 1.;
        self.recordBtnView.alpha = 0.;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)resetBtnLayout
{
    [self.sendBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.recordBtnView);
    }];
    
    [self.cancelBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.recordBtnView);
    }];
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
        self.sendBtn.alpha = 0.;
        self.cancelBtn.alpha = 0.;
        self.recordBtnView.alpha = 1.;
    }];
}


- (void)setupVideo {
    NSString *unUseInfo = nil;
    if (TARGET_IPHONE_SIMULATOR) {
        unUseInfo = @"模拟器不可以的..";
    }
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if(videoAuthStatus == ALAuthorizationStatusRestricted || videoAuthStatus == ALAuthorizationStatusDenied){
        unUseInfo = @"相机访问受限...";
    }
    AVAuthorizationStatus audioAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if(audioAuthStatus == ALAuthorizationStatusRestricted || audioAuthStatus == ALAuthorizationStatusDenied){
        unUseInfo = @"录音访问受限...";
    }
    
    [self configureSession];
}

- (void)configureSession
{
    _recoding_queue = dispatch_queue_create("com.artstudio.queue", DISPATCH_QUEUE_SERIAL);
    
    _videoSession = [[AVCaptureSession alloc] init];
    /*if ([_videoSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        _videoSession.sessionPreset = AVCaptureSessionPreset640x480;
    }*/
    
    [_videoSession beginConfiguration];
    
    [self addVideo];
    [self addAudio];
    [self addPreviewLayer];
    
    if (self.stillImageOutput==nil) {
        self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([_videoSession canAddOutput:self.stillImageOutput]) {
            [_videoSession addOutput:self.stillImageOutput];
        }
    }
    [_videoSession commitConfiguration];
    
    [_videoSession startRunning];
}

- (void)addVideo
{
    _videoDevice = [self deviceWithMediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    [self addVideoInput];
#ifdef DataOutputType
    [self addVideoOutput];
#else 
    [self addMovieOutput];
#endif
}

- (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType position:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = devices.firstObject;
    
    for (AVCaptureDevice *device in devices)
    {
        if (device.position == position)
        {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

- (void)addVideoInput
{
    if (!_videoDevice || !_videoSession)
    {
        return;
    }
    
    NSError *error;
    
    // 视频输入对象
    // 根据输入设备初始化输入对象，用户获取输入数据
    _videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:_videoDevice error:&error];
    if (error)
    {
        NSLog(@"获取摄像头出错--->>>%@",error);
        return;
    }
    
    // 将视频输入对象添加到会话 (AVCaptureSession) 中
    if ([_videoSession canAddInput:_videoInput])
    {
        [_videoSession addInput:_videoInput];
    }
}

- (void)addAudio
{
    NSError *error;
    // 添加一个音频输入设备
    _audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    //  音频输入对象
    _audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:_audioDevice error:&error];
    if (error)
    {
        NSLog(@"获取音频设备出错--->>>%@",error);
        return;
    }
    // 将音频输入对象添加到会话 (AVCaptureSession) 中
    if ([_videoSession canAddInput:_audioInput])
    {
        [_videoSession addInput:_audioInput];
    }
    
#ifdef DataOutputType
    [self addAudioOutput];
#else
#endif
}

- (void)addVideoOutput
{
    _videoDataOut = [[AVCaptureVideoDataOutput alloc] init];
    _videoDataOut.videoSettings = @{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)};
    _videoDataOut.alwaysDiscardsLateVideoFrames = YES;
    [_videoDataOut setSampleBufferDelegate:self queue:_recoding_queue];
    if ([_videoSession canAddOutput:_videoDataOut]) {
        [_videoSession addOutput:_videoDataOut];
    }
    AVCaptureConnection *captureConnection = [_videoDataOut connectionWithMediaType:AVMediaTypeVideo];
    captureConnection.enabled = YES;
    [captureConnection setVideoOrientation:AVCaptureVideoOrientationPortrait];

}

- (void)addAudioOutput
{
    _audioDataOut = [[AVCaptureAudioDataOutput alloc] init];
    [_audioDataOut setSampleBufferDelegate:self queue:_recoding_queue];
    if ([_videoSession canAddOutput:_audioDataOut]) {
        [_videoSession addOutput:_audioDataOut];
    }
}

- (void)addMovieOutput
{
    if (!_videoSession)
    {
        return;
    }
    // 拍摄视频输出对象
    // 初始化输出设备对象，用户获取输出数据
    _movieOutput = [[AVCaptureMovieFileOutput alloc] init];
    //  [_movieOutput connectionWithMediaType:AVMediaTypeVideo].videoOrientation=AVCaptureVideoOrientationPortrait;
    
    if ([_videoSession canAddOutput:_movieOutput])
    {
        [_videoSession addOutput:_movieOutput];
        
        AVCaptureConnection *captureConnection = [_movieOutput connectionWithMediaType:AVMediaTypeVideo];
        if([captureConnection isVideoOrientationSupported])
        {
            [captureConnection setVideoOrientation:[[UIDevice currentDevice] orientation]];
        }
        
        if ([captureConnection isVideoStabilizationSupported])
        {
            if ([captureConnection respondsToSelector:@selector(setPreferredVideoStabilizationMode:)])
            {
                captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            }
        }
        
        captureConnection.videoScaleAndCropFactor = captureConnection.videoMaxScaleAndCropFactor;
    }
}

//创建预览层
- (void)addPreviewLayer
{
    if (_videoPreLayer!=nil) {
        return;
    }
    _videoPreLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_videoSession];
    _videoPreLayer.frame = [UIScreen mainScreen].bounds;
    _videoPreLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
#ifdef DataOutputType
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        _videoPreLayer.connection.videoOrientation = orientation == UIInterfaceOrientationLandscapeLeft ? AVCaptureVideoOrientationLandscapeLeft : AVCaptureVideoOrientationLandscapeRight;
    }
#else
    _videoPreLayer.connection.videoOrientation = [_movieOutput connectionWithMediaType:AVMediaTypeVideo].videoOrientation;
#endif
    [_videoView.layer addSublayer:_videoPreLayer];
}

- (void)showBtn
{
    self.toggleCameraBtn.hidden=NO;
    self.backBtn.hidden = NO;
    self.tipLabel.hidden = NO;
    self.tipLabel.alpha = 1.0;
    [UIView animateWithDuration:0.2 delay:2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.tipLabel.alpha = 0.;
    } completion:^(BOOL finished) {
        self.tipLabel.hidden = YES;
    }];
}

- (void)hideBtn {
    self.toggleCameraBtn.hidden=YES;
    self.backBtn.hidden = YES;
    self.tipLabel.hidden = YES;
}


- (void)createWriter:(NSURL *)assetUrl {
    _assetWriter = [AVAssetWriter assetWriterWithURL:assetUrl fileType:AVFileTypeMPEG4 error:nil];
    int videoWidth = [UIScreen mainScreen].bounds.size.width;
    int videoHeight = [UIScreen mainScreen].bounds.size.height;
    

    NSDictionary *outputSettings = @{
                                     AVVideoCodecKey : AVVideoCodecH264,
                                     AVVideoWidthKey : @(videoWidth+1),
                                     AVVideoHeightKey : @(videoHeight+1),
                                     AVVideoScalingModeKey:AVVideoScalingModeResizeAspectFill,
                                     //                          AVVideoCompressionPropertiesKey:codecSettings
                                     };
    _assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSettings];
    _assetWriterVideoInput.expectsMediaDataInRealTime = YES;
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        CGFloat rotation = orientation == UIInterfaceOrientationLandscapeRight ? 0. : M_PI;
        _assetWriterVideoInput.transform = CGAffineTransformMakeRotation(rotation);
    }
    
    
    NSDictionary *audioOutputSettings = @{
                                          AVFormatIDKey:@(kAudioFormatMPEG4AAC),
                                          AVEncoderBitRateKey:@(64000),
                                          AVSampleRateKey:@(44100),
                                          AVNumberOfChannelsKey:@(1),
                                          };
    
    _assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioOutputSettings];
    _assetWriterAudioInput.expectsMediaDataInRealTime = YES;
    
    
    NSDictionary *SPBADictionary = @{
                                     (__bridge NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
                                     (__bridge NSString *)kCVPixelBufferWidthKey : @(videoWidth),
                                     (__bridge NSString *)kCVPixelBufferHeightKey  : @(videoHeight),
                                     (__bridge NSString *)kCVPixelFormatOpenGLESCompatibility : ((__bridge NSNumber *)kCFBooleanTrue)
                                     };
    _assetWriterPixelBufferInput = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_assetWriterVideoInput sourcePixelBufferAttributes:SPBADictionary];
    if ([_assetWriter canAddInput:_assetWriterVideoInput]) {
        [_assetWriter addInput:_assetWriterVideoInput];
    }else {
        NSLog(@"不能添加视频writer的input \(assetWriterVideoInput)");
    }
    if ([_assetWriter canAddInput:_assetWriterAudioInput]) {
        [_assetWriter addInput:_assetWriterAudioInput];
    }else {
        NSLog(@"不能添加视频writer的input \(assetWriterVideoInput)");
    }
}

- (void)saveVideo:(void(^)(NSURL *outFileURL))complier {
    
    if (_recoding) return;
    
    if (!_recoding_queue){
        complier(nil);
        return;
    };
    
    //WEAKSELF(weakSelf);
    dispatch_async(_recoding_queue, ^{
        NSURL *outputFileURL = [NSURL fileURLWithPath:_currentRecord.videoAbsolutePath];
        NSLog(@"=====writer status = %tu",_assetWriter.status);
        if (_assetWriter.status != AVAssetWriterStatusWriting) {
            complier(nil);
            return ;
        }
        //_assetWriter.status == 0 时调用该方法会崩溃
        [_assetWriter finishWritingWithCompletionHandler:^{
            [ArtVideoUtil saveThumImageWithVideoURL:outputFileURL second:1 errorBlock:^(NSError *error) {
                //[weakSelf showErrorText:[error localizedDescription]];
            }];
            if (complier) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complier(outputFileURL);
                });
            }
            if (self.savePhotoAlbum) {
                [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                    [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:outputFileURL];
                } completionHandler:^(BOOL success, NSError * _Nullable error) {
                    if (!error && success) {
                        NSLog(@"保存相册成功!");
                        _isSaveSuccess=YES;
                        
                    }
                    else {
                        NSLog(@"保存相册失败! :%@",error);
                    }
                }];
            }
        }];
    });
}

- (void)startRecord
{
    self.currentRecord = [ArtVideoUtil createNewVideo];
    NSURL *outURL = [NSURL fileURLWithPath:self.currentRecord.videoAbsolutePath];
#ifdef DataOutputType
    NSLog(@"视频开始录制");
    [self createWriter:outURL];
    self.recoding = YES;
#else
    [_movieOutput startRecordingToOutputFileURL:outURL recordingDelegate:self];
#endif
    
}

- (void)stopRecord
{
    // 取消视频拍摄
    [_movieOutput stopRecording];
}

- (void)startRunning
{
    [_videoSession startRunning];
}

- (void)stopRunning
{
    [_videoSession stopRunning];
}



//MARK: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    if (!_recoding) return;
    
    @autoreleasepool {
        _currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer);
        NSLog(@"%lld",_currentSampleTime.value/_currentSampleTime.timescale);
        if (_assetWriter.status != AVAssetWriterStatusWriting) {
            [_assetWriter startWriting];
            [_assetWriter startSessionAtSourceTime:_currentSampleTime];
        }
        if (captureOutput == _videoDataOut) {
            if (_assetWriterPixelBufferInput.assetWriterInput.isReadyForMoreMediaData) {
                CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
                BOOL success = [_assetWriterPixelBufferInput appendPixelBuffer:pixelBuffer withPresentationTime:_currentSampleTime];
                if (!success) {
                    NSLog(@"Pixel Buffer没有append成功");
                }
            }
        }
        if (captureOutput == _audioDataOut) {
            [_assetWriterAudioInput appendSampleBuffer:sampleBuffer];
        }
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
}

//MARK: lazy
- (UIView *)videoView
{
    if(!_videoView){
        _videoView = [[UIView alloc] init];
        [self.view addSubview:_videoView];
    }
    return _videoView;
}

- (ArtAnimationRecordView *)recordBtnView
{
    if(!_recordBtnView){
        _recordBtnView = [[ArtAnimationRecordView alloc] init];
        [self.view addSubview:_recordBtnView];
        _isSaveSuccess=NO;
    }
    return _recordBtnView;
}

- (UIButton *)sendBtn
{
    if(!_sendBtn){
        _sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_sendBtn setImage:[UIImage imageNamed:@"record_finish"] forState:UIControlStateNormal];
        [_sendBtn addTarget:self action:@selector(actionRecordFinish:) forControlEvents:UIControlEventTouchUpInside];
        _sendBtn.alpha = 0.;
        [self.view addSubview:_sendBtn];
    }
    return _sendBtn;
}

-(void)actionRecordFinish:(id)sender{
    if (_isTakePhoto) {
        NSLog(@"拍照结束");
        if(self.takePhotoComplete){
            self.takePhotoComplete(_imageOfTakePhoto);
            _imageOfTakePhoto=nil;
        }
        [_videoSession stopRunning];
        
        /*[[TZImageManager manager] savePhotoWithImage:_imageOfTakePhoto location:nil completion:^(NSError *error){
         if (error) {
         NSLog(@"图片保存失败 %@",error);
         } else {
         NSLog(@"图片保存成功");
         }
         }];*/
    }
    else{
        int m=15;
        while (_isSaveSuccess==NO && m>0) {
            [NSThread sleepForTimeInterval:0.5];
            m--;
        }
        
        // [self resetBtnLayout];
        [self.playerView stop];
        [self.playerView removeFromSuperview];
        
        if (self.recordComplete) {
            self.recordComplete(self.currentRecord.videoAbsolutePath,self.currentRecord.thumAbsolutePath);
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self.navigationController popViewControllerAnimated:NO];
}

- (UIButton *)cancelBtn
{
    if(!_cancelBtn){
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelBtn setImage:[UIImage imageNamed:@"record_cancel"] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(actionRecordCancel:) forControlEvents:UIControlEventTouchUpInside];
        _cancelBtn.alpha = 0.;
        [self.view addSubview:_cancelBtn];
    }
    return _cancelBtn;
}

-(void)actionRecordCancel:(id)sender{
    _isSaveSuccess=NO;
    
    [_previewTakePhoto removeFromSuperview];
    
    [self showBtn];
    [self resetBtnLayout];
    [self.playerView stop];
    [self.playerView removeFromSuperview];
    self.playerView = nil;
    [self startRunning];
    [ArtVideoUtil deleteVideo:self.currentRecord.videoAbsolutePath];
}

- (UIButton *)backBtn
{
    if(!_backBtn){
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowOffset = CGSizeMake(1, 1);
        shadow.shadowColor = [UIColor colorWithWhite:0 alpha:0.8];
        shadow.shadowBlurRadius = 6;
        NSMutableAttributedString *one = [[NSMutableAttributedString alloc]initWithString:@"取 消" attributes:@{
                                                                                                              NSFontAttributeName:[UIFont boldSystemFontOfSize:15.],
                                                                                                              NSForegroundColorAttributeName:[UIColor whiteColor],
                                                                                                             NSShadowAttributeName:shadow
                                                                                                             }];
        [_backBtn setAttributedTitle:one forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(actionBack:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_backBtn];
    }
    return _backBtn;
}

- (UIButton *)toggleCameraBtn
{
    if(!_toggleCameraBtn){
        _toggleCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_toggleCameraBtn setImage:[UIImage imageNamed:@"changeCamera"] forState:UIControlStateNormal];
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowOffset = CGSizeMake(1, 1);
        shadow.shadowColor = [UIColor colorWithWhite:0 alpha:0.8];
        shadow.shadowBlurRadius = 6;
        NSMutableAttributedString *one = [[NSMutableAttributedString alloc]initWithString:@"" attributes:@{
                                                                                                              NSFontAttributeName:[UIFont boldSystemFontOfSize:15.],
                                                                                                              NSForegroundColorAttributeName:[UIColor whiteColor],
                                                                                                              NSShadowAttributeName:shadow
                                                                                                              }];
        [_toggleCameraBtn setAttributedTitle:one forState:UIControlStateNormal];
        [_toggleCameraBtn addTarget:self action:@selector(actionToggleCamera:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_toggleCameraBtn];
    }
    return _toggleCameraBtn;
}

-(void)actionBack:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self.navigationController popViewControllerAnimated:YES];
}

-(void)actionToggleCamera:(id)sender{
    [self toggleCamera];
}

- (UILabel *)tipLabel
{
    if(!_tipLabel){
        _tipLabel = [[UILabel alloc] init];
        NSShadow *shadow = [[NSShadow alloc] init];
        shadow.shadowOffset = CGSizeMake(1, 1);
        shadow.shadowColor = [UIColor colorWithWhite:0 alpha:0.8];
        shadow.shadowBlurRadius = 6;
        NSMutableAttributedString *one = [[NSMutableAttributedString alloc]initWithString:@"长按开始录制" attributes:@{
                                                                                                              NSFontAttributeName:[UIFont boldSystemFontOfSize:15.],
                                                                                                              NSForegroundColorAttributeName:[UIColor whiteColor],
                                                                                                              NSShadowAttributeName:shadow
                                                                                                              }];
        _tipLabel.attributedText = one;
        [self.view addSubview:_tipLabel];
    }
    return _tipLabel;
}

//--------------------------------------------------
- (void) shutterCamera
{
    if(_previewTakePhoto==nil){
        _previewTakePhoto=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        
        //这是输出流的设置参数AVVideoCodecJPEG参数表示以JPEG的图片格式输出图片
        NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
        [self.stillImageOutput setOutputSettings:outputSettings];
    }
    
    
    AVCaptureConnection * videoConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) {
        NSLog(@"take photo failed!");
        return;
    }
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer == NULL) {
            return;
        }
        NSData * imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        _imageOfTakePhoto = [UIImage imageWithData:imageData];
        NSLog(@"image size = %@",NSStringFromCGSize(_imageOfTakePhoto.size));
        
        _previewTakePhoto.image=_imageOfTakePhoto;
        [self.view insertSubview:_previewTakePhoto aboveSubview:self.videoView];
        
        [self remakeBtnLayout];
    }];
}

//获取前后摄像头对象的方法
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *)frontCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

- (void)toggleCamera {
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        NSError *error;
        AVCaptureDeviceInput *newVideoInput;
        AVCaptureDevicePosition position = [[_videoInput device] position];
        
        if (position == AVCaptureDevicePositionBack)
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontCamera] error:&error];
        else if (position == AVCaptureDevicePositionFront)
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:&error];
        else
            return;
        
        if (newVideoInput != nil) {
            [_videoSession beginConfiguration];
            [_videoSession removeInput:_videoInput];
            if ([_videoSession canAddInput:newVideoInput]) {
                [_videoSession addInput:newVideoInput];
                _videoInput=newVideoInput;
            } else {
                [_videoSession addInput:_videoInput];
            }
            [_videoSession commitConfiguration];
        } else if (error) {
            NSLog(@"toggle carema failed, error = %@", error);
        }
    }
}
@end
