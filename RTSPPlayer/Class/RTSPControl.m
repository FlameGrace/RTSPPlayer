//
//  RTSPControlInterface.m
//  RTSPDecoder
//
//  Created by Flame Grace on 2017/10/24.
//  Copyright © 2017年 flamegrace@hotmail.com. All rights reserved.
//

#import "RTSPControl.h"
#import "EasyDarwin_RTSPPacket.h"

@interface RTSPControl() <RTSPControlDelegate>

@end

@implementation RTSPControl
@synthesize url = _url;
@synthesize responseOk = _responseOk;
@synthesize version = _version;
@synthesize sessionID = _sessionID;
@synthesize state = _state;
@synthesize delegate = _delegate;
@synthesize seq = _seq;
@synthesize responseBuffer = _responseBuffer;

- (instancetype)init
{
    if(self = [super init])
    {
        self.version = RTSP_VERSION;
        self.responseOk = RTSP_OK;
    }
    return self;
}

- (void)rtspControlDidStartPlay:(id <RTSPControlProtocol>)control firstVideoPayloadData:(NSData *)payloadData
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(rtspControlDidStartPlay:firstVideoPayloadData:)])
    {
        [self.delegate rtspControlDidStartPlay:control firstVideoPayloadData:payloadData];
    }
}

- (void)rtspControlCanDoNextControl:(id <RTSPControlProtocol>)control
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(rtspControlCanDoNextControl:)])
    {
        [self.delegate rtspControlCanDoNextControl:control];
    }
}

- (void)rtspControlFailed:(id <RTSPControlProtocol>)control
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(rtspControlFailed:)])
    {
        [self.delegate rtspControlFailed:control];
    }
}

+ (NSString *)endStringNumber:(NSInteger)number
{
    if(number < 1)
    {
        return @"";
    }
    NSMutableString *options = [[NSMutableString alloc]initWithString:@""];
    for (int i = 0;i < number; i++)
    {
        [options appendString:@"\r\n"];
    }
    return options;
}

- (void)gainNewResponse:(NSString *)response firstVideoPayloadData:(NSData *)payloadData
{
    NSLog(@"获取RTSP服务器回复的Response:%@,firstVideoPayloadData长度：%ld",response,payloadData.length);
    if(!response || ![response containsString:self.responseOk])
    {
        switch (self.state) {
            case RTSPControlStateDoOption:
                self.state = RTSPControlStateDoOptionFailed;
                break;
            case RTSPControlStateDoDescribe:
                self.state = RTSPControlStateDoDescribeFailed;
                break;
            case RTSPControlStateDoSetup:
                self.state = RTSPControlStateDoSetupFailed;
                break;
            case RTSPControlStateDoPlay:
                self.state = RTSPControlStateDoPlayFailed;
                break;
            default:
                break;
        }
        [self rtspControlFailed:self];
        return;
    }
    
    if(self.state == RTSPControlStateDoPlay)
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(rtspControlDidStartPlay:firstVideoPayloadData:)])
        {
            [self rtspControlDidStartPlay:self firstVideoPayloadData:payloadData];
        }
        return;
    }
    if(self.state == RTSPControlStateDoSetup)
    {
        NSRange sessionRange = [response rangeOfString:@"Session:"];
        
        if(sessionRange.location != NSNotFound)
        {
            NSString *sessionID = [response substringFromIndex:sessionRange.location + 8];
            NSRange dateRange = [sessionID rangeOfString:[[self class]endStringNumber:1]];
            if(dateRange.location != NSNotFound)
            {
                self.sessionID = [sessionID substringToIndex:dateRange.location];
                [self rtspControlCanDoNextControl:self];
                return;
            }
        }
        self.state = RTSPControlStateDoSetupFailed;
        [self rtspControlFailed:self];
    }
    [self rtspControlCanDoNextControl:self];
}

- (NSString *)currentContrl
{
    NSString *control = nil;
    switch (self.state) {
        case RTSPControlStateNotDo:
            control = [self doOption];
            break;
        case RTSPControlStateDoOption:
            control = [self doDescribe];
            break;
        case RTSPControlStateDoDescribe:
            control = [self doSetup];
            break;
        case RTSPControlStateDoSetup:
            control = [self doPlay];
            break;
        default:
            break;
    }
    return control;
}

- (void)recieveNewResponseData:(NSData *)newData
{
    
}

- (NSString *)doOption
{
    self.state = RTSPControlStateDoOption;
    return nil;
}

- (NSString *)doDescribe
{
    self.state = RTSPControlStateDoDescribe;
    return nil;
}

- (NSString *)doSetup
{
    self.state = RTSPControlStateDoSetup;
    return nil;
}

- (NSString *)doPlay
{
    self.state = RTSPControlStateDoPlay;
    return nil;
}

- (NSString *)doTeardown
{
    self.state = RTSPControlStateDoTeardown;
    return nil;
}



- (NSMutableData *)responseBuffer
{
    if(!_responseBuffer)
    {
        _responseBuffer = [[NSMutableData alloc]init];
    }
    return _responseBuffer;
}
   


@end
