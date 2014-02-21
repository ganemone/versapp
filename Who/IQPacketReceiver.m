//
//  IQPacketReceiver.m
//  Who
//
//  Created by Giancarlo Anemone on 1/15/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "IQPacketReceiver.h"
#import "Constants.h"
#import "GroupChat.h"
#import "GroupChatManager.h"
#import "OneToOneChatManager.h"
#import "ChatParticipantVCardBuffer.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"
#import "FriendsDBManager.h"
#import "MessagesDBManager.h"
#import "UserProfile.h"
#import "AppDelegate.h"

#import "Confession.h"
#import "ConfessionsManager.h"

@implementation IQPacketReceiver

+(bool)isPacketWithID:(NSString *)packetID packet:(XMPPIQ *)packet {
    return ([packet.elementID compare:packetID] == 0);
}

+(void)handleIQPacket:(XMPPIQ *)iq {
    if([self isPacketWithID:PACKET_ID_CREATE_VCARD packet:iq]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_CREATE_VCARD object:nil];
    } else if([self isPacketWithID:PACKET_ID_GET_JOINED_CHATS packet:iq]) {
        [self handleGetJoinedChatsPacket:iq];
    } else if([self isPacketWithID:PACKET_ID_GET_PENDING_CHATS packet:iq]) {
        [self handleGetPendingChatsPacket:iq];
    } else if([self isPacketWithID:PACKET_ID_GET_ROSTER packet:iq]) {
        [self handleGetRosterPacket: iq];
        
    } else if([self isPacketWithID:PACKET_ID_JOIN_MUC packet:iq]) {
        
    } else if([self isPacketWithID:PACKET_ID_REGISTER_USER packet:iq]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_REGISTER_USER object:nil];
    } else if([self isPacketWithID:PACKET_ID_GET_LAST_TIME_ACTIVE packet:iq]) {
        [self handleGetLastTimeActivePacket:iq];
    } else if([self isPacketWithID:PACKET_ID_GET_SERVER_TIME packet:iq]) {
        [self handleGetServerTimePacket:iq];
    } else if([self isPacketWithID:PACKET_ID_GET_VCARD packet:iq]) {
        [self handleGetVCardPacket:iq];
    } else if([self isPacketWithID:PACKET_ID_INVITE_USER_TO_CHAT packet:iq]) {
        [self handleInviteUserToChatPacket:iq];
    } else if([self isPacketWithID:PACKET_ID_CREATE_ONE_TO_ONE_CHAT packet:iq]) {
        [self handleCreateOneToOneChatPacket:iq];
    } else if([self isPacketWithID:PACKET_ID_GET_SESSION_ID packet:iq]) {
        [self handleGetSessionIDPacket:iq];
    } else if([self isPacketWithID:PACKET_ID_GET_CONFESSIONS packet:iq]) {
        [self handleGetConfessionsPacket:iq];
    } else if([self isPacketWithID:PACKET_ID_GET_MY_CONFESSIONS packet:iq]) {
        [self handleGetMyConfessionsPacket:iq];
    } else if([self isPacketWithID:PACKET_ID_FAVORITE_CONFESSION packet:iq]) {
        [self handleToggleFavoriteConfessionPacket:iq];
    } else if([self isPacketWithID:PACKET_ID_POST_CONFESSION packet:iq]) {
        [self handlePostConfessionPacket:iq];
    }
}

