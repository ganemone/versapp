//
//  PresencePacketReceiver.m
//  Who
//
//  Created by Giancarlo Anemone on 2/5/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "PresencePacketReceiver.h"
#import "GroupChatManager.h"
#import "GroupChat.h"
#import "Constants.h"

@implementation PresencePacketReceiver

+(void)handlePresencePacket:(XMPPPresence *)presence {
    NSArray *namespaces = [presence namespaces];
    for (int i = 0; i < namespaces.count; i++) {
        NSLog(@"Name Space: %@", [[namespaces objectAtIndex:i] description]);
    }
    
    NSError *error;
    NSRegularExpression *createGroupRegex = [NSRegularExpression regularExpressionWithPattern:@"<presence.xmlns=\"jabber:client\".from=\"(.*?)@.*?\".to=\"(.*?)\"><x xmlns=\"(.*?)\"><item.jid=\"(.*?)\".affiliation=\"owner\".role=\"moderator\"\\/><status.code=\"201\"\\/><\\/x><\\/presence>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [createGroupRegex firstMatchInString:presence.XMLString options:0 range:NSMakeRange(0, presence.XMLString.length)];
    if ([match numberOfRanges] > 0) {
        NSString *from = [presence.XMLString substringWithRange:[match rangeAtIndex:1]];
        //NSString *to = [presence.XMLString substringWithRange:[match rangeAtIndex:2]];
        NSString *xmlns = [presence.XMLString substringWithRange:[match rangeAtIndex:3]];
        //NSString *jid = [presence.XMLString substringWithRange:[match rangeAtIndex:4]];
        if ([xmlns compare:@"http://jabber.org/protocol/muc#user"] == 0) {
            GroupChatManager *gcm = [GroupChatManager getInstance];
            GroupChat *gc = [gcm getChat:from];
            [gc invitePendingParticpants];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CREATED_MUC object:nil];
        }
    }
}

@end
