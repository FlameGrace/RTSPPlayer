//
//  EastDarwin_RTSPReciever.h
//  RTSPDecoder
//
//  Created by Flame Grace on 2017/10/24.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//  RTSP数据接收器（仅针对EasyDrawin，码流格式H264）
//  对上层RTSPReciever传递的RTP包进行层层解析
//  第一层：解析Easydarwin外层协议封装下的RTP数据
//  第二层：解析RTP数据获取其中包含的payload视频载荷
//  第三层：解析payload视频载荷中的nalu编码祯

#import <Foundation/Foundation.h>
#import "RTSPRecieverProtocol.h"
#import "RTSPReciever.h"


@interface EastDarwin_RTSPReciever : RTSPReciever

@end
