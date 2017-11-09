//
//  RTPBytePacket.h
//  RTSPDecoder
//
//  Created by Flame Grace on 2017/10/26.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//  RTP包解析 ,参见邵国峰博客http://blog.csdn.net/yiyecheer/article/details/53008424
 /**
 * |V(2)|P(1)|X(1)|cc(4)|M(1)|PT(7)|seq(16)|timestamp(32)|SSRC(32)|
 * |<-- header 12 bytes */
/**                                -->
 | | CSRC (
 * cc * 4 * bytes) ... |(2bytes)|NumOfRemExtHdr(2bytes)| remain extension
 * header ... |<-- ExtHdr, length = (1+NumOfRemExtHdr)*4
 */

#import "BytePacket.h"

@interface RTPBytePacket : BytePacket

@property (assign, nonatomic) int cc; //CSRC的个数
@property (assign, nonatomic) int p;  //如果p为1，则包含padding
@property (assign, nonatomic) int x;  //如果X为1，则包含extension header
@property (assign, nonatomic) long numOfRemExtHdr;

@property (strong, nonatomic) NSData *payloadData; //载荷数据

@end
