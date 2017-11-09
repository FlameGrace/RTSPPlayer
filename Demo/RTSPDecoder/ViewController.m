//
//  ViewController.m
//  TestVideo
//
//  Created by Flame Grace on 12/21/14.
//  Copyright (c) 2014 flamegrace@hotmail.com. All rights reserved.
//

#import "ViewController.h"
#import "EastDarwin_RTSPReciever.h"


@interface ViewController () <RTSPRecieverDelegate>

@property (strong, nonatomic) EastDarwin_RTSPReciever *reciever;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.reciever startRecieveVideo:@"rtsp://xxxx/xx.sdp"];
}


- (void)RTSPReciever:(id<RTSPRecieverProtocol>)reciever didRecieveNewStream:(NSData *)newStream
{
    
}

- (void)RTSPReciever:(id<RTSPRecieverProtocol>)reciever failToError:(NSError *)error
{
    
}



- (void)dealloc
{
    [self.reciever stopRecieveVideo];
}


- (EastDarwin_RTSPReciever *)reciever
{
   if(!_reciever)
   {
       _reciever = [[EastDarwin_RTSPReciever alloc]init];
       _reciever.delegate = self;
   }
    
    return _reciever;
}

@end
