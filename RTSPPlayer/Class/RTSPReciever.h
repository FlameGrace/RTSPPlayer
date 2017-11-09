//
//  RTSPReciever.h
//  RTSPDecoder
//
//  Created by Flame Grace on 2017/10/24.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//  承担RTSP链接，发送及解析RTSP命令，向下层传递RTP包的任务
//  注意使用该类只将RTP传递出去，本身并不会解析RTP包
//  使用该类必须指定control来指定RTSP命令格式

#import <Foundation/Foundation.h>
#import "RTSPRecieverProtocol.h"

@interface RTSPReciever : NSObject <RTSPRecieverProtocol,RTSPRecieverDelegate>

@property (assign, nonatomic) BOOL didPlaying;

@end
