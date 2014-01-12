//
//  ConnectionProvider.m
//  Who
//
//  Created by Giancarlo Anemone on 1/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ConnectionProvider.h"
#import "XMPPStream.h"
#import "XMPPJID.h"

@interface ConnectionProvider ()

@property XMPPStream* xmppStream;

@end

@implementation ConnectionProvider

- (void) connect
{
    if(_xmppStream == nil) {
        _xmppStream = [[XMPPStream alloc] init];
        _xmppStream.myJID = [XMPPJID jidWithString:@"12695998050@199.175.55.10"];
        //xmppStream.hostPort
        
        NSError *error = nil;
        if(![_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
            NSLog(@"Failed to connection due to some error %@", error);
        } else {
            NSLog(@"Connection Successfully");
            NSLog(@"Is Connected? %hhd", [_xmppStream isConnected]);
            [_xmppStream disconnect];
            NSLog(@"Is Connected? %hhd", [_xmppStream isConnected]);
        }
    }
}

@end
