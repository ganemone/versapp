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

+(ChatMO*)insertChatWithID:(NSString*)chatID chatName:(NSString*)chatName chatType:(NSString*)chatType status:(int)status;

+(void)updateUserDefinedChatNameWithID:(NSString*)chatID chatName:(NSString*)chatName;

+(NSString*)getChatNameWithID:(NSString*)chatID;

+(NSString*)getUserDefinedChatNameWithID:(NSString*)chatID;

+(NSArray*)getAllGroupChats;

+(NSArray*)getAllOneToOneChats;

+(void)setHasNewMessageYes:(NSString*)chatID;

+(void)setHasNewMessageNo:(NSString*)chatID;

+(BOOL)doesChatHaveNewMessage:(NSString *)chatID;

@end
