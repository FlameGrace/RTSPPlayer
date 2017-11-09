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
//编码后的数据长度或一个完整的可解码块的数据长度（在解码成功后必须计算并赋值）
@property (assign, nonatomic) NSUInteger encodeLength;

//解码
- (BOOL)decodeWithError:(NSError **)error;
//编码
- (BOOL)encodeWithError:(NSError **)error;




@end



