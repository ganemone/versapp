//
//  OneToOneChatManager.m
//  Who
//
//  Created by Giancarlo Anemone on 1/25/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "OneToOneChatManager.h"
#import "Constants.h"

@interface OneToOneChatManager()

@property(strong, nonatomic) NSMutableDictionary *chats;
@property(strong, nonatomic) NSMutableArray *chatIDValues;

@property NSInteger numUninvitedUsers;
@end

@implementation OneToOneChatManager

static OneToOneChatManager *selfInstance;

+(OneToOneChatManager *)getInstance {
    @synchronized(self) {
        if(selfInstance == nil) {
            selfInstance = [[self alloc] init];
            selfInstance.chats = [[NSMutableDictionary alloc] init];
            selfInstance.chatIDValues = [[NSMutableArray alloc] init];
        }
    }
    return selfInstance;
}

-(void)addChat:(OneToOneChat *)chat {
    NSLog(@"Adding One to One Chat inside");
    [self.chats setObject:chat forKey:chat.chatID];
    [self.chatIDValues addObject:chat.chatID];
}

-(void)removeChat:(NSString *)chatId {
    [self.chats removeObjectForKey:chatId];
    [self.chatIDValues removeObject:chatId];
}

-(OneToOneChat *)getChat:(NSString *)chatId {
    return [self.chats objectForKey:chatId];
}

-(int)getNumberOfChats {
    NSLog(@"Number: %lu", (unsigned long)[self.chats count]);
    return (int)[self.chats count];
}

-(OneToOneChat *)getChatByIndex:(NSInteger)index {
    NSUInteger unsignedInteger = (NSUInteger)index;
    OneToOneChat *chat = [self.chats objectForKey:[self.chatIDValues objectAtIndex:unsignedInteger]];
    return chat;
}

-(void)incrementNumUninvitedUsers {
    self.numUninvitedUsers++;
    NSLog(@"Incrementing Number of Users to: %ld", (long)self.numUninvitedUsers);
}

-(void)decrementNumUninvitedUsers {
    self.numUninvitedUsers--;
    NSLog(@"Decrementing number of users to: %ld", (long)self.numUninvitedUsers);
    if (self.numUninvitedUsers == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_FINISHED_INVITING_ONE_TO_ONE_USERS object:nil];
    }
}

@end
