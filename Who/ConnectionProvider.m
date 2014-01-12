//
//  ConnectionProvider.m
//  Who
//
//  Created by Giancarlo Anemone on 1/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ConnectionProvider.h"
#import "XMPPJID.h"
#import "XMPPPresence.h"

@interface ConnectionProvider ()

@property XMPPStream* xmppStream;
@property NSString* username;
@property NSString* password;

@end

static ConnectionProvider *selfInstance;

@implementation ConnectionProvider

// Class method (+) for getting instance of Connection Provider
+ (id)getInstance {
    static ConnectionProvider *myInstance = nil;
    @synchronized(self) {
        if(myInstance == nil) {
            myInstance = [[self alloc] init];
        }
    }
    return myInstance;
}

- (void) connect: (NSString*)username password:(NSString*) password
{
    [self setUpStream];
    [self addConnectInfo:"a"];
    
    NSError *error = nil;
    if(![_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
        NSLog(@"Failed to connection due to some error %@", error);
    } else {
        NSLog(@"Connection Successfully");
    }
}

- (void) setUpStream
{
    if(_xmppStream == nil) {
        _xmppStream = [[XMPPStream alloc] init];
    }
    
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void) addConnectInfo: (char*)username
{
    NSString *formattedUsername = [NSString stringWithFormat:@"%c@199.175.55.10", *username];
    _xmppStream.myJID = [XMPPJID jidWithString:formattedUsername];
    _xmppStream.hostName = @"199.175.55.10";
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSError *error;
    NSString *password = @"a";
    if ([[self xmppStream] authenticateWithPassword:password error:&error])
    {
        NSLog(@"Authentificated to XMPP.");
    }
    else
    {
        NSLog(@"Error authentificating to XMPP: %@", [error localizedDescription]);
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"Successfully Authenticated");
    NSLog(@"%s", __FUNCTION__);
    
    [_xmppStream disconnect];
    //XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    //[sender sendElement:presence];
}





@end
