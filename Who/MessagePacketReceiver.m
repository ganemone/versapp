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
#import "GroupChat.h"
#import "GroupChatManager.h"
#import "OneToOneChat.h"
#import "OneToOneChatManager.h"
// DB
#import "MessagesDBManager.h"
// Other
#import "Constants.h"
#import "ConnectionProvider.h"
#import "Message.h"
#import "IQPacketManager.h"


@implementation MessagePacketReceiver

// Inserts message into db, adds message to chat history (either group chat or one to one chat),
// and sends notification with dictionary containing ONLY the group id.
+(void)handleMessagePacket:(XMPPMessage*)message {
    NSError *error = NULL;
    
    NSRegularExpression *chatInvitationRegex = [NSRegularExpression regularExpressionWithPattern:[NSString stringWithFormat:@"<property><name>%@<\\/name><value>(.*?)<\\/value><\\/property>", MESSAGE_PROPERTY_INVITATION_MESSAGE] options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult *invitationResult = [chatInvitationRegex firstMatchInString:message.XMLString options:0 range:NSMakeRange(0, message.XMLString.length)];
    if ([invitationResult numberOfRanges] > 0) {
        [self handleMessageInvitationReceived:[message.XMLString substringWithRange:[invitationResult rangeAtIndex:1]]];
    } else if([message.type compare:MESSAGE_TYPE_HEADLINE] == 0) {
    } else {
        [self handleChatMessageReceived:message];
    }
}

+(void)handleMessageInvitationReceived:(NSString*)chatID {
    NSLog(@"Chat ID: %@", chatID);
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
    *receiverID = nil;
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
        }
    }
    [MessagesDBManager insert:message.body groupID:groupID time:timestamp senderID:senderID receiverID:receiverID];
    
    if ([message.type compare:CHAT_TYPE_GROUP] == 0) {
        NSDictionary *messageDictionary = [NSDictionary dictionaryWithObject:groupID forKey:MESSAGE_PROPERTY_GROUP_ID];
        GroupChatManager *gcm = [GroupChatManager getInstance];
        GroupChat *gc = [gcm getChat:groupID];
        [gc addMessage: [Message createForMUC:message.body sender:senderID chatID:groupID timestamp:timestamp]];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_MUC_MESSAGE_RECEIVED object:nil userInfo:messageDictionary];
    } else {
        NSDictionary *messageDictionary = [NSDictionary dictionaryWithObject:message.thread forKey:MESSAGE_PROPERTY_GROUP_ID];
        OneToOneChatManager *cm = [OneToOneChatManager getInstance];
        OneToOneChat *chat = [cm getChat:groupID];
        [chat addMessage:[Message createForOneToOne:message.body sender:senderID chatID:message.thread messageTo:receiverID timestamp:timestamp]];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ONE_TO_ONE_MESSAGE_RECEIVED object:nil userInfo:messageDictionary];
    }
}

@end