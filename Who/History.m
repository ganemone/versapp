//
//  History.m
//  Who
//
//  Created by Giancarlo Anemone on 1/15/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "History.h"

@implementation History

+(History *)create:(NSMutableArray *)messages {
    History *instance = [[History alloc] init];
    instance.messages = messages;
    return instance;
}

-(NSString *)getLastMessage {
    if (self.messages.count == 0) {
        return @"";
    }
    return [[self.messages lastObject] body];
}

-(void)addMessage:(Message *)message {
    [self.messages addObject:message];
}

@end
