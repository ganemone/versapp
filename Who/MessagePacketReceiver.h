//
//  MessagePacketReceiver.h
//  Who
//
//  Created by Giancarlo Anemone on 2/5/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPMessage.h"

@interface MessagePacketReceiver : NSObject

+(void)handleMessagePacket:(XMPPMessage *)message;

@end
