//
//  Chat.m
//  Who
//
//  Created by Giancarlo Anemone on 1/15/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "Chat.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"
#import "MessagesDBManager.h"

@implementation Chat

-(NSArray *)getHistory {
    return self.history;
}

-(NSString *)getChatAddress {
    return [NSString stringWithFormat:@"%@@%@", self.chatID, [ConnectionProvider getConferenceIPAddress]];
}

-(void)sendMUCMessage:(NSString *)messageText {
    Message *message = [Message createForMUC:messageText sender:[ConnectionProvider getUser] chatID:self.chatID];
    [self addMessage:message];
    DDXMLElement *packet = [IQPacketManager createSendMUCMessagePacket:message];
    [[[ConnectionProvider getInstance] getConnection] sendElement:packet];
}

-(void)sendOneToOneMessage:(NSString *)messageText messageTo:(NSString *)messageTo {
    Message *message = [Message createForOneToOne:messageText sender:[ConnectionProvider getUser] chatID:self.chatID messageTo:messageTo];
    [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createSendOneToOneMessagePacket:message]];
}

-(void)sendMUCMessage:(NSString *)messageText imageLink:(NSString *)imageLink {
    Message *message = [Message createForMUCWithImage:messageText sender:[ConnectionProvider getUser] chatID:self.chatID imageLink:imageLink];
    [self addMessage:message];
    [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createSendMUCMessagePacket:message]];
}

-(void)sendOneToOneMessage:(NSString *)messageText messageTo:(NSString *)messageTo imageLink:(NSString *)imageLink {
    NSString * timeStampValue = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    Message *message = [Message createForOneToOneWithImage:messageText sender:[ConnectionProvider getUser] chatID:self.chatID messageTo:messageTo imageLink:imageLink timestamp:timeStampValue];
    [self addMessage:message];
    [MessagesDBManager insert:messageText groupID:self.chatID time:timeStampValue senderID:[ConnectionProvider getUser] receiverID:message.messageTo imageLink:imageLink];
    [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createSendOneToOneMessagePacket:message]];
}

-(void)updateMessage:(Message *)message {
    Message *tempMessage;
    for (int i = (int)self.history.count - 1; i >= 0; i--) {
        tempMessage = [self.history objectAtIndex:i];
        if ([tempMessage timestamp] == nil) {
            [tempMessage setTimestamp:message.timestamp];
            i = 0;
        }
    }
}

-(void)addMessage:(Message *)message {
    [self.history addObject:message];
}

-(void)loadHistory {
    NSArray *messages = [MessagesDBManager getMessagesByChat:self.chatID];
    self.history = [[NSMutableArray alloc] initWithCapacity:messages.count];
    for (int i = 0; i < messages.count; i++) {
    }
}

-(Message*)getMessageByIndex:(NSInteger) index {
    return [self.history objectAtIndex:index];
}

-(NSString *)getMessageTextByIndex:(NSInteger)index {
    return [[self getMessageByIndex:index] body];
}

-(Message*)getLastMessage {
    if (self.history.count > 0) {
        return [self getMessageByIndex:self.history.count - 1];
    }
    return nil;
}

-(NSString*)getLastMessageText {
    if(self.history.count > 0) {
        return [self getMessageTextByIndex:self.history.count - 1];
    }
    return @"";
}

-(NSInteger)getNumberOfMessages {
    return self.history.count;
}

+(NSString *)createGroupID {
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    return [NSString stringWithFormat:@"%@%d", [ConnectionProvider getUser], (int)timeStamp];
}

@end
