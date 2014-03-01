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
#import "UserProfile.h"

static ChatParticipantVCardBuffer *selfInstance;

@implementation ChatParticipantVCardBuffer

// Class method (+) for getting instance of Connection Provider
+ (id)getInstance {
    @synchronized(self) {
        if(selfInstance == nil) {
            selfInstance = [[self alloc] init];
            selfInstance.users = [[NSMutableDictionary alloc] init];
            selfInstance.pending = [[NSMutableArray alloc] init];
        }
    }
    return selfInstance;
}

-(void)addVCard:(UserProfile*)vcard {
    if ([self.accepted containsObject:vcard.jid]) {
        [vcard setSubscriptionStatus:STATUS_FRIENDS];
    } else {
        [vcard setSubscriptionStatus:STATUS_PENDING];
    }
    [self.users setValue:vcard forKey:vcard.jid];
    [self updateOneToOneChatNames:vcard];
}

-(UserProfile*)getVCard:(NSString*)username {
    return [self.users objectForKey:username];
}

-(NSString *)getName:(NSString *)username {
    return [[self getVCard:username] nickname];
}

-(BOOL)hasVCard:(NSString *)username {
    return ([self.users objectForKey:username] != NULL) ? YES : NO;
}

-(BOOL)isFriendsWithUser:(NSString *)username {
    UserProfile *userItem = [self.users objectForKey:username];
    if (userItem == nil) {
        return NO;
    }
    return (userItem.subscriptionStatus == STATUS_FRIENDS);
}

-(BOOL)isPendingFriendWithUser:(NSString*)username {
    UserProfile *userItem = [self.users objectForKey:username];
    if (userItem == nil) {
        return NO;
    }
    return (userItem.subscriptionStatus == STATUS_PENDING);
}

-(void)setUserStatusFriends:(NSString*)username {
    [[self.users objectForKey:username] setSubscriptionStatus:STATUS_FRIENDS];
}

-(void)setUserStatusPending:(NSString*)username {
    [[self.users objectForKey:username] setSubscriptionStatus:STATUS_PENDING];
}

-(void)updateUserProfile:(NSString *)jid firstName:(NSString *)firstName lastName:(NSString *)lastName nickname:(NSString *)nickname email:(NSString *)email {
    UserProfile *user = [self getVCard:jid];
    if (user == nil) {
        user = [UserProfile create:jid subscriptionStatus:STATUS_PENDING];
        [self.users setObject:user forKey:jid];
    }
    [user setFirstName:firstName];
    [user setLastName:lastName];
    [user setNickname:nickname];
    [user setEmail:email];
    
    if ([user subscriptionStatus] == STATUS_FRIENDS) {
        [self updateOneToOneChatNames:user];
    }
}

-(NSArray*)getAcceptedUserProfiles {
    return [self.users objectsForKeys:self.accepted notFoundMarker:[NSNull null]];
}

-(NSMutableArray *)getPendingUserProfiles {
    return [self.users objectsForKeys:self.pending notFoundMarker:[NSNull null]];
}

-(void)updateOneToOneChatNames:(UserProfile*)vcard {
    OneToOneChatManager *cm = [OneToOneChatManager getInstance];
    OneToOneChat *chat;
    for (int i = 0; i < [cm getNumberOfChats]; i++) {
        chat = [cm getChatByIndex:i];
        if([chat.invitedID compare:vcard.jid] == 0 && [vcard.jid compare:[ConnectionProvider getUser]] != 0) {
            chat.name = vcard.nickname;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_UPDATE_CHAT_LIST object:nil];
        }
    }
}

-(void)addPendingFriend:(NSString *)username {
    NSLog(@"adding pending friend");
    [self.pending addObject:username];
}

@end
