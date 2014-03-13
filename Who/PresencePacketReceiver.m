//
//  PresencePacketReceiver.m
//  Who
//
//  Created by Giancarlo Anemone on 2/5/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "PresencePacketReceiver.h"
#import "Constants.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"
#import "FriendsDBManager.h"

@implementation PresencePacketReceiver

+(void)handlePresencePacket:(XMPPPresence *)presence {
    NSArray *namespaces = [presence namespaces];
    for (int i = 0; i < namespaces.count; i++) {
        NSLog(@"Name Space: %@", [[namespaces objectAtIndex:i] description]);
    }
    
    // -----------------
    // Group Was Created
    // -----------------
    NSError *error;
    NSRegularExpression *createGroupRegex = [NSRegularExpression regularExpressionWithPattern:@"<presence.xmlns=\"jabber:client\".from=\"(.*?)@.*?\".to=\"(.*?)\"><x xmlns=\"(.*?)\"><item.jid=\"(.*?)\".affiliation=\"owner\".role=\"moderator\"\\/><status.code=\"201\"\\/><\\/x><\\/presence>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [createGroupRegex firstMatchInString:presence.XMLString options:0 range:NSMakeRange(0, presence.XMLString.length)];
    if ([match numberOfRanges] > 0) {
        NSString *from = [presence.XMLString substringWithRange:[match rangeAtIndex:1]];
        //NSString *to = [presence.XMLString substringWithRange:[match rangeAtIndex:2]];
        NSString *xmlns = [presence.XMLString substringWithRange:[match rangeAtIndex:3]];
        //NSString *jid = [presence.XMLString substringWithRange:[match rangeAtIndex:4]];
        if ([xmlns compare:@"http://jabber.org/protocol/muc#user"] == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CREATED_MUC object:nil];
        }
    }
    else if([presence.elementID isEqualToString:PACKET_ID_JOIN_MUC]) {
        NSLog(@"joined muc...");
    }
    // -----------------------
    // Handle Friend Request
    // -----------------------
    // Accept
    else {
        NSString *jid = [[[presence fromStr] componentsSeparatedByString:@"/"] firstObject];
        NSString *username = [[[presence fromStr] componentsSeparatedByString:@"@"] firstObject];
        XMPPStream *conn = [[ConnectionProvider getInstance] getConnection];
        NSLog(@"Friend Request Presence: %@", presence.XMLString);
        if ([FriendsDBManager hasUserWithJID:username] == NO && [username compare:[ConnectionProvider getUser]] != 0) {
            [conn sendElement:[IQPacketManager createGetVCardPacket:username]];
        }
        // Packet represents a friend request
        if ([presence.type compare:@"subscribe"] == 0) {
            NSLog(@"Adding Pending Friend...");
            [FriendsDBManager insert:username name:nil email:nil status:[NSNumber numberWithInt:STATUS_PENDING] searchedPhoneNumber:nil searchedEmail:nil];
        }
        // Friend accepted connected users request
        // => move friend to contacts
        else if([presence.type compare:@"subscribed"] == 0) {
            [conn sendElement:[IQPacketManager createForceCreateRosterEntryPacket:jid]];
            [FriendsDBManager updateUserSetStatusFriends:username];
        }
        // Remove friend from roster...
        else if([presence.type compare:@"unsubscribed"] == 0) {
            NSLog(@"Friend Request Type unsubscribed");
            [FriendsDBManager updateUserSetStatusRejected:username];
        }
        // Return unsubscribed packet + remove friend from roster
        else if([presence.type compare:@"unsubscribe"] == 0) {
            NSLog(@"Friend Request Type unsubscribe");
            [FriendsDBManager updateUserSetStatusRejected:username];
        }
    }
}

@end
