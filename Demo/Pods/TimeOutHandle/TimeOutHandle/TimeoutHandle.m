//
//  TimeoutHandle.m
//
//  Created by Flame Grace on 16/10/20.
//  Copyright © 2016年 flamegrace@hotmail.com. All rights reserved.
//

#import "TimeoutHandle.h"

@interface TimeoutHandle()

@property (strong, nonatomic) dispatch_source_t timer;
@property (strong, nonatomic) NSTimer *timeOutTimer;
@property (assign, nonatomic) NSTimeInterval startTime;
@property (readwrite, assign, nonatomic) BOOL isValid;

@end

@implementation TimeoutHandle

- (instancetype)init
{
    if(self = [super init])
    {
        self.handlePeriod = 1;
    }
    return self;
}

- (id)initWithTimeout:(NSInteger)timeout timeOutHandle:(LMTimeOutCallback)timeOutHandle
{
    return [self initWithTimeout:timeout timeOutHandle:timeOutHandle handlePeriod:0 handleTimeBlock:nil];
}


- (id)initWithTimeout:(NSInteger)timeout timeOutHandle:(LMTimeOutCallback)timeOutHandle handlePeriod:(NSTimeInterval)handlePeriod handleTimeBlock:(LMTimeOutHandleTimeCallback)handleTimeBlock
{
    if(self = [super init])
    {
        self.handlePeriod = handlePeriod;
        self.timeout = timeout;
        self.timeOutHandle = timeOutHandle;
        self.handleTimeBlock = handleTimeBlock;
    }
    return self;
}



- (void)startTimer
{
    [self endTimer];
    self.startTime = [[NSDate date]timeIntervalSince1970];
    NSTimeInterval period = self.handlePeriod; //设置时间间隔
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.timer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(self.timer, ^{ //在这里执行事件
        [self handleTimer];
    });
    
    dispatch_resume(self.timer);
}

- (void)endTimer
{
    if(self.timer)
    {
        dispatch_source_cancel(self.timer);
        self.timer = nil;
        self.startTime = 0;
    }
}

- (void)setHandlePeriod:(NSTimeInterval)handlePeriod
{
    if(handlePeriod <= 0)
    {
        handlePeriod = 1;
    }
    _handlePeriod = handlePeriod;
}


//计时器回调方法
- (void)handleTimer
{
    
    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
    NSTimeInterval handleTime = now - self.startTime;
    if(self.handleTimeBlock)
    {
        self.handleTimeBlock(self, handleTime);
    }
    if(handleTime >= self.timeout)
    {
        [self endTimer];
        self.isValid = NO;
        if(self.timeOutHandle)self.timeOutHandle(self);
    }
}

//开始生效
- (void)valid
{
    if(self.timeout > 0 && self.timeOutHandle)
    {   self.isValid = YES;
        [self startTimer];
    }
}

//请求失效
- (void)invalidate
{
    [self endTimer];
    self.isValid = NO;
}
@end;
