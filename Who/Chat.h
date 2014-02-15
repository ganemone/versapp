//
//  Chat.h
//  Who
//
//  Created by Giancarlo Anemone on 1/15/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"


@interface Chat : NSObject

@property(strong, nonatomic) NSString* chatID;
@property(strong, nonatomic) NSString* name;
@property(strong, nonatomic) NSString* createdTime;
@property(strong, nonatomic) NSString* owner;
@property(strong, nonatomic) NSMutableArray* history;

// Must update the equivalent of android preferences for the name - Link name with id

-(NSArray*)getHistory;

-(void)loadHistory;

-(void)sendMUCMessage:(NSString*)messageText;

-(void)sendMUCMessage:(NSString*)messageText imageLink:(NSString*)imageLink;

-(void)sendOneToOneMessage:(NSString*)messageText messageTo:(NSString*)messageTo;

-(void)sendOneToOneMessage:(NSString*)messageText messageTo:(NSString*)messageTo imageLink:(NSString*)imageLink;

-(void)addMessage:(Message*)message;

-(NSString*)getChatAddress;

-(Message*)getMessageByIndex:(NSInteger)index;

-(NSString *)getMessageTextByIndex:(NSInteger)index;

-(Message*)getLastMessage;

-(NSString*)getLastMessageText;

-(NSInteger)getNumberOfMessages;

+(NSString *)createGroupID;

@end
