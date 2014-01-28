//
//  Chat.h
//  Who
//
//  Created by Giancarlo Anemone on 1/15/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "History.h"
#import "Message.h"


@interface Chat : NSObject

@property(strong, nonatomic) NSString* chatID;
@property(strong, nonatomic) NSString* name;
@property(strong, nonatomic) NSString* createdTime;
@property(strong, nonatomic) NSString* owner;
@property (strong, nonatomic) History* history;

// Must update the equivalent of android preferences for the name - Link name with id

-(History*)getHistory;

-(void)setHistory:(History*)history;

-(void)sendMUCMessage:(NSString*)messageText;

-(void)sendMUCMessage:(NSString*)messageText image:(UIImage*)image;

-(void)sendOneToOneMessage:(NSString*)messageText;

-(void)sendOneToOneMessage:(NSString*)messageText image:(UIImage*)image;


-(NSString*)getChatAddress;

@end
