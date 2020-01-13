//
//  ViewController.m
//  FFmpeg_iOS
//
//  Created by sen on 2018/12/15.
//  Copyright © 2018年 sen. All rights reserved.
//

#import "ViewController.h"
#import "ffmpeg.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreServices/CoreServices.h>
#import <Photos/Photos.h>
#import "CustomVideoBgView.h"
#define INPUT_VIDEO @"input.mp4"


@interface ViewController ()

@property (strong,nonatomic) AVPlayer *inputVideoPlayer;

@property (strong,nonatomic) AVPlayer *outputVideoPlayer;

@property (strong,nonatomic) AVAudioPlayer *audioPlayer;

@property (weak, nonatomic) IBOutlet UIButton *inputVideoPlayerButton;

@property (weak, nonatomic) IBOutlet UISlider *inputVideoPlayerSlider;

@property (weak, nonatomic) IBOutlet UILabel *inputVideoTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *inputAudioTimeLabel;

@property (weak, nonatomic) IBOutlet CustomVideoBgView *inputVideoView;

@property (weak, nonatomic) IBOutlet UISlider *inputAudioSlider;

@property (copy, nonatomic) NSString *outputPath;

@property (weak, nonatomic) IBOutlet UISlider *outputSlider;

@property (weak, nonatomic) IBOutlet UILabel *outputTimeLabel;


@property (weak, nonatomic) IBOutlet UIButton *outputPlayerButton;


@property (weak, nonatomic) IBOutlet CustomVideoBgView *outputVideoView;


@end
@implementation ViewController{
    NSTimer *_videoTimer;
    NSTimer *_audioTimer;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [self initInputVideoPlayer];
    [self initInputAudioPlayer];
//    [self normalRun2];
    

}

#pragma mark -FFmpeg Caller -

/**
 第一种调用方式
 */
- (void)normalRun{
    NSString *fromFile = [[NSBundle mainBundle]pathForResource:@"video.mov" ofType:nil];
    NSString *toFile = @"/Users/sen/Desktop/Output/video.gif";
    
    int argc = 4;
    char **arguments = calloc(argc, sizeof(char*));
    if(arguments != NULL)
    {
        arguments[0] = "ffmpeg";
        arguments[1] = "-i";
        arguments[2] = (char *)[fromFile UTF8String];
        arguments[3] = (char *)[toFile UTF8String];
        
        if (!ffmpeg_main(argc, arguments)) {
            NSLog(@"生成成功");
        }
    }
}

- (void)normalRun2{
    
    NSString *video = [[NSBundle mainBundle]pathForResource:INPUT_VIDEO ofType:nil];
    NSString *audio   = [[NSBundle mainBundle]pathForResource:@"birth.m4a" ofType:nil];
    //ffmpeg -i foo.mp3 -itsoffset 60 -i blah.mpeg -acodec copy -vcodec copy -copyts out.mkv

//    self.outputPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"output.mkv"];
//    self.outputPath = @"/Users/mac/Desktop/output.mkv";
//    NSString *command_str = [NSString stringWithFormat:@"ffmpeg -i %@ -itsoffset 60 -i %@ -acodec copy -vcodec copy -copyts %@",audio,video,self.outputPath];
    NSString *command_str = [NSString stringWithFormat:@"ffmpeg -i %@ -itsoffset 60 -i %@ -acodec copy -vcodec copy -copyts %@",audio,video,self.outputPath];
    // 分割字符串
    NSMutableArray  *argv_array  = [command_str componentsSeparatedByString:(@" ")].mutableCopy;
    
    // 获取参数个数
    int argc = (int)argv_array.count;
    
    // 遍历拼接参数
    char **argv = calloc(argc, sizeof(char*));
    
    for(int i=0; i<argc; i++)
    {
        NSString *codeStr = argv_array[i];
        argv_array[i]     = codeStr;
        argv[i]      = (char *)[codeStr UTF8String];
    }
    
    ffmpeg_main(argc, argv);
}

//初始化输入播放源
-(void)initInputVideoPlayer{
    
    NSString *path = [[NSBundle mainBundle]pathForResource:INPUT_VIDEO ofType:nil];
    //为即将播放的视频内容进行建模
        AVPlayerItem *avplayerItem = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:path]];
    //创建监听（这是一种KOV的监听模式）
        [avplayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        //给播放器赋值要播放的对象模型
        self.inputVideoPlayer = [AVPlayer playerWithPlayerItem:avplayerItem];
     // 将player输出到显示动画层playerLayer
       [(AVPlayerLayer *)self.inputVideoView.layer setPlayer:self.inputVideoPlayer];
    
//    [self.inputVideoPlayerSlider addTarget:self action:@selector(sliderValueChange:) forControlEvents:UIControlEventValueChanged];
    
}

//初始化输入音频源
-(void)initInputAudioPlayer{
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"birth.m4a" ofType:nil];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
    _audioTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(countAudioCurrentTime) userInfo:nil repeats:YES];
}

