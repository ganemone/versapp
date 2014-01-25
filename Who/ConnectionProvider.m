//
//  ConnectionProvider.m
//  Who
//
//  Created by Giancarlo Anemone on 1/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ConnectionProvider.h"
#import "XMPPJID.h"
#import "XMPPIQ.h"
#import "XMPPPresence.h"
#import "XMPPMessage.h"
#import "MainTabBarController.h"
#import "RequestsViewController.h"
#import "IQPacketManager.h"
#import "Constants.h"
#import "LoginViewController.h"

@interface ConnectionProvider ()

@property(strong, nonatomic) XMPPStream* xmppStream;
@property(strong, nonatomic) NSString* username;
@property(strong, nonatomic) NSString* password;
@property(strong, nonatomic) NSString* SERVER_IP_ADDRESS;
@property(strong, nonatomic) NSString* CONFERENCE_IP_ADDRESS;
@property(strong, nonatomic) LoginViewController *loginView;

@end

static ConnectionProvider *selfInstance;

@implementation ConnectionProvider


// Class method (+) for getting instance of Connection Provider
+ (id)getInstance {
    @synchronized(self) {
        if(selfInstance == nil) {
            selfInstance = [[self alloc] init];
            selfInstance.SERVER_IP_ADDRESS = @"199.175.55.10";
            selfInstance.CONFERENCE_IP_ADDRESS = @"conference.199.175.55.10";
        }
    }
    return selfInstance;
}

// Returns connection stream object
- (XMPPStream *)getConnection
{
    return self.xmppStream;
}

- (void) connect: (NSString*)username password:(NSString*) password {
    self.authenticated = false;
    self.didConnect = false;
    
    NSLog(@"Server IP Address %@", self.SERVER_IP_ADDRESS);
    [self addSelfStreamDelegate];
    [self.xmppStream setHostName:self.SERVER_IP_ADDRESS];
    self.username = username;
    self.password = password;
    self.xmppStream.myJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@/%@", self.username, self.SERVER_IP_ADDRESS, APPLICATION_RESOURCE]];

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
    
    self.didConnect = true;
    
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"XMPP Stream Did Authenticate");
    NSLog(@"%s", __FUNCTION__);
    self.authenticated = true;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"authenticated" object:nil];
    [self.xmppStream sendElement:[IQPacketManager createGetJoinedChatsPacket]];
    [self.xmppStream sendElement:[IQPacketManager createGetLastTimeActivePacket]];
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
-(void)xmppStream:(XMPPStream *)sender didReceiveError:(DDXMLElement *)error {
    NSLog(@"Received Error: %@", error.XMLString);
}

-(void)xmppStream:(XMPPStream *)sender didReceiveP2PFeatures:(DDXMLElement *)streamFeatures {
    NSLog(@"Received P2P Features: %@", streamFeatures.XMLString);
}

-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    [self handleMessagePacket:message];
}

-(void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    NSLog(@"Received Presence: %@", presence.XMLString);
}

-(void)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error {
    NSLog(@"didFailToSendIQ. Error: %@", error);
}

-(BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
    NSLog(@"didReceiveIQ %@", [iq XMLString]);
    [self handleIQPacket:iq];
    return true;
}

-(void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq {
    NSLog(@"didSendIQ");
}

+(NSString *)getServerIPAddress {
    return [[self getInstance] SERVER_IP_ADDRESS];
}

+(NSString *)getConferenceIPAddress {
    return [[self getInstance] CONFERENCE_IP_ADDRESS];
}

+(NSString *)getUser {
    return [[self getInstance] username];
}


@end
