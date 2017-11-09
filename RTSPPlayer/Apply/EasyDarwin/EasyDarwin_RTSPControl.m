//
//  EasyDarwin_RTSPControl.m
//  RTSPDecoder
//
//  Created by Flame Grace on 2017/11/9.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//

#import "EasyDarwin_RTSPControl.h"
#import "EasyDarwin_RTSPPacket.h"

@implementation EasyDarwin_RTSPControl


- (void)recieveNewResponseData:(NSData *)newData
{
    @synchronized(self)
    {
        [self.responseBuffer appendData:newData];
        NSData *bufferData = [NSData dataWithData:self.responseBuffer];
        EasyDarwin_RTSPPacket *packet = [[EasyDarwin_RTSPPacket alloc]init];
        packet.encodeData = bufferData;
        NSError *error;
        if([packet decodeWithError:&error])
        {
            NSData *remainData = nil;
            if(self.state == RTSPControlStateDoPlay)
            {
                remainData = [packet remainData];
            }
            [self gainNewResponse:packet.response firstVideoPayloadData:remainData];
            [self.responseBuffer replaceBytesInRange:NSMakeRange(0, packet.encodeLength) withBytes:NULL length:0];
            return;
        }
        if(error.code == BytePacketLackDataErrorCode)
        {
            return;
        }
        [self gainNewResponse:nil firstVideoPayloadData:nil];
        [self.responseBuffer replaceBytesInRange:NSMakeRange(0, bufferData.length) withBytes:NULL length:0];
    }
}

- (NSString *)doOption
{
    [super doOption];
    NSMutableString *options = [[NSMutableString alloc]initWithString:@"OPTIONS "];
    [options appendString:self.url];
    [options appendString:@" "];
    [options appendString:self.version];
    [options appendString:@" "];
    [options appendString:[[self class] endStringNumber:1]];
    [options appendString:@"Cseq: "];
    self.seq++;
    [options appendFormat:@"%ld",self.seq];
    [options appendString:[[self class] endStringNumber:1]];
    [options appendString:@"User-Agent: Gavin RTSP Client Test"];
    [options appendString:[[self class] endStringNumber:2]];
    
    return options;
}

- (NSString *)doDescribe
{
    [super doDescribe];
    NSMutableString *options = [[NSMutableString alloc]initWithString:@"DESCRIBE "];
    [options appendString:self.url];
    [options appendString:@" "];
    [options appendString:self.version];
    [options appendString:@" "];
    [options appendString:[[self class] endStringNumber:1]];
    [options appendString:@"Cseq: "];
    self.seq++;
    [options appendFormat:@"%ld",self.seq];
    [options appendString:[[self class] endStringNumber:1]];
    [options appendString:@"User-Agent: Gavin RTSP Client Test"];
    [options appendString:[[self class] endStringNumber:1]];
    [options appendString:@"Accept: application/sdp"];
    [options appendString:[[self class] endStringNumber:2]];
    return options;
}



- (NSString *)doSetup
{
    [super doSetup];
    NSMutableString *options = [[NSMutableString alloc]initWithString:@"SETUP "];
    [options appendString:self.url];
    [options appendString:@"/"];
    [options appendString:@"trackID=0 "];
    [options appendString:@" "];
    [options appendString:self.version];
    [options appendString:@" "];
    [options appendString:[[self class] endStringNumber:1]];
    [options appendString:@"Cseq: "];
    self.seq++;
    [options appendFormat:@"%ld",self.seq];
    [options appendString:[[self class] endStringNumber:1]];
    [options appendString:@"User-Agent: Gavin RTSP Client Test"];
    [options appendString:[[self class] endStringNumber:1]];
    [options appendString:@"Transport: RTP/AVP/TCP;unicast;interleaved=0-1"];
    [options appendString:[[self class] endStringNumber:2]];
    return options;
}


- (NSString *)doPlay
{
    [super doPlay];
    NSMutableString *options = [[NSMutableString alloc]initWithString:@"PLAY "];
    [options appendString:self.url];
    [options appendString:@"/ "];
    [options appendString:self.version];
    [options appendString:@" "];
    [options appendString:[[self class] endStringNumber:1]];
    [options appendString:@"Cseq: "];
    self.seq++;
    [options appendFormat:@"%ld",self.seq];
    [options appendString:[[self class] endStringNumber:1]];
    [options appendString:@"User-Agent: Gavin RTSP Client Test"];
    [options appendString:[[self class] endStringNumber:1]];
    [options appendString:@"Session: "];
    [options appendString:self.sessionID];
    [options appendString:[[self class] endStringNumber:1]];
    [options appendString:@"Range: npt=0.000-"];
    [options appendString:[[self class] endStringNumber:2]];
    return options;
}



- (NSString *)doTeardown
{
    if(self.state != RTSPControlStateDoPlay)
    {
        return nil;
    }
    [super doTeardown];
    NSMutableString *options = [[NSMutableString alloc]initWithString:@"TEARDOWN "];
    [options appendString:self.url];
    [options appendString:@"/ "];
    [options appendString:self.version];
    [options appendString:@" "];
    [options appendString:[[self class] endStringNumber:1]];
    [options appendString:@"Cseq: "];
    self.seq++;
    [options appendFormat:@"%ld",self.seq];
    [options appendString:[[self class] endStringNumber:1]];
    [options appendFormat:@"User-Agent: Gavin RTSP Client Test"];
    [options appendString:[[self class] endStringNumber:1]];
    [options appendString:@"Session: "];
    [options appendString:self.sessionID];
    [options appendString:[[self class] endStringNumber:2]];
    return options;
}

@end
