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

@implementation Chat

-(History *)getHistory {
    return self.history;
}

-(NSString *)getChatAddress {
    return [NSString stringWithFormat:@"%@@%@", self.chatID, [ConnectionProvider getConferenceIPAddress]];
}

-(void)sendMUCMessage:(NSString *)messageText {
    Message *message = [Message create:messageText sender:[ConnectionProvider getUser] chatID:self.chatID];
    [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createSendMUCMessagePacket:message]];
}

-(void)sendOneToOneMessage:(NSString *)messageText {
    Message *message = [Message create:messageText sender:[ConnectionProvider getUser] chatID:self.chatID];
    [[[ConnectionProvider getInstance] getConnection] sendElement:[IQPacketManager createSendOneToOneMessagePacket:message]];
}

-(void)sendMUCMessage:(NSString *)messageText image:(UIImage *)image {
}

-(void)sendOneToOneMessage:(NSString *)messageText image:(UIImage *)image {
}
@end
