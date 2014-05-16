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

static NSString *chatIDAddingParticipants;
static NSString *chatIDUpdatingParticipants;
static NSString *chatIDPendingCreation;
static int numUninvitedParticipants;

+(BOOL)hasChatWithID:(NSString *)chatID {
    return ([self getChatWithID:chatID] != nil);
}

+(ChatMO*)insertChatWithID:(NSString *)chatID chatName:(NSString *)chatName chatType:(NSString*)chatType participantString:(NSString*)participantString status:(int)status degree:(NSString *)degree {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    
    ChatMO *chatEntry = [self getChatWithID:chatID];
    
    if (chatEntry == nil) {
        chatEntry = [NSEntityDescription insertNewObjectForEntityForName:CORE_DATA_TABLE_CHATS inManagedObjectContext:moc];
        [chatEntry setValue:chatType forKey:CHATS_TABLE_COLUMN_NAME_CHAT_TYPE];
    }
    [chatEntry setValue:chatID forKey:CHATS_TABLE_COLUMN_NAME_CHAT_ID];
    [chatEntry setValue:chatName forKey:CHATS_TABLE_COLUMN_NAME_CHAT_NAME];
    [chatEntry setValue:[NSNumber numberWithInt:status] forKey:CHATS_TABLE_COLUMN_NAME_STATUS];
    [chatEntry setValue:participantString forKey:CHATS_TABLE_COLUMN_NAME_PARTICIPANT_STRING];
    [chatEntry setParticipants:[[NSMutableArray alloc] initWithArray:[participantString componentsSeparatedByString:@", "]]];
    [delegate saveContext];
    return chatEntry;
}

+(ChatMO*)insertChatWithID:(NSString *)chatID chatName:(NSString *)chatName chatType:(NSString*)chatType participantString:(NSString*)participantString status:(int)status degree:(NSString *)degree withContext:(NSManagedObjectContext *)moc {
    ChatMO *chatEntry = [self getChatWithID:chatID];
    if (chatEntry == nil) {
        chatEntry = [NSEntityDescription insertNewObjectForEntityForName:CORE_DATA_TABLE_CHATS inManagedObjectContext:moc];
    }
    [chatEntry setValue:chatType forKey:CHATS_TABLE_COLUMN_NAME_CHAT_TYPE];
    [chatEntry setValue:chatID forKey:CHATS_TABLE_COLUMN_NAME_CHAT_ID];
    [chatEntry setValue:chatName forKey:CHATS_TABLE_COLUMN_NAME_CHAT_NAME];
    [chatEntry setValue:[NSNumber numberWithInt:status] forKey:CHATS_TABLE_COLUMN_NAME_STATUS];
    [chatEntry setValue:participantString forKey:CHATS_TABLE_COLUMN_NAME_PARTICIPANT_STRING];
    [chatEntry setParticipants:[[NSMutableArray alloc] initWithArray:[participantString componentsSeparatedByString:@", "]]];
    
    return chatEntry;
}

+(ChatMO *)insertChatWithID:(NSString *)chatID chatName:(NSString *)chatName chatType:(NSString *)chatType participantString:(NSString *)participantString status:(int)status degree:(NSString *)degree ownerID:(NSString *)ownerID {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    
    ChatMO *chatEntry = [self getChatWithID:chatID];
    
    if (chatEntry == nil) {
        chatEntry = [NSEntityDescription insertNewObjectForEntityForName:CORE_DATA_TABLE_CHATS inManagedObjectContext:moc];
        [chatEntry setValue:chatType forKey:CHATS_TABLE_COLUMN_NAME_CHAT_TYPE];
    }
    [chatEntry setValue:chatID forKey:CHATS_TABLE_COLUMN_NAME_CHAT_ID];
    [chatEntry setValue:chatName forKey:CHATS_TABLE_COLUMN_NAME_CHAT_NAME];
    [chatEntry setValue:[NSNumber numberWithInt:status] forKey:CHATS_TABLE_COLUMN_NAME_STATUS];
    [chatEntry setValue:participantString forKey:CHATS_TABLE_COLUMN_NAME_PARTICIPANT_STRING];
    [chatEntry setValue:ownerID forKeyPath:CHATS_TABLE_COLUMN_NAME_OWNER_ID];
    [delegate saveContext];
    if (participantString != nil) {
        [chatEntry setParticipants:[[NSMutableArray alloc] initWithArray:[participantString componentsSeparatedByString:@", "]]];
    } else {
        [chatEntry setParticipants:[[NSMutableArray alloc] initWithObjects:[ConnectionProvider getUser], ownerID, nil]];
    }
    
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

+(ChatMO *)getChatWithID:(NSString *)chatID withMOC:(NSManagedObjectContext *)moc {
    ChatMO *chat = [[self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\"", CHATS_TABLE_COLUMN_NAME_CHAT_ID, chatID] withMOC:moc] firstObject];
    [chat setParticipants:[[NSMutableArray alloc] initWithArray:[chat.participant_string componentsSeparatedByString:@", "]]];
    return chat;
}

+(void)joinAllChats {
    NSArray *chats = [self getAllActiveGroupChats];
    XMPPStream *conn = [[ConnectionProvider getInstance] getConnection];
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSString *time = [MessagesDBManager getTimeForHistory:[delegate managedObjectContext]];
    for (ChatMO *chat in chats) {
        [conn sendElement:[IQPacketManager createJoinMUCPacket:chat.chat_id lastTimeActive:time]];
    }
}

