//
//  ChatDBManager.h
//  Who
//
//  Created by Giancarlo Anemone on 2/28/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatDBManager : NSObject

+(BOOL)hasChatWithID:(NSString*)chatID;

+(void)insertChatWithID:(NSString*)chatID chatName:(NSString*)chatName;

+(void)updateUserDefinedChatNameWithID:(NSString*)chatID chatName:(NSString*)chatName;

+(NSString*)getChatNameWithID:(NSString*)chatID;

+(NSString*)getUserDefinedChatNameWithID:(NSString*)chatID;

+(NSArray*)getAllChats;

+(void)setHasNewMessageYes:(NSString*)chatID;

+(void)setHasNewMessageNo:(NSString*)chatID;

@end
