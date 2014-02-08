//
//  GroupChatManager.m
//  Who
//
//  Created by Giancarlo Anemone on 1/20/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "GroupChatManager.h"
#import "Constants.h"

@interface GroupChatManager()

@property(strong, nonatomic) NSMutableDictionary *mucs;
@property(strong, nonatomic) NSMutableArray *mucIDValues;
@property NSInteger numUninvitedUsers;

@end

static GroupChatManager * selfInstance;

@implementation GroupChatManager

+(GroupChatManager *)getInstance {
    @synchronized(self) {
        if(selfInstance == nil) {
            selfInstance = [[self alloc] init];
            selfInstance.mucs = [[NSMutableDictionary alloc] init];
            selfInstance.mucIDValues = [[NSMutableArray alloc] init];
            selfInstance.numUninvitedUsers = 0;
        }
    }
    return selfInstance;
}

-(void)addChat:(GroupChat *)chat {
    [self.mucs setObject:chat forKey:chat.chatID];
    [self.mucIDValues addObject:chat.chatID];
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
    NSLog(@"Incrementing Number of Users to: %ld", (long)self.numUninvitedUsers);
}

-(void)decrementNumUninvitedUsers {
    self.numUninvitedUsers--;
    NSLog(@"Decrementing number of users to: %ld", (long)self.numUninvitedUsers);
    if (self.numUninvitedUsers == 0) {
        GroupChat * chat;
        for (int i = 0; i < self.mucIDValues.count; i++) {
            chat = [self.mucs objectForKey:[self.mucIDValues objectAtIndex:i]];
            [chat sendInviteMessageToParticipants];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FINISHED_INVITING_MUC_USERS object:nil];
    }
}

@end
