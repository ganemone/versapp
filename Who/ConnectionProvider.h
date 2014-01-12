//
//  ConnectionProvider.h
//  Who
//
//  Created by Giancarlo Anemone on 1/11/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPStream.h"

// A class that handles connecting and authenticating to xmpp. Implements a
// singleton pattern to allow connection functionality across the application.
// Extends from NSObject and implements the <XMPPStreamDelegate> interface to
// allow for helpful callback methods.
@interface ConnectionProvider : NSObject <XMPPStreamDelegate>

// Singleton pattern - returns shared instance of connectionProvider.
+ (id) getInstance;

// Attempts to connect to the xmpp server with the credentials username/password
// passed as parameters.
- (void) connect:(NSString*)username password:(NSString*)password;

- (void) disconnect;

- (XMPPStream*) getConnection;

@end
