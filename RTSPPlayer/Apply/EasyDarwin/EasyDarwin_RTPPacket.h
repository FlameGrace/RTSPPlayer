//
//  EasyDarwin_RTPPacket.h
//  RTSPDecoder
//
//  Created by Flame Grace on 2017/10/26.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//  解析EasyDarwin对RTP包的封装
/*
 * this method will be called cyclically for(;;) ReadNextRTPPacket();
 *
 * RTP format: | magic number(1 byte: '$') | channel number(1 byte, 0 for
 * RTP, 1 for RTCP) | embedded data length(2 bytes) | data |
 *
 * after this, RTPByteBuf is fill with RTP data without header, pos is at
 * start of RTP Payload.
 *
 * return 1 when read time out. return 2 when read to end.
 */

#import "BytePacket.h"

@interface EasyDarwin_RTPPacket : BytePacket

@property (assign, nonatomic) short channel;
@property (strong, nonatomic) NSData *rtpData;

@end
