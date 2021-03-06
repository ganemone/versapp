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
#import "Constants.h"

@implementation ChatMO

@dynamic chat_id;
@dynamic chat_name;
@dynamic has_new_message;
@dynamic status;
@dynamic user_defined_chat_name;
@dynamic chat_type;
@dynamic participant_string;
@dynamic owner_id;
@dynamic degree;

@synthesize messages = _messages;
@synthesize participants = _participants;

-(NSString *)getChatAddress {
    return [NSString stringWithFormat:@"%@@%@", self.chat_id, [ConnectionProvider getConferenceIPAddress]];
}

-(void)sendMUCMessageWithBody:(NSString *)messageText imageLink:(NSString*)imageLink {
    NSString * timeStampValue = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    MessageMO *newMessage = [MessagesDBManager insert:messageText groupID:self.chat_id time:timeStampValue senderID:[ConnectionProvider getUser] receiverID:self.chat_id imageLink:imageLink];
    [self addMessage:newMessage];
    DDXMLElement *packet = [IQPacketManager createSendMUCMessagePacket:newMessage];
    [[[ConnectionProvider getInstance] getConnection] sendElement:packet];
}

-(void)sendOneToOneMessage:(NSString*)messageText imageLink:(NSString*)imageLink {
    NSString * timeStampValue = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    MessageMO *newMessage = [MessagesDBManager insert:messageText groupID:self.chat_id time:timeStampValue senderID:[ConnectionProvider getUser] receiverID:[self getMessageTo] imageLink:imageLink];
    [self addMessage:newMessage];
    DDXMLElement *packet = [IQPacketManager createSendOneToOneMessagePacket:newMessage];
    [[[ConnectionProvider getInstance] getConnection] sendElement:packet];
}

-(NSString *)getLastMessage {
    return [[_messages lastObject] message_body];
}

-(int)getNumberOfMessages {
    return (int)[_messages count];
}

-(void)addMessage:(MessageMO*)message {
    if(_messages == nil) {
        _messages = [[NSMutableArray alloc] initWithCapacity:20];
    }
    [_messages addObject:message];
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

-(NSString *)getMessageTo {
    return ([[ConnectionProvider getUser] isEqualToString:[self getFirstParticipantJID]]) ? [self getLastParticipantJID] : [self getFirstParticipantJID];
}

-(NSString *)getFirstParticipantJID {
    return [[_participants firstObject] objectForKey:PARTICIPANT_USERNAME];
}

-(NSString *)getLastParticipantJID {
    return [[_participants lastObject] objectForKey:PARTICIPANT_USERNAME];
}

-(NSArray *)getParticipantJIDS {
    return [_participants valueForKey:PARTICIPANT_USERNAME];
}

+(NSString *)createGroupID {
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    return [NSString stringWithFormat:@"%@%d", [ConnectionProvider getUser], (int)timeStamp];
}

-(NSString *)description {
    return [NSString stringWithFormat:@"\n Chat ID: %@ \n Chat Name: %@ \n Chat Type: %@ \n Chat Status: %@ \n", self.chat_id, self.chat_name, self.chat_type, self.status];
}

-(NSString *)getChatName {
    return (self.user_defined_chat_name == nil || [self.user_defined_chat_name isEqualToString:@""]) ? self.chat_name : self.user_defined_chat_name;
}

-(NSString *)getOldChatName {
    return self.chat_name;
}

@end
