//
//  GroupChat.h
//  Who
//
//  Created by Giancarlo Anemone on 1/15/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "Chat.h"

@interface GroupChat : Chat

@property BOOL joined;

+(GroupChat*)create:(NSString*)chatID participants:(NSArray *)participants groupName: (NSString*)groupName owner: (NSString*) owner createdTime: (NSString*) createdTime;

-(void)addPendingParticipants:(NSArray*)participants;

-(void)invitePendingParticpants;

-(void)sendInviteMessageToParticipants;

@end
