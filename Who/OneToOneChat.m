//
//  OneToOneChat.m
//  Who
//
//  Created by Giancarlo Anemone on 1/15/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "OneToOneChat.h"
#import "ConnectionProvider.h"

@implementation OneToOneChat

+(OneToOneChat *)create:(NSString *)threadID inviterID:(NSString *)inviterID invitedID:(NSString *)invitedID createdTimestamp:(NSString *)createdTimestamp {
    OneToOneChat *instance = [[OneToOneChat alloc] init];
    instance.chatID = threadID;
    instance.createdTime = createdTimestamp;
    if([invitedID compare:[ConnectionProvider getUser]] == 0) {
        instance.name = @"Anonymous Friend";
    } else {
        instance.name = invitedID;
    }
    instance.invitedID = invitedID;
    instance.inviterID = inviterID;
    instance.history = [History create:[[NSMutableArray alloc] init]];
    [instance.history addMessage:[Message create:@"Hey man, what is going on?" sender:inviterID chatID:threadID]];
    [instance.history addMessage:[Message create:@"Not much dude.  This is a test message that goes for a bit longer than the other message" sender:inviterID chatID:threadID]];
    
    return instance;
}

@end
