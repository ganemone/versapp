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

@implementation IQPacketReceiver

-(bool)isPacketWithID:(NSString *)packetID packet:(XMPPIQ *)packet {
    return ([packet.elementID compare:packetID] == 0);
}

-(void)handleIQPacket:(XMPPIQ *)iq {
    if([self isPacketWithID:PACKET_ID_CREATE_MUC packet:iq]) {
        NSLog(@"-----------------\n");
        NSLog(@"Response: %@", iq.XMLString);
        NSLog(@"-----------------\n");
    } else if([self isPacketWithID:PACKET_ID_CREATE_VCARD packet:iq]) {
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
    }
}

-(void)handleGetJoinedChatsPacket:(XMPPIQ *)iq {
    NSLog(@"Packet: %@", iq.XMLString);
    NSError *error = NULL;
    
    NSString *packetXML = [self getPacketXMLWithoutNewLines:iq];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\{\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\"\\}" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:packetXML options:0 range:NSMakeRange(0, packetXML.length)];
    GroupChatManager *gcm = [GroupChatManager getInstance];
    OneToOneChatManager *cm = [OneToOneChatManager getInstance];
    ChatParticipantVCardBuffer *buff = [ChatParticipantVCardBuffer getInstance];
    XMPPStream *conn = [[ConnectionProvider getInstance] getConnection];
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
            NSLog(@"Adding Group Chat");
            [gcm addChat:[GroupChat create:chatId participants:participants groupName:name owner:owner createdTime:createdTime]];
            for (int i = 0; i < participants.count; i++) {
                if([buff hasVCard:[participants objectAtIndex:i]] == NO) {
                    DDXMLElement *packet = [IQPacketManager createGetVCardPacket:[participants objectAtIndex:i]];
                    [conn sendElement:packet];
                }
            }
        } else if([type isEqualToString:CHAT_TYPE_ONE_TO_ONE]) {
            NSLog(@"Adding One To One Chat");
            [cm addChat:[OneToOneChat create:chatId inviterID:owner invitedID:participantString createdTimestamp:createdTime]];
            if([participantString compare:[ConnectionProvider getServerIPAddress]] != 0) {
                if([buff hasVCard:participantString] == NO) {
                    [conn sendElement:[IQPacketManager createGetVCardPacket:participantString]];
                }
            }
        }
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_CHAT_LIST object:nil];
}

-(void)handleGetLastTimeActivePacket:(XMPPIQ *)iq {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\{\"(.*?)\"\\}" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:iq.XMLString options:0 range:NSMakeRange(0, iq.XMLString.length)];
    NSString *timestamp = [iq.XMLString substringWithRange:[match rangeAtIndex:1]];
    
    if([timestamp compare:@""] == 0) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"1970-01-01T00:00:00Z" forKey:PACKET_ID_GET_LAST_TIME_ACTIVE];
        [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_GET_LAST_TIME_ACTIVE object:nil userInfo:userInfo];
    } else {
        NSTimeInterval interval= [timestamp doubleValue];
        NSDate *gregDate = [NSDate dateWithTimeIntervalSince1970: interval];
        NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
        [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        NSString *utcStringDate =[formatter stringFromDate:gregDate];
        NSLog(@"UTC: %@", utcStringDate);
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:utcStringDate forKey:PACKET_ID_GET_LAST_TIME_ACTIVE];
        [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_GET_LAST_TIME_ACTIVE object:nil userInfo:userInfo];
    }
}

-(void)handleMessagePacket:(XMPPMessage *)message {
    if([message.type compare:CHAT_TYPE_GROUP] == 0) {
        [self handleGroupChatMessage:message];
    } else {
        [self handleOneToOneMessage:message];
    }
}

