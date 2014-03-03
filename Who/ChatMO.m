//
//  ChatMO.m
//  Who
//
//  Created by Giancarlo Anemone on 3/2/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ChatMO.h"
#import "MessageMO.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"
#import "MessagesDBManager.h"

@implementation ChatMO

@dynamic chat_id;
@dynamic chat_name;
@dynamic has_new_message;
@dynamic status;
@dynamic user_defined_chat_name;
@dynamic chat_type;

@synthesize messages = _messages;

-(NSString *)getChatAddress {
    return [NSString stringWithFormat:@"%@@%@", self.chat_id, [ConnectionProvider getConferenceIPAddress]];
}

-(void)sendMUCMessageWithBody:(NSString *)messageText imageLink:(NSString*)imageLink {
    MessageMO *newMessage = [MessagesDBManager insert:messageText groupID:self.chat_id time:nil senderID:[ConnectionProvider getUser] receiverID:self.chat_id imageLink:imageLink];
    [self addMessage:newMessage];
    DDXMLElement *packet = [IQPacketManager createSendMUCMessagePacket:newMessage];
    [[[ConnectionProvider getInstance] getConnection] sendElement:packet];
}

-(void)createSendOneToOneMessage:(NSString*)messageText messageTo:(NSString*)messageTo imageLink:(NSString*)imageLink {
    NSString * timeStampValue = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    MessageMO *newMessage = [MessagesDBManager insert:messageText groupID:self.chat_id time:timeStampValue senderID:[ConnectionProvider getUser] receiverID:messageTo imageLink:imageLink];
    DDXMLElement *packet = [IQPacketManager createSendOneToOneMessagePacket:newMessage];
    [[[ConnectionProvider getInstance] getConnection] sendElement:packet];
}

-(NSString *)getLastMessage {
    return [[_messages lastObject] message_body];
}

-(int)getNumberOfMessages {
    return [_messages count];
}

-(void)addMessage:(MessageMO*)message {
    [self.messages addObject:message];
}

-(void)updateMessage:(MessageMO*)message {
    MessageMO *tempMessage;
    for (int i = 0; i < [_messages count]; i++) {
        tempMessage = [_messages objectAtIndex:i];
        if ([tempMessage time] == nil) {
            [tempMessage setTime:message.time];
        }
    }
}

@end
