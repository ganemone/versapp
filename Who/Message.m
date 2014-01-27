//
//  Message.m
//  Who
//
//  Created by Giancarlo Anemone on 1/15/14.
//  Copyright (c) 2014 Giancarlo Anemone. All rights reserved.
//

#import "Message.h"
#import "ConnectionProvider.h"

@implementation Message

+(Message *)create:(NSString *)body sender:(NSString *)sender chatID:(NSString *)chatID timestamp:(NSString *)timestamp {
    Message *instance = [[Message alloc] init];
    instance.body = body;
    instance.sender = sender;
    instance.chatID = chatID;
    instance.timestamp = timestamp;
    return instance;
}

+(Message *)create:(NSString *)body sender:(NSString *)sender chatID:(NSString *)chatID timestamp:(NSString *)timestamp messageTo:(NSString *)messageTo {
    Message *instance = [[Message alloc] init];
    instance.body = body;
    instance.sender = sender;
    instance.chatID = chatID;
    instance.timestamp = timestamp;
    instance.messageTo = messageTo;
    return instance;
}

/*-(NSTextAlignment)getMessageTextAlignment {
    return ([self.sender compare:[ConnectionProvider getUser]] == 0) ? NSTextAlignmentLeft : NSTextAlignmentRight;
}*/

@end
