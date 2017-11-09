//
//  RTSPRecieverProtocol.h
//  RTSPDecoder
//
//  Created by Flame Grace on 2017/10/24.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RTSPControlProtocol.h"


typedef NS_ENUM(NSInteger, RTSPRecieverErrorCode)
{
    RTSPReciever_VideoPathInvalid = 1710241111, //视频路径非法
    RTSPReciever_DidNotDesignControl, //未指定RTSP命令控制器
    RTSPReciever_ControlResponseTimeout, //Rtsp命令回复超时
    RTSPReciever_ControlResponseControlFailed, //Rtsp服务器回复命令操作失败
    RTSPReciever_SocketDisconnect,  //链接断开
};

#define NS_Error(errorDomain,errorCode,errorUserInfo) ([NSError errorWithDomain:errorDomain code:errorCode userInfo:errorUserInfo])

#define RTSPRecieverErrorDomain (@"com.RTSPReciever.error")


@protocol RTSPRecieverProtocol;



@protocol RTSPRecieverDelegate <NSObject>


//收到新的流
- (void)RTSPReciever:(id <RTSPRecieverProtocol>)reciever didRecieveNewStream:(NSData *)newStream;
//错误回调
- (void)RTSPReciever:(id <RTSPRecieverProtocol>)reciever failToError:(NSError *)error;

@end





@protocol RTSPRecieverProtocol <NSObject>

@property (strong, nonatomic) id <RTSPControlProtocol> control;
@property (weak, nonatomic) id <RTSPRecieverDelegate> delegate;

@property (readonly, copy, nonatomic) NSString *videoUrl;

- (void)startRecieveVideo:(NSString *)videoPath;

- (void)stopRecieveVideo;


@end