-(void)handleGroupChatMessage:(XMPPMessage *)message {
    
    NSError *error = NULL;
    NSRegularExpression *groupIDRegex = [NSRegularExpression regularExpressionWithPattern:@"(.*?)@" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *groupIDMatch = [groupIDRegex firstMatchInString:message.fromStr options:0 range:NSMakeRange(0, message.fromStr.length)];
    NSString *groupID = [message.fromStr substringWithRange:[groupIDMatch rangeAtIndex:1]];
    
    //NSTextCheckingResult *toMatch = [groupIDRegex firstMatchInString:message.toStr options:0 range:NSMakeRange(0, message.toStr.length)];
    //NSString *toID = [message.toStr substringWithRange:[toMatch rangeAtIndex:1]];
    
    error = NULL;
    NSRegularExpression *propertyRegex = [NSRegularExpression regularExpressionWithPattern:@"<property><name>(.*?)<\\/name><value type=\"(.*?)\">(.*?)<\\/value>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [propertyRegex matchesInString:message.XMLString options:0 range:NSMakeRange(0, message.XMLString.length)];
    NSString *senderID = nil;
    NSString *timestamp = nil;
    for(NSTextCheckingResult *match in matches) {
        NSString *name = [message.XMLString substringWithRange:[match rangeAtIndex:1]];
        //NSString *type = [message.XMLString substringWithRange:[match rangeAtIndex:2]];
        if ([name compare:MESSAGE_PROPERTY_SENDER_ID] == 0) {
            senderID = [message.XMLString substringWithRange:[match rangeAtIndex:3]];
        } else if([name compare:MESSAGE_PROPERTY_TIMESTAMP] == 0) {
            timestamp = [message.XMLString substringWithRange:[match rangeAtIndex:3]];
        }
    }
    GroupChatManager *gcm = [GroupChatManager getInstance];
    GroupChat *gc = [gcm getChat:groupID];
    [MessagesDBManager insert:message.body groupID:groupID time:timestamp senderID:senderID receiverID:groupID];
    [gc addMessage:[Message createForMUC:message.body sender:senderID chatID:groupID timestamp:timestamp]];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MUC_MESSAGE_RECEIVED object:nil];
}

-(void)handleOneToOneMessage:(XMPPMessage *)message {
    NSError *error = NULL;
    NSRegularExpression *groupIDRegex = [NSRegularExpression regularExpressionWithPattern:@"(.*?)@" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *groupIDMatch = [groupIDRegex firstMatchInString:message.fromStr options:0 range:NSMakeRange(0, message.fromStr.length)];
    NSString *groupID = [message.fromStr substringWithRange:[groupIDMatch rangeAtIndex:1]];
    
    //NSTextCheckingResult *toMatch = [groupIDRegex firstMatchInString:message.toStr options:0 range:NSMakeRange(0, message.toStr.length)];
    //NSString *toID = [message.toStr substringWithRange:[toMatch rangeAtIndex:1]];
    
    error = NULL;
    NSRegularExpression *propertyRegex = [NSRegularExpression regularExpressionWithPattern:@"<property><name>(.*?)<\\/name><value type=\"(.*?)\">(.*?)<\\/value>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [propertyRegex matchesInString:message.XMLString options:0 range:NSMakeRange(0, message.XMLString.length)];
    NSString *senderID = nil;
    NSString *timestamp = nil;
    for(NSTextCheckingResult *match in matches) {
        NSString *name = [message.XMLString substringWithRange:[match rangeAtIndex:1]];
        //NSString *type = [message.XMLString substringWithRange:[match rangeAtIndex:2]];
        if ([name compare:MESSAGE_PROPERTY_SENDER_ID] == 0) {
            senderID = [message.XMLString substringWithRange:[match rangeAtIndex:3]];
        } else if([name compare:MESSAGE_PROPERTY_TIMESTAMP] == 0) {
            timestamp = [message.XMLString substringWithRange:[match rangeAtIndex:3]];
        }
    }
    OneToOneChatManager *cm = [OneToOneChatManager getInstance];
    OneToOneChat *chat = [cm getChat:message.thread];
    [MessagesDBManager insert:message.body groupID:message.thread time:timestamp senderID:senderID receiverID:[ConnectionProvider getUser]];
    [chat addMessage:[Message createForOneToOne:message.body sender:senderID chatID:groupID messageTo:[ConnectionProvider getUser] timestamp:timestamp]];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ONE_TO_ONE_MESSAGE_RECEIVED object:nil];
}

-(void)handleGetServerTimePacket:(XMPPIQ *)packet {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<utc>(.*?)<\\/utc>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:packet.XMLString options:0 range:NSMakeRange(0, packet.XMLString.length)];
    NSString *utcTime = [packet.XMLString substringWithRange:[match rangeAtIndex:1]];
    
    NSLog(@"Received Server Time: %@", utcTime);
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:utcTime forKey:PACKET_ID_GET_SERVER_TIME];
    [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_GET_SERVER_TIME object:nil userInfo:userInfo];
}

