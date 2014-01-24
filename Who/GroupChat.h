//
//  GroupChat.h
//  Who
//
//  Created by Giancarlo Anemone on 1/15/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "Chat.h"

@interface GroupChat : Chat

-(void)join;

-(void)leave;

+(GroupChat*)create:(NSString*)chatID groupName: (NSString*)groupName owner: (NSString*) owner createdTime: (NSString*) createdTime;

+(NSString*)createGroupID;

@end
