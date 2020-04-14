//
//  NoiseReduction.h
//  FFmpeg_iOS
//
//  Created by 李一贤 on 2020/4/13.
//  Copyright © 2020 sen. All rights reserved.
//音频降噪工具

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoiseReduction : NSObject

//输出路径为空的话，则覆盖输入路径下的音频
+(void)noiseReduceFrom:(NSString *)inputPath to:(nullable NSString *)outputPath;

@end

NS_ASSUME_NONNULL_END
