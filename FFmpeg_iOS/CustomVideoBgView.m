//
//  CustomVideoBgView.m
//  FFmpeg_iOS
//
//  Created by mac on 2019/12/23.
//  Copyright © 2019 sen. All rights reserved.
//

#import "CustomVideoBgView.h"
#import <AVFoundation/AVFoundation.h>

@implementation CustomVideoBgView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

@end
