//
//  EastDarwin_RTSPReciever.m
//  RTSPDecoder
//
//  Created by Flame Grace on 2017/10/24.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//

#import "EastDarwin_RTSPReciever.h"
#import "EasyDarwin_RTSPControl.h"
#import "EasyDarwin_RTPPacket.h"
#import "RTPBytePacket.h"
#import "H264NaluPacketDecoder.h"


@interface EastDarwin_RTSPReciever() <BytePacketDecoderDelegate>

@property (strong, nonatomic) BytePacketDecoder *easyDarwinDecoder; //EasyDarwin解码器
@property (strong, nonatomic) H264NaluPacketDecoder *naluDecoder; //nalu解码器
@end


@implementation EastDarwin_RTSPReciever

- (instancetype)init
{
    if(self = [super init])
    {
        self.control = [[EasyDarwin_RTSPControl alloc]init];
    }
    return self;
}


- (void)RTSPReciever:(id<RTSPRecieverProtocol>)reciever didRecieveNewStream:(NSData *)newStream
{
//    NSLog(@"RTSP接收RTP流长度：%ld，码流数据：%@",newStream.length,newStream);
    [self.easyDarwinDecoder receiveNewBufferData:newStream];
}


- (void)bytePacketDecoder:(id<BytePacketDecoderProtocol>)decoder decodeNewPacket:(id<BytePacketProtocol>)packet
{
    if([decoder isEqual:self.easyDarwinDecoder])
    {
        EasyDarwin_RTPPacket *newPacket = (EasyDarwin_RTPPacket* )packet;
//        NSLog(@"RTSP解码器解析到RTP包，channel:%d，长度：%ld",newPacket.channel,newPacket.rtpData.length);
        RTPBytePacket *rtp = [[RTPBytePacket alloc]init];
        rtp.encodeData = newPacket.rtpData;
        if([rtp decodeWithError:nil])
        {
            [self.naluDecoder receiveNewBufferData:rtp.payloadData];
        }
        
    }
    if([decoder isEqual:self.naluDecoder])
    {
        H264NaluBytePacket *newPacket = (H264NaluBytePacket* )packet;
        [super RTSPReciever:self didRecieveNewStream:newPacket.naluData];
//        NSLog(@"解析到祯：%ld,帧数据总长：%ld",newPacket.naluTypeCode,newPacket.naluData.length);
    }
}

- (BytePacketDecoder *)easyDarwinDecoder
{
    if(!_easyDarwinDecoder)
    {
        _easyDarwinDecoder = [[BytePacketDecoder alloc]initWithPacketType:[EasyDarwin_RTPPacket class]];
        _easyDarwinDecoder.delegate = self;
    }
    return _easyDarwinDecoder;
}

- (H264NaluPacketDecoder *)naluDecoder
{
    if(!_naluDecoder)
    {
        _naluDecoder = [[H264NaluPacketDecoder alloc]init];
        _naluDecoder.delegate = self;
    }
    return _naluDecoder;
}

@end
