//
//  GroupChatManager.h
//  Who
//
//  Created by Giancarlo Anemone on 1/20/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GroupChat.h"

@interface GroupChatManager : NSObject

+(GroupChatManager*)getInstance;

-(void)addChat:(GroupChat*)chat;

-(void)removeChat:(NSString*)chatId;

-(GroupChat*)getChat:(NSString*)chatId;

-(GroupChat*)getChatByIndex:(NSInteger)index;

-(int)getNumberOfChats;

@end
