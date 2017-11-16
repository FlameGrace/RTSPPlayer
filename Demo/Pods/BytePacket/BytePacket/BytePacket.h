//
//  BytePacket.h
//
//  Created by Flame Grace on 16/11/16.
//  Copyright © 2016年 hello. All rights reserved.
//  字节数据
//  decode/encode

#import <Foundation/Foundation.h>
#import "BytePacketProtocol.h"

@interface BytePacket : NSObject <BytePacketProtocol>


- (NSData *)packHead;

+ (instancetype)packet;

@end
