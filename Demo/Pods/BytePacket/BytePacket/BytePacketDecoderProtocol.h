//
//  BytePacketDecoderProtocol.h
//
//  Created by Flame Grace on 2017/8/24.
//  Copyright © 2017年 zhouhaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BytePacketProtocol.h"

@protocol BytePacketDecoderProtocol;


@protocol BytePacketDecoderDelegate <NSObject>

//解析到新数据块
- (void)bytePacketDecoder:(id<BytePacketDecoderProtocol>)decoder decodeNewPacket:(id<BytePacketProtocol>)packet;

@end


@protocol BytePacketDecoderProtocol <NSObject>

@property (strong, nonatomic) NSMutableData *bufferData;

@property (strong, nonatomic) dispatch_queue_t decodeQueue;
//需要解码的数据块类型
@property (readonly, nonatomic) Class packetType;

@property (weak, nonatomic) id <BytePacketDecoderDelegate>delegate;

- (instancetype)initWithPacketType:(Class<BytePacketProtocol>)packetType;
//接收新数据
- (void)receiveNewBufferData:(NSData *)newBuffer;

@end


