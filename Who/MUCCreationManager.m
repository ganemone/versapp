//
//  MUCCreationManager.m
//  Who
//
//  Created by Giancarlo Anemone on 2/4/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "MUCCreationManager.h"
#import "XMPPRoomMemoryStorage.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"
#import "ChatDBManager.h"
#import "Constants.h"
#import "NSString+URLEncode.h"

@implementation MUCCreationManager

+(ChatMO*)createMUC:(NSString *)roomName participants:(NSArray*)participants {
    // Send who:iq packet to activate create chat module
    ConnectionProvider *cp = [ConnectionProvider getInstance];
    XMPPStream *conn = [cp getConnection];
    NSString *chatID = [ChatMO createGroupID];
    roomName = [roomName urlEncode];
    [conn sendElement:[IQPacketManager createCreateMUCPacket:chatID roomName:roomName participants:participants]];
    [cp setPendingParticipantsChatID:chatID];
    // initialize, configure, and join room
    XMPPRoomMemoryStorage *storage = [[XMPPRoomMemoryStorage alloc] init];
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", chatID, [ConnectionProvider getConferenceIPAddress]]];
    XMPPRoom *room = [[XMPPRoom alloc] initWithRoomStorage:storage jid:jid];

    [room addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [room activate:conn];
    [room joinRoomUsingNickname:[ConnectionProvider getUser] history:nil];
    //[room fetchConfigurationForm];
    [room configureRoomUsingOptions:[IQPacketManager createRoomConfigurationForm:chatID]];
    ChatMO *chat = [ChatDBManager insertChatWithID:chatID chatName:roomName chatType:CHAT_TYPE_GROUP participantString:[participants componentsJoinedByString:@", "] status:STATUS_JOINED degree:@"1"];
    for (NSString *participant in participants) {
        [conn sendElement:[IQPacketManager createInviteToMUCMessage:chatID username:participant chatName:roomName]];
    }
    return chat;
}

-(void)handleDidJoinRoom:(XMPPRoom *)room withNickname:(NSString *)nickname {
}

-(void)handleDidLeaveRoom:(XMPPRoom *)room {
}

-(void)handleIncomingMessage:(XMPPMessage *)message room:(XMPPRoom *)room {
}

-(void)handleOutgoingMessage:(XMPPMessage *)message room:(XMPPRoom *)room {
}

-(void)handlePresence:(XMPPPresence *)presence room:(XMPPRoom *)room {
}

@end
