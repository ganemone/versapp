//
//  ChatDBManager.m
//  Who
//
//  Created by Giancarlo Anemone on 2/28/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "Constants.h"
#import "ChatDBManager.h"
#import "ChatMO.h"
#import "MessageMO.h"
#import "MessagesDBManager.h"

@implementation ChatDBManager

+(BOOL)hasChatWithID:(NSString *)chatID {
    return ([self getChatWithID:chatID] != nil);
}

+(void)insertChatWithID:(NSString *)chatID chatName:(NSString *)chatName chatType:(NSString*)chatType status:(int)status {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    ChatMO *chatEntry = [NSEntityDescription insertNewObjectForEntityForName:CORE_DATA_TABLE_CHATS inManagedObjectContext:moc];
    
    [chatEntry setValue:chatID forKey:CHATS_TABLE_COLUMN_NAME_CHAT_ID];
    [chatEntry setValue:chatName forKey:CHATS_TABLE_COLUMN_NAME_CHAT_NAME];
    [chatEntry setValue:chatName forKey:CHATS_TABLE_COLUMN_NAME_USER_DEFINED_CHAT_NAME];
    [chatEntry setValue:chatType forKey:CHATS_TABLE_COLUMN_NAME_CHAT_TYPE];
    [chatEntry setValue:[NSNumber numberWithInt:status] forKey:CHATS_TABLE_COLUMN_NAME_STATUS];
    [delegate saveContext];
}

+(void)updateUserDefinedChatNameWithID:(NSString *)chatID chatName:(NSString *)chatName {
    ChatMO *chatEntry = [self getChatWithID:chatID];
    [chatEntry setValue:chatName forKey:CHATS_TABLE_COLUMN_NAME_USER_DEFINED_CHAT_NAME];
    [(AppDelegate*)[UIApplication sharedApplication].delegate saveContext];
}

+(NSString *)getChatNameWithID:(NSString *)chatID {
    return [[self getChatWithID:chatID] chat_name];
}

+(NSString *)getUserDefinedChatNameWithID:(NSString *)chatID {
    return [[self getChatWithID:chatID] user_defined_chat_name];
}

+(ChatMO*)getChatWithID:(NSString*)chatID {
    return [[self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\"", CHATS_TABLE_COLUMN_NAME_CHAT_ID, chatID]] firstObject];
}

+(NSArray*)makeFetchRequest:(NSString*)predicateString {
    
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:CORE_DATA_TABLE_CHATS inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: predicateString];
    [fetchRequest setPredicate:predicate];
    
    NSError* error = NULL;
    NSArray *fetchedRecords = [moc executeFetchRequest:fetchRequest error:&error];
    
    return fetchedRecords;
}

+(NSArray*)getAllGroupChats {
    NSArray *chats = [self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\"", CHATS_TABLE_COLUMN_NAME_CHAT_TYPE, @"groupchat"]];
    [self setMessagesForChatsInArray:chats];
    for (int i = 0; i < [chats count]; i++) {
        NSLog(@"Chats: %@", [[chats objectAtIndex:i] user_defined_chat_name]);
    }
    return [self sortChats:chats];
}

+(NSArray*)getAllOneToOneChats {
    NSArray *chats =  [self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\"", CHATS_TABLE_COLUMN_NAME_CHAT_TYPE, @"chat"]];
    [self setMessagesForChatsInArray:chats];
    for (int i = 0; i < [chats count]; i++) {
        NSLog(@"Chats: %@", [[chats objectAtIndex:i] user_defined_chat_name]);
    }
    return [self sortChats:chats];
}

+(void)setMessagesForChatsInArray:(NSArray*)chats {
    ChatMO *chat;
    for (int i = 0; i < [chats count]; i++) {
        chat = [chats objectAtIndex:i];
        [chat setMessages:[MessagesDBManager getMessagesByChat:chat.chat_id]];
    }
}

+(NSArray*)sortChats:(NSArray*)chats {
    return [chats sortedArrayUsingComparator:^NSComparisonResult(id chat1, id chat2) {
        return [[[[chat2 messages] firstObject] time] compare:[[[chat1 messages] firstObject] time]];
    }];
}

+(void)setHasNewMessageNo:(NSString *)chatID {
    ChatMO *chatEntry = [self getChatWithID:chatID];
    [chatEntry setValue:@"NO" forKey:CHATS_TABLE_COLUMN_NAME_HAS_NEW_MESSAGE];
    [(AppDelegate*)[UIApplication sharedApplication].delegate saveContext];
}

+(void)setHasNewMessageYes:(NSString *)chatID {
    ChatMO *chatEntry = [self getChatWithID:chatID];
    [chatEntry setValue:@"YES" forKey:CHATS_TABLE_COLUMN_NAME_HAS_NEW_MESSAGE];
    [(AppDelegate*)[UIApplication sharedApplication].delegate saveContext];
}

+(BOOL)doesChatHaveNewMessage:(NSString *)chatID {
    ChatMO *chatEntry = [self getChatWithID:chatID];
    return ([chatEntry.has_new_message compare:@"YES"] == 0);
}

+(void)setChatStatus:(int)status chatID:(NSString*)chatID {
    ChatMO *chatEntry = [self getChatWithID:chatID];
    [chatEntry setValue:[NSNumber numberWithInt:status] forKey:CHATS_TABLE_COLUMN_NAME_STATUS];
    [(AppDelegate*)[UIApplication sharedApplication].delegate saveContext];
}


@end
