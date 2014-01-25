//
//  GroupChatManager.m
//  Who
//
//  Created by Giancarlo Anemone on 1/20/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "GroupChatManager.h"

@interface GroupChatManager()

@property(strong, nonatomic) NSMutableDictionary *mucs;
@property(strong, nonatomic) NSMutableArray *mucIDValues;

@end

static GroupChatManager * selfInstance;

@implementation GroupChatManager

+(GroupChatManager *)getInstance {
    @synchronized(self) {
        if(selfInstance == nil) {
            selfInstance = [[self alloc] init];
            selfInstance.mucs = [[NSMutableDictionary alloc] init];
            selfInstance.mucIDValues = [[NSMutableArray alloc] init];
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
    return [self.mucs count];
}

-(GroupChat *)getChatByIndex:(NSInteger)index {
    NSUInteger unsignedInteger = (NSUInteger)index;
    GroupChat *muc = [self.mucs objectForKey:[self.mucIDValues objectAtIndex:unsignedInteger]];
    return muc;
}
@end
