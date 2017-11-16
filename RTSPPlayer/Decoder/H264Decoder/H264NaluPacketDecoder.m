//
//  H264NaluPacketDecoder.m
//  RTSPDecoder
//
//  Created by Flame Grace on 2017/10/26.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//

#import "H264NaluPacketDecoder.h"

@interface H264NaluPacketDecoder()


@property (strong, nonatomic) NSMutableData *fuBufferData;


@end

@implementation H264NaluPacketDecoder

- (BOOL)decodeSinglePacketInBufferData
{
    NSData *singleBufferData = [NSData dataWithData:self.bufferData];
    H264NaluBytePacket *packet = [[H264NaluBytePacket alloc] init];
    packet.encodeData = singleBufferData;
    NSError *error = nil;
    [packet decodeWithError:&error];
    [self.bufferData replaceBytesInRange:NSMakeRange(0, singleBufferData.length) withBytes:NULL length:0];
    if(error)
    {
        return YES;
    }
    if(packet.naluTypeCode != H264NaluTypeFU_A && packet.naluTypeCode == H264NaluTypeFU_B)
    {
        if([self.delegate respondsToSelector:@selector(bytePacketDecoder:decodeNewPacket:)])
        {
            [self.delegate bytePacketDecoder:self decodeNewPacket:packet];
        }
    }
    else
    {
        if(packet.naluData && packet.naluData.length>0)
        {
            [self.fuBufferData appendData:packet.naluData];
        }
        if(packet.fuEnd)
        {
            packet.naluData = [NSMutableData dataWithData:self.fuBufferData];
            [self.fuBufferData replaceBytesInRange:NSMakeRange(0, self.fuBufferData.length) withBytes:NULL length:0];
            if([self.delegate respondsToSelector:@selector(bytePacketDecoder:decodeNewPacket:)])
            {
                [self.delegate bytePacketDecoder:self decodeNewPacket:packet];
            }
        }
    }
    return YES;
    
}



- (NSMutableData *)fuBufferData
{
    if(!_fuBufferData)
    {
        _fuBufferData = [[NSMutableData alloc]init];
    }
    return _fuBufferData;
}

@end
