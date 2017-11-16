//
//  BytePacketDecoder.m
//
//  Created by Flame Grace on 2017/8/24.
//  Copyright © 2017年 zhouhaoran. All rights reserved.
//

#import "BytePacketDecoder.h"

@interface BytePacketDecoder()

@end

@implementation BytePacketDecoder
@synthesize delegate = _delegate;
@synthesize packetType = _packetType;
@synthesize decodeQueue = _decodeQueue;
@synthesize bufferData = _bufferData;

- (instancetype)initWithPacketType:(Class<BytePacketProtocol>)packetType
{
    if(self = [super init])
    {
        self.packetType = packetType;
    }
    return self;
}

- (void)setPacketType:(Class)packetType
{
    _packetType = packetType;
}

- (void)receiveNewBufferData:(NSData *)newBuffer
{
    dispatch_sync(self.decodeQueue, ^{
        if(!newBuffer||newBuffer.length == 0)
        {
            return;
        }
        else
        {
            [self.bufferData appendData:newBuffer];
        }
        [self decodePacketsInBufferData];
    });
}



- (void)decodePacketsInBufferData
{
    BOOL need = YES;
    while (need && self.bufferData.length) {
        need = [self decodeSinglePacketInBufferData];
    }
}


- (BOOL)decodeSinglePacketInBufferData
{
    NSData *singleBufferData = [NSData dataWithData:self.bufferData];
    id <BytePacketProtocol> packet = [[self.packetType alloc]init];
    packet.encodeData = singleBufferData;
    NSError *error = nil;
    [packet decodeWithError:&error];
    //if lack data, wait next packet.
    if(error && error.code == BytePacketLackDataErrorCode)
    {
        return NO;
    }
    //Remove data which can be skipped from buffer.
    if(self.bufferData.length >= packet.canBeSkippedLength && packet.canBeSkippedLength > 0)
    {
        [self.bufferData replaceBytesInRange:NSMakeRange(0, packet.canBeSkippedLength) withBytes:NULL length:0];
    }
    if(!error)
    {
        if([self.delegate respondsToSelector:@selector(bytePacketDecoder:decodeNewPacket:)])
        {
            [self.delegate bytePacketDecoder:self decodeNewPacket:packet];
        }
    }
    return YES;
}

- (NSMutableData *)bufferData
{
    if(!_bufferData)
    {
        _bufferData = [[NSMutableData alloc]init];
    }
    return _bufferData;
}

- (dispatch_queue_t)decodeQueue
{
    if(!_decodeQueue)
    {
        NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
        NSString *identifier = [NSString stringWithFormat:@"BytePacketDecoder_%f",now];
        _decodeQueue = dispatch_queue_create([identifier UTF8String], DISPATCH_QUEUE_PRIORITY_DEFAULT);
    }
    return _decodeQueue;
}

@end
