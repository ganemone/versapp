//
//  ChatDBManager.h
//  Who
//
//  Created by Giancarlo Anemone on 2/28/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatMO.h"

@interface ChatDBManager : NSObject

+(BOOL)hasChatWithID:(NSString*)chatID;

+(ChatMO*)getChatWithID:(NSString*)chatID;

+(ChatMO *)getChatWithID:(NSString *)chatID withMOC:(NSManagedObjectContext *)moc;

+(ChatMO*)insertChatWithID:(NSString *)chatID chatName:(NSString *)chatName chatType:(NSString*)chatType participantString:(NSString*)participantString status:(int)status;

+(ChatMO*)insertChatWithID:(NSString *)chatID chatName:(NSString *)chatName chatType:(NSString*)chatType participantString:(NSString*)participantString status:(int)status ownerID:(NSString *)ownerID;

+(ChatMO*)insertChatWithID:(NSString *)chatID chatName:(NSString *)chatName chatType:(NSString*)chatType participantString:(NSString*)participantString status:(int)status withContext:(NSManagedObjectContext *)moc;

+(void)updateUserDefinedChatNameWithID:(NSString*)chatID chatName:(NSString*)chatName;

+(NSString*)getChatNameWithID:(NSString*)chatID;

+(NSString*)getUserDefinedChatNameWithID:(NSString*)chatID;

+(NSArray*)getAllGroupChats;

+(NSArray*)getAllActiveGroupChats;

+(NSArray*)getAllActiveOneToOneChats;

+(NSArray*)getAllOneToOneChats;

+(NSArray*)getAllPendingGroupChats;

+(void)setChatStatus:(int)status chatID:(NSString*)chatID;

+(void)setHasNewMessageYes:(NSString*)chatID;

+(void)setHasNewMessageNo:(NSString*)chatID;

+(BOOL)doesChatHaveNewMessage:(NSString *)chatID;

+(void)updateOneToOneChatNames:(NSString *)name username:(NSString*)username;

+(void)joinAllChats:(NSManagedObjectContext *)moc;

+(void)addChatParticipants:(NSMutableArray *)participants;

+(void)setChatIDAddingParticipants:(NSString *)chatID;

+(void)updateChatParticipants:(NSMutableArray*)participants;

+(void)setChatIDUpdatingParticipants:(NSString*)chatID;

+(void)setChatIDPendingCreation:(NSString*)chatID;

+(void)resetChatIDPendingCreation;

+(NSString *)getChatIDPendingCreation;

+(void)deleteChat:(ChatMO *)chat;

@end
