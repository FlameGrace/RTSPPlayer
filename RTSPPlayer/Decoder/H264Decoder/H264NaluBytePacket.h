//
//  H264NaluBytePacket.h
//  RTSPDecoder
//
//  Created by Flame Grace on 2017/10/27.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//  请参考 http://www.cnblogs.com/lidabo/p/5570286.html
/**
 * analyze RTP PL data get Nalu type, OrderCode, and write data to
 * NaluPLByteBuf
 *
 * EasyDarwin server's most NALU types are FU-A(code = 28) and STAP-A(24),
 * so we only analyze these 2 types. at this time, RTPByteBuf should be
 * like: for FU-A | Indicator(1byte) | FU-A header(1byte) | Nalu data |
 * Indicator: | F(1bit) | NRI(2bits) | Nal Packet Type(5bits) | FU-A header:
 * | S(1) | E(1) | not care(1) | Nal PL Type(5) |
 *
 * for STAP-A | Indicator(1byte) | length(2bytes) | header(1byte) | NALU
 * data | ... | length(2bytes) | header(1byte) | NALU data | ... | Indicator
 * is same as FU-A.
 *
 * return value: 1, Nalu get end. 0, not end and ok. 0, error
 *
 * since ReadNextRTPPacket will flip RTPByteBuf after read, so this func
 * will follow this rule, flip NaluPLByteBuf after copy data from
 * RTPByteBuf. so after call this func, you can read data from NaluPLByteBuf
 * without other operation.
 *
 */
/**
 * 去掉RTP包头部之后，在去掉特殊头部。即指针指向特殊头部之后。若Type为28且为start，
 * 则将组装后的Nalu的头部写入RTPByteBuf，并把指针指向这个头部。 return val: 0: it is start of a
 * nalu. 1: not a start nal. -1: format error.
 */

#import "BytePacket.h"

typedef NS_ENUM(NSInteger ,H264NaluTypeCode)
{
    H264NaluTypeSingle, //单NAL包 1--23
    H264NaluTypeSTAP_A = 24, //STAP-A包，聚合包
    H264NaluTypeSTAP_B = 25, //STAP-B包，聚合包
    H264NaluTypeMTAP16 = 26, //MTAP16包，聚合包
    H264NaluTypeMTAP24 = 27, //MTAP24包，聚合包
    H264NaluTypeFU_A = 28, //FU-A包，分片包
    H264NaluTypeFU_B = 29, //FU-B包，聚合包
};

@interface H264NaluBytePacket : BytePacket

@property (assign, nonatomic)  H264NaluTypeCode naluTypeCode;

@property (strong, nonatomic)  NSMutableData *naluData;


@property (assign, nonatomic)  BOOL fuEnd;
@end
