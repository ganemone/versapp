//
//  MUCCreationManager.m
//  Who
//
//  Created by Giancarlo Anemone on 2/4/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "MUCCreationManager.h"
#import "XMPPRoom.h"
#import "XMPPMUC.h"
#import "XMPPRoomMemoryStorage.h"
#import "ConnectionProvider.h"
#import "GroupChatManager.h"
#import "IQPacketManager.h"
#import "ChatMO.h"
#import "ChatDBManager.h"
#import "Constants.h"

@implementation MUCCreationManager

+(ChatMO*)createMUC:(NSString *)roomName participants:(NSArray*)participants {
    // Send who:iq packet to activate create chat module
    ConnectionProvider *cp = [ConnectionProvider getInstance];
    XMPPStream *conn = [cp getConnection];
    NSString *chatID = [ChatMO createGroupID];
    [conn sendElement:[IQPacketManager createCreateMUCPacket:chatID roomName:roomName participants:participants]];
    
    // initialize, configure, and join room
    XMPPRoomMemoryStorage *storage = [[XMPPRoomMemoryStorage alloc] init];
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", chatID, [ConnectionProvider getConferenceIPAddress]]];
    XMPPRoom *room = [[XMPPRoom alloc] initWithRoomStorage:storage jid:jid];

    [room addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [room activate:conn];
    [room joinRoomUsingNickname:[ConnectionProvider getUser] history:nil];
    //[room fetchConfigurationForm];
    [room configureRoomUsingOptions:[IQPacketManager createRoomConfigurationForm:roomName]];
    
    return [ChatDBManager insertChatWithID:chatID chatName:roomName chatType:CHAT_TYPE_GROUP participantString:@"" status:STATUS_JOINED];
}

-(void)handleDidJoinRoom:(XMPPRoom *)room withNickname:(NSString *)nickname {
    NSLog(@"Did Join Room: %@ %@", [room description], nickname);
}

-(void)handleDidLeaveRoom:(XMPPRoom *)room {
    NSLog(@"Did leave room: %@", [room description]);
}

-(void)handleIncomingMessage:(XMPPMessage *)message room:(XMPPRoom *)room {
    NSLog(@"Handle Incoming Message: %@ %@", message.XMLString, [room description]);
}

-(void)handleOutgoingMessage:(XMPPMessage *)message room:(XMPPRoom *)room {
    NSLog(@"Handle Outgoing Message: %@ %@", message.XMLString, [room description]);
}

-(void)handlePresence:(XMPPPresence *)presence room:(XMPPRoom *)room {
    NSLog(@"Handle Presence: %@ %@", presence.XMLString, [room description]);
}

@end
