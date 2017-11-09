//
//  RTSPControlInterface.h
//  RTSPDecoder
//
//  Created by Flame Grace on 2017/10/24.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//  RTSP命令控制器，处理RTSP命令与服务器回复

#import <Foundation/Foundation.h>
#import "RTSPControlProtocol.h"


#define RTSP_VERSION (@"RTSP/1.0")
#define RTSP_OK (@"RTSP/1.0 200 OK")


@interface RTSPControl : NSObject <RTSPControlProtocol,RTSPControlDelegate>

+ (NSString *)endStringNumber:(NSInteger)number;

- (void)gainNewResponse:(NSString *)response firstVideoPayloadData:(NSData *)payloadData;


@end
