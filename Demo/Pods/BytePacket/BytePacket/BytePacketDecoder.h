//
//  BytePacketDecoder.h
//
//  Created by Flame Grace on 2017/8/24.
//  Copyright © 2017年 zhouhaoran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BytePacketDecoderProtocol.h"

@interface BytePacketDecoder : NSObject <BytePacketDecoderProtocol>
/**
 Cyclic decoding of current cached data
 对当前缓存数据进行循环解码
 */
- (void)decodePacketsInBufferData;

/**
 Parse a single package
 解析单个包
 @return YES:已解析出一个包，可以继续下一个包的解析；NO:当前包解析因数据长度不足失败，需要等待数据
         YES: has resolved a package that can continue parsing the next packet; NO: current packet parsing needs to wait for data because of lack data
 */
- (BOOL)decodeSinglePacketInBufferData;

@end
