//
//  GroupChatManager.m
//  Who
//
//  Created by Giancarlo Anemone on 1/20/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "GroupChatManager.h"
#import "Constants.h"
#import "ConnectionProvider.h"
#import "IQPacketManager.h"

@interface GroupChatManager()

@property(strong, nonatomic) NSMutableDictionary *mucs;
@property(strong, nonatomic) NSMutableArray *mucIDValues;
@property (strong, nonatomic) NSString *timeLastActive;
@property NSInteger numUninvitedUsers;

@end

static GroupChatManager * selfInstance;

@implementation GroupChatManager

@synthesize pending;

+(GroupChatManager *)getInstance {
    @synchronized(self) {
        if(selfInstance == nil) {
            selfInstance = [[self alloc] init];
            selfInstance.mucs = [[NSMutableDictionary alloc] init];
            selfInstance.mucIDValues = [[NSMutableArray alloc] init];
            selfInstance.numUninvitedUsers = 0;
            selfInstance.pending = [[NSMutableArray alloc] init];
        }
    }
    return selfInstance;
}

-(void)addChat:(GroupChat *)chat {
    if (self.timeLastActive == nil) {
        chat.joined = NO;
    } else {
        chat.joined = YES;
        XMPPStream *conn = [[ConnectionProvider getInstance] getConnection];
        [conn sendElement:[IQPacketManager createJoinMUCPacket:chat.chatID lastTimeActive:self.timeLastActive]];
    }
    [self.mucs setObject:chat forKey:chat.chatID];
    [self.mucIDValues addObject:chat.chatID];
    [self sortChats];
}

-(void)removeChat:(NSString *)chatId {
    [self.mucs removeObjectForKey:chatId];
    [self.mucIDValues removeObject:chatId];
}

-(GroupChat *)getChat:(NSString *)chatId {
    return [self.mucs objectForKey:chatId];
}

-(int)getNumberOfChats {
    return (int)[self.mucs count];
}

-(GroupChat *)getChatByIndex:(NSInteger)index {
    NSUInteger unsignedInteger = (NSUInteger)index;
    GroupChat *muc = [self.mucs objectForKey:[self.mucIDValues objectAtIndex:unsignedInteger]];
    return muc;
}

-(void)invitePendingParticipants {
    GroupChat * chat;
    for (int i = 0; i < self.mucIDValues.count; i++) {
        chat = [self.mucs objectForKey:[self.mucIDValues objectAtIndex:i]];
        [chat invitePendingParticpants];
    }
}

-(void)incrementNumUninvitedUsers {
    self.numUninvitedUsers++;
}

-(void)decrementNumUninvitedUsers {
    self.numUninvitedUsers--;
    if (self.numUninvitedUsers == 0) {
        GroupChat * chat;
        for (int i = 0; i < self.mucIDValues.count; i++) {
            chat = [self.mucs objectForKey:[self.mucIDValues objectAtIndex:i]];
            [chat sendInviteMessageToParticipants];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FINISHED_INVITING_MUC_USERS object:nil];
    }
}

-(void)setTimeForHistory:(NSString *)time {
    self.timeLastActive = time;
    NSEnumerator *enumerator = [self.mucs objectEnumerator];
    XMPPStream *conn = [[ConnectionProvider getInstance] getConnection];
    GroupChat *gc;
    while ((gc = enumerator.nextObject) != nil) {
        if (gc.joined == NO) {
            [conn sendElement:[IQPacketManager createJoinMUCPacket:gc.chatID lastTimeActive:self.timeLastActive]];
        }
    }
}

-(void)sortChats {
    NSArray *sortedIDValues = [self.mucIDValues sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSString *first = [[[[self mucs] objectForKey:a] getLastMessage] timestamp];
        NSString *second = [[[[self mucs] objectForKey:b] getLastMessage] timestamp];
        return [second compare:first];
    }];
    _mucIDValues = [[NSMutableArray alloc] initWithArray:sortedIDValues];
}

@end
