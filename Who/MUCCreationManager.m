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

@implementation MUCCreationManager

+(GroupChat*)createMUC:(NSString *)roomName participants:(NSArray*)participants {
    NSLog(@"Going to try and create a muc");
    XMPPRoomMemoryStorage *storage = [[XMPPRoomMemoryStorage alloc] init];
    XMPPJID *jid = [XMPPJID jidWithString:roomName];
    NSLog(@"jid: %@", [jid description]);
    XMPPRoom *room = [[XMPPRoom alloc] initWithRoomStorage:storage jid:jid];
    ConnectionProvider *cp = [ConnectionProvider getInstance];
    XMPPStream *stream = [cp getConnection];
    [room addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [room activate:stream];
    [room joinRoomUsingNickname:[ConnectionProvider getUser] history:nil];
    [room fetchConfigurationForm];
    [room configureRoomUsingOptions:[IQPacketManager createRoomConfigurationForm:roomName]];
    GroupChatManager *gcm = [GroupChatManager getInstance];
    NSString *groupId = [GroupChat createGroupID];
    GroupChat *gc = [GroupChat create:groupId participants:participants groupName:roomName owner:[ConnectionProvider getUser] createdTime:0];
    [gcm addChat: gc];
    
    for (int i = 0; i < participants.count; i++) {
        [stream sendElement:[IQPacketManager createInviteToChatPacket:groupId invitedUsername:[participants objectAtIndex:i]]];
    }
    return gc;
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
