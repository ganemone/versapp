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
#import "PhoneVerificationManager.h"

#import "Confession.h"
#import "AppDelegate.h"
#import "XMPPReconnect.h"
#import "XMPPAutoPing.h"

#import "MUCCreationManager.h"
#import "UserDefaultManager.h"

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
@property BOOL isFetchingFromNotification;

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
            selfInstance.tempVCardInfo = [[NSMutableDictionary alloc] initWithCapacity:5];
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
    
    [self.xmppStream setHostName:self.SERVER_IP_ADDRESS];
    self.username = username;
    self.password = password;
    self.xmppStream.myJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@/%@", self.username, self.SERVER_IP_ADDRESS, APPLICATION_RESOURCE]];
    
    NSError *error = nil;
    if(![self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
        //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FAILED_TO_AUTHENTICATE object:self];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CONNECTING object:self];
}

- (void) connectForPushNotificationFetch:(NSString *)username password:(NSString *) password {
    _isFetchingFromNotification = YES;
    [self connect:username password:password];
}

- (void) createAccount:(NSDictionary*)accountInfo {
    self.authenticated = NO;
    self.didConnect = NO;
    self.isCreatingAccount = YES;
    self.pendingAccountInfo = accountInfo;
    [self.xmppStream setHostName:self.SERVER_IP_ADDRESS];
    self.xmppStream.myJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", [accountInfo objectForKey:FRIENDS_TABLE_COLUMN_NAME_USERNAME], self.SERVER_IP_ADDRESS]];
    NSError *error = nil;
    if ([self.xmppStream isConnected]) {
        [self.xmppStream disconnect];
    }
    if(![self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DID_FAIL_TO_REGISTER_USER object:nil];
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
        BOOL success = [[self xmppStream] registerWithPassword:[self.pendingAccountInfo objectForKey:USER_DEFAULTS_PASSWORD] error:&error];
        if (success) {
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DID_FAIL_TO_REGISTER_USER object:nil];
        }
    }
    else {
        if (![[self xmppStream] authenticateWithPassword:self.password error:&error]) {
            //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FAILED_TO_AUTHENTICATE object:nil];
        }
    }
    self.didConnect = YES;
    
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    //[self.xmppReconnect activate:self.xmppStream];
    self.authenticated = YES;
    if (self.isCreatingAccount == YES) {
        [self.xmppStream sendElement:[IQPacketManager createCreateVCardPacket:[_pendingAccountInfo objectForKey:VCARD_TAG_FIRST_NAME] lastname:[_pendingAccountInfo objectForKey:VCARD_TAG_LAST_NAME]]];
        self.isCreatingAccount = NO;
        [self.xmppStream sendElement:[IQPacketManager createSetUserInfoPacketFromDefaults]];
        [self.xmppStream sendElement:[IQPacketManager createAvailabilityPresencePacket]];
        [self.xmppStream sendElement:[IQPacketManager createGetSessionIDPacket]];
    } else if(_isFetchingFromNotification == YES) {
        _isFetchingFromNotification = NO;
        [self.xmppStream sendElement:[IQPacketManager createAvailabilityPresencePacket]];
        [self.xmppStream sendElement:[IQPacketManager createGetJoinedChatsPacket]];
        [self.xmppStream sendElement:[IQPacketManager createGetPendingChatsPacket]];
        //[self.xmppStream sendElement:[IQPacketManager createGetRosterPacket]];
    } else {
        [self.xmppStream sendElement:[IQPacketManager createGetUserInfoPacket]];
        [self.xmppStream sendElement:[IQPacketManager createGetSessionIDPacket]];
        [self.xmppStream sendElement:[IQPacketManager createAvailabilityPresencePacket]];
        [self.xmppStream sendElement:[IQPacketManager createGetConnectedUserVCardPacket]];
        [self.xmppStream sendElement:[IQPacketManager createGetJoinedChatsPacket]];
        [self.xmppStream sendElement:[IQPacketManager createGetRosterPacket]];
        [self.xmppStream sendElement:[IQPacketManager createGetPendingChatsPacket]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_AUTHENTICATED object:nil];
    NSString *deviceID = [UserDefaultManager loadDeviceID];
    if (deviceID != nil) {
        [self.xmppStream sendElement:[IQPacketManager createSetDeviceTokenPacket:deviceID]];
    }
}
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"didNotAuthenticate" object:nil];
    [self.xmppStream disconnect];
}

-(void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
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
    //NSLog(@"Did Receive Error: %@", error);
}

-(void)xmppStream:(XMPPStream *)sender didReceiveP2PFeatures:(DDXMLElement *)streamFeatures {
}

-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    //NSLog(@"Received Message: %@", message.XMLString);
    [MessagePacketReceiver handleMessagePacket:message];
}

-(void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message {
    //NSLog(@"Did Send Message: %@", [message description]);
}

-(void)xmppStream:(XMPPStream *)sender didSendPresence:(XMPPPresence *)presence {
    //NSLog(@"Did send presence: %@", presence.XMLString);
}

-(void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    [PresencePacketReceiver handlePresencePacket:presence];
}

-(void)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error {
}

-(BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
    NSLog(@"Received IQ: %@", iq.XMLString);
    [IQPacketReceiver handleIQPacket:iq];
    return YES;
}

-(void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq {
    NSLog(@"Did Send IQ: %@", iq.XMLString);
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
}

-(void)xmppAutoPingDidReceivePong:(XMPPAutoPing *)sender {
}

-(BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkConnectionFlags)connectionFlags {
    return true;
}

-(void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags {
}

-(void)xmppStreamDidRegister:(XMPPStream *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DID_REGISTER_USER object:nil];
    
    self.username = [self.pendingAccountInfo objectForKey:FRIENDS_TABLE_COLUMN_NAME_USERNAME];
    self.password = [self.pendingAccountInfo objectForKey:USER_DEFAULTS_PASSWORD];
    
    [UserDefaultManager saveUsername:self.username];
    [UserDefaultManager savePassword:self.password];
    [UserDefaultManager saveEmail:[self.pendingAccountInfo objectForKey:FRIENDS_TABLE_COLUMN_NAME_EMAIL]];
    
    NSError *error = nil;
    if (![[self xmppStream] authenticateWithPassword:self.password error:&error]) {
        //[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FAILED_TO_AUTHENTICATE object:nil];
    }
}

-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error {
    DDXMLElement *errorXML = [error elementForName:@"error"];
    NSString *errorCode  = [[errorXML attributeForName:@"code"] stringValue];
    NSString *errorMessage;
    if([errorCode isEqualToString:@"409"]){
        errorMessage = @"Username already exists";
    } else if([errorCode isEqualToString:@"500"]) {
        errorMessage = @"You can't register for multiple accounts from a single device.";
    } else {
        errorMessage = @"Failed to register user. Please check your network connection";
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_DID_FAIL_TO_REGISTER_USER
                                                        object:nil
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:errorCode, DICTIONARY_KEY_ERROR_CODE, errorMessage, DICTIONARY_KEY_ERROR_MESSAGE, nil]];
}

-(void)addName:(NSString *)name forUsername:(NSString *)username {
    [_tempVCardInfo setObject:name forKey:username];
}

@end