+(NSArray*)makeFetchRequest:(NSString*)predicateString {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *moc = [delegate managedObjectContext];
    return [self makeFetchRequest:predicateString withMOC:moc];
}

+(NSArray *)makeFetchRequest:(NSString *)predicateString withMOC:(NSManagedObjectContext *)moc {
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
    NSArray *chats = [self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\" || %@ = \"%@\" || %@ = \"%@\"",CHATS_TABLE_COLUMN_NAME_CHAT_TYPE, CHAT_TYPE_ONE_TO_ONE_CONFESSION, CHATS_TABLE_COLUMN_NAME_CHAT_TYPE, CHAT_TYPE_ONE_TO_ONE_INVITED, CHATS_TABLE_COLUMN_NAME_CHAT_TYPE, CHAT_TYPE_ONE_TO_ONE_INVITER]];
    [self setUpChatsInArray:chats];
    return [self sortChats:chats];
}

+(NSArray*)getAllActiveGroupChats {
    return [self getAllChatsWithType:CHAT_TYPE_GROUP status:STATUS_JOINED];
}

+(NSArray*)getAllActiveOneToOneChats {
    NSArray *chats = [self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\" || %@ = \"%@\" || %@ = \"%@\" && %@ = \"%d\"",CHATS_TABLE_COLUMN_NAME_CHAT_TYPE, CHAT_TYPE_ONE_TO_ONE_CONFESSION, CHATS_TABLE_COLUMN_NAME_CHAT_TYPE, CHAT_TYPE_ONE_TO_ONE_INVITED, CHATS_TABLE_COLUMN_NAME_CHAT_TYPE, CHAT_TYPE_ONE_TO_ONE_INVITER, CHATS_TABLE_COLUMN_NAME_STATUS, STATUS_JOINED]];
    [self setUpChatsInArray:chats];
    return [self sortChats:chats];
}

+(NSArray*)getAllPendingGroupChats {
    return [self getAllChatsWithType:CHAT_TYPE_GROUP status:STATUS_PENDING];
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
        return [[[[chat2 messages] lastObject] time] compare:[[[chat1 messages] lastObject] time]];
    }];
}

+(void)setHasNewMessageNo:(NSString *)chatID {
    ChatMO *chatEntry = [self getChatWithID:chatID];
    [chatEntry setValue:@"NO" forKey:CHATS_TABLE_COLUMN_NAME_HAS_NEW_MESSAGE];
    UIApplication *sharedApp = [UIApplication sharedApplication];
    [(AppDelegate*)sharedApp.delegate saveContext];
    if (sharedApp.applicationIconBadgeNumber > 0) {
        [sharedApp setApplicationIconBadgeNumber:sharedApp.applicationIconBadgeNumber - 1];
    }
}

+(void)setHasNewMessageYes:(NSString *)chatID {
    ChatMO *chatEntry = [self getChatWithID:chatID];
    [chatEntry setValue:@"YES" forKey:CHATS_TABLE_COLUMN_NAME_HAS_NEW_MESSAGE];
    [(AppDelegate*)[UIApplication sharedApplication].delegate saveContext];
}

+(BOOL)doesChatHaveNewMessage:(NSString *)chatID {
    ChatMO *chatEntry = [self getChatWithID:chatID];
    return ([chatEntry.has_new_message isEqualToString:@"YES"]);
}

+(void)setChatStatus:(int)status chatID:(NSString*)chatID {
    ChatMO *chatEntry = [self getChatWithID:chatID];
    [chatEntry setValue:[NSNumber numberWithInt:status] forKey:CHATS_TABLE_COLUMN_NAME_STATUS];
    [(AppDelegate*)[UIApplication sharedApplication].delegate saveContext];
}

+(int)getNumForBadge {
    return (int)[[self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\" || %@ = \"%@\"", CHATS_TABLE_COLUMN_NAME_HAS_NEW_MESSAGE, @"YES", CHATS_TABLE_COLUMN_NAME_STATUS, [NSNumber numberWithInt:STATUS_PENDING]]] count];
}

+(void)updateOneToOneChatNames:(NSString *)name username:(NSString*)username {
    NSArray *loadingOneToOneChats = [self makeFetchRequest:[NSString stringWithFormat:@"%@ = \"%@\"", CHATS_TABLE_COLUMN_NAME_CHAT_TYPE, CHAT_TYPE_ONE_TO_ONE_INVITER]];
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

+(void)addChatParticipants:(NSMutableArray *)participants {
    if (chatIDAddingParticipants != nil) {
        ChatMO *chat = [self getChatWithID:chatIDAddingParticipants];
        chat.owner_id = [ConnectionProvider getUser];
        
        XMPPStream *conn = [[ConnectionProvider getInstance] getConnection];
        for (NSString *participant in participants) {
            if ([chat.participants containsObject:participant] == NO) {
                [conn sendElement:[IQPacketManager createInviteToChatPacket:chat.chat_id invitedUsername:participant]];
                [conn sendElement:[IQPacketManager createInviteToMUCMessage:chat.chat_id username:participant chatName:chat.chat_name]];
            }
        }
        
        AppDelegate *delegate = [UIApplication sharedApplication].delegate;
        [delegate saveContext];
        chatIDUpdatingParticipants = nil;
    }
}

+(void)setChatIDAddingParticipants:(NSString *)chatID {
    chatIDAddingParticipants = chatID;
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

+(void)deleteChat:(ChatMO *)chat {
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [[delegate managedObjectContext] deleteObject:chat];
    [delegate saveContext];
}

@end
