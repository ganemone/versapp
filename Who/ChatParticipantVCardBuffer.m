//
//  ChatParticipantVCardBuffer.m
//  Who
//
//  Created by Giancarlo Anemone on 1/31/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "ChatParticipantVCardBuffer.h"
#import "Constants.h"
#import "OneToOneChatManager.h"
#import "OneToOneChat.h"
#import "ConnectionProvider.h"

@interface ChatParticipantVCardBuffer()

@property (strong, nonatomic) NSMutableDictionary *vcards;
@property int numFriends;
@property int numPending;

@end

static ChatParticipantVCardBuffer *selfInstance;

@implementation ChatParticipantVCardBuffer

@synthesize numFriends;
@synthesize numPending;

// Class method (+) for getting instance of Connection Provider
+ (id)getInstance {
    @synchronized(self) {
        if(selfInstance == nil) {
            selfInstance = [[self alloc] init];
            selfInstance.vcards = [[NSMutableDictionary alloc] init];
            selfInstance.numFriends = 0;
            selfInstance.numPending = 0;
        }
    }
    return selfInstance;
}

-(void)addVCard:(NSDictionary*)vcard {
    NSString *username = [vcard objectForKey:VCARD_TAG_USERNAME];
    [self.vcards setValue:vcard forKey:username];
    OneToOneChatManager *cm = [OneToOneChatManager getInstance];
    OneToOneChat *chat;
    for (int i = 0; i < [cm getNumberOfChats]; i++) {
        chat = [cm getChatByIndex:i];
        NSLog(@"Invited ID: %@", chat.invitedID);
        NSLog(@"Inviter ID: %@", chat.inviterID);
        if([chat.invitedID compare:username] == 0 && [username compare:[ConnectionProvider getUser]] != 0) {
            chat.name = [vcard objectForKey:VCARD_TAG_NICKNAME];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_CHAT_LIST object:nil];
        }
    }
    if ((int)[vcard objectForKey:FRIENDS_TABLE_COLUMN_NAME_STATUS] == STATUS_FRIENDS) {
        self.numFriends++;
    } else if((int)[vcard objectForKey:FRIENDS_TABLE_COLUMN_NAME_STATUS] == STATUS_PENDING) {
        self.numPending++;
    }
}

-(NSDictionary*)getVCard:(NSString*)username {
    return [self.vcards objectForKey:username];
}

-(NSString *)getName:(NSString *)username {
    return [[self getVCard:username] objectForKey:VCARD_TAG_NICKNAME];
}

-(BOOL)hasVCard:(NSString *)username {
    return ([self.vcards objectForKey:username] != NULL) ? YES : NO;
}

-(BOOL)isFriendsWithUser:(NSString *)username {
    NSDictionary *userItem = [self.vcards objectForKey:username];
    if (userItem == nil) {
        return NO;
    }
    return ((int)[self.vcards objectForKey:FRIENDS_TABLE_COLUMN_NAME_STATUS] == STATUS_FRIENDS);
}

-(BOOL)isPendingFriendWithUser:(NSString*)username {
    NSDictionary *userItem = [self.vcards objectForKey:username];
    if (userItem == nil) {
        return NO;
    }
    return ((int)[self.vcards objectForKey:FRIENDS_TABLE_COLUMN_NAME_STATUS] == STATUS_PENDING);
}

-(void)setUserStatusFriends:(NSString*)username {
    if ((int)[[self.vcards objectForKey:username] objectForKey:FRIENDS_TABLE_COLUMN_NAME_STATUS] == STATUS_PENDING) {
        self.numPending--;
    }
    [[self.vcards objectForKey:username] setObject:[NSNumber numberWithInt:STATUS_FRIENDS] forKey:FRIENDS_TABLE_COLUMN_NAME_STATUS];
    self.numFriends++;
}

-(void)setUserStatusPending:(NSString*)username {
    if ((int)[[self.vcards objectForKey:username] objectForKey:FRIENDS_TABLE_COLUMN_NAME_STATUS] == STATUS_FRIENDS) {
        self.numFriends--;
    }
    [[self.vcards objectForKey:username] setObject:[NSNumber numberWithInt:STATUS_PENDING] forKey:FRIENDS_TABLE_COLUMN_NAME_STATUS];
    self.numPending++;
}

@end
