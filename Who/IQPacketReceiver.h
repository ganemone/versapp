//
//  IQPacketReceiver.h
//  Who
//
//  Created by Giancarlo Anemone on 1/15/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPIQ.h"
#import "XMPPMessage.h"

@interface IQPacketReceiver : NSObject<NSXMLParserDelegate>

+(void)handleIQPacket:(XMPPIQ*)iq;

@end
