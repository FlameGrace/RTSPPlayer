//
//  EasyDarwin_RTPPacket.m
//  RTSPDecoder
//
//  Created by Flame Grace on 2017/10/26.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//

#import "EasyDarwin_RTPPacket.h"

@implementation EasyDarwin_RTPPacket

- (NSData *)packHead
{
    char *head = malloc(sizeof(char)*1);
    head[0] = 36;
    NSData *data = [NSData dataWithBytes:head length:1];
    free(head);
    return data;
}

- (BOOL)decodeWithError:(NSError *__autoreleasing *)error
{
    NSInteger length = self.encodeData.length;
    if(length< 4)
    {
        if(error != NULL)
        {
            *error = [NSError errorWithDomain:BytePacketErrorDomain code:BytePacketLackDataErrorCode userInfo:@{NSLocalizedDescriptionKey:@"要解码的数据长度不足4"}];
        }
        return NO;
    }
    NSInteger current = 0;
    NSInteger find = [ByteTransfrom findData:[self packHead] firstPositionInData:self.encodeData];
    current = find + 1;
    if(find == -1)
    {
        if(error != NULL)
        {
            *error = [NSError errorWithDomain:BytePacketErrorDomain code:BytePacketDefaultErrorCode userInfo:@{NSLocalizedDescriptionKey:@"要解码的数据没有包含指定头"}];
        }
        return NO;
    }

    //获取数据区的长度
    Byte *channelByte = (Byte *)[ByteTransfrom substr:self.encodeData start:current length:1];
    current += 1;
    unsigned short channel = [ByteTransfrom highBytesToShortInt:channelByte];
    
    //获取数据区的长度
    Byte *dataLengthByte = (Byte *)[ByteTransfrom substr:self.encodeData start:current length:2];
    current += 2;
    unsigned short dataLength = [ByteTransfrom highBytesToShortInt:dataLengthByte];
    
    if(length < current + dataLength)
    {
        if(error != NULL)
        {
            NSString *string = [NSString stringWithFormat:@"要解码的数据长度不足,数据区长度%d",dataLength];
            *error = [NSError errorWithDomain:BytePacketErrorDomain code:BytePacketLackDataErrorCode userInfo:@{NSLocalizedDescriptionKey:string}];
        }
        return NO;
    }
    //获取扩展数据
    NSData *rtpData = [ByteTransfrom subdata:self.encodeData start:current length:dataLength];
    current += dataLength;
    self.channel = channel;
    self.rtpData = rtpData;
    self.encodeLength = current;
    
    return YES;
}

- (BOOL)encodeWithError:(NSError *__autoreleasing *)error
{
    return NO;
}

@end
