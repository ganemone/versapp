//
//  History.h
//  Who
//
//  Created by Giancarlo Anemone on 1/15/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Message.h"

@interface History : NSObject

@property (strong, nonatomic) NSMutableArray *messages;

+(History*)create:(NSMutableArray*)messages;

-(NSString*)getLastMessage;

-(void)addMessage:(Message*)message;

-(int)getNumberOfMessages;

-(NSString*)getMessageByIndex:(int)index;

@end
