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

+(ChatMO*)insertChatWithID:(NSString *)chatID chatName:(NSString *)chatName chatType:(NSString*)chatType participantString:(NSString*)participantString status:(int)status;

+(void)updateUserDefinedChatNameWithID:(NSString*)chatID chatName:(NSString*)chatName;

+(NSString*)getChatNameWithID:(NSString*)chatID;

+(NSString*)getUserDefinedChatNameWithID:(NSString*)chatID;

+(NSArray*)getAllGroupChats;

+(NSArray*)getAllActiveActiveGroupChats;

+(NSArray*)getAllOneToOneChats;

+(void)setHasNewMessageYes:(NSString*)chatID;

+(void)setHasNewMessageNo:(NSString*)chatID;

+(BOOL)doesChatHaveNewMessage:(NSString *)chatID;

+(void)updateOneToOneChatNames:(NSString *)name username:(NSString*)username;

+(void)joinAllChats;

@end
