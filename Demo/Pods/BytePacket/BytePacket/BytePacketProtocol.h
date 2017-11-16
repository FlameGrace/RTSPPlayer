//
//  BytePacketProtocol.h
//
//  Created by Flame Grace on 16/11/16.
//  Copyright © 2016年 hello. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ByteTransfrom.h"

#define BytePacketErrorDomain @"com.bytePacket.error"

typedef NS_ENUM(NSInteger, BytePacketErrorCode){
    
    BytePacketDefaultErrorCode = -1, //解码或编码过程中时数据出现错误
    BytePacketLackDataErrorCode, //解码因当前数据不足而失败
};


@protocol BytePacketProtocol <NSObject>

//编码后的数据或需要解码的数据
@property (strong ,nonatomic) NSData *encodeData;
/*
 可以被解码器忽略的长度
 The Length Can Be Skipped By Decoder From the Buffer。
*/
@property (assign, nonatomic) NSUInteger canBeSkippedLength;

//解码
- (BOOL)decodeWithError:(NSError **)error;
//编码
- (BOOL)encodeWithError:(NSError **)error;




@end



