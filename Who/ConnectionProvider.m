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
#import "MainTabBarController.h"
#import "RequestsViewController.h"

@interface ConnectionProvider ()

@property(strong, nonatomic) XMPPStream* xmppStream;
@property(strong, nonatomic) NSString* username;
@property(strong, nonatomic) NSString* password;
@property(strong, nonatomic) NSString* SERVER_IP_ADDRESS;

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
    [self addSelfStreamDelegate];
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

- (void) addSelfStreamDelegate
{
    if(self.xmppStream == nil) {
        self.xmppStream = [[XMPPStream alloc] init];
    }
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
}

- (void) addStreamDelegate: (id)streamDelegate
{
    [self.xmppStream addDelegate:streamDelegate delegateQueue:dispatch_get_main_queue()];
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
    //MainTabBarController *main = [[MainTabBarController alloc] init];
    RequestsViewController *main = [[RequestsViewController alloc] init];
    NSLog(@"Initialized Main Tab Bar Controller");
    [self.controller presentViewController:main animated:YES completion:NULL];
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
