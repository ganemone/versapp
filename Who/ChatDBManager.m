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
#import "ConnectionProvider.h"
#import "IQPacketManager.h"
@implementation ChatDBManager

static NSString *chatIDUpdatingParticipants;
static NSString *chatIDPendingCreation;
static int numUninvitedParticipants;

+(BOOL)hasChatWithID:(NSString *)chatID {
    return ([self getChatWithID:chatID] != nil);
}

+(ChatMO*)insertChatWithID:(NSString *)chatID chatName:(NSString *)chatName chatType:(NSString*)chatType participantString:(NSString*)participantString status:(int)status {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    
    ChatMO *chatEntry = [self getChatWithID:chatID];
    
    if (chatEntry == nil) {
        chatEntry = [NSEntityDescription insertNewObjectForEntityForName:CORE_DATA_TABLE_CHATS inManagedObjectContext:moc];
    }
    NSLog(@"Setting Chat Name from %@ to %@",chatEntry.user_defined_chat_name, chatName);
    [chatEntry setValue:chatID forKey:CHATS_TABLE_COLUMN_NAME_CHAT_ID];
    [chatEntry setValue:chatName forKey:CHATS_TABLE_COLUMN_NAME_CHAT_NAME];
    [chatEntry setValue:chatName forKey:CHATS_TABLE_COLUMN_NAME_USER_DEFINED_CHAT_NAME];
    [chatEntry setValue:chatType forKey:CHATS_TABLE_COLUMN_NAME_CHAT_TYPE];
    [chatEntry setValue:[NSNumber numberWithInt:status] forKey:CHATS_TABLE_COLUMN_NAME_STATUS];
    [chatEntry setValue:participantString forKey:CHATS_TABLE_COLUMN_NAME_PARTICIPANT_STRING];
    [delegate saveContext];
    NSLog(@"Inserting Chat: %@", [chatEntry description]);
    [chatEntry setParticipants:[[NSMutableArray alloc] initWithArray:[participantString componentsSeparatedByString:@", "]]];
    
    return chatEntry;
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
    ChatMO *chat = [[self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\"", CHATS_TABLE_COLUMN_NAME_CHAT_ID, chatID]] firstObject];
    [chat setParticipants:[[NSMutableArray alloc] initWithArray:[chat.participant_string componentsSeparatedByString:@", "]]];
    return chat;
}

+(void)joinAllChats {
    NSArray *chats = [self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\" && %@ = \"%d\"",CHATS_TABLE_COLUMN_NAME_CHAT_TYPE, CHAT_TYPE_GROUP, CHATS_TABLE_COLUMN_NAME_STATUS, STATUS_JOINED]];
    XMPPStream *conn = [[ConnectionProvider getInstance] getConnection];
    NSString *time = [MessagesDBManager getTimeForHistory];
    for (ChatMO *chat in chats) {
        [conn sendElement:[IQPacketManager createJoinMUCPacket:chat.chat_id lastTimeActive:time]];
    }
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
    return [self getAllChatsWithType:CHAT_TYPE_GROUP];
}

+(NSArray*)getAllOneToOneChats {
    return [self getAllChatsWithType:CHAT_TYPE_ONE_TO_ONE];
}

+(NSArray*)getAllActiveGroupChats {
    return [self getAllChatsWithType:CHAT_TYPE_GROUP status:STATUS_JOINED];
}

+(NSArray*)getAllActiveOneToOneChats {
    return [self getAllChatsWithType:CHAT_TYPE_ONE_TO_ONE status:STATUS_JOINED];
}

+(NSArray*)getAllPendingGroupChats {
    return [self getAllChatsWithType:CHAT_TYPE_GROUP status:STATUS_PENDING];
}

+(NSArray*)getAllPendingOneToOneChats {
    return [self getAllChatsWithType:CHAT_TYPE_ONE_TO_ONE status:STATUS_PENDING];
}

+(NSArray*)getAllChatsWithType:(NSString*)type status:(int)status {
    NSArray *chats = [self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\" && %@ = \"%d\"", CHATS_TABLE_COLUMN_NAME_CHAT_TYPE, type, CHATS_TABLE_COLUMN_NAME_STATUS, status]];
    [self setUpChatsInArray:chats];
    return [self sortChats:chats];
}

+(NSArray*)getAllChatsWithType:(NSString*)type {
    NSArray *chats = [self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\"", CHATS_TABLE_COLUMN_NAME_CHAT_TYPE, type]];
    [self setUpChatsInArray:chats];
    return [self sortChats:chats];
}

+(void)setUpChatsInArray:(NSArray*)chats {
    ChatMO *chat;
    for (int i = 0; i < [chats count]; i++) {
        chat = [chats objectAtIndex:i];
        [chat setMessages:[MessagesDBManager getMessagesByChat:chat.chat_id]];
        [chat setParticipants:[NSMutableArray arrayWithArray:[chat.participant_string componentsSeparatedByString:@", "]]];
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

+(void)updateOneToOneChatNames:(NSString *)name username:(NSString*)username {
    NSArray *loadingOneToOneChats = [self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\"", CHATS_TABLE_COLUMN_NAME_CHAT_TYPE, CHAT_TYPE_ONE_TO_ONE]];
    ChatMO *chatEntry;
    for (int i = 0; i < loadingOneToOneChats.count; i++) {
        chatEntry = [loadingOneToOneChats objectAtIndex:i];
        if ([chatEntry.chat_name isEqualToString:@"Loading..."] || chatEntry.chat_name == nil) {
            if ([[chatEntry.participant_string componentsSeparatedByString:@", "] containsObject:username]) {
                [chatEntry setValue:name forKey:CHATS_TABLE_COLUMN_NAME_CHAT_NAME];
                [chatEntry setValue:name forKey:CHATS_TABLE_COLUMN_NAME_USER_DEFINED_CHAT_NAME];
                [(AppDelegate*)[UIApplication sharedApplication].delegate saveContext];
            }
        }
    }
}

+(void)updateChatParticipants:(NSMutableArray *)participants {
    if (chatIDUpdatingParticipants != nil) {
        ChatMO *chat = [self getChatWithID:chatIDUpdatingParticipants];
        [chat setParticipants:participants];
        [chat setParticipant_string:[participants componentsJoinedByString:@", "]];
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        [delegate saveContext];
        chatIDUpdatingParticipants = nil;
    }
}

+(void)setChatIDUpdatingParticipants:(NSString*)chatID {
    chatIDUpdatingParticipants = chatID;
}

+(void)incrementNumUninvitedParticipants {
    numUninvitedParticipants++;
}

+(void)decrementNumUninvitedParticipants {
    numUninvitedParticipants--;
    if (numUninvitedParticipants == 0) {
        ChatMO *chat = [self getChatWithID:chatIDUpdatingParticipants];
        XMPPStream *conn = [[ConnectionProvider getInstance] getConnection];
        for (NSString *participant in chat.participants) {
            [conn sendElement:[IQPacketManager createInviteToMUCMessage:chat.chat_id username:participant]];
        }
    }
}

+(int)getNumUninvitedParticipants {
    return numUninvitedParticipants;
}

+(void)resetNumUninvitedParticipants {
    numUninvitedParticipants = 0;
}

+(void)setNumUninvitedParticipants:(int)num {
    numUninvitedParticipants = num;
}

+(void)setChatIDPendingCreation:(NSString*)chatID {
    chatIDPendingCreation = chatID;
}

+(void)resetChatIDPendingCreation {
    chatIDPendingCreation = nil;
}

+(NSString *)getChatIDPendingCreation {
    return chatIDPendingCreation;
}

@end
