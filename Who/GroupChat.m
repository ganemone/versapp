//
//  GroupChat.m
//  Who
//
//  Created by Giancarlo Anemone on 1/15/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "GroupChat.h"
#import "ConnectionProvider.h"
#import "MessagesDBManager.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"
#import "GroupChatManager.h"

@interface GroupChat()

@property (strong, nonatomic) NSArray *participants;
@property BOOL uninvitedParticpants;

@end

@implementation GroupChat

+(GroupChat*)create:(NSString *)chatID participants:(NSArray*)participants groupName:(NSString *)groupName owner:(NSString *)owner createdTime:(NSString *)createdTime {
    GroupChat *instance = [[GroupChat alloc] init];
    instance.chatID = chatID;
    instance.participants = participants;
    instance.name = groupName;
    instance.owner = owner;
    instance.createdTime = createdTime;
    instance.history = [MessagesDBManager getMessageObjectsForMUC:instance.chatID];
    instance.uninvitedParticpants = NO;
    return instance;
}

-(void)addPendingParticipants:(NSArray *)participants {
    NSLog(@"Adding participants: %@", [participants description]);
    self.participants = participants;
    self.uninvitedParticpants = YES;
}

-(void)invitePendingParticpants {
    NSLog(@"Trying to invite Pending participants");
    GroupChatManager *gcm = [GroupChatManager getInstance];
    if (self.uninvitedParticpants == YES) {
        NSLog(@"Does have uninvited participants...");
        
        XMPPStream *conn = [[ConnectionProvider getInstance] getConnection];
        for (int i = 0; i < self.participants.count; i++) {
            NSLog(@"Inviting User: %@", [self.participants objectAtIndex:i]);
            [gcm incrementNumUninvitedUsers];
            [conn sendElement:[IQPacketManager createInviteToChatPacket:self.chatID invitedUsername:[self.participants objectAtIndex:i]]];
        }
        [gcm incrementNumUninvitedUsers];
        [conn sendElement:[IQPacketManager createInviteToChatPacket:self.chatID invitedUsername:[ConnectionProvider getUser]]];
    }
}

-(void)sendInviteMessageToParticipants {
    NSLog(@"Sending Invite Message to pending participants");
    if (self.uninvitedParticpants == YES) {
        XMPPStream *conn = [[ConnectionProvider getInstance] getConnection];
        for (int i = 0; i < self.participants.count; i++) {
            [conn sendElement:[IQPacketManager createInviteToMUCMessage:self.chatID username:[self.participants objectAtIndex:i]]];
        }
        [conn sendElement:[IQPacketManager createAcceptChatInvitePacket:self.chatID]];
        self.uninvitedParticpants = NO;
    }
}

-(NSString *)description {
    return [NSString stringWithFormat:@"Group Name: %@ \n Group ID: %@ \n Owner: %@ \n CreatedTime: %@ \n participants: %@", self.name, self.chatID, self.owner, self.createdTime, [self.participants componentsJoinedByString:@"\n"]];
}

@end
