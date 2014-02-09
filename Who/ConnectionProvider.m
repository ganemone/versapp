//
//  ConnectionProvider.m
//  Who
//
//  Created by Giancarlo Anemone on 1/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ConnectionProvider.h"
// XMPP Helper Classes
#import "XMPPJID.h"
#import "XMPPIQ.h"
#import "XMPPPresence.h"
#import "XMPPMessage.h"
// Packet Receivers
#import "IQPacketReceiver.h"
#import "PresencePacketReceiver.h"
#import "MessagePacketReceiver.h"
// Packet Related Helper Classes
#import "Constants.h"
#import "IQPacketManager.h"
#import "MUCCreationManager.h"


@interface ConnectionProvider ()

@property(strong, nonatomic) XMPPStream* xmppStream;
@property(strong, nonatomic) NSString* username;
@property(strong, nonatomic) NSString* password;
@property(strong, nonatomic) NSString* SERVER_IP_ADDRESS;
@property(strong, nonatomic) NSString* CONFERENCE_IP_ADDRESS;

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
            [selfInstance addSelfStreamDelegate];
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
    self.authenticated = NO;
    self.didConnect = NO;
    
    NSLog(@"Server IP Address %@", self.SERVER_IP_ADDRESS);
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

- (void) connectAdmin {
    self.authenticated = NO;
    self.didConnect = NO;
    
    NSLog(@"Server IP Address %@", self.SERVER_IP_ADDRESS);
    
    [self.xmppStream setHostName:self.SERVER_IP_ADDRESS];
    self.username = @"admin";
    self.password = @"kalamazoo123";
    self.xmppStream.myJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"admin@%@", self.SERVER_IP_ADDRESS]];
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
    
    self.didConnect = YES;
    
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"XMPP Stream Did Authenticate");
    NSLog(@"%s", __FUNCTION__);
    self.authenticated = YES;
    if([self.username compare:@"admin"] == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ADMIN_AUTHENTICATED object:nil];
    } else {
        [self.xmppStream sendElement:[IQPacketManager createAvailabilityPresencePacket]];
        [self.xmppStream sendElement:[IQPacketManager createGetConnectedUserVCardPacket]];
        [self.xmppStream sendElement:[IQPacketManager createGetLastTimeActivePacket]];
        [self.xmppStream sendElement:[IQPacketManager createGetJoinedChatsPacket]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"authenticated" object:nil];
    }
}

-(void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    NSLog(@"XMPPStream Disconnected.  Error: %@", error);
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STREAM_DID_DISCONNECT object:nil];
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
    NSLog(@"Received Message: %@", message);
    [MessagePacketReceiver handleMessagePacket:message];
}

-(void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
    NSLog(@"Sent Message! %@", message.XMLString);
}

-(void)xmppStream:(XMPPStream *)sender didSendPresence:(XMPPPresence *)presence {
    NSLog(@"Send Presence: %@", presence.XMLString);
}

-(void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    [PresencePacketReceiver handlePresencePacket:presence];
}

-(void)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error {
    NSLog(@"didFailToSendIQ. Error: %@", error);
}

-(BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
    NSLog(@"didReceiveIQ %@", [iq XMLString]);
    [IQPacketReceiver handleIQPacket:iq];
    return YES;
}

-(void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq {
    NSLog(@"didSendIQ: %@", iq.XMLString);
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
