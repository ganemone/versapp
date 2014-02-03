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
#import "UserProfile.h"

@implementation IQPacketReceiver

-(bool)isPacketWithID:(NSString *)packetID packet:(XMPPIQ *)packet {
    return ([packet.elementID compare:packetID] == 0);
}

-(void)handleIQPacket:(XMPPIQ *)iq {
    if([self isPacketWithID:PACKET_ID_CREATE_MUC packet:iq]) {
        
    } else if([self isPacketWithID:PACKET_ID_CREATE_VCARD packet:iq]) {
        
    } else if([self isPacketWithID:PACKET_ID_GET_JOINED_CHATS packet:iq]) {
        [self handleGetJoinedChatsPacket:iq];
    } else if([self isPacketWithID:PACKET_ID_GET_PENDING_CHATS packet:iq]) {
        
    } else if([self isPacketWithID:PACKET_ID_GET_ROSTER packet:iq]) {
        [self handleGetRosterPacket: iq];
        
    } else if([self isPacketWithID:PACKET_ID_JOIN_MUC packet:iq]) {
        
    } else if([self isPacketWithID:PACKET_ID_REGISTER_USER packet:iq]) {
        
    } else if([self isPacketWithID:PACKET_ID_GET_LAST_TIME_ACTIVE packet:iq]) {
        [self handleGetLastTimeActivePacket:iq];
    } else if([self isPacketWithID:PACKET_ID_GET_SERVER_TIME packet:iq]) {
        [self handleGetServerTimePacket:iq];
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
    
    for (NSTextCheckingResult *match in matches) {
        NSString *participantString = [packetXML substringWithRange:[match rangeAtIndex:1]];
        NSArray *participants = [participantString componentsSeparatedByString:@", "];
        NSLog(@"Participant String: %@", participantString);
        NSLog(@"Participant Array: %@", participants.description);
        NSLog(@"Participant Array Size: %d", participants.count);
        NSString* chatId = [packetXML substringWithRange:[match rangeAtIndex:2]];
        NSString* type = [packetXML substringWithRange:[match rangeAtIndex:3]];
        NSString* owner = [packetXML substringWithRange:[match rangeAtIndex:4]];
        NSString* name = [packetXML substringWithRange:[match rangeAtIndex:5]];
        NSString* createdTime = [packetXML substringWithRange:[match rangeAtIndex:6]];
        if([type isEqualToString:CHAT_TYPE_GROUP]) {
            [gcm addChat:[GroupChat create:chatId participants:participants groupName:name owner:owner createdTime:createdTime]];
        } else if([type isEqualToString:CHAT_TYPE_ONE_TO_ONE]) {
            [cm addChat:[OneToOneChat create:chatId inviterID:owner invitedID:participantString createdTimestamp:createdTime]];
        }
    }
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
        NSTimeInterval interval= [timestamp doubleValue] + 5*60*60;
        NSDate *gregDate = [NSDate dateWithTimeIntervalSince1970: interval];
        NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
        //[formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        NSString *utcStringDate =[formatter stringFromDate:gregDate];
        
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
    [gc.history addMessage:[Message createForMUC:message.body sender:senderID chatID:groupID timestamp:timestamp]];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_DASHBOARD_LISTVIEW object:nil];
}

-(void)handleOneToOneMessage:(XMPPMessage *)message {
    
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

-(NSString*)getPacketXMLWithoutNewLines:(XMPPIQ *)iq {
    NSString *packetXML = [iq.XMLString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    packetXML = [packetXML stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    return packetXML;
}

-(void)handleGetRosterPacket: (XMPPIQ *)iq{
    NSLog(@"IQRoster: %@", iq.XMLString);
    NSError *error = NULL;
    /*
    // Deprecated code to parse the entire XML string, might be useful when the structure of the XMLString changes.
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<item (subscription=\"(.*?)\")|(jid=\"([^@]+){1,}@.*?\"[^\\/]{1,}) (subscription=\"(.*?)\")|(jid=\"([^@]+){1,}@.*?\"[^\\/]{1,})\\/>" options:(NSRegularExpressionCaseInsensitive) error:&error];
    NSArray *match = [regex matchesInString:iq.XMLString options:0 range:NSMakeRange(0, iq.XMLString.length)];
     */
    
    DDXMLElement *query = [[iq children] firstObject];
    NSArray *items = [query children];
    DDXMLElement *item;
    
    NSMutableArray *pendingFriends = [[NSMutableArray alloc] init],
    *acceptedFriends = [[NSMutableArray alloc] init];
    
    
    for (int i = 0; i < items.count; i++) {
        item = items[i];
        
        /*
        // Parse subscription
        NSString *subscription = [[item attributeForName:@"subscription"] XMLString];
        NSRegularExpression *regexSubs = [NSRegularExpression regularExpressionWithPattern:@"subscription=\"(.*)\"" options: 0 error:&error];
        NSTextCheckingResult *matchSubs = [regexSubs firstMatchInString:subscription options:0 range:NSMakeRange(0,subscription.length)];
        NSString *resultSubs = [subscription substringWithRange:[matchSubs rangeAtIndex:1]];
        */
        
        NSString *subscription = [[item attributeForName:@"subscription"] XMLString];
        //Parse jid
        NSString *jid = [[item attributeForName:@"jid"] XMLString] ;
        NSRegularExpression *regexJid = [NSRegularExpression regularExpressionWithPattern:@"jid=\"(.*)@" options: 0 error:&error];
        NSTextCheckingResult *matchJid = [regexJid firstMatchInString:jid options:0 range:NSMakeRange(0,jid.length)];
        NSString *resultJid = [jid substringWithRange:[matchJid rangeAtIndex:1]];
        
        if ([subscription rangeOfString:@"none"].location == NSNotFound){
            [acceptedFriends addObject:[UserProfile create:resultJid subscription_status: USER_STATUS_FRIENDS]];
        }
        else{
            [pendingFriends addObject:[UserProfile create:resultJid subscription_status: USER_STATUS_PENDING]];
        }
        
    }
    
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:acceptedFriends, USER_STATUS_FRIENDS, pendingFriends, USER_STATUS_PENDING, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_GET_ROSTER object:nil userInfo:userInfo];
    NSLog(@"I am trying to send");
    
}

@end
