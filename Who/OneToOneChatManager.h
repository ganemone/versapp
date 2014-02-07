//
//  OneToOneChatManager.h
//  Who
//
//  Created by Giancarlo Anemone on 1/25/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OneToOneChat.h"

@interface OneToOneChatManager : NSObject

+(OneToOneChatManager*)getInstance;

-(void)addChat:(OneToOneChat*)chat;

-(void)removeChat:(NSString*)chatId;

-(OneToOneChat*)getChat:(NSString*)chatId;

-(OneToOneChat*)getChatByIndex:(NSInteger)index;

-(int)getNumberOfChats;

-(void)incrementNumUninvitedUsers;

-(void)decrementNumUninvitedUsers;

@end
