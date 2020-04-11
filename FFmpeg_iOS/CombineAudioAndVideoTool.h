//
//  CombineAudioAndVideoTool.h
//  FFmpeg_iOS
//
//  Created by 李一贤 on 2020/4/11.
//  Copyright © 2020 sen. All rights reserved.
//音频合成工具(合成到一个现有video里)

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CombineAudioAndVideoTool : NSObject

+(AVMutableComposition*)combineOrginalVideo:(NSString*)videoPath WithAudio:(NSString*)audioPath atTime:(CMTime)beginTime;

@end

NS_ASSUME_NONNULL_END
