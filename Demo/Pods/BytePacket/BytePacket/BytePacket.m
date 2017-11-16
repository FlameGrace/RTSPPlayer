//
//  BytePacket.m
//
//  Created by Flame Grace on 16/11/16.
//  Copyright © 2016年 hello. All rights reserved.
//

#import "BytePacket.h"
#import "ByteTransfrom.h"

@implementation BytePacket
@synthesize encodeData = _encodeData;
@synthesize canBeSkippedLength = _canBeSkippedLength;

+ (instancetype)packet
{
    return [[[self class] alloc]init];
}

- (NSData *)packHead
{
    return nil;
}


- (BOOL)decodeWithError:(NSError *__autoreleasing *)error
{
    return NO;
}

- (BOOL)encodeWithError:(NSError *__autoreleasing *)error
{
    return NO;
}



@end