-(void)handleGetVCardPacket:(XMPPIQ *)packet {
    NSLog(@"VCard: %@", packet.XMLString);
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
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              firstName, VCARD_TAG_FIRST_NAME,
                              lastName, VCARD_TAG_LAST_NAME,
                              username, VCARD_TAG_USERNAME,
                              email, VCARD_TAG_EMAIL,
                              nickname, VCARD_TAG_NICKNAME, nil];
    ChatParticipantVCardBuffer *buff = [ChatParticipantVCardBuffer getInstance];
    [buff addVCard:userInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_GET_VCARD object:nil userInfo:userInfo];
}

-(void)handleGetPendingChatsPacket:(XMPPIQ *)packet {
    
    NSLog(@"Pending Chats Packet Received: %@", packet.XMLString);
    
    NSError *error = NULL;
    NSString *packetXML = [self getPacketXMLWithoutNewLines:packet];
    NSLog(@"PacketXML: %@", packetXML);
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\{\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\".*?\"(.*?)\"\\}" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:packetXML options:0 range:NSMakeRange(0, packetXML.length)];
    
    NSLog(@"Matches: %@", matches);
    
    NSMutableDictionary *allNotifications = [[NSMutableDictionary alloc] init];
    NSArray *keys = [NSArray arrayWithObjects:@"chatId", @"chatType", @"chatOwnerId", @"chatName", @"created", nil];
    int count = 0;
    
    for(NSTextCheckingResult *match in matches) {
        NSMutableArray *values = [[NSMutableArray alloc] init];
        
        for (int i=1; i<=5; i++)
            [values addObject:[packetXML substringWithRange:[match rangeAtIndex:i]]];
        
        NSDictionary *pendingChats = [NSDictionary dictionaryWithObjects:values forKeys:keys];
        count++;
        NSString *keyName = (@"notification%i", [NSString stringWithFormat:@"%i", count]);
        [allNotifications setObject:pendingChats forKey:keyName];
        NSLog(@"Notifications: %@", allNotifications);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_GET_PENDING_CHATS object:nil userInfo:allNotifications];
}

-(NSString*)getPacketXMLWithoutNewLines:(XMPPIQ *)iq {
    NSString *packetXML = [iq.XMLString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    packetXML = [packetXML stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    return packetXML;
}

-(void)handleGetRosterPacket: (XMPPIQ *)iq{
    NSLog(@"IQRoster: %@", iq.XMLString);
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
        if ([buff hasVCard:jid] == NO) {
            [conn sendElement:[IQPacketManager createGetVCardPacket:resultJid]];
        }
        if ([subscription rangeOfString:@"none"].location == NSNotFound){
            [acceptedFriends addObject:[UserProfile create:resultJid subscription_status: USER_STATUS_FRIENDS]];
        }
        else {
            [pendingFriends addObject:[UserProfile create:resultJid subscription_status: USER_STATUS_PENDING]];
        }
    }
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:acceptedFriends, USER_STATUS_FRIENDS, pendingFriends, USER_STATUS_PENDING, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_GET_ROSTER object:nil userInfo:userInfo];
    NSLog(@"I am trying to send");
    
}

@end
