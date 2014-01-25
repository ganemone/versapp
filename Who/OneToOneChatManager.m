//
//  OneToOneChatManager.m
//  Who
//
//  Created by Giancarlo Anemone on 1/25/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "OneToOneChatManager.h"

@interface OneToOneChatManager()

@property(strong, nonatomic) NSMutableDictionary *chats;
@property(strong, nonatomic) NSMutableArray *chatIDValues;

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
    return [self.chats count];
}

-(OneToOneChat *)getChatByIndex:(NSInteger)index {
    NSUInteger unsignedInteger = (NSUInteger)index;
    OneToOneChat *chat = [self.chats objectForKey:[self.chatIDValues objectAtIndex:unsignedInteger]];
    return chat;
}

@end
