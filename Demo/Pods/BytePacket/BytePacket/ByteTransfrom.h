//
//  ByteTransfrom.h
//
//  Created by Flame Grace on 16/11/4.
//  Copyright © 2016年 hello. All rights reserved.
//  字节数据转换、查找工具类

#import <Foundation/Foundation.h>

@interface ByteTransfrom : NSObject

//小端
+ (short)lowBytesToShortInt:(Byte *)byte;
//大端
+ (short)highBytesToShortInt:(Byte *)byte;
//小端
+ (int)lowBytesToInt:(Byte *)byte;
//大端
+ (int)highBytesToInt:(Byte*)byte;
//小端
+ (long)lowBytesToLong:(Byte *)byte;

/**
 从data中查找指定字节的数据，并返回第一次出现的位置，-1代表未找到
 */
+ (NSInteger)findData:(NSData *)find firstPositionInData:(NSData *)data;

//从data数组中查找含有相应字节的子数组的位置，返回位置数组
+ (NSArray <NSNumber *> *)findData:(NSData *)find positionsInData:(NSData *)data;

/**
 从Data中截取部分字节数组
 @param data 被截取的数据
 @param start 起始位置
 @param length 截取长度
 @return 返回截取出的数据
 */
+ (NSData *)subdata:(NSData *)data start:(NSInteger)start length:(NSInteger)length;

//从字符串中截取部分字符串
+ (char *)substr:(NSData *)src start:(NSInteger)start length:(NSInteger)length;



@end