//初始化合成后的视频播放
-(void)initOutputVideoPlayer{

    //为即将播放的视频内容进行建模
        AVPlayerItem *avplayerItem = [[AVPlayerItem alloc] initWithURL:[NSURL fileURLWithPath:self.outputPath]];
    //创建监听（这是一种KOV的监听模式）
        [avplayerItem addObserver:self forKeyPath:@"OutputStatus" options:NSKeyValueObservingOptionNew context:nil];
        //给播放器赋值要播放的对象模型
        self.outputVideoPlayer = [AVPlayer playerWithPlayerItem:avplayerItem];
     // 将player输出到显示动画层playerLayer
       [(AVPlayerLayer *)self.outputVideoView.layer setPlayer:self.outputVideoPlayer];
}

//播放状态监听
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    AVPlayerItem *item = object;
    //判断监听对象的状态
    if ([keyPath isEqualToString:@"status"]) {
    
        if (item.status == AVPlayerItemStatusReadyToPlay) {//准备好的
            NSLog(@"AVPlayerItemStatusReadyToPlay");
            _videoTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(countInputVideoCurrentTime) userInfo:nil repeats:YES];
        } else if(item.status ==AVPlayerItemStatusUnknown){//未知的状态
           NSLog(@"AVPlayerItemStatusUnknown");
        }else if(item.status ==AVPlayerItemStatusFailed){//有错误的
            NSLog(@"AVPlayerItemStatusFailed");
        }
        
    }
    
    if ([keyPath isEqualToString:@"OutputStatus"]) {
    
        if (item.status == AVPlayerItemStatusReadyToPlay) {//准备好的
            NSLog(@"AVPlayerItemStatusReadyToPlay");
            _videoTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(countOutputVideoCurrentTime) userInfo:nil repeats:YES];
        } else if(item.status ==AVPlayerItemStatusUnknown){//未知的状态
           NSLog(@"AVPlayerItemStatusUnknown");
        }else if(item.status ==AVPlayerItemStatusFailed){//有错误的
            NSLog(@"AVPlayerItemStatusFailed");
        }
        
    }
    
}

#pragma mark - Action Methods

//播放视频源
- (IBAction)actInputVideoButtonTouched:(UIButton *)sender {
    
    [self.audioPlayer pause];
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.inputVideoPlayer play];
    }else{
        [self.inputVideoPlayer pause];
    }
}

//播放音频源
- (IBAction)actInputAudioButtonTouched:(UIButton*)sender {
    
    [self.inputVideoPlayer pause];
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.audioPlayer play];
    }else{
        [self.audioPlayer pause];
    }
    
}


- (IBAction)actCombineVedioAndAudio:(id)sender {
    
    [self combineVideoAndAudio];
    
}

//播放合成后的视频
- (IBAction)actPlayOutputButtonTouched:(UIButton*)sender {
    
    [self.audioPlayer pause];
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.outputVideoPlayer play];
    }else{
        [self.outputVideoPlayer pause];
    }
    
}

#pragma mark - CustomMethods -

-(void)countInputVideoCurrentTime{
    
    float current = CMTimeGetSeconds([self.inputVideoPlayer currentTime]);
    NSInteger min = current/60;
    NSInteger sec = (NSInteger)current%60;
    NSString *currentTime = [NSString stringWithFormat:@"%02ld:%02ld",min,sec];
    float total = CMTimeGetSeconds(self.inputVideoPlayer.currentItem.duration);
    CGFloat sliderValue = current / total;
    self.inputVideoTimeLabel.text = currentTime;
    self.inputVideoPlayerSlider.value = sliderValue;
    
}

-(void)countOutputVideoCurrentTime{
    
    float current = CMTimeGetSeconds([self.outputVideoPlayer currentTime]);
    NSInteger min = current/60;
    NSInteger sec = (NSInteger)current%60;
    NSString *currentTime = [NSString stringWithFormat:@"%02ld:%02ld",min,sec];
    float total = CMTimeGetSeconds(self.outputVideoPlayer.currentItem.duration);
    CGFloat sliderValue = current / total;
    self.outputTimeLabel.text = currentTime;
    self.outputSlider.value = sliderValue;
    self.outputTimeLabel.text = currentTime;
    self.outputSlider.value = sliderValue;
}

-(void)countAudioCurrentTime{
    
//    float current = CMTimeGetSeconds([self.videoPlayer currentTime]);
//    NSInteger min = current/60;
//    NSInteger sec = (NSInteger)current%60;
//    NSString *currentTime = [NSString stringWithFormat:@"%02ld:%02ld",min,sec];
//    self.inputVideoTimeLabel.text = currentTime;
//    float total = CMTimeGetSeconds(self.videoPlayer.currentItem.duration);
//    CGFloat sliderValue = current / total;
//    self.inputVideoPlayerSlider.value = sliderValue;
    
    NSTimeInterval current = [self.audioPlayer currentTime];
    NSInteger min = current/60;
    NSInteger sec = (NSInteger)current%60;
    NSString *currentTime = [NSString stringWithFormat:@"%02ld:%02ld",min,sec];
    self.inputAudioTimeLabel.text = currentTime;
    NSTimeInterval total = [self.audioPlayer duration];
    CGFloat sliderValue = current / total;
    self.inputAudioSlider.value = sliderValue;
    
}

