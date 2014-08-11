//
//  MessagePacketReceiver.m
//  Who
//
//  Created by Giancarlo Anemone on 2/5/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "MessagePacketReceiver.h"
#import "XMPPMessage.h"
// Chat Related Objects
// DB
#import "MessagesDBManager.h"
#import "ChatDBManager.h"
// Other
#import "Constants.h"
#import "ConnectionProvider.h"
#import "ChatMO.h"
#import "MessageMO.h"
#import "IQPacketManager.h"
#import "ChatDBManager.h"
#import "AppDelegate.h"
#import "FriendsDBManager.h"

@implementation MessagePacketReceiver
    
// Inserts message into db, adds message to chat history (either group chat or one to one chat),
// and sends notification with dictionary containing ONLY the group id.
+(void)handleMessagePacket:(XMPPMessage*)message {
    NSError *error = NULL;
    NSRegularExpression *broadcastRegex = [NSRegularExpression regularExpressionWithPattern:@"^<message .*?><body>(.*?)<\\/body><broadcast.*?><type>new_user<\\/type><\\/broadcast><\\/message>$"options:NSRegularExpressionCaseInsensitive error:&error];
    if ([[broadcastRegex matchesInString:message.XMLString options:0 range:NSMakeRange(0, message.XMLString.length)] count] > 0) {
        return;
    }

    error = NULL;
    NSRegularExpression *chatInvitationRegex = [NSRegularExpression regularExpressionWithPattern:@"<property><name>(.*?)<\\/name><value.*?>(.*?)<\\/value><\\/property>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [chatInvitationRegex matchesInString:message.XMLString options:0 range:NSMakeRange(0, message.XMLString.length)];
    NSString *chatID,
    *chatName,
    *tempName,
    *tempValue,
    *invitedBy;
    for (NSTextCheckingResult *match in matches) {
        tempName = [message.XMLString substringWithRange:[match rangeAtIndex:1]];
        tempValue = [message.XMLString substringWithRange:[match rangeAtIndex:2]];
        if ([tempName isEqualToString:MESSAGE_PROPERTY_INVITATION_MESSAGE]) {
            chatID = tempValue;
        } else if ([tempName isEqualToString:MESSAGE_PROPERTY_GROUP_NAME]) {
            chatName = tempValue;
        }
    }
    if (chatID != nil) {
        invitedBy = [[message.fromStr componentsSeparatedByString:@"@"] firstObject];
        [self handleMessageInvitationReceived:chatID groupName:chatName invitedBy:invitedBy];
    } else if([message.type compare:MESSAGE_TYPE_HEADLINE] == 0) {
        // Handle Confession Messages Here...
    } else {
        [self handleChatMessageReceived:message];
    }
}

+(void)handleMessageInvitationReceived:(NSString*)chatID groupName:(NSString *)groupName invitedBy:(NSString *)invitedBy {
    [ChatDBManager insertChatWithID:chatID chatName:groupName chatType:CHAT_TYPE_GROUP participantString:nil status:STATUS_PENDING degree:@"1" ownerID:invitedBy];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_NOTIFICATIONS object:nil];
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    
    localNotification.alertBody = [NSString stringWithFormat:@"%@: invited by %@", groupName, invitedBy];
    //localNotification.alertAction = alertAction;
    
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber++;
    
    localNotification.applicationIconBadgeNumber = application.applicationIconBadgeNumber;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

+(void)handleChatMessageReceived:(XMPPMessage*)message {
    
    NSError *error = NULL;
    NSRegularExpression *groupIDRegex = [NSRegularExpression regularExpressionWithPattern:@"(.*?)@" options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *groupIDMatch = [groupIDRegex firstMatchInString:message.fromStr options:0 range:NSMakeRange(0, message.fromStr.length)];
    NSString *groupID = [message.fromStr substringWithRange:[groupIDMatch rangeAtIndex:1]];
    
    //NSTextCheckingResult *toMatch = [groupIDRegex firstMatchInString:message.toStr options:0 range:NSMakeRange(0, message.toStr.length)];
    //NSString *toID = [message.toStr substringWithRange:[toMatch rangeAtIndex:1]];
    
    error = NULL;
    NSRegularExpression *propertyRegex = [NSRegularExpression regularExpressionWithPattern:@"<property><name>(.*?)<\\/name><value type=\"(.*?)\">(.*?)<\\/value>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [propertyRegex matchesInString:message.XMLString options:0 range:NSMakeRange(0, message.XMLString.length)];
    NSString *senderID = nil,
    *timestamp = nil,
    *imageLink = nil,
    *name = nil,
    *value = nil,
    *receiverID = nil,
    *inviteFlag = nil;
    for(NSTextCheckingResult *match in matches) {
        name = [message.XMLString substringWithRange:[match rangeAtIndex:1]];
        //NSString *type = [message.XMLString substringWithRange:[match rangeAtIndex:2]];
        value = [message.XMLString substringWithRange:[match rangeAtIndex:3]];
        if ([name isEqualToString:MESSAGE_PROPERTY_SENDER_ID]) {
            senderID = value;
        } else if([name isEqualToString:MESSAGE_PROPERTY_TIMESTAMP] && timestamp == nil) {
            timestamp = value;
        } else if([name isEqualToString:MESSAGE_PROPERTY_IMAGE_LINK]) {
            imageLink = value;
        } else if([name isEqualToString:MESSAGE_PROPERTY_RECEIVER_ID]) {
            receiverID = value;
        } else if([name isEqualToString:@"CHAT_ID"]) {
            inviteFlag = value;
            break;
        }
    }
    if ([senderID isEqualToString:[ConnectionProvider getUser]]) {
        [MessagesDBManager updateMessageWithGroupID:groupID time:timestamp];
    } else if (inviteFlag == nil) {
        MessageMO *newMessage;
        if ([message.type isEqualToString:CHAT_TYPE_GROUP]) {
            if (imageLink != nil) {
                newMessage = [MessagesDBManager insert:message.body groupID:groupID time:timestamp senderID:senderID receiverID:receiverID imageLink:imageLink];
            } else {
                newMessage = [MessagesDBManager insert:message.body groupID:groupID time:timestamp senderID:senderID receiverID:receiverID];
            }
            ChatMO *currentChat = [ChatDBManager getChatWithID:groupID];
            if (![[currentChat getParticipantJIDS] containsObject:senderID]) {
                [currentChat.participants addObject:@{PARTICIPANT_STATUS : @"joined",
                                                      PARTICIPANT_USERNAME : senderID,
                                                      PARTICIPANT_INVITED_BY : @""}];
                [currentChat setValue:[[currentChat getParticipantJIDS] componentsJoinedByString:@", "] forKey:CHATS_TABLE_COLUMN_NAME_PARTICIPANT_STRING];
                AppDelegate *delegate = [UIApplication sharedApplication].delegate;
                [delegate saveContext];
            }
            NSDictionary *messageDictionary = [NSDictionary dictionaryWithObject:newMessage forKey:DICTIONARY_KEY_MESSAGE_OBJECT];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MUC_MESSAGE_RECEIVED object:nil userInfo:messageDictionary];
            [ChatDBManager setHasNewMessageYes:groupID];
            
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            
            localNotification.alertBody = [NSString stringWithFormat:@"%@: %@", currentChat.getChatName, newMessage.message_body];
            localNotification.userInfo = [NSDictionary dictionaryWithObject:currentChat.chat_id forKey:@"chat_id"];
            
            UIApplication *application = [UIApplication sharedApplication];
            application.applicationIconBadgeNumber++;
            
            localNotification.applicationIconBadgeNumber = application.applicationIconBadgeNumber;
            
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        } else if([message.type isEqualToString:CHAT_TYPE_ONE_TO_ONE]) {
            if (imageLink != nil) {
                newMessage = [MessagesDBManager insert:message.body groupID:message.thread time:timestamp senderID:senderID receiverID:receiverID imageLink:imageLink];
            } else {
                newMessage = [MessagesDBManager insert:message.body groupID:message.thread time:timestamp senderID:senderID receiverID:receiverID];
            }
            NSDictionary *messageDictionary = [NSDictionary dictionaryWithObjectsAndKeys:message.thread, MESSAGE_PROPERTY_GROUP_ID, newMessage, DICTIONARY_KEY_MESSAGE_OBJECT, nil];
            if ([ChatDBManager hasChatWithID:message.thread] == NO) {
                [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createGetJoinedChatsPacket]];
                //NSString *degree = ([FriendsDBManager hasUserWithJID:senderID] == YES) ? @"1" : @"2";
                //[ChatDBManager insertChatWithID:message.thread chatName:name chatType:CHAT_TYPE_ONE_TO_ONE participantString:[NSString stringWithFormat:@"%@, %@", receiverID, senderID] status:STATUS_JOINED degree:degree];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ONE_TO_ONE_MESSAGE_RECEIVED object:nil userInfo:messageDictionary];
            [ChatDBManager setHasNewMessageYes:message.thread];
            
            ChatMO *currentChat = [ChatDBManager getChatWithID:message.thread];
            
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            
            localNotification.alertBody = [NSString stringWithFormat:@"%@: %@", currentChat.getChatName, newMessage.message_body];
            localNotification.userInfo = [NSDictionary dictionaryWithObject:currentChat.chat_id forKey:@"chat_id"];
            
            UIApplication *application = [UIApplication sharedApplication];
            application.applicationIconBadgeNumber++;
            
            localNotification.applicationIconBadgeNumber = application.applicationIconBadgeNumber;
            
            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        }
    }
}

@end
