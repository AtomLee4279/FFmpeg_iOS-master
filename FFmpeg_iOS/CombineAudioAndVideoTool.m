//
//  CombineAudioAndVideoTool.m
//  FFmpeg_iOS
//
//  Created by 李一贤 on 2020/4/11.
//  Copyright © 2020 sen. All rights reserved.
//

#import "CombineAudioAndVideoTool.h"


@implementation CombineAudioAndVideoTool

+(AVMutableComposition*)combineOrginalVideo:(NSString*)videoPath WithAudio:(NSString*)audioPath atTime:(CMTime)beginTime{
    
        //1.先创建一个音视频多轨道容器
        AVMutableComposition *mixComposition = [AVMutableComposition composition];
        //2.初始化视频源资源对象
        AVURLAsset* videoAsset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:videoPath] options:nil];
        //3.多轨道容器里先添加一个视频轨道容器，用于装载原视频视频轨道
        AVMutableCompositionTrack *compositionVideoTrackContainer = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo
        preferredTrackID:kCMPersistentTrackID_Invalid];
        //4.多轨道容器里添加一个音频轨道容器，用于装载原视频音频轨道
        AVMutableCompositionTrack *compositionOrginalAudioTrackContainer =
        [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                               preferredTrackID:kCMPersistentTrackID_Invalid];
        //5.======下面的操作开始封装视频源的视频和音频轨道========
            //5.1 获取视频源视频轨道
        NSArray *orginalVideoTracks = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
        
            //5.2 把视频源视频轨道插入到多轨道容器的视频轨道容器中
        [compositionVideoTrackContainer insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
        ofTrack:[orginalVideoTracks firstObject]
         atTime:kCMTimeZero error:nil];
            //5.3 获取视频源音频轨道
        NSArray <AVAssetTrack *>*orginalAudioTracks = [videoAsset tracksWithMediaType:AVMediaTypeAudio];
        
            //5.4 把原视频中音频轨道插入到多轨道容器的音频轨道容器中
        [compositionOrginalAudioTrackContainer insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration)
        ofTrack:[orginalAudioTracks firstObject]
         atTime:kCMTimeZero error:nil];
        //===============封装视频源的视频和音频轨道完毕===================//
        
        //6.初始化要合成的外界音频(例如人声)资源对象
        AVURLAsset *voiceAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:audioPath] options:nil];
        //7.多轨道容器里添加一个新的音频轨道容器，用于装载外界音频轨道
        AVMutableCompositionTrack *voiceTrackContainer =
        [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio
                               preferredTrackID:kCMPersistentTrackID_Invalid];
        //8.获取外界音频轨道
        NSArray <AVAssetTrack *>*audioTracks = [voiceAsset tracksWithMediaType:AVMediaTypeAudio];
        //9.把外界音频轨道插入到多轨道容器的新的音频轨道容器中
        [voiceTrackContainer insertTimeRange:CMTimeRangeMake(kCMTimeZero, voiceAsset.duration)
                                            ofTrack:[audioTracks firstObject]
                                             atTime:beginTime error:nil];
        return mixComposition;

}

@end