//使用系统自带框架合成视频/音频
-(void)combineVideoAndAudio{
    
    NSString *videoPath = [[NSBundle mainBundle]pathForResource:INPUT_VIDEO ofType:nil];
    AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:videoPath] options:nil];
    NSString *audioPath = [[NSBundle mainBundle]pathForResource:@"birth.m4a" ofType:nil];
    AVURLAsset *backgroundAudio = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:audioPath] options:nil];
    AVURLAsset *backgroundAudio2 = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoPath] options:nil];
    
    AVMutableComposition *mixComposition = [AVMutableComposition composition];
    AVMutableCompositionTrack *backgroundTrack =
    [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                           preferredTrackID:kCMPersistentTrackID_Invalid];
    NSArray *audioTracks = [backgroundAudio tracksWithMediaType:AVMediaTypeAudio];
    [backgroundTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, backgroundAudio.duration)
                                        ofTrack:[audioTracks firstObject]
                                         atTime:kCMTimeZero error:nil];
    
    AVMutableCompositionTrack *backgroundTrack2 =
    [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                           preferredTrackID:kCMPersistentTrackID_Invalid];
    NSArray *audioTracks2 = [backgroundAudio2 tracksWithMediaType:AVMediaTypeAudio];
    [backgroundTrack2 insertTimeRange:CMTimeRangeMake(kCMTimeZero, backgroundAudio.duration)
                                        ofTrack:[audioTracks2 firstObject]
                                         atTime:kCMTimeZero error:nil];
    
    AVMutableCompositionTrack *compositionVideoTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                                       preferredTrackID:kCMPersistentTrackID_Invalid];
    NSArray *videoTracks = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
    [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
                                       ofTrack:[videoTracks firstObject]
                                        atTime:kCMTimeZero error:nil];
    [self outputProcessedVideoWithAsset:mixComposition];

}

//输出合成后的视频
-(void)outputProcessedVideoWithAsset:(AVAsset*)compostion{
    
    NSString *filePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    filePath = [filePath stringByAppendingPathComponent:@"user"];
    NSFileManager *manage = [NSFileManager defaultManager];
    if ([manage createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil])
    {
        filePath = [filePath stringByAppendingPathComponent:@"output.mp4"];
    }
    self.outputPath = filePath;
    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc]initWithAsset:compostion presetName:AVAssetExportPresetMediumQuality];
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.outputPath])
        {
            NSError *error;
            [[NSFileManager defaultManager] removeItemAtPath:self.outputPath error:&error];
            if (error) {
                return;
            }
        }

        for (NSString *supportFileType in assetExport.supportedFileTypes) {
            NSLog(@"%@",supportFileType);
        }

        assetExport.outputFileType = AVFileTypeQuickTimeMovie;
        NSLog(@"file type %@",assetExport.outputFileType);
        assetExport.outputURL = [NSURL fileURLWithPath:self.outputPath];
        assetExport.shouldOptimizeForNetworkUse = YES;
        [assetExport exportAsynchronouslyWithCompletionHandler:
         ^(void ) {
             // your completion code here
             NSLog(@"%@",assetExport.outputURL);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.outputPlayerButton.userInteractionEnabled = YES;
                self->_videoTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(countOutputVideoCurrentTime) userInfo:nil repeats:YES];
                [self initOutputVideoPlayer];
                //保存到相册
                [self addNewAssetWithVideoUrl:[NSURL fileURLWithPath:self.outputPath]];
            });


         }
         ];
    
}

//保存视频到相册
- (void) addNewAssetWithVideoUrl:(NSURL*)videoURL
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        // Request creating an asset from the image.
        PHAssetChangeRequest* createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoURL];
        PHFetchResult *album = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
         // Request editing the album.
        PHAssetCollectionChangeRequest* albumChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:album.firstObject];
         // Get a placeholder for the new asset and add it to the album editing request.
        PHObjectPlaceholder* assetPlaceholder = [createAssetRequest placeholderForCreatedAsset];
        [albumChangeRequest addAssets:@[ assetPlaceholder ]];
     } completionHandler:^(BOOL success, NSError* error) {
        NSLog(@"Finished adding asset. %@", (success ? @"Success" : error));
    }];
}



#pragma mark - Notification -

-(void)videoPlayEnd{
    
    [self.inputVideoPlayer.currentItem seekToTime:kCMTimeZero];
    [self.outputVideoPlayer.currentItem seekToTime:kCMTimeZero];
}

@end
