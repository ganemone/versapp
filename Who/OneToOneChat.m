//
//  OneToOneChat.m
//  Who
//
//  Created by Giancarlo Anemone on 1/15/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "OneToOneChat.h"
#import "ConnectionProvider.h"
#import "Constants.h"
#import "MessagesDBManager.h"
#import "FriendMO.h"
#import "FriendsDBManager.h"

@implementation OneToOneChat

+(OneToOneChat *)create:(NSString *)threadID inviterID:(NSString *)inviterID invitedID:(NSString *)invitedID createdTimestamp:(NSString *)createdTimestamp {
    OneToOneChat *instance = [[OneToOneChat alloc] init];
    instance.chatID = threadID;
    instance.createdTime = createdTimestamp;
    if([invitedID compare:[ConnectionProvider getUser]] == 0) {
        instance.name = @"Anonymous Friend";
    } else if([FriendsDBManager hasUserWithJID:invitedID]) {
        instance.name = [[FriendsDBManager getUserWithJID:invitedID] name];
    } else {
        instance.name = @"Loading...";
    }
    instance.invitedID = invitedID;
    instance.inviterID = inviterID;
    instance.history = [MessagesDBManager getMessageObjectsForOneToOneChat:instance.chatID];
    return instance;
}

+(OneToOneChat *)create:(NSString *)threadID inviterID:(NSString *)inviterID invitedID:(NSString *)invitedID createdTimestamp:(NSString *)createdTimestamp chatName:(NSString*)chatName {
    OneToOneChat *instance = [[OneToOneChat alloc] init];
    instance.chatID = threadID;
    instance.createdTime = createdTimestamp;
    instance.name = chatName;
    instance.invitedID = invitedID;
    instance.inviterID = inviterID;
    instance.history = [MessagesDBManager getMessageObjectsForOneToOneChat:instance.chatID];
    return instance;
}

-(NSString *)getMessageTo {
    return ([self.invitedID compare:[ConnectionProvider getUser]] == 0) ? self.inviterID : self.invitedID;
}

@end
