//
//  RTSPControlInterfaceProtocol.h
//  RTSPDecoder
//
//  Created by Flame Grace on 2017/11/9.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RTSPControlState)
{
    RTSPControlStateNotDo = 0,
    RTSPControlStateDoOption,
    RTSPControlStateDoOptionFailed,
    RTSPControlStateDoDescribe,
    RTSPControlStateDoDescribeFailed,
    RTSPControlStateDoSetup,
    RTSPControlStateDoSetupFailed,
    RTSPControlStateDoPlay,
    RTSPControlStateDoPlayFailed,
    RTSPControlStateDoTeardown,
};



@protocol RTSPControlProtocol;

@protocol RTSPControlDelegate <NSObject>

- (void)rtspControlFailed:(id <RTSPControlProtocol> )control;

- (void)rtspControlCanDoNextControl:(id <RTSPControlProtocol>)control;

/**
 服务器开始发送RTP包
 @param control RTSP命令控制协议
 @param payloadData 正常情况下为空，但当TCP粘包时，会发生第一个视频载荷与RTSP PLAY回复在一起的情况
 */
- (void)rtspControlDidStartPlay:(id <RTSPControlProtocol>)control firstVideoPayloadData:(NSData *)payloadData;

@end


@protocol RTSPControlProtocol <NSObject>

@property (weak, nonatomic) id <RTSPControlDelegate> delegate;

@property (assign, nonatomic) RTSPControlState state;  //当前控制状态
@property (copy, nonatomic) NSString *url; //rtsp地址
@property (copy, nonatomic) NSString *version; //rtsp协议版本
@property (copy, nonatomic) NSString *responseOk; //标识服务器回复无异常的字段
@property (copy, nonatomic) NSString *sessionID; //此次请求的成功标志，在doSetup回复中携带
@property (assign, nonatomic) NSInteger seq;
@property (strong, nonatomic) NSMutableData *responseBuffer;

- (void)recieveNewResponseData:(NSData *)newData; //接收到服务器的回复数据，需对其进行解析处理

- (NSString *)currentContrl;  //当前需要发送的control命令

- (NSString *)doOption;

- (NSString *)doDescribe;

- (NSString *)doSetup;

- (NSString *)doPlay;

- (NSString *)doTeardown;

@end
