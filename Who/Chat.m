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
    [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createSendMUCMessagePacket:message]];
}

-(void)sendOneToOneMessage:(NSString *)messageText messageTo:(NSString *)messageTo {
    Message *message = [Message createForOneToOne:messageText sender:[ConnectionProvider getUser] chatID:self.chatID messageTo:messageTo];
    [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createSendOneToOneMessagePacket:message]];
}

-(void)sendMUCMessage:(NSString *)messageText image:(UIImage *)image {
}

-(void)sendOneToOneMessage:(NSString *)messageText messageTo:(NSString*)messageTo image:(UIImage *)image {
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

@end
