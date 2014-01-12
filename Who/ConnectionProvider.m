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

@property(nonatomic, strong) XMPPStream* xmppStream;
@property(nonatomic, strong) NSString* username;
@property(nonatomic, strong) NSString* password;
@property(nonatomic, strong) NSString* SERVER_IP_ADDRESS;

@end

static ConnectionProvider *selfInstance;

@implementation ConnectionProvider

// Class method (+) for getting instance of Connection Provider
+ (id)getInstance {
    @synchronized(self) {
        if(selfInstance == nil) {
            selfInstance = [[self alloc] init];
            selfInstance.SERVER_IP_ADDRESS = @"199.175.55.10";
        }
    }
    return selfInstance;
}

// Returns connection stream object
- (XMPPStream *)getConnection
{
    return self.xmppStream;
}

- (void) connect: (NSString*)username password:(NSString*) password
{
    NSLog(@"Server IP Address %@", self.SERVER_IP_ADDRESS);
    self.SERVER_IP_ADDRESS = @"199.175.55.10";
    [self addStreamDelegate];
    [self.xmppStream setHostName:self.SERVER_IP_ADDRESS];
    self.username = username;
    self.password = password;
    self.xmppStream.myJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", self.username, self.SERVER_IP_ADDRESS]];
    NSError *error = nil;
    if(![self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
        NSLog(@"Failed to connection due to some error %@", error);
    } else {
        NSLog(@"Connected Successfully");
    }
}

- (void) addStreamDelegate
{
    if(self.xmppStream == nil) {
        self.xmppStream = [[XMPPStream alloc] init];
    }
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSError *error;
    NSLog(@"XMPP Stream Did Connect");
    if ([[self xmppStream] authenticateWithPassword:self.password error:&error])
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
    NSLog(@"XMPP Stream Did Authenticate");
    NSLog(@"%s", __FUNCTION__);
    [self.xmppStream disconnect];
    //XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    //[sender sendElement:presence];
}

-(void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    NSLog(@"XMPPStream Disconnected.  Error: %@", error);
}

// May want to set the self instance to nil and remove self as delegate
-(void)disconnect
{
    [self.xmppStream disconnect];
}

@end
