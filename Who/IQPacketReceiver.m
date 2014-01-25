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
        
    } else if([self isPacketWithID:PACKET_ID_JOIN_MUC packet:iq]) {
        
    } else if([self isPacketWithID:PACKET_ID_REGISTER_USER packet:iq]) {
        
    } else if([self isPacketWithID:PACKET_ID_GET_LAST_TIME_ACTIVE packet:iq]) {
        [self handleGetLastTimeActivePacket:iq];
    } else if([self isPacketWithID:PACKET_ID_GET_SERVER_TIME packet:iq]) {
        [self handleGetServerTimePacket:iq];
    }
}

-(void)handleGetJoinedChatsPacket:(XMPPIQ *)iq {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\{\"(.*?)\",\"(.*?)\",\"(.*?)\",\"(.*?)\",\"(.*?)\"\\}" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [regex matchesInString:iq.XMLString options:0 range:NSMakeRange(0, iq.XMLString.length)];
    GroupChatManager *gcm = [GroupChatManager getInstance];
    // CREATE ONE TO ONE MANAGER HERE
    
    for (NSTextCheckingResult *match in matches) {
        NSString* chatId = [iq.XMLString substringWithRange:[match rangeAtIndex:1]];
        NSString* type = [iq.XMLString substringWithRange:[match rangeAtIndex:2]];
        NSString* owner = [iq.XMLString substringWithRange:[match rangeAtIndex:3]];
        NSString* name = [iq.XMLString substringWithRange:[match rangeAtIndex:4]];
        NSString* createdTime = [iq.XMLString substringWithRange:[match rangeAtIndex:5]];
        if([type isEqualToString:CHAT_TYPE_GROUP]) {
            [gcm addChat:[GroupChat create:chatId groupName:name owner:owner createdTime:createdTime]];
        } else if([type isEqualToString:CHAT_TYPE_ONE_TO_ONE]) {
            // ADD ONE TO ONE CHAT HERE
        }
    }
}

-(void)handleGetLastTimeActivePacket:(XMPPIQ *)iq {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\{\"\"\\}" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *match = [regex firstMatchInString:iq.XMLString options:0 range:NSMakeRange(0, iq.XMLString.length)];
    NSString *timestamp = [iq.XMLString substringWithRange:[match rangeAtIndex:1]];
    
    if([timestamp compare:@""]) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"1970-01-01T00:00:00Z" forKey:PACKET_ID_GET_LAST_TIME_ACTIVE];
        [[NSNotificationCenter defaultCenter] postNotificationName:PACKET_ID_GET_LAST_TIME_ACTIVE object:nil userInfo:userInfo];
    } else {
        
        NSLog(@"MilliSeconds: %@", timestamp);
        NSTimeInterval interval= [timestamp doubleValue];
        NSDate *gregDate = [NSDate dateWithTimeIntervalSince1970: interval];
        NSDateFormatter *formatter=[[NSDateFormatter alloc]init];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        NSString *utcStringDate =[formatter stringFromDate:gregDate];
        
        NSLog(@"UTC Date: %@", utcStringDate);
        
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
    NSLog(@"Message From: %@", message.fromStr);
    NSLog(@"Message To: %@", message.toStr);
    NSLog(@"Message Type: %@", message.type);
    
    NSError *error = NULL;
    NSRegularExpression *groupIDRegex = [NSRegularExpression regularExpressionWithPattern:@"(.*?)@" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *groupIDMatch = [groupIDRegex firstMatchInString:message.fromStr options:0 range:NSMakeRange(0, message.fromStr.length)];
    NSString *groupID = [message.fromStr substringWithRange:[groupIDMatch rangeAtIndex:1]];
    NSLog(@"Group ID: %@", groupID);
    
    NSTextCheckingResult *toMatch = [groupIDRegex firstMatchInString:message.toStr options:0 range:NSMakeRange(0, message.toStr.length)];
    NSString *toID = [message.toStr substringWithRange:[toMatch rangeAtIndex:1]];
    NSLog(@"To ID: %@", toID);
    
    error = NULL;
    NSRegularExpression *propertyRegex = [NSRegularExpression regularExpressionWithPattern:@"<property><name>(.*?)<\\/name><value type=\"(.*?)\">(.*?)<\\/value>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [propertyRegex matchesInString:message.XMLString options:0 range:NSMakeRange(0, message.XMLString.length)];
    NSString *senderID = nil;
    NSString *timestamp = nil;
    for(NSTextCheckingResult *match in matches) {
        NSString *name = [message.XMLString substringWithRange:[match rangeAtIndex:1]];
        //NSString *type = [message.XMLString substringWithRange:[match rangeAtIndex:2]];
        if ([name compare:MESSAGE_PROPERTY_SENDER_ID]) {
            senderID = [message.XMLString substringWithRange:[match rangeAtIndex:3]];
        } else if([name compare:MESSAGE_PROPERTY_TIMESTAMP]) {
            timestamp = [message.XMLString substringWithRange:[match rangeAtIndex:3]];
        }
    }
    GroupChatManager *gcm = [GroupChatManager getInstance];
    GroupChat *gc = [gcm getChat:groupID];
    [gc.history addMessage:[Message create:message.body sender:senderID chatID:groupID timestamp:timestamp]];
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

@end