+(void)handleGetJoinedChatsPacket:(XMPPIQ *)iq {
    NSLog(@"Joined Chats Packet: %@", iq.XMLString);
    NSError *error = NULL;
    
    NSString *packetXML = [self getPacketXMLWithoutNewLines:iq];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\{\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\"\\}" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:packetXML options:0 range:NSMakeRange(0, packetXML.length)];
    GroupChatManager *gcm = [GroupChatManager getInstance];
    OneToOneChatManager *cm = [OneToOneChatManager getInstance];
    for (NSTextCheckingResult *match in matches) {
        NSString *participantString = [packetXML substringWithRange:[match rangeAtIndex:1]];
        NSArray *participants = [participantString componentsSeparatedByString:@", "];
        NSString* chatId = [packetXML substringWithRange:[match rangeAtIndex:2]];
        NSString* type = [packetXML substringWithRange:[match rangeAtIndex:3]];
        NSString* owner = [packetXML substringWithRange:[match rangeAtIndex:4]];
        NSString* name = [packetXML substringWithRange:[match rangeAtIndex:5]];
        NSString* createdTime = [packetXML substringWithRange:[match rangeAtIndex:6]];
        if([owner compare:participantString] == 0) {
            participantString = [ConnectionProvider getUser];
        }
        if([type isEqualToString:CHAT_TYPE_GROUP]) {
            [gcm addChat:[GroupChat create:chatId participants:participants groupName:name owner:owner createdTime:createdTime]];
        } else if([type isEqualToString:CHAT_TYPE_ONE_TO_ONE]) {
            [cm addChat:[OneToOneChat create:chatId inviterID:owner invitedID:participantString createdTimestamp:createdTime]];
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_CHAT_LIST object:nil];
}

+(void)handleGetLastTimeActivePacket:(XMPPIQ *)iq {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\{\"(.*?)\"\\}" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:iq.XMLString options:0 range:NSMakeRange(0, iq.XMLString.length)];
    NSString *timestamp = [iq.XMLString substringWithRange:[match rangeAtIndex:1]];
    NSDictionary *userInfo;
    if([timestamp compare:@""] == 0) {
        userInfo = [NSDictionary dictionaryWithObject:@"1970-01-01T00:00:00Z" forKey:PACKET_ID_GET_LAST_TIME_ACTIVE];
        [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_GET_LAST_TIME_ACTIVE object:nil userInfo:userInfo];
    } else {
        NSTimeInterval interval= [timestamp doubleValue];
        NSDate *gregDate = [NSDate dateWithTimeIntervalSince1970: interval];
        NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        NSString *utcStringDate =[formatter stringFromDate:gregDate];
        userInfo = [NSDictionary dictionaryWithObject:utcStringDate forKey:PACKET_ID_GET_LAST_TIME_ACTIVE];
    }
    GroupChatManager *gcm = [GroupChatManager getInstance];
    [gcm setTimeForHistory:[userInfo objectForKey:PACKET_ID_GET_LAST_TIME_ACTIVE]];
    [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_GET_LAST_TIME_ACTIVE object:nil userInfo:userInfo];
}

+(void)handleGetServerTimePacket:(XMPPIQ *)packet {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<utc>(.*?)<\\/utc>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:packet.XMLString options:0 range:NSMakeRange(0, packet.XMLString.length)];
    NSString *utcTime = [packet.XMLString substringWithRange:[match rangeAtIndex:1]];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:utcTime forKey:PACKET_ID_GET_SERVER_TIME];
    [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_GET_SERVER_TIME object:nil userInfo:userInfo];
}

+(void)handleGetVCardPacket:(XMPPIQ *)packet {
    NSString *firstName, *lastName, *username, *email, *itemName, *nickname;
    NSArray *children = [packet children];
    for (int i = 0; i < children.count; i++) {
        NSArray *grand = [[children objectAtIndex:i] children];
        NSLog(@"Child: %@", [[children objectAtIndex:i] XMLString]);
        for (int j = 0; j < grand.count; j++) {
            itemName = [[grand objectAtIndex:j] name];
            if([itemName compare:VCARD_TAG_NICKNAME] == 0) {
                nickname = [[grand objectAtIndex:j] stringValue];
            } else if([itemName compare:VCARD_TAG_EMAIL] == 0) {
                email = [[grand objectAtIndex:j] stringValue];
            } else if([itemName compare:VCARD_TAG_USERNAME] == 0) {
                username = [[grand objectAtIndex:j] stringValue];
            } else if([itemName compare:@"N"] == 0) {
                NSArray *nameItems = [[grand objectAtIndex:j] children];
                for(int k = 0; k < nameItems.count; k++) {
                    itemName = [[nameItems objectAtIndex:k] name];
                    if ([itemName compare:VCARD_TAG_FIRST_NAME] == 0) {
                        firstName = [[nameItems objectAtIndex:k] stringValue];
                    } else if([itemName compare:VCARD_TAG_LAST_NAME] == 0) {
                        lastName = [[nameItems objectAtIndex:k] stringValue];
                    }
                }
            }
        }
    }

    ChatParticipantVCardBuffer *buff = [ChatParticipantVCardBuffer getInstance];
    [buff updateUserProfile:username firstName:firstName lastName:lastName nickname:nickname email:email];
    [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_GET_VCARD object:nil];
}

