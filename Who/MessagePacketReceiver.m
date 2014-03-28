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

@implementation MessagePacketReceiver

// Inserts message into db, adds message to chat history (either group chat or one to one chat),
// and sends notification with dictionary containing ONLY the group id.
+(void)handleMessagePacket:(XMPPMessage*)message {
    NSError *error = NULL;

    NSRegularExpression *chatInvitationRegex = [NSRegularExpression regularExpressionWithPattern:@"<property><name>(.*?)<\\/name><value.*?>(.*?)<\\/value><\\/property>" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *matches = [chatInvitationRegex matchesInString:message.XMLString options:0 range:NSMakeRange(0, message.XMLString.length)];
    NSString *chatID,
    *chatName,
    *tempName,
    *tempValue;
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
        [self handleMessageInvitationReceived:chatID groupName:chatName];
    } else if([message.type compare:MESSAGE_TYPE_HEADLINE] == 0) {
        // Handle Confession Messages Here...
    } else {
        [self handleChatMessageReceived:message];
    }
}

+(void)handleMessageInvitationReceived:(NSString*)chatID groupName:(NSString *)groupName {
    NSLog(@"Received Group Invite Chat ID: %@ %@", chatID, groupName);
    [ChatDBManager insertChatWithID:chatID chatName:groupName chatType:CHAT_TYPE_GROUP participantString:nil status:STATUS_PENDING];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_NOTIFICATIONS object:nil];
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
        if ([name compare:MESSAGE_PROPERTY_SENDER_ID] == 0) {
            senderID = value;
        } else if([name compare:MESSAGE_PROPERTY_TIMESTAMP] == 0) {
            timestamp = value;
        } else if([name compare:MESSAGE_PROPERTY_IMAGE_LINK] == 0) {
            imageLink = value;
        } else if([name compare:MESSAGE_PROPERTY_RECEIVER_ID] == 0) {
            receiverID = value;
        } else if([name compare:@"CHAT_ID"] == 0) {
            inviteFlag = value;
            break;
        }
    }
    
    if ([senderID isEqualToString:[ConnectionProvider getUser]]) {
        [MessagesDBManager updateMessageWithGroupID:groupID time:timestamp];
    } else if (inviteFlag == nil) {
        if ([message.type compare:CHAT_TYPE_GROUP] == 0) {
            MessageMO *newMessage;
            if (imageLink != nil) {
                newMessage = [MessagesDBManager insert:message.body groupID:groupID time:timestamp senderID:senderID receiverID:receiverID imageLink:imageLink];
            } else {
                newMessage = [MessagesDBManager insert:message.body groupID:groupID time:timestamp senderID:senderID receiverID:receiverID];
            }
            NSDictionary *messageDictionary = [NSDictionary dictionaryWithObject:newMessage forKey:DICTIONARY_KEY_MESSAGE_OBJECT];
            NSLog(@"Received Message! Sending notification now...");
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MUC_MESSAGE_RECEIVED object:nil userInfo:messageDictionary];
            [ChatDBManager setHasNewMessageYes:groupID];
            
        } else if([message.type compare:CHAT_TYPE_ONE_TO_ONE] == 0) {
            if (imageLink != nil) {
                [MessagesDBManager insert:message.body groupID:message.thread time:timestamp senderID:senderID receiverID:receiverID imageLink:imageLink];
            } else {
                [MessagesDBManager insert:message.body groupID:message.thread time:timestamp senderID:senderID receiverID:receiverID];
            }
            NSDictionary *messageDictionary = [NSDictionary dictionaryWithObject:message.thread forKey:MESSAGE_PROPERTY_GROUP_ID];
            if ([ChatDBManager hasChatWithID:message.thread] == NO) {
                NSLog(@"Getting New Chat HERE!!");
                NSLog(@"Chat Name should be anonymous friend");
                [ChatDBManager insertChatWithID:message.thread chatName:@"Anonymous Friend" chatType:CHAT_TYPE_ONE_TO_ONE participantString:senderID status:STATUS_JOINED];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ONE_TO_ONE_MESSAGE_RECEIVED object:nil userInfo:messageDictionary];
            [ChatDBManager setHasNewMessageYes:message.thread];
        } else {
            NSLog(@"Received Unrecognized Message Packet Type!!");
        }
    }
}

@end
