//
//  H264NaluBytePacket.m
//  RTSPDecoder
//
//  Created by Flame Grace on 2017/10/27.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//

#import "H264NaluBytePacket.h"

@interface H264NaluBytePacket()

@property (assign, nonatomic) NSInteger current;

@end


@implementation H264NaluBytePacket


- (NSData *)startCodeData
{
    unsigned char startCode[] = {0,0,0,1};
    return [NSData dataWithBytes:startCode length:4];
}

- (BOOL)decodeWithError:(NSError *__autoreleasing *)error
{
    //NSLog(@"encodeData %@",self.encodeData);
    NSInteger length = self.encodeData.length;
    if(length < 1)
    {
        if(error != NULL)
        {
            *error = [NSError errorWithDomain:BytePacketErrorDomain code:BytePacketLackDataErrorCode userInfo:@{NSLocalizedDescriptionKey:@"要解码的数据长度不足1"}];
        }
        return NO;
    }
    self.naluData = [[NSMutableData alloc]init];
    char *indicatorByte = [ByteTransfrom substr:self.encodeData start:0 length:1];
    char temp1 = *indicatorByte;
    NSInteger naluType = temp1 & 0x1F;
    
    if(naluType < H264NaluTypeSTAP_A || naluType > H264NaluTypeFU_B)
    {
        self.naluTypeCode = H264NaluTypeSingle;
    }
    else
    {
        self.naluTypeCode = naluType;
    }
    
//    NSLog(@"naluTypeCode :%ld",naluType);
    
    BOOL ok  = YES;
    
    switch (self.naluTypeCode)
    {
        case H264NaluTypeSTAP_A:
            ok =[self stap_ADecodeWithError:error];
            break;
        case H264NaluTypeSTAP_B:
            ok =[self stap_BDecodeWithError:error];
            break;
        case H264NaluTypeMTAP16:
            ok =[self mtap16DecodeWithError:error];
            break;
        case H264NaluTypeMTAP24:
            ok =[self mtap24DecodeWithError:error];
            break;
        case H264NaluTypeFU_A:
            ok =[self fu_ADecodeWithError:error];
            break;
        case H264NaluTypeFU_B:
            ok =[self fu_BDecodeWithError:error];
            break;
        default:
            ok = [self singleDecodeWithError:error];
            break;
    }
    //每个nalu包都是完整的，因此在下一个解析前，需要全部从buffer中移除
    self.canBeSkippedLength = self.encodeData.length;
    return ok;
}


- (BOOL)singleDecodeWithError:(NSError *__autoreleasing *)error
{
    [self.naluData appendData:[self startCodeData]];
    [self.naluData appendData:self.encodeData];
    return YES;
}

- (BOOL)stap_ADecodeWithError:(NSError *__autoreleasing *)error
{
    self.current = 1;
    return [self tap_DecodeWithError:error skipPosition:0];
}

- (BOOL)stap_BDecodeWithError:(NSError *__autoreleasing *)error
{
    self.current = 3;
    return [self tap_DecodeWithError:error skipPosition:0];
}

- (BOOL)mtap16DecodeWithError:(NSError *__autoreleasing *)error
{
    self.current = 3;
    return [self tap_DecodeWithError:error skipPosition:3];
}

- (BOOL)mtap24DecodeWithError:(NSError *__autoreleasing *)error
{
    self.current = 3;
    return [self tap_DecodeWithError:error skipPosition:4];
}


- (BOOL)tap_DecodeWithError:(NSError *__autoreleasing *)error skipPosition:(NSInteger)skipPosition
{
    NSMutableData *nalusData = [[NSMutableData alloc]init];
    NSData *naluData = [self singleTap_DecodeSkipPosition:skipPosition];
    while (naluData) {
        [nalusData appendData:naluData];
        naluData = [self singleTap_DecodeSkipPosition:skipPosition];
    }
    self.naluData = nalusData;
    return YES;
}

- (NSData *)singleTap_DecodeSkipPosition:(NSInteger)skipPosition
{
    NSInteger length = self.encodeData.length;
    if(length < self.current + 2 + skipPosition)
    {
        return nil;
    }
    NSMutableData *naluData = [[NSMutableData alloc]init];
    [naluData appendData:[self startCodeData]];
    NSData *remainData = nil;
    Byte *singleLengthByte = (Byte *)[ByteTransfrom substr:self.encodeData start:self.current length:2];
    unsigned short singleLength = [ByteTransfrom highBytesToShortInt:singleLengthByte];
    self.current += 2 + skipPosition;
    if(length < self.current + singleLength)
    {
        remainData = [ByteTransfrom subdata:self.encodeData start:self.current length:length - self.current];
        self.current = length;
    }
    else
    {
        remainData = [ByteTransfrom subdata:self.encodeData start:self.current length:singleLength];
        self.current += singleLength;
    }
    [naluData appendData:remainData];
//    NSLog(@"naluData: %@",naluData);
    
    return naluData;
    
}

- (BOOL)fu_ADecodeWithError:(NSError *__autoreleasing *)error
{
    return [self fu_DecodeWithError:error];
}

- (BOOL)fu_BDecodeWithError:(NSError *__autoreleasing *)error
{
    return [self fu_DecodeWithError:error];
}

- (BOOL)fu_DecodeWithError:(NSError *__autoreleasing *)error
{
    NSInteger length = self.encodeData.length;
    self.current = 1;
    if(length <= self.current + 1)
    {
        return YES;
    }
    NSMutableData *naluData = [[NSMutableData alloc]init];
    char *headByte = [ByteTransfrom substr:self.encodeData start:self.current length:1];
    char head = *headByte;
    self.current += 1;
    BOOL fuEnd = NO;
    if(head & 64)
    {
        fuEnd = YES;
    }
    if(head & 128)
    {
        [naluData appendData:[self startCodeData]];
        char *indicatorByte = [ByteTransfrom substr:self.encodeData start:0 length:1];
        char indicator = *indicatorByte;
        char fuHeader = (indicator & 0xe0)|(head & 0x1f);
        NSData *fuHeaderData = [NSData dataWithBytes:&fuHeader length:1];
        [naluData appendData:fuHeaderData];
    }
    NSData * remainData = [ByteTransfrom subdata:self.encodeData start:self.current length:length - self.current];
    [naluData appendData:remainData];
    self.naluData = naluData;
    self.fuEnd = fuEnd;
//    NSLog(@"naluData: %@",naluData);
    return YES;
}

- (BOOL)encodeWithError:(NSError *__autoreleasing *)error
{
    return NO;
}

@end
