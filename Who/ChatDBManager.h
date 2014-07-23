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


+(ChatMO*)getChatWithID:(NSString*)chatID;
+(ChatMO *)getChatWithID:(NSString *)chatID withMOC:(NSManagedObjectContext *)moc;
+(ChatMO*)insertChatWithID:(NSString *)chatID chatName:(NSString *)chatName chatType:(NSString*)chatType participantString:(NSString*)participantString status:(int)status degree:(NSString *)degree;
+(ChatMO*)insertChatWithID:(NSString *)chatID chatName:(NSString *)chatName chatType:(NSString*)chatType participantString:(NSString*)participantString status:(int)status degree:(NSString *)degree ownerID:(NSString *)ownerID;
+(ChatMO*)insertChatWithID:(NSString *)chatID chatName:(NSString *)chatName chatType:(NSString*)chatType participantString:(NSString*)participantString status:(int)status degree:(NSString *)degree withContext:(NSManagedObjectContext *)moc;

+(void)updateUserDefinedChatNameWithID:(NSString*)chatID chatName:(NSString*)chatName;
+(NSString*)getChatNameWithID:(NSString*)chatID;
+(NSString*)getUserDefinedChatNameWithID:(NSString*)chatID;
+(NSArray*)getAllGroupChats;
+(NSArray*)getAllActiveGroupChats;
+(NSArray*)getAllActiveOneToOneChats;
+(NSArray*)getAllOneToOneChats;
+(NSArray*)getAllPendingGroupChats;
+(NSArray*)getAllThoughtChats;

+(void)setChatStatus:(int)status chatID:(NSString*)chatID;
+(void)setHasNewMessageYes:(NSString*)chatID;
+(void)setHasNewMessageNo:(NSString*)chatID;
+(void)deleteChatsNotInArray:(NSArray *)chatIDS withStatus:(int)status;

+(void)updateOneToOneChatNames:(NSString *)name username:(NSString*)username;
+(void)joinAllChats;
+(void)addChatParticipants:(NSMutableArray *)participants;
+(void)setChatIDAddingParticipants:(NSString *)chatID;
+(void)updateChatParticipants:(NSMutableArray*)participants;
+(void)setChatIDUpdatingParticipants:(NSString*)chatID;
+(void)setChatIDPendingCreation:(NSString*)chatID;
+(void)resetChatIDPendingCreation;
+(NSString *)getChatIDPendingCreation;
+(void)deleteChat:(ChatMO *)chat;
+(int)getNumForBadge;

+(BOOL)hasChatWithID:(NSString*)chatID;
+(BOOL)doesChatHaveNewMessage:(NSString *)chatID;
@end
