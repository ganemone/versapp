//
//  PresencePacketReceiver.m
//  Who
//
//  Created by Giancarlo Anemone on 2/5/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "PresencePacketReceiver.h"
#import "GroupChatManager.h"

@implementation PresencePacketReceiver

+(void)handlePresencePacket:(XMPPPresence *)presence {
    NSLog(@"Received Presence Packet: \n\n %@ \n\n", presence.XMLString);
    NSLog(@"Presence From STR: %@", [presence fromStr]);
    NSLog(@"Presence To: %@", [presence toStr]);
    NSLog(@"Presence Name: %@", [presence name]);
    NSArray *namespaces = [presence namespaces];
    for (int i = 0; i < namespaces.count; i++) {
        NSLog(@"Name Space: %@", [[namespaces objectAtIndex:i] description]);
    }
    
    NSError *error;
    NSRegularExpression *createGroupRegex = [NSRegularExpression regularExpressionWithPattern:@"<presence.xmlns=\"jabber:client\".from=\"(.*?)@.*?\".to=\"(.*?)\"><x xmlns=\"(.*?)\"><item.jid=\"(.*?)\".affiliation=\"owner\".role=\"moderator\"\\/><status.code=\"201\"\\/><\\/x><\\/presence>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [createGroupRegex firstMatchInString:presence.XMLString options:0 range:NSMakeRange(0, presence.XMLString.length)];
    if ([match numberOfRanges] > 0) {
        
    }
}

@end
