//
//  PresencePacketReceiver.h
//  Who
//
//  Created by Giancarlo Anemone on 2/5/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPPresence.h"

@interface PresencePacketReceiver : NSObject

+(void)handlePresencePacket:(XMPPPresence*)presence;

@end
