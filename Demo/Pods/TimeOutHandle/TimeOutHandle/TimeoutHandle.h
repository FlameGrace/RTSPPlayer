//
//  TimeoutHandle.h
//
//  Created by Flame Grace on 16/10/20.
//  Copyright © 2016年 flamegrace@hotmail.com. All rights reserved.
//  针对一些需要进行超时处理的操作，可以使用此类来完成
//  此类也作为超时管理类（TimeOutHandleCenter）的基础模型，用来记录超时请求的一些关键信息

#import <Foundation/Foundation.h>

@class TimeoutHandle;

//超时回调
typedef void(^LMTimeOutCallback)(TimeoutHandle *handle);
typedef void(^LMTimeOutHandleTimeCallback)(TimeoutHandle *handle, NSTimeInterval handleTime);

@interface TimeoutHandle : NSObject
//注册时间
@property (assign, nonatomic) NSTimeInterval time;
//注册标识符
@property (strong, nonatomic) NSString *identifier;
//超时回调
@property (copy, nonatomic) LMTimeOutCallback timeOutHandle;
//等待超时中回调间隔,默认1s
@property (assign, nonatomic) NSTimeInterval handlePeriod;
//handleTime回调
@property (copy, nonatomic) LMTimeOutHandleTimeCallback handleTimeBlock;
//超时时间，<=0时不回调
@property (assign, nonatomic) NSInteger timeout;
//handle是否失效
@property (readonly, nonatomic) BOOL isValid;

//让handle开始生效
- (void)valid;
//让handle失效
- (void)invalidate;

- (id)initWithTimeout:(NSInteger)timeout timeOutHandle:(LMTimeOutCallback)timeOutHandle;

- (id)initWithTimeout:(NSInteger)timeout timeOutHandle:(LMTimeOutCallback)timeOutHandle handlePeriod:(NSTimeInterval)handlePeriod handleTimeBlock:(LMTimeOutHandleTimeCallback)handleTimeBlock;

@end
