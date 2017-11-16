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
    NSInteger current = 0;
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
    current = find+4;
    if(!response)
    {
        self.canBeSkippedLength = current;
        if(error != NULL)
        {
            *error = [NSError errorWithDomain:BytePacketErrorDomain code:BytePacketDefaultErrorCode userInfo:@{NSLocalizedDescriptionKey:@"Response数据解码失败"}];
        }
        return NO;
    }
    //remainData主要为获取doPlay后的粘包视频数据
    if(self.encodeData.length > current)
    {
        NSData *remainData = [ByteTransfrom subdata:self.encodeData start:current length:self.encodeData.length - current];
        self.remainData = remainData;
        //此处不能执行：current = self.encodeData.length;
    }
    self.canBeSkippedLength = current;
    self.response = response;
    return YES;
}


- (BOOL)encodeWithError:(NSError *__autoreleasing *)error
{
    return NO;
}


@end
