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

+(Message *)createForMUC:(NSString *)body sender:(NSString *)sender chatID:(NSString *)chatID {
    Message *instance = [[Message alloc] init];
    instance.body = body;
    instance.sender = sender;
    instance.chatID = chatID;
    return instance;
}

+(Message *)createForMUC:(NSString *)body sender:(NSString *)sender chatID:(NSString *)chatID timestamp:(NSString *)timestamp {
    Message *instance = [[Message alloc] init];
    instance.body = body;
    instance.sender = sender;
    instance.chatID = chatID;
    instance.timestamp = timestamp;
    return instance;
}

+(Message *)createForOneToOne:(NSString *)body sender:(NSString *)sender chatID:(NSString *)chatID messageTo:(NSString *)messageTo {
    Message *instance = [[Message alloc] init];
    instance.body = body;
    instance.sender = sender;
    instance.chatID = chatID;
    instance.messageTo = messageTo;
    return instance;
}

+(Message *)createForOneToOne:(NSString *)body sender:(NSString *)sender chatID:(NSString *)chatID messageTo:(NSString *)messageTo timestamp:(NSString *)timestamp {
    Message *instance = [[Message alloc] init];
    instance.body = body;
    instance.sender = sender;
    instance.chatID = chatID;
    instance.messageTo = messageTo;
    instance.timestamp = timestamp;
    return instance;
}

@end
