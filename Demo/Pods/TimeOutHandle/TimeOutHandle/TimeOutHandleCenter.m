//
//  TimeOutHandleCenter.m
//
//  Created by Flame Grace on 2017/3/29.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//

#import "TimeOutHandleCenter.h"

@interface TimeOutHandleCenter()
@property (readwrite, strong, nonatomic) NSMutableDictionary *handles;
@property (strong, nonatomic) NSTimer *removeTimer;
@end

@implementation TimeOutHandleCenter

static TimeOutHandleCenter *defaultCenter = nil;

+ (instancetype)defaultCenter
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultCenter = [[TimeOutHandleCenter alloc]init];
    });
    return defaultCenter;
}


//开始超时计时器
- (void)startTimer
{
    if(self.removeTimer.valid)
    {
        return;
    }
    self.removeTimer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(handleTimer) userInfo:self repeats:YES];
    [self.removeTimer fire];
    
}
//停止计时器
- (void)endTimer
{
    [self.removeTimer invalidate];
    self.removeTimer = nil;
}

//计时器回调方法
- (void)handleTimer
{
    [self cleanLongTimeHandles];
    if(self.handles.count < 1)
    {
        [self endTimer];
    }
}



//注册一个超时请求，一经注册超时机制立即生效
- (void)registerTimeOutHandle:(TimeoutHandle *)handle
{
    if(!handle)
    {
        return;
    }
    
    NSString *identifier = handle.identifier;
    if(!identifier.length)
    {
        NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
        identifier = [NSString stringWithFormat:@"%f",now];
    }
    @synchronized (self) {
        [self removeHandleByIdentifier:identifier];
        [self.handles setObject:handle forKey:identifier];
        [handle valid];
        [self startTimer];
    }
}

//从请求列表去除一个请求
- (void)removeHandleByIdentifier:(NSString *)identifier
{
    if(!identifier || [identifier length] < 1)
    {
        return;
    }
    @synchronized (self) {
        TimeoutHandle *handle = [self.handles objectForKey:identifier];
        if(handle)
        {
            [handle invalidate];
            [self.handles removeObjectForKey:identifier];
        }
    }
}


//发送数据，requestIdentifier此次请求的标志符，timeOut超时时间(0不超时，不能大于100），timeOutCallback，超时回调
//调用该方法会默认生成一个request对象放入请求列表中
- (void)registerHandleWithIdentifier:(NSString *)identifier timeOut:(NSInteger)timeOut timeOutCallback:(LMTimeOutCallback)timeOutCallback
{
    [self registerHandleWithIdentifier:identifier timeOut:timeOut timeOutCallback:timeOutCallback handlePeriod:0 handleTimeBlock:nil];
}

- (void)registerHandleWithIdentifier:(NSString *)identifier timeOut:(NSInteger)timeOut timeOutCallback:(LMTimeOutCallback)timeOutCallback handlePeriod:(NSTimeInterval)handlePeriod handleTimeBlock:(LMTimeOutHandleTimeCallback)handleTimeBlock
{
    TimeoutHandle *handle = [[TimeoutHandle alloc]initWithTimeout:timeOut timeOutHandle:timeOutCallback];
    handle.identifier = identifier;
    handle.handlePeriod = handlePeriod;
    handle.time = [[NSDate date]timeIntervalSince1970];
    handle.handleTimeBlock = handleTimeBlock;
    [self registerTimeOutHandle:handle];
}


//清理失效的请求
- (void)cleanLongTimeHandles
{
    [self.handles enumerateKeysAndObjectsUsingBlock:^(NSString *identifier, TimeoutHandle *handle, BOOL * _Nonnull stop) {
        if(!handle.isValid)
        {
            [self.handles removeObjectForKey:identifier];
        }
    }];
}


- (NSMutableDictionary *)handles
{
    if(!_handles)
    {
        _handles = [[NSMutableDictionary alloc]init];
    }
    return _handles;
}


@end
