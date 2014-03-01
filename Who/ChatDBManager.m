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

@implementation ChatDBManager

+(BOOL)hasChatWithID:(NSString *)chatID {
    return ([self getChatWithID:chatID] != nil);
}

+(void)insertChatWithID:(NSString *)chatID chatName:(NSString *)chatName {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    ChatMO *chatEntry = [NSEntityDescription insertNewObjectForEntityForName:CORE_DATA_TABLE_CHATS inManagedObjectContext:moc];
    
    [chatEntry setValue:chatID forKey:CHATS_TABLE_COLUMN_NAME_CHAT_ID];
    [chatEntry setValue:chatName forKey:CHATS_TABLE_COLUMN_NAME_CHAT_NAME];
    [chatEntry setValue:chatName forKey:CHATS_TABLE_COLUMN_NAME_USER_DEFINED_CHAT_NAME];
    
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

+(NSArray *)getAllChats {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:CORE_DATA_TABLE_CHATS inManagedObjectContext:moc];
    [fetchRequest setEntity:entity];
    NSError * error = NULL;
    return [moc executeFetchRequest:fetchRequest error:&error];
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

@end