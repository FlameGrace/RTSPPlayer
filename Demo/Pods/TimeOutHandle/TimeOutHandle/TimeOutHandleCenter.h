//
//  TimeOutHandleCenter.h
//
//  Created by Flame Grace on 2017/3/29.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
// 主要用于管理需要超时反馈的请求操作，会定时移除已超时的请求

#import <Foundation/Foundation.h>
#import "TimeoutHandle.h"

@interface TimeOutHandleCenter : NSObject

+ (instancetype)defaultCenter;

//请求列表，管理发送的请求
@property (readonly, nonatomic) NSMutableDictionary *handles;


//注册一个超时请求，一经注册超时机制立即生效
- (void)registerTimeOutHandle:(TimeoutHandle *)handle;

//从超时列表去除一个handle
- (void)removeHandleByIdentifier:(NSString *)identifier;
/**
 注册一个超时请求，一经注册超时机制立即生效

 @param identifier 此次请求的标志符
 @param timeOut 超时时间(0不超时）
 @param timeOutCallback 超时回调
 */
- (void)registerHandleWithIdentifier:(NSString *)identifier timeOut:(NSInteger)timeOut timeOutCallback:(LMTimeOutCallback)timeOutCallback;
/**
 注册一个超时请求，一经注册超时机制立即生效
 
 @param identifier 此次请求的标志符
 @param timeOut 超时时间(0不超时）
 @param timeOutCallback 超时回调
 @param handlePeriod 等待超时中的回调时间间隔
 @param handleTimeBlock 等待超时中的回调
 */
- (void)registerHandleWithIdentifier:(NSString *)identifier timeOut:(NSInteger)timeOut timeOutCallback:(LMTimeOutCallback)timeOutCallback handlePeriod:(NSTimeInterval)handlePeriod handleTimeBlock:(LMTimeOutHandleTimeCallback)handleTimeBlock;

@end
