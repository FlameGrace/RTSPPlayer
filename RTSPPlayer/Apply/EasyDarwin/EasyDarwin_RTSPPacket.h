//
//  EasyDarwin_RTSPPacket.h
//  RTSPDecoder
//
//  Created by Flame Grace on 2017/10/27.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//  每个RTSP命令回复以 "\r\n\r\n"为结束标志

#import "BytePacket.h"

@interface EasyDarwin_RTSPPacket : BytePacket

@property (copy, nonatomic) NSString *response;

- (NSData *)remainData;

@end
