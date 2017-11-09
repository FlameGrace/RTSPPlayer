//
//  EasyDarwin_RTSPPacket.m
//  RTSPDecoder
//
//  Created by Flame Grace on 2017/10/27.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//

#import "EasyDarwin_RTSPPacket.h"


@implementation EasyDarwin_RTSPPacket

- (NSData *)packHead
{
    return nil;
}
- (NSData *)packEnd
{
    char *packEndChar = "\r\n\r\n"; 
    return [NSData dataWithBytes:packEndChar length:4];
}

- (BOOL)decodeWithError:(NSError *__autoreleasing *)error
{
    NSInteger find = [ByteTransfrom findData:[self packEnd] firstPositionInData:self.encodeData];
    if(find == -1)
    {
        if(error != NULL)
        {
            *error = [NSError errorWithDomain:BytePacketErrorDomain code:BytePacketLackDataErrorCode userInfo:@{NSLocalizedDescriptionKey:@"要解码的数据没有包含指定尾"}];
        }
        return NO;
    }
    
    NSData *responseData = [ByteTransfrom subdata:self.encodeData start:0 length:find+4];
    NSString *response = [[NSString alloc]initWithData:responseData encoding:NSUTF8StringEncoding];
    if(!response)
    {
        if(error != NULL)
        {
            *error = [NSError errorWithDomain:BytePacketErrorDomain code:BytePacketDefaultErrorCode userInfo:@{NSLocalizedDescriptionKey:@"Response数据解码失败"}];
        }
        return NO;
    }
    self.encodeLength = find+4;
    self.response = response;
    return YES;
}

- (NSData *)remainData
{
    if(!self.encodeData||!self.encodeData.length||!self.response||self.encodeLength >= self.encodeData.length)
    {
        return nil;
    }
    NSData *remainData = [ByteTransfrom subdata:self.encodeData start:self.encodeLength length:self.encodeData.length - self.encodeLength];
    return remainData;
}

- (BOOL)encodeWithError:(NSError *__autoreleasing *)error
{
    return NO;
}

@end
