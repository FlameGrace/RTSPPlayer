//
//  RTPBytePacket.m
//  RTSPDecoder
//
//  Created by Flame Grace on 2017/10/26.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//

#import "RTPBytePacket.h"


@implementation RTPBytePacket

- (NSData *)packHead
{
    return nil;
}

- (BOOL)decodeWithError:(NSError *__autoreleasing *)error
{
    
    NSInteger length = self.encodeData.length;
    if(length< 12)
    {
        if(error != NULL)
        {
            *error = [NSError errorWithDomain:BytePacketErrorDomain code:BytePacketLackDataErrorCode userInfo:@{NSLocalizedDescriptionKey:@"要解码的数据长度不足12字节"}];
        }
        return NO;
    }
    NSInteger current = 0;
    char *headByte = [ByteTransfrom substr:self.encodeData start:current length:1];
    char temp1 = *headByte;
    current += 1;
    int x = 0;
    int p = 0;
    if(temp1 & 32)
    {
        p = 1;
    }
    if(temp1 & 16)
    {
        x = 1;
    }
    //获取cc
    int cc = (int)(temp1 & 15);
    //跳过RTP header(12bytes) + CSRCs 
    current = 12 + cc*4;
    //获取扩展 extension headers
    unsigned short numOfRemExtHdr = 0;
    if(x)
    {
        current += 2;
        if(length < current + 2)
        {
            if(error != NULL)
            {
                NSString *string = @"要解码的数据长度不足,缺少extension headers区域的长度信息";
                *error = [NSError errorWithDomain:BytePacketErrorDomain code:BytePacketLackDataErrorCode userInfo:@{NSLocalizedDescriptionKey:string}];
            }
            return NO;
        }
        Byte *numOfRemExtHdrLByte = (Byte *)[ByteTransfrom substr:self.encodeData start:current length:2];
        current += 2;
        numOfRemExtHdr = [ByteTransfrom highBytesToShortInt:numOfRemExtHdrLByte];
        current += numOfRemExtHdr*4;
    }
    if(length < current)
    {
        if(error != NULL)
        {
            NSString *string = [NSString stringWithFormat:@"要解码的数据长度不足,extension headers数据不足"];
            *error = [NSError errorWithDomain:BytePacketErrorDomain code:BytePacketLackDataErrorCode userInfo:@{NSLocalizedDescriptionKey:string}];
        }
        return NO;
    }
    self.canBeSkippedLength = length;
    NSInteger payloadDataLength = length;
    if(p)
    {
        Byte *paddingLengthByte = (Byte *)[ByteTransfrom substr:self.encodeData start:length-2 length:1];
        unsigned short paddingLength = [ByteTransfrom highBytesToShortInt:paddingLengthByte];
        if(length != current + paddingLength + 1)
        {
            if(error != NULL)
            {
                NSString *string = [NSString stringWithFormat:@"要解码的数据出现错误,padding数据区长度取值错误，包已损毁"];
                *error = [NSError errorWithDomain:BytePacketErrorDomain code:BytePacketDefaultErrorCode userInfo:@{NSLocalizedDescriptionKey:string}];
            }
            return NO;
        }
        //去除填充区
        payloadDataLength -= paddingLength + 1;
    }
    //获取扩展数据
    NSData *payloadData = [ByteTransfrom subdata:self.encodeData start:current length:payloadDataLength - current];
    self.x = x;
    self.cc = cc;
    self.numOfRemExtHdr = numOfRemExtHdr;
    self.payloadData = payloadData;
    return YES;
    
    return YES;
}

- (BOOL)encodeWithError:(NSError *__autoreleasing *)error
{
    return NO;
}

@end
