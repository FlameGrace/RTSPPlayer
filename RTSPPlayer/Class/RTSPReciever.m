//
//  RTSPReciever.m
//  RTSPDecoder
//
//  Created by Flame Grace on 2017/10/24.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//

#import "RTSPReciever.h"
#import "RTSPControl.h"
#import "TimeOutHandleCenter.h"
#import "GCDAsyncSocket.h"

@interface RTSPReciever() <GCDAsyncSocketDelegate, RTSPControlDelegate>

@property (readwrite, copy, nonatomic) NSString *videoUrl;
@property (strong, nonatomic) GCDAsyncSocket *tcp;
@property (copy, nonatomic) NSString *ip;
@property (assign, nonatomic) int16_t port;



@end

@implementation RTSPReciever
@synthesize videoUrl = _videoUrl;
@synthesize delegate = _delegate;
@synthesize control =_control;


static NSString *rtspControlTimeOutIdentifier = @"rtspControlTimeOutIdentifier";


- (void)RTSPReciever:(id<RTSPRecieverProtocol>)reciever failToError:(NSError *)error
{
    NSLog(@"RTSP失败：%@",error);
    if(self.delegate && [self.delegate respondsToSelector:@selector(RTSPReciever:failToError:)])
    {
        [self.delegate RTSPReciever:reciever failToError:error];
    }
}


-(void)RTSPReciever:(id<RTSPRecieverProtocol>)reciever didRecieveNewStream:(NSData *)newStream
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(RTSPReciever:didRecieveNewStream:)])
    {
        [self.delegate RTSPReciever:reciever didRecieveNewStream:newStream];
    }
}


- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"RTSP已链接");
    [self.tcp readDataWithTimeout:-1 tag:0];
    [self rtspControlCanDoNextControl:self.control];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [self.tcp readDataWithTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    [self.tcp readDataWithTimeout:-1 tag:0];
    if(self.didPlaying)
    {
        [self RTSPReciever:self didRecieveNewStream:data];
    }
    else
    {
        [self.control recieveNewResponseData:data];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    NSLog(@"RTSP已断开:%@",err);
    [self RTSPReciever:self failToError:NS_Error(RTSPRecieverErrorDomain, RTSPReciever_SocketDisconnect, @{@"description":@"RTSP链接断开"})];
}


- (void)rtspControlCanDoNextControl:(id <RTSPControlProtocol>)control
{
    [[TimeOutHandleCenter defaultCenter]removeHandleByIdentifier:rtspControlTimeOutIdentifier];
    NSString *controlString = [control currentContrl];
    NSLog(@"RTSP开始发送命令：%@",controlString);
    if (controlString) {
        NSData *data = [controlString dataUsingEncoding:NSUTF8StringEncoding];
        [self.tcp writeData:data withTimeout:-1 tag:0];
        __weak typeof(self) weakSelf = self;
        [[TimeOutHandleCenter defaultCenter]registerHandleWithIdentifier:rtspControlTimeOutIdentifier timeOut:15 timeOutCallback:^(TimeoutHandle *handle) {
            __strong typeof(weakSelf) self = weakSelf;
            [self RTSPReciever:self failToError:NS_Error(RTSPRecieverErrorDomain, RTSPReciever_ControlResponseTimeout, @{@"description":@"Rtsp命令回复超时"})];
            [self stopRecieveVideo];
        }];
    }
}

- (void)rtspControlDidStartPlay:(id <RTSPControlProtocol>)control firstVideoPayloadData:(NSData *)payloadData
{
    [[TimeOutHandleCenter defaultCenter]removeHandleByIdentifier:rtspControlTimeOutIdentifier];
    self.didPlaying = YES;
    NSLog(@"RTSP开始接收RTP数据,firstVideoPayloadData长度：%ld",(unsigned long)payloadData.length);
    [self RTSPReciever:self didRecieveNewStream:payloadData];
}



- (void)rtspControlFailed:(id <RTSPControlProtocol>)control
{
    [[TimeOutHandleCenter defaultCenter]removeHandleByIdentifier:rtspControlTimeOutIdentifier];
    NSString *description = [NSString stringWithFormat:@"Rtsp服务器回复命令操作失败,错误码：%ld",(long)control.state];
    [self RTSPReciever:self failToError:NS_Error(RTSPRecieverErrorDomain, RTSPReciever_ControlResponseControlFailed, @{@"description":description})];
    
    [self stopRecieveVideo];
}

- (void)startRecieveVideo:(NSString *)videoPath
{
    if(self.didPlaying)
    {
        if(videoPath&&self.videoUrl && [self.videoUrl isEqualToString:videoPath])
        {
            return;
        }
        self.tcp.delegate = nil;
        [self stopRecieveVideo];
    }
    if(!self.control)
    {
        [self RTSPReciever:self failToError:NS_Error(RTSPRecieverErrorDomain, RTSPReciever_DidNotDesignControl, @{@"description":@"未指定RTSP命令控制器"})];
        return;
    }
    BOOL check = [self checkAndGetVideoIPAndPort:videoPath];
    if(!check)
    {
        [self RTSPReciever:self failToError:NS_Error(RTSPRecieverErrorDomain, RTSPReciever_VideoPathInvalid, @{@"description":@"视频路径格式出错"})];
        return;
    }
    if(self.tcp&&self.tcp.isConnected)
    {
        [self stopRecieveVideo];
    }
    self.didPlaying = NO;
    self.control.url = self.videoUrl;
    self.control.delegate = self;
    dispatch_queue_t delegateQueue = dispatch_queue_create([NSStringFromClass([self class]) UTF8String], DISPATCH_QUEUE_PRIORITY_DEFAULT);
    self.tcp = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:delegateQueue socketQueue:nil];
    self.tcp.delegate = self;
    [self.tcp connectToHost:self.ip onPort:self.port error:nil];
}


- (void)stopRecieveVideo
{
    self.didPlaying = NO;
    NSString *controlString = [self.control doTeardown];
    if(controlString)
    {
        NSData *data = [controlString dataUsingEncoding:NSUTF8StringEncoding];
        [self.tcp writeData:data withTimeout:-1 tag:0];
    }
    [self.tcp disconnect];
    self.tcp = nil;
}

- (void)dealloc
{
    [self stopRecieveVideo];
}

- (BOOL)checkAndGetVideoIPAndPort:(NSString *)videoPath
{
    if(!videoPath)
    {
        return NO;
    }
    if(self.videoUrl && [videoPath isEqualToString:self.videoUrl])
    {
        return YES;
    }
    NSString *head = [videoPath substringToIndex:7];
    if(!head|| ![head isEqualToString:@"rtsp://"])
    {
        return NO;
    }
    NSString *backString = [videoPath substringFromIndex:7];
    if(!backString||backString.length < 1)
    {
        return NO;
    }
    NSRange range = [backString rangeOfString:@":"];
    if(range.location == NSNotFound)
    {
        return NO;
    }
    NSString *ip = [backString substringToIndex:range.location];
    if(backString.length<=range.location+range.length)
    {
        return NO;
    }
    NSString *portBackString = [backString substringFromIndex:range.location+range.length];
    NSRange portRange = [portBackString rangeOfString:@"/"];
    if(portRange.location == NSNotFound)
    {
        return NO;
    }
    NSString *portString = [portBackString substringToIndex:portRange.location];
    
    if(!ip||!portString)
    {
        return NO;
    }
    self.ip = ip;
    self.port = portString.intValue;
    self.videoUrl = videoPath;
    return YES;
}


@end
