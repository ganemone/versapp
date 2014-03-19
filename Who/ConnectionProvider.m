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

#import "Confession.h"
#import "AppDelegate.h"
#import "XMPPReconnect.h"
#import "XMPPAutoPing.h"

#import "MUCCreationManager.h"
#import "LoginManager.h"

#import "ContactSearchManager.h"
@interface ConnectionProvider ()

@property(strong, nonatomic) XMPPReconnect *xmppReconnect;
@property(strong, nonatomic) XMPPAutoPing *xmppPing;
@property(strong, nonatomic) XMPPStream* xmppStream;
@property(strong, nonatomic) NSString* username;
@property(strong, nonatomic) NSString* password;
@property(strong, nonatomic) NSString* SERVER_IP_ADDRESS;
@property(strong, nonatomic) NSString* CONFERENCE_IP_ADDRESS;
@property(strong, nonatomic) NSDictionary *pendingAccountInfo;

@property BOOL isCreatingAccount;

@end

static ConnectionProvider *selfInstance;

@implementation ConnectionProvider

// Class method (+) for getting instance of Connection Provider
+ (id)getInstance {
    @synchronized(self) {
        if(selfInstance == nil) {
            selfInstance = [[self alloc] init];
            selfInstance.SERVER_IP_ADDRESS = @"ejabberd.versapp.co";
            selfInstance.CONFERENCE_IP_ADDRESS = @"conference.ejabberd.versapp.co";
            selfInstance.xmppReconnect = [[XMPPReconnect alloc] initWithDispatchQueue:dispatch_get_main_queue()];
            [selfInstance.xmppReconnect addDelegate:self delegateQueue:dispatch_get_main_queue()];
            selfInstance.xmppPing = [[XMPPAutoPing alloc] initWithDispatchQueue:dispatch_get_main_queue()];
            selfInstance.xmppPing.pingInterval = 25.f; // default is 60
            selfInstance.xmppPing.pingTimeout = 10.f; // default is 10
            [selfInstance.xmppPing addDelegate:self delegateQueue:dispatch_get_main_queue()];
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
    self.isCreatingAccount = NO;
    
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

- (void) createAccount:(NSDictionary*)accountInfo {
    NSLog(@"Trying to create an account...");
    self.authenticated = NO;
    self.didConnect = NO;
    self.isCreatingAccount = YES;
    self.pendingAccountInfo = accountInfo;
    [self.xmppStream setHostName:self.SERVER_IP_ADDRESS];
    self.xmppStream.myJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", [accountInfo objectForKey:VCARD_TAG_USERNAME], self.SERVER_IP_ADDRESS]];
    NSError *error = nil;
    if(![self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
        NSLog(@"Failed to connection due to some error %@", error);
    } else {
        NSLog(@"Connected Successfully... about to create an account");
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
    
    if (self.isCreatingAccount == YES) {
        NSLog(@"Trying to create an account");
        BOOL success = [[self xmppStream] registerWithPassword:[self.pendingAccountInfo objectForKey:USER_DEFAULTS_PASSWORD] error:&error];
        if (success) {
            NSLog(@"Creating Account");
        } else {
            NSLog(@"Failed to create account");
        }
    }
    else {
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
    self.didConnect = YES;
    
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"XMPP Stream Did Authenticate");
    [self.xmppReconnect activate:self.xmppStream];
    self.authenticated = YES;
    if (self.isCreatingAccount == YES) {
        NSLog(@"Creating VCard...");
        [self.xmppStream sendElement:
         [IQPacketManager createCreateVCardPacket:[self.pendingAccountInfo objectForKey:VCARD_TAG_FIRST_NAME]
                                         lastname:[self.pendingAccountInfo objectForKey:VCARD_TAG_LAST_NAME]
                                            phone:[self.pendingAccountInfo objectForKey:VCARD_TAG_USERNAME]
                                            email:[self.pendingAccountInfo objectForKey:VCARD_TAG_EMAIL]]];
        self.isCreatingAccount = NO;
    }
    [self.xmppStream sendElement:[IQPacketManager createAvailabilityPresencePacket]];
    [self.xmppStream sendElement:[IQPacketManager createGetConnectedUserVCardPacket]];
    //[self.xmppStream sendElement:[IQPacketManager createGetLastTimeActivePacket]];
    [self.xmppStream sendElement:[IQPacketManager createGetJoinedChatsPacket]];
    [self.xmppStream sendElement:[IQPacketManager createGetRosterPacket]];
    //[self.xmppStream sendElement:[IQPacketManager createGetSessionIDPacket]];
    [self.xmppStream sendElement:[IQPacketManager createGetConfessionsPacket]];
    [self.xmppStream sendElement:[IQPacketManager createGetPendingChatsPacket]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"authenticated" object:nil];
}
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    NSLog(@"did not authenticate");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didNotAuthenticate" object:nil];
    [self.xmppStream disconnect];
}

-(void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    NSLog(@"XMPPStream Disconnected.  Error: %@", error);
    //AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    //[delegate handleConnectionLost];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_STREAM_DID_DISCONNECT object:nil];
}

// May want to set the self instance to nil and remove self as delegate
-(void)disconnect
{
    [self.xmppStream disconnect];
}
-(void)xmppStream:(XMPPStream *)sender didReceiveError:(DDXMLElement *)error {
    NSLog(@"didReceiveError: %@", error.XMLString);
}

-(void)xmppStream:(XMPPStream *)sender didReceiveP2PFeatures:(DDXMLElement *)streamFeatures {
    NSLog(@"Received P2P Features: %@", streamFeatures.XMLString);
}

-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    NSLog(@"didReceiveMessage: %@", message);
    [MessagePacketReceiver handleMessagePacket:message];
}

-(void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
    NSLog(@"didSendMessage %@", message.XMLString);
}

-(void)xmppStream:(XMPPStream *)sender didSendPresence:(XMPPPresence *)presence {
    NSLog(@"didSendPresence: %@", presence.XMLString);
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

-(void)xmppAutoPingDidSendPing:(XMPPAutoPing *)sender {
    NSLog(@"Did send ping...");
}

-(void)xmppAutoPingDidReceivePong:(XMPPAutoPing *)sender {
    NSLog(@"Did receive pong...");
}

-(BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkConnectionFlags)connectionFlags {
    NSLog(@"Should attempt auto reconnect: %u", connectionFlags);
    return true;
}

-(void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags {
    NSLog(@"Did detect accidental disconnect...");
}

-(void)xmppStreamDidRegister:(XMPPStream *)sender {
    NSLog(@"Registered Account!");
    self.username = [self.pendingAccountInfo objectForKey:VCARD_TAG_USERNAME];
    self.password = [self.pendingAccountInfo objectForKey:USER_DEFAULTS_PASSWORD];
    
    [LoginManager savePassword:self.username];
    [LoginManager saveUsername:self.password];
    NSError *error = nil;
    if ([[self xmppStream] authenticateWithPassword:self.password error:&error])
    {
        NSLog(@"Authentificated to XMPP.");
    }
    else
    {
        NSLog(@"Error authentificating to XMPP: %@", [error localizedDescription]);
    }
}

-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error {
    DDXMLElement *errorXML = [error elementForName:@"error"];
    NSString *errorCode  = [[errorXML attributeForName:@"code"] stringValue];
    
    NSString *regError = [NSString stringWithFormat:@"ERROR :- %@",error.description];
    
    if([errorCode isEqualToString:@"409"]){
        NSLog(@"Username already exists");
    }
    
    NSLog(@"%@", regError);
}

@end
