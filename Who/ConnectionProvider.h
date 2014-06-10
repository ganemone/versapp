//
//  ConnectionProvider.h
//  Who
//
//  Created by Giancarlo Anemone on 1/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPStream.h"
#import "IQPacketReceiver.h"
#import "LoginViewController.h"
#import "XMPPAutoPing.h"
#import "XMPPReconnect.h"

// A class that handles connecting and authenticating to xmpp. Implements a
// singleton pattern to allow connection functionality across the application.
// Extends from NSObject and implements the <XMPPStreamDelegate> interface to
// allow for helpful callback methods.
@interface ConnectionProvider : NSObject  <XMPPStreamDelegate, XMPPAutoPingDelegate, XMPPReconnectDelegate>

@property(strong, nonatomic) NSString *pendingParticipantsChatID;
@property(strong, nonatomic) NSMutableDictionary *tempVCardInfo;
@property BOOL authenticated;
@property BOOL didConnect;
//@property BOOL shouldAlertUserWithAddedFriends;

// Singleton pattern - returns shared instance of connectionProvider.
+ (id) getInstance;

// Attempts to connect to the xmpp server with the credentials username/password
// passed as parameters.
- (void) connect:(NSString*)username password:(NSString*)password;
- (void) connectForPushNotificationFetch:(NSString *)username password:(NSString *) password;
- (void) disconnect;
- (XMPPStream*) getConnection;
- (void) addStreamDelegate: (id)streamDelegate;
+ (NSString*) getServerIPAddress;
+ (NSString*) getConferenceIPAddress;
+ (NSString*) getUser;
- (void) createAccount:(NSDictionary*)accountInfo;
- (void)addName:(NSString *)name forUsername:(NSString *)username;

@end
