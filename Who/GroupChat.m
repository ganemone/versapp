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

+(NSString *)createGroupID {
    NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
    return [NSString stringWithFormat:@"%@%f", [ConnectionProvider getUser], timeStamp];
}

-(void)addPendingParticipants:(NSArray *)participants {
    self.participants = participants;
    self.uninvitedParticpants = YES;
}

-(void)invitePendingParticpants {
    if (self.uninvitedParticpants == YES) {
        XMPPStream *conn = [[ConnectionProvider getInstance] getConnection];
        for (int i = 0; i < self.participants.count; i++) {
            [conn sendElement:[IQPacketManager createInviteToChatPacket:self.chatID invitedUsername:[self.participants objectAtIndex:i]]];
        }
        self.uninvitedParticpants = NO;
    }
}

@end