+(void)handleGetPendingChatsPacket:(XMPPIQ *)packet {
    
    NSError *error = NULL;
    NSString *packetXML = [self getPacketXMLWithoutNewLines:packet];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\{\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\"\\}" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:packetXML options:0 range:NSMakeRange(0, packetXML.length)];
    
    NSMutableDictionary *allNotifications = [[NSMutableDictionary alloc] init];
    NSArray *keys = [NSArray arrayWithObjects:@"chatId", @"chatType", @"chatOwnerId", @"chatName", @"created", nil];
    int count = 0;
    
    for(NSTextCheckingResult *match in matches) {
        NSMutableArray *values = [[NSMutableArray alloc] init];
        
        for (int i=1; i<=5; i++)
            [values addObject:[packetXML substringWithRange:[match rangeAtIndex:i]]];
        
        NSDictionary *pendingChats = [NSDictionary dictionaryWithObjects:values forKeys:keys];
        count++;
        NSString *keyName = [NSString stringWithFormat:@"%i", count];
        [allNotifications setObject:pendingChats forKey:keyName];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_GET_PENDING_CHATS object:nil userInfo:allNotifications];
}

+(NSString*)getPacketXMLWithoutNewLines:(XMPPIQ *)iq {
    NSString *packetXML = [iq.XMLString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    packetXML = [packetXML stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    return packetXML;
}

+(NSString*)getPacketXMLWithoutWhiteSpace:(XMPPIQ *)iq {
    NSString *packetXML = [iq.XMLString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    packetXML = [packetXML stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    packetXML = [packetXML stringByReplacingOccurrencesOfString:@" " withString:@""];
    return packetXML;
}

+(NSString*)getDecodedPacketXML:(XMPPIQ *)iq {
    NSString *ret = [self getPacketXMLWithoutWhiteSpace:iq];
    return [[ret stringByReplacingOccurrencesOfString:@"+" withString:@" "]stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+(void)handleGetRosterPacket: (XMPPIQ *)iq{
    NSError *error = NULL;
    DDXMLElement *query = [[iq children] firstObject];
    NSArray *items = [query children];
    DDXMLElement *item;
    
    NSMutableArray *pendingFriends = [[NSMutableArray alloc] init],
    *acceptedFriends = [[NSMutableArray alloc] init];
    XMPPStream *conn = [[ConnectionProvider getInstance] getConnection];
    ChatParticipantVCardBuffer *buff = [ChatParticipantVCardBuffer getInstance];
    
    for (int i = 0; i < items.count; i++) {
        item = items[i];
        NSString *subscription = [[item attributeForName:@"subscription"] XMLString];
        //Parse jid
        NSString *jid = [[item attributeForName:@"jid"] XMLString] ;
        NSRegularExpression *regexJid = [NSRegularExpression regularExpressionWithPattern:@"jid=\"(.*)@" options: 0 error:&error];
        NSTextCheckingResult *matchJid = [regexJid firstMatchInString:jid options:0 range:NSMakeRange(0,jid.length)];
        NSString *resultJid = [jid substringWithRange:[matchJid rangeAtIndex:1]];
        [conn sendElement:[IQPacketManager createGetVCardPacket:resultJid]];
        if ([subscription rangeOfString:@"none"].location == NSNotFound){
            [acceptedFriends addObject:resultJid];
            [buff addVCard:[UserProfile create:resultJid subscriptionStatus:STATUS_FRIENDS]];
        }
        else {
            [pendingFriends addObject:resultJid];
            [buff addVCard:[UserProfile create:resultJid subscriptionStatus:STATUS_PENDING]];
        }
    }
    [buff setPending:pendingFriends];
    [buff setAccepted:acceptedFriends];
}

+(void)handleInviteUserToChatPacket:(XMPPIQ*)iq {
    GroupChatManager *gcm = [GroupChatManager getInstance];
    [gcm decrementNumUninvitedUsers];
}

+(void)handleCreateOneToOneChatPacket:(XMPPIQ*)iq {
    [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_CREATE_ONE_TO_ONE_CHAT object:nil];
}

+(void)handleGetSessionIDPacket:(XMPPIQ*)iq {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\{\"(.*?)\"\\}" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSTextCheckingResult *match = [regex firstMatchInString:iq.XMLString options:0 range:NSMakeRange(0, iq.XMLString.length)];
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate setSessionID:[iq.XMLString substringWithRange:[match rangeAtIndex:1]]];
}

+(void)handleGetConfessionsPacket:(XMPPIQ *)iq {
    NSLog(@"\n\n Handling Get Confessions Packet: %@ \n\n", iq.XMLString);
    NSString *decodedPacketXML = [self getPacketXMLWithoutWhiteSpace:iq];
    decodedPacketXML = [self getDecodedPacketXML:iq];
    NSError *error = NULL;
    NSLog(@"Decoded Packet XML: %@", decodedPacketXML);
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\{\"(\\d+)\",\"(.*?)\",\"(.*?)\",\"(.*?)\",\"(.*?)\",(\".*?\"|null),\"(\\d+)\"\\}" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:decodedPacketXML options:0 range:NSMakeRange(0, decodedPacketXML.length)];
    NSTextCheckingResult *match;
    NSString *confessionID, *jid, *body, *imageURL, *timestamp, *favoritedUsers;
    NSNumber *favoriteCount;
    NSMutableArray *favoritedUsersArray;
    Confession *confession;
    ConfessionsManager *confessionsManager = [ConfessionsManager getInstance];
    
    for (int i = 0; i < [matches count]; i++) {
        match = [matches objectAtIndex:i];
        confessionID = [decodedPacketXML substringWithRange:[match rangeAtIndex:1]];
        jid = [decodedPacketXML substringWithRange:[match rangeAtIndex:2]];
        body = [decodedPacketXML substringWithRange:[match rangeAtIndex:3]];
        imageURL = [decodedPacketXML substringWithRange:[match rangeAtIndex:4]];
        timestamp = [decodedPacketXML substringWithRange:[match rangeAtIndex:5]];
        favoritedUsers = [decodedPacketXML substringWithRange:[match rangeAtIndex:6]];
        favoriteCount = [NSNumber numberWithInt:[[decodedPacketXML substringWithRange:[match rangeAtIndex:7]] integerValue]];
        if (favoriteCount > 0) {
            favoritedUsers = [favoritedUsers stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            favoritedUsersArray = [NSMutableArray arrayWithArray:[favoritedUsers componentsSeparatedByString:@","]];
        } else {
            favoritedUsersArray = [[NSMutableArray alloc] init];
        }
        NSLog(@"Confession Body: %@", body);
        confession = [Confession create:body imageURL:imageURL confessionID:confessionID createdTimestamp:timestamp favoritedUsers:favoritedUsersArray];
        [confessionsManager addConfession:confession];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_GET_CONFESSIONS object:nil];
}

+(void)handleGetMyConfessionsPacket:(XMPPIQ *)iq {
    
}

+(void)handleToggleFavoriteConfessionPacket:(XMPPIQ *)iq {
    
}

+(void)handlePostConfessionPacket:(XMPPIQ *)iq {
    
}

@end
